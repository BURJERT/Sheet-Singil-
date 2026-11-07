// Service worker: lets the site open without internet after one online visit.
// Strategy: try the network first (so updates arrive), fall back to the saved copy when offline.
// Supabase API calls are never touched here; offline data is handled inside index.html.
const V = 'singil-v6';
const CORE = ['./', 'index.html', 'config.js', 'supabase.js', 'manifest.webmanifest', 'photo.jpg',
  'fonts/plus-jakarta-sans.woff2', 'singil/singin(1).png', 'singil/singil.ico',
  'singil/singil-180.png', 'singil/singil-192.png', 'singil/singil-512.png'];

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
  e.respondWith(
    fetch(r).then(res => {
      if (res.ok) { const copy = res.clone(); caches.open(V).then(c => c.put(r, copy)); }
      return res;
    }).catch(() => caches.match(r, { ignoreSearch: true })
      .then(m => m || (r.mode === 'navigate' ? caches.match('index.html') : undefined)))
  );
});
