# Sheet, Singil!

Static site (HTML/CSS/JS) + Supabase. No build step. Works offline after one online visit.

## Files
- index.html – the whole app (screens, offline storage, sync, sign in/up/reset)
- config.js – Supabase URL + key, About page texts
- sw.js – service worker (makes the site open offline)
- manifest.webmanifest – lets phones "Add to Home Screen" as an app
- supabase.js – Supabase library (kept locally so it works offline)
- fonts/ – the site font, kept locally
- favicon/ – tab icons. See favicon/README.txt to replace them
- schema.sql – first-time database setup (run once)
- upgrade.sql – roles, archived students, account approval (run once, safe to re-run)

## Setup
1. Supabase: SQL Editor > run `schema.sql`, then `upgrade.sql` (replace YOUR_EMAIL_HERE first).
2. Put your Project URL and publishable key in `config.js`.
3. Authentication > URL Configuration: set Site URL to your Vercel address and add it under Redirect URLs
   (needed for the confirmation and password reset emails).
4. Deploy to Vercel: framework preset "Other", no build command.

## Accounts
Anyone can create an account on the sign-in page. New accounts wait as "pending" until the admin
approves them in the app (Home > Accounts). Roles: admin (everything) and officer (attendance + treasurer).

## Offline
Changes are saved on the device first and synced to Supabase when the internet returns.
Sign in, create account and password reset need internet. Everything else works offline.
