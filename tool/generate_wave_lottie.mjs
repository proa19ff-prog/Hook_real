// Original Hook wave mark. Run outside the downloaded player:
// node tool/generate_wave_lottie.mjs <official-player-root> <app-animation-dir>
import fs from 'node:fs';
import path from 'node:path';

const [playerRoot, assetRoot] = process.argv.slice(2);
if (!playerRoot || !assetRoot) {
  throw new Error('Pass the official player root and app animation directory');
}

const still = k => ({ a: 0, k });
const ease = (t, s, e) => ({
  t,
  s,
  e,
  i: { x: [0.51], y: [0.99] },
  o: { x: [0], y: [0.65] },
});
const linear = (t, s, e) => ({
  t,
  s,
  e,
  i: { x: [1], y: [1] },
  o: { x: [0], y: [0] },
});

function transform({ position = [0, 0, 0], scale = [100, 100, 100], rotation = 0, opacity = 100 } = {}) {
  return {
    a: still([0, 0, 0]), p: still(position), s: still(scale),
    r: typeof rotation === 'number' ? still(rotation) : rotation,
    o: typeof opacity === 'number' ? still(opacity) : opacity,
  };
}

function bar(index, x, height, phase) {
  const low = 42 + (index % 2) * 8;
  const high = 104 - (index % 3) * 7;
  const frames = [0, 22, 45, 67, 90];
  const values = frames.map(frame => {
    const shifted = (frame + phase) % 90;
    const wave = Math.sin((shifted / 90) * Math.PI * 2);
    return Math.round(low + (high - low) * (wave + 1) / 2);
  });
  return {
    ty: 4, ind: index, nm: `Wave bar ${index}`, sr: 1, ip: 0, op: 90, st: 0, bm: 0,
    ks: {
      ...transform({ position: [x, 60, 0] }),
      s: { a: 1, k: frames.map((frame, i) => ease(frame, [100, values[i], 100], [100, values[(i + 1) % values.length], 100])) },
    },
    shapes: [
      { ty: 'rc', d: 1, p: still([0, 0]), s: still([8, height]), r: still(4) },
      { ty: 'fl', c: { ...still([1, 1, 1, 1]), sid: 'ink' }, o: still(100), r: 1, bm: 0 },
    ],
  };
}

const ring = {
  ty: 4, ind: 1, nm: 'Orbit ring', sr: 1, ip: 0, op: 90, st: 0, bm: 0,
  ks: { ...transform({ position: [60, 60, 0] }), r: { a: 1, k: [linear(0, [0], [360]), { t: 90, s: [360] }] } },
  shapes: [
    { ty: 'el', d: 1, p: still([0, 0]), s: still([94, 94]) },
    { ty: 'st', c: { ...still([1, 1, 1, 1]), sid: 'ink' }, o: still(32), w: still(2), lc: 2, lj: 2, ml: 4, d: [
      { n: 'd', v: still(8) }, { n: 'g', v: still(7) }, { n: 'o', v: still(0) },
    ], bm: 0 },
  ],
};

const orbitDot = {
  ty: 4, ind: 2, nm: 'Orbit pulse', sr: 1, ip: 0, op: 90, st: 0, bm: 0,
  ks: {
    ...transform({ position: [60, 60, 0] }),
    r: { a: 1, k: [linear(0, [0], [360]), { t: 90, s: [360] }] },
  },
  shapes: [
    { ty: 'el', d: 1, p: still([0, -47]), s: still([10, 10]) },
    { ty: 'fl', c: { ...still([1, 1, 1, 1]), sid: 'ink' }, o: still(100), r: 1, bm: 0 },
  ],
};

const layers = [
  orbitDot,
  ...[
    [38, 36, 0], [49, 56, 13], [60, 70, 25], [71, 52, 38], [82, 34, 51],
  ].map(([x, height, phase], i) => bar(i + 3, x, height, phase)),
  ring,
];

const scene = {
  v: '5.12.2', fr: 60, ip: 0, op: 90, w: 120, h: 120,
  nm: 'Hook / live wave', ddd: 0, assets: [],
  slots: { ink: { p: still([1, 1, 1, 1]) } },
  layers,
};

const canonical = path.resolve(playerRoot, 'public', 'projects', 'hook-wave', 'scene-1', 'lottie.json');
if (!canonical.replaceAll('\\', '/').endsWith('/public/projects/hook-wave/scene-1/lottie.json')) {
  throw new Error('Unexpected scene target');
}
const json = `${JSON.stringify(scene, null, 2)}\n`;
JSON.parse(json);
fs.mkdirSync(path.dirname(canonical), { recursive: true });
fs.writeFileSync(canonical, json);
fs.writeFileSync(path.join(path.dirname(canonical), 'controls.json'), `${JSON.stringify({
  controls: [{ sid: 'ink', label: 'Wave color' }],
}, null, 2)}\n`);
fs.mkdirSync(assetRoot, { recursive: true });
fs.writeFileSync(path.resolve(assetRoot, 'wave_signal.json'), json);
console.log(canonical);
