# Vercel Deployment Guide (BaoBab HR)

## 1) Prerequisites
- Vercel account and connected Git repo
- Supabase project with DB + Edge Functions deployed
- Flutter web build support in CI

## 2) Exactly where to connect your keys

### Vercel (Frontend runtime)
Open: **Vercel Dashboard → Project → Settings → Environment Variables**

Add these variables for **Production / Preview / Development**:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `PAYSTACK_PUBLIC_KEY`

These are consumed by Flutter via `AppConstants` (`String.fromEnvironment`).

### Supabase Edge Functions (Backend secure secrets)
Open: **Supabase Dashboard → Project Settings → Edge Functions → Secrets**

Add:
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `PAYSTACK_SECRET_KEY`

> Keep `PAYSTACK_SECRET_KEY` only in Supabase secrets (never in Flutter frontend).

## 3) Build Settings (Vercel)
- Install command: `flutter pub get`
- Build command: `flutter build web --release --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY --dart-define=PAYSTACK_PUBLIC_KEY=$PAYSTACK_PUBLIC_KEY`
- Output directory: `build/web`

## 4) SPA Routing
`vercel.json` must include rewrite to `index.html` (already present in repo):

```json
{
  "routes": [
    { "src": "/(.*)", "dest": "/index.html" }
  ]
}
```

## 5) Post-deploy Checklist
- Login and role redirects work (`super_admin`, `hr`, `employee`)
- HR dashboard loads live attendance/leave data
- Employee dashboard can Log In / Log Out attendance
- Billing route initializes checkout and verifies Paystack callback
- Supabase edge functions are reachable from app
