# Sheet, Singil!

Static site (HTML/CSS/JS) + Supabase. No build step. Works offline after one online visit.

## Files
- index.html – the whole app (screens, offline storage, sync, sign in/up/reset)
- config.js – Supabase URL + key, About page texts
- sw.js – service worker (makes the site open offline)
- manifest.webmanifest – lets phones "Add to Home Screen" as an app
- supabase.js – Supabase library (kept locally so it works offline)
- fonts/ – the site font, kept locally
- singillogo/ – tab and app icons. See singillogo/README.txt to replace them
- schema.sql – first-time database setup (run once)
- upgrade.sql – archived students and private-section rules (run once, safe to re-run)

## Setup
1. Supabase: SQL Editor > run `schema.sql` (first time only), then `upgrade.sql`.
2. Put your Project URL and publishable key in `config.js`.
3. Authentication > URL Configuration: set Site URL to your Vercel address and add it under Redirect URLs
   (needed for the confirmation and password reset emails).
4. Deploy to Vercel: framework preset "Other", no build command.

## Accounts and sections
Anyone can create their own account on the sign-in page and choose a section name (for example BSIT 2-A).
Each account is its own private section: its students, attendance and payments are visible only to that account.
The section name shows on Home and on printouts, and can be edited from Home > Account.

## Offline
Changes are saved on the device first and synced to Supabase when the internet returns.
Sign in, create account and password reset need internet. Everything else works offline.
