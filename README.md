# Sheet, Singil!

Static site (HTML/CSS/JS) + Supabase. No build step.

## 1. Supabase
1. Create a project at supabase.com.
2. SQL Editor > run `schema.sql`.
3. Project Settings > API: copy the Project URL and the anon public key into `config.js`.
4. Authentication > Providers > Email: for quick setup turn off "Confirm email" (or keep it on and confirm via the email link).

## 2. Run locally
Serve the folder (e.g. `npx serve .`) and open it. Opening index.html directly also works.

## 3. Deploy to Vercel
- Push the folder to GitHub, then Vercel > Add New > Project > import it. Framework preset: Other. No build command, no output directory.
- Or run `npx vercel` inside the folder.
- After deploying, in Supabase go to Authentication > URL Configuration and set Site URL to your Vercel URL.
