# Checkmate Cafe Tracker: setup guide

Files: `index.html` (the app), `config.js` (your Supabase keys), `supabase.sql` (database), this guide.

## Part 1. Supabase (about 15 minutes)
1. supabase.com > New project. Name it `checkmate-tracker`, pick the region closest to you (Singapore), and save the database password.
2. SQL Editor > New query. Paste all of `supabase.sql`. Near the bottom, change `your-email@example.com` to your own email, then click Run. This creates the tables, the security rules, the activity log (it cannot be edited or deleted), live updates, and your Zoom/café settings.
3. Table Editor > `agents` > Insert row for each agent (email + name). Only these emails can sign in. To remove an agent, delete their row.
4. Project Settings > API: copy the Project URL and the anon (publishable) key into `config.js`.
5. Authentication > Emails > SMTP Settings: turn on custom SMTP using a free email service (for example Resend or Brevo; check their current limits). Supabase's built-in email sender is only for testing and is very limited, so sign-in emails to your team may not arrive without this.

## Part 2. Vercel
**Option A (recommended): GitHub.** Every change you push redeploys automatically.
```
cd checkmate-tracker
git init
git add .
git commit -m "Checkmate tracker"
git branch -M main
git remote add origin https://github.com/YOUR-NAME/checkmate-tracker.git
git push -u origin main
```
Then vercel.com > Add New > Project > import the repo. Framework Preset: **Other**. Leave Build Command and Output Directory empty. Click Deploy.

**Option B: CLI.** `npm i -g vercel`, then run `vercel` in the folder, then `vercel --prod`.

## Part 3. Connect the two
1. Copy your Vercel URL (like `https://checkmate-tracker.vercel.app`).
2. Supabase > Authentication > URL Configuration: set **Site URL** to that URL, and add it under **Redirect URLs** too.
3. Open the URL, type your email, click the link in the email. You are in. Send the URL to your agents (add their emails first).

## Good to know
- **Add your students:** use the Add student button, or Table Editor > `students` > Insert > Import CSV (columns: `client, name, kind, total, done, last_attended, start_date, agent, price, link`; kind is `gb`, `gi`, `oo` or `fc`).
- **Zoom link or café address changes:** Table Editor > `settings`.
- **Activity Log:** the fourth page. It is written by the database itself, so agents cannot skip it, edit it, or delete it.
- **Never** put the `service_role` key in these files.
- Vercel's free Hobby plan is for personal, non-commercial use. This same folder also works on Cloudflare Pages or Netlify if you need another free host.
