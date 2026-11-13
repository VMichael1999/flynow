// Compara las posiciones de texto del prototipo HTML con las de la app Flutter.
//
// 1. flutter test tool/layout_probe_test.dart      → build/probe/flutter.json
// 2. Servir el HTML y ese JSON desde el mismo origen (p. ej. `python3 -m http.server`)
//    y abrir el HTML a escala 1 (`--s: 1` en #stage, pantalla de 440 × 956).
// 3. Pegar este archivo en la consola y llamar: await cmp('home')   // o 'select', 'fare', ...
//    (para Pasajeros: await cmp('pax', 'passengers'))
//
// Devuelve, por texto, la diferencia vertical (dy) y horizontal (dx) en px entre Flutter y HTML.
window.cmp = async (id, flutterKey) => {
  document.querySelector('#jump [data-go=' + id + ']').click();
  await new Promise((r) => setTimeout(r, 500));
  const F = (await (await fetch('flutter.json?' + Date.now())).json())[flutterKey || id] || [];
  const sc = document.querySelector('#screen').getBoundingClientRect();
  const sec = document.querySelector('#s-' + id);
  const items = [];
  const w = document.createTreeWalker(sec, NodeFilter.SHOW_TEXT);
  let n;
  while ((n = w.nextNode())) {
    const t = n.textContent.replace(/\s+/g, ' ').trim();
    if (!t) continue;
    let el = n.parentElement, hidden = false;
    while (el && el !== sec.parentElement) {
      const cs = getComputedStyle(el);
      if (cs.display === 'none' || cs.visibility === 'hidden' || parseFloat(cs.opacity) === 0) { hidden = true; break; }
      el = el.parentElement;
    }
    if (hidden || n.parentElement.closest('.sb,.toast,.ovl')) continue;
    const rg = document.createRange();
    rg.selectNodeContents(n);
    const r = rg.getBoundingClientRect();
    if (r.width === 0) continue;
    items.push({ t, x: r.left - sc.left, y: r.top - sc.top, w: r.width, h: r.height });
  }
  const norm = (s) => s.replace(/\s+/g, ' ').trim();
  const used = new Set();
  const diffs = [];
  let matched = 0;
  for (const f of F) {
    const ft = norm(f.text);
    const cyF = f.y + f.h / 2;
    let best = null, bd = 1e9, bi = -1;
    items.forEach((it, i) => {
      if (used.has(i) || it.t !== ft) return;
      const d = Math.abs(it.y + it.h / 2 - cyF) + Math.abs(it.x - f.x) * 0.1;
      if (d < bd) { bd = d; best = it; bi = i; }
    });
    if (!best) { diffs.push({ t: ft, note: 'sin pareja en HTML' }); continue; }
    used.add(bi);
    matched++;
    const dy = cyF - (best.y + best.h / 2);
    const dx = f.x - best.x;
    if (Math.abs(dy) > 1 || Math.abs(dx) > 1.5) diffs.push({ t: ft.slice(0, 28), dy: +dy.toFixed(1), dx: +dx.toFixed(1) });
  }
  return JSON.stringify({ id, flutter: F.length, html: items.length, matched, diffs });
};
