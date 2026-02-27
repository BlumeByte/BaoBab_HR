# Environment Setup (Local + CI)

## Flutter app runtime vars
Use `--dart-define`:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `PAYSTACK_PUBLIC_KEY`

Example:

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY \
  --dart-define=PAYSTACK_PUBLIC_KEY=pk_test_xxx
```

## Supabase Edge Function secrets
Set in Supabase dashboard:
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `PAYSTACK_SECRET_KEY`

## Deploy edge functions
```bash
supabase functions deploy paystack-initialize
supabase functions deploy paystack-verify
supabase functions deploy paystack-webhook
supabase functions deploy send-email-notification
```

## Database migration
Run SQL script:
- `supabase/phase1_backend.sql`

Then verify key tables:
- `companies`, `users`, `employees`, `subscriptions`, `payments`, `audit_logs`, `paystack_payment_references`
