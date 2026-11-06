# Резолвер-сервер (опционально)

Hook работает полностью на устройстве и не требует сервера. Но внешние сервисы
(в первую очередь YouTube) всё активнее ограничивают «анонимные» клиенты без
PO-токена: часть популярных записей отдаёт HTTP 403 на CDN даже при корректном
User-Agent. Единственный надёжный обходной путь на сегодня — собственный
сервер-резолвер, который извлекает поток там, где это получается стабильнее,
и отдаёт приложению ссылку (или сам проксирует аудио).

Эта страница описывает контракт «приложение ↔ сервер» и эталонную реализацию.
Hook никак не связан с содержимым вашего сервера; вы разворачиваете его на
своей инфраструктуре и для своих нужд.

## Включение в приложении

`Настройки → Резолвер-сервер` → введите базовый URL (например
`https://hook.example.com`) → «Сохранить». Пустое поле = источник выключен.
Пока сервер не настроен, соответствующий источник неактивен и ни на что не
влияет.

## Контракт

Приложение обращается только к двум GET-эндпоинтам:

```
GET {base}/search?q=<запрос>&limit=<1..50>
200 → [ {"id": "...", "title": "...", "artist": "...",
         "album": "...", "duration": 158, "artwork": "https://..."} ]
```

- `id` — непустая строка на ваш выбор (yt-dlp video ID, UUID — что угодно);
- `duration` — секунды (int, можно 0, если неизвестно);
- любое поле кроме `id`, `title`, `artist` может отсутствовать;
- ошибки — любой статус ≠ 200 (приложение просто получит пустой результат).

```
GET {base}/resolve?id=<id из поиска>
200 → { "url": "https://...", "user_agent": "...", "ext": "m4a" }
```

- `url` — абсолютная ссылка на аудио. Может указывать на сам сервер
  (`{base}/stream?id=...`): из-за привязки googlevideo-ссылок к IP часто
  надёжнее проксировать байты через сервер, чем отдавать прямую ссылку;
- `user_agent` (необязательно) — заголовок, с которым приложение будет
  запрашивать `url`; для прокси-схемы не нужен;
- `ext` (необязательно) — расширение файла (`m4a`, `webm`) для скачивания.

Приложение ничего не отправляет на сервер, кроме поисковой строки и ID.
Плейлисты, избранное и история остаются на устройстве.

## Эталонная реализация (~100 строк, Flask + yt-dlp)

Сохраните как `resolver.py` на сервере (Python 3.10+):

```bash
pip install flask yt-dlp requests
python resolver.py   # слушает :8787; поставьте за nginx/HTTPS
```

```python
import re
from flask import Flask, Response, jsonify, request
import requests
import yt_dlp

app = Flask(__name__)
SEARCH_LIMIT = 25

def ydl(opts):
    return yt_dlp.YoutubeDL({"quiet": True, "no_warnings": True, **opts})

@app.get("/search")
def search():
    q = request.args.get("q", "").strip()
    limit = min(int(request.args.get("limit", 20) or 20), SEARCH_LIMIT)
    if not q:
        return jsonify([])
    try:
        info = ydl({"extract_flat": True}).extract_info(
            f"ytsearch{limit}:{q}", download=False)
    except Exception:
        return jsonify([])
    out = []
    for e in (info or {}).get("entries") or []:
        if not e or not e.get("id"):
            continue
        out.append({
            "id": e["id"],
            "title": e.get("title") or "",
            "artist": (e.get("uploader") or e.get("channel") or "").strip(),
            "duration": int(e.get("duration") or 0),
            "artwork": e.get("thumbnails", [{}])[-1].get("url", ""),
        })
    return jsonify(out)

def audio_info(video_id):
    return ydl({"noplaylist": True,
                "format": "bestaudio[ext=m4a]/bestaudio"}).extract_info(
                    video_id, download=False)

@app.get("/resolve")
def resolve():
    video_id = request.args.get("id", "").strip()
    try:
        info = audio_info(video_id)
    except Exception:
        return jsonify({"error": "unavailable"}), 502
    if not info or not info.get("url"):
        return jsonify({"error": "unavailable"}), 502
    # По умолчанию проксируем через сервер: прямые googlevideo-ссылки
    # привязаны к нашему IP и с телефона могут отдавать 403.
    base = request.host_url.rstrip("/")
    return jsonify({
        "url": f"{base}/stream?id={video_id}",
        "ext": info.get("ext") or "m4a",
        "direct": info["url"],
        "user_agent": (info.get("http_headers") or {}).get("User-Agent"),
    })

@app.get("/stream")
def stream():
    video_id = request.args.get("id", "").strip()
    try:
        info = audio_info(video_id)
    except Exception:
        return Response("unavailable", status=502)
    if not info or not info.get("url"):
        return Response("unavailable", status=502)
    upstream = info["url"]
    headers = {"User-Agent": (info.get("http_headers") or {}).get(
        "User-Agent", "Mozilla/5.0")}
    range_header = request.headers.get("Range")
    if range_header:
        headers["Range"] = range_header
    upstream_response = requests.get(upstream, headers=headers, stream=True,
                                     timeout=30)
    excluded = {"connection", "keep-alive", "transfer-encoding",
                "content-encoding"}
    response_headers = [(k, v) for k, v in upstream_response.headers.items()
                        if k.lower() not in excluded]
    return Response(upstream_response.iter_content(chunk_size=64 * 1024),
                    status=upstream_response.status_code,
                    headers=response_headers)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8787)
```

## Эксплуатация

- **HTTPS обязателен**: приложение на Android по умолчанию не ходит по
  открытому HTTP. Самый простой путь — nginx + Let's Encrypt перед `resolver.py`.
- yt-dlp быстро устаревает против изменений YouTube — обновляйте
  (`pip install -U yt-dlp`) автоматом (cron/systemd timer).
- `/stream` расходует трафик сервера (примерно битрейт трека на слушателя).
  Для ~160 kbps это ~70 МБ/час на устройство.
- Закройте сервер от посторонних (basic-auth в nginx, VPN, или свой токен в
  `resolve.py`) — открытый резолвер быстро найдут сканеры.
- Для генерации PO-токенов вместо «плоских» запросов посмотрите проект
  [bgutil-ytdlp-pot-provider](https://github.com/Brainicism/bgutil-ytdlp-pot-provider):
  он подключается к yt-dlp и заметно повышает долю записей, которые сервер
  может извлечь.
