// Original Hook mode-preview icons. Run outside the downloaded player:
// node tool/generate_lyrics_lottie.mjs <official-player-root> <app-animation-dir>
import fs from 'node:fs';
import path from 'node:path';

const [playerRoot, assetRoot] = process.argv.slice(2);
if (!playerRoot || !assetRoot) throw new Error('Pass the official player root and app animation directory');
const still = k => ({ a: 0, k });
const motion = points => ({ a: 1, k: points.map(([t, v]) => ({
  t, s: [v], i: { x: [0.51], y: [0.99] }, o: { x: [0], y: [0.65] },
})) });
function capsule(index, name, x, y, width, height, opacity) {
  return {
    ty: 4, ind: index, nm: name, sr: 1, ip: 0, op: 120, st: 0, bm: 0,
    ks: { a: still([0, 0, 0]), p: still([0, 0, 0]), s: still([100, 100, 100]),
      r: still(0), o: opacity },
    shapes: [
      { ty: 'rc', d: 1, p: still([x + width / 2, y]), s: still([width, height]), r: still(height / 2) },
      { ty: 'fl', c: { ...still([1, 1, 1, 1]), sid: 'ink' }, o: still(100), r: 1, bm: 0 },
    ],
  };
}
function scene(mode) {
  const layers = [];
  const widths = [27, 17, 32, 20];
  for (let row = 0; row < 3; row++) {
    let x = 16;
    for (let word = 0; word < widths.length; word++) {
      let opacity;
      let y = 26 + row * 22;
      let height = 6;
      if (mode === 'lines') {
        const values = [0, 40, 80, 120].map((frame, i) => [frame, i % 3 === row ? 100 : 22]);
        opacity = motion(values);
      } else if (mode === 'karaoke') {
        opacity = row !== 1 ? still(19) : motion([
          [0, 25], [8 + word * 13, 25], [20 + word * 13, 100], [88, 100], [120, 25],
        ]);
      } else {
        y = 22 + row * 26;
        height = row === 1 ? 10 : 4;
        opacity = row !== 1 ? still(16) : motion([[0, 70], [22, 100], [76, 100], [120, 70]]);
      }
      layers.push(capsule(layers.length + 1, `${mode} / line ${row + 1} / word ${word + 1}`,
        x, y, widths[word], height, opacity));
      x += widths[word] + 5;
    }
  }
  return {
    v: '5.12.2', fr: 60, ip: 0, op: 120, w: 144, h: 96,
    nm: `Hook / lyrics / ${mode}`, ddd: 0, assets: [],
    slots: { ink: { p: still([1, 1, 1, 1]) } }, layers,
  };
}
function safeWrite(file, content) {
  if (fs.existsSync(file)) {
    if (fs.readFileSync(file, 'utf8') === content) return;
    throw new Error(`Scene already exists and differs; inspect it before editing: ${file}`);
  }
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, content, { flag: 'wx' });
}
for (const [index, mode] of ['lines', 'karaoke', 'focus'].entries()) {
  const canonical = path.resolve(playerRoot, 'public', 'projects', 'hook-lyrics', `scene-${index + 1}`, 'lottie.json');
  if (!canonical.replaceAll('\\', '/').endsWith(`/public/projects/hook-lyrics/scene-${index + 1}/lottie.json`)) {
    throw new Error('Unexpected scene target');
  }
  const json = `${JSON.stringify(scene(mode), null, 2)}\n`;
  JSON.parse(json);
  safeWrite(canonical, json);
  safeWrite(path.join(path.dirname(canonical), 'controls.json'),
    `${JSON.stringify({ controls: [{ sid: 'ink', label: 'Цвет текста' }] }, null, 2)}\n`);
  safeWrite(path.resolve(assetRoot, `lyrics_${mode}.json`), json);
  console.log(canonical);
}
