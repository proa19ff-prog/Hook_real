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

Сборка Hook уже содержит адрес рабочего резолвера по умолчанию — источник
активен сразу после установки. `Настройки → Резолвер-сервер`:

- введите базовый URL своего сервера (например `https://hook.example.com`) →
  «Сохранить» — приложение будет ходить только на него;
- «Отключить» — источник выключается полностью;
- пустое хранилище (значение по умолчанию) — работает встроенный адрес.

Адрес по умолчанию задаётся константой `defaultEndpoint` в
`lib/features/extractor/sources/remote_resolver_source.dart`.

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

## Пул эндпоинтов

Приложение держит список адресов (`RemoteResolverSource.defaultEndpoints`):
воркеры Cloudflare вперёд, прямой адрес сервера — последним. Автоматически:

- HTTP 429 (квота воркера исчерпана) — адрес замораживается до следующего
  UTC-полуноча, запросы уходят на следующий;
- любая сетевая ошибка (в т.ч. блокировка маршрута) — то же самое;
- ответивший адрес становится «липким» — весь остальной трафик идёт через
  него, пока не откажет.

Лимит Cloudflare Workers Free — 100 000 запросов в день **на аккаунт**, а
не на воркер: реальный пул = по одному воркеру на отдельный аккаунт
(разные e-mail), один и тот же код воркера. Добавление воркера в пул —
одна строка в `defaultEndpoints` плюс релиз.

## Опционально: возрастные ограничения (18+)

YouTube отдаёт age-restricted видео только по аккаунту. Сервер это умеет,
если на нём настроено:

1. `cookies.txt` (Netscape, экспорт из браузера с залогиненным YouTube) —
   путь задать переменной `HOOK_YT_COOKIES=/path/cookies.txt` в окружении
   сервиса; права 600.
2. JS-рантайм **Deno** в PATH (`/usr/local/bin/deno`) — yt-dlp решает через
   него n-challenge (флаг `--remote-components ejs:github` проставляется
   кодом сервера автоматически).

Без этих двух шагов всё остальное работает как есть: 18+ треки просто
останутся на совести других источников (SoundCloud и т.п.).

```
GET {base}/playlist?url=<ссылка на плейлист>
200 → { "title": "...", "tracks": [ {"id","title","artist","duration","artwork"} ] }
502 → чтение не удалось (таймаут/недоступен); 400 → url вне белого списка
```

- Необязательный эндпоинт для импорта плейлистов: YouTube / YouTube Music
  читаются одним flat-извлечением yt-dlp (`--playlist-end 300`), Deezer —
  публичным API api.deezer.com (yt-dlp сам Deezer не умеет: DRM-guard);
- только https и публичные плейлисты: youtube.com, music.youtube.com,
  youtu.be, deezer.com, link.deezer.com;
- ответ кэшируется 15 минут; приватные плейлисты («Мне нравится» в YT
  Music) прочесть нельзя — только публичные.

```
GET {base}/download?url=<страница трека>
200 → аудиофайл целиком (yt-dlp bestaudio), Content-Length присутствует
502 → упаковка не удалась; 503 → сервер занят; 400 → url вне белого списка
```

- Необязательный эндпоинт для кнопки «Скачать»: сервер скачивает трек сам
  (yt-dlp + ffmpeg) и отдаёт одним файлом — выручает, когда сеть устройства
  не может ни получить поток напрямую (HTTP 403 от CDN), ни сохранить его
  (SoundCloud HLS-аплоады — плейлист стримится, но файлом не сохраняется);
- `url` — только https-страницы треков: soundcloud.com, youtube.com,
  youtu.be, music.youtube.com (защита от SSRF через маршрут);
- приложение использует его для SoundCloud-треков, чей permalink был отдан
  поиском в поле `streamUrl`;
- YouTube-треки, уже попавшие в дисковый кэш сервера, отдаются мгновенно,
  без запуска yt-dlp.
Плейлисты, избранное и история остаются на устройстве.

## Дисковый кэш популярных треков (на сервере)

Эталонная реализация хранит прослушанные треки как файлы в `cache/` рядом с
`resolver.py` и отдаёт их с диска, не обращаясь к YouTube:

- первое воспроизведение идёт через googlevideo как обычно, но параллельно
  файл целиком складывается в кэш;
- все следующие воспроизведения и перемотки — с диска: старт мгновенный,
  куки и PO-токены не расходуются, VPN-блокировки не страшны;
- счётчик прослушиваний на каждый ID (одно прослушивание = один счёт в
  90-секундном окне, запросы Range не раздут счётчик) живёт в
  `cache/index.json` и переживает перезапуски;
- самые прослушиваемые треки сервер подогревает сам: раз в 30 минут
  проверяет топ-10 и докачивает отсутствующие файлы (не более 2 за проход);
- размер кэша ограничен (по умолчанию 8 ГБ, `HOOK_CACHE_GB`), вытеснение —
  LRU; треки длиннее 90 минут и файлы больше 300 МБ не кэшируются
  (`HOOK_CACHE_MAX_SECONDS`, `HOOK_CACHE_MAX_FILE_MB`);
- `/resolve` в дополнение отвечает полем `cached: true|false`.

## Куки: контроль здоровья и замена без SSH

Слетевшие куки — главная причина «сервер перестал отдавать 403/пустой
поиск». Эталонная реализация решает это тремя механизмами:

1. **Проверка здоровья перед каждым использованием.** Джар читается и
   валидируется (Netscape-формат, есть youtube-cookie, не истекли) с кэшем
   на 90 секунд. Битый файл не ломает сервер — запросы просто идут
   анонимно, а в лог падает `[cookies] state: ok=False (...)`.
2. **Щуп каждые 6 часов** — лёгкое simulate-извлечение тестового видео
   через реальные куки. Итог — в `/cookies/status` (`last_probe.state`:
   `ok` / `bot-check` / `stale` / `fail` / `unhealthy`).
3. **Замена без SSH:**
   ```
   POST {base}/<prefix>/cookies/upload
   body: содержимое cookies.txt (Netscape, ≤256 КиБ)
   200 → { "ok": true, "cookies": 11 }   # 11 живых youtube-cookie
   400 → {"error": "..."}                 # формат/просрочено — старое не тронуто
   ```
   Файл подменяется атомарно, предыдущая версия сохраняется рядом как
   `cookies.txt.bak`. Проверить состояние:
   ```
   GET {base}/<prefix>/cookies/status
   → {"configured":true,"healthy":true,"cookies":14,
      "last_probe":{"at":"...","state":"ok"}}
   ```

Экспортируйте куки из браузера заново и отправляйте одной командой:
`curl -X POST --data-binary @cookies.txt "https://host/<prefix>/cookies/upload"`.


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
