// Service worker: lets the site open without internet after one online visit.
// Strategy: answer from the saved copy IMMEDIATELY, and refresh the copy in the background.
// (So a bad or slow connection never makes the page wait.) Supabase calls are never touched here.
const V = 'fund-sheet-v11';
const CORE = ['./', 'index.html', 'config.js', 'supabase.js', 'vendor/jspdf.umd.min.js', 'vendor/jspdf.plugin.autotable.min.js', 'manifest.webmanifest', 'photo.jpg',
  'fonts/plus-jakarta-sans.woff2', 'singillogo/singillogo-32.png', 'singillogo/singillogo.ico',
  'singillogo/singillogo-180.png', 'singillogo/singillogo-192.png', 'singillogo/singillogo-512.png'];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(V)
    .then(c => Promise.all(CORE.map(u => c.add(u).catch(() => {}))))
    .then(() => self.skipWaiting()));
});
self.addEventListener('activate', e => {
  e.waitUntil(caches.keys()
    .then(ks => Promise.all(ks.filter(k => k !== V).map(k => caches.delete(k))))
    .then(() => self.clients.claim()));
});
self.addEventListener('fetch', e => {
  const r = e.request, u = new URL(r.url);
  if (r.method !== 'GET' || u.origin !== location.origin) return;
  e.respondWith(caches.match(r, { ignoreSearch: true }).then(hit => {
    const net = fetch(r).then(res => {
      if (res.ok) { const copy = res.clone(); caches.open(V).then(c => c.put(r, copy)); }
      return res;
    }).catch(() => null);
    if (hit) { e.waitUntil(net); return hit; }
    return net.then(res => res || (r.mode === 'navigate' ? caches.match('index.html') : Response.error()));
  }));
});
