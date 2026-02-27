-- BaoBab HR — PHASE 1 Supabase Backend Foundation
-- Multi-tenant HR SaaS schema, constraints, RLS, triggers, and seed data.
-- This script is written for PostgreSQL/Supabase.

create extension if not exists pgcrypto;

-- =============================
-- 1) Types
-- =============================
do $$
begin
  if not exists (select 1 from pg_type where typname = 'app_role') then
    create type app_role as enum ('super_admin', 'hr_admin', 'employee');
  end if;

  if not exists (select 1 from pg_type where typname = 'subscription_status') then
    create type subscription_status as enum ('trial', 'active', 'past_due', 'expired', 'cancelled');
  end if;

  if not exists (select 1 from pg_type where typname = 'leave_status') then
    create type leave_status as enum ('pending', 'approved', 'rejected', 'cancelled');
  end if;

  if not exists (select 1 from pg_type where typname = 'leave_type') then
    create type leave_type as enum ('annual', 'maternity', 'paternity', 'sick', 'compassionate', 'other');
  end if;
end $$;

-- =============================
-- 2) Core tables
-- =============================

-- companies: tenant root. company_id included (generated from id) to satisfy all-table company_id rule.
create table if not exists public.companies (
  id uuid primary key default gen_random_uuid(),
  company_id uuid generated always as (id) stored unique,
  name text not null,
  slug text not null unique,
  email text,
  phone text,
  address text,
  trial_start_at timestamptz not null default now(),
  trial_end_at timestamptz not null default (now() + interval '14 days'),
  subscription_status subscription_status not null default 'trial',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- users: app-level users mapped to auth.users
create table if not exists public.users (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  auth_user_id uuid not null unique references auth.users(id) on delete cascade,
  role app_role not null,
  full_name text not null,
  email text not null,
  avatar_url text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(company_id, email)
);

-- employees: HR profile for employee data
create table if not exists public.employees (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  user_id uuid references public.users(id) on delete set null,
  employee_code text,
  full_name text not null,
  work_email text,
  personal_email text,
  department text,
  job_title text,
  manager_employee_id uuid references public.employees(id) on delete set null,
  hire_date date,
  employment_status text not null default 'active',
  profile_photo_url text,
  offer_letter_url text,
  leave_balance_annual numeric(8,2) not null default 0,
  leave_balance_sick numeric(8,2) not null default 0,
  leave_balance_maternity numeric(8,2) not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- attendance: daily attendance logs
create table if not exists public.attendance (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  employee_id uuid not null references public.employees(id) on delete cascade,
  attendance_date date not null,
  check_in_at timestamptz,
  check_out_at timestamptz,
  hours_worked numeric(6,2) generated always as (
    case
      when check_in_at is not null and check_out_at is not null then
        extract(epoch from (check_out_at - check_in_at)) / 3600.0
      else null
    end
  ) stored,
  status text not null default 'present',
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(company_id, employee_id, attendance_date)
);

-- payroll: payroll records per period
create table if not exists public.payroll (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  employee_id uuid not null references public.employees(id) on delete cascade,
  period_start date not null,
  period_end date not null,
  basic_salary numeric(12,2) not null default 0,
  allowances numeric(12,2) not null default 0,
  deductions numeric(12,2) not null default 0,
  taxes numeric(12,2) not null default 0,
  net_pay numeric(12,2) generated always as (basic_salary + allowances - deductions - taxes) stored,
  currency text not null default 'USD',
  paid_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(company_id, employee_id, period_start, period_end)
);

-- leaves: leave requests and approvals
create table if not exists public.leaves (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  employee_id uuid not null references public.employees(id) on delete cascade,
  leave_type leave_type not null,
  start_date date not null,
  end_date date not null,
  total_days numeric(8,2) generated always as ((end_date - start_date + 1)) stored,
  reason text,
  status leave_status not null default 'pending',
  approved_by_user_id uuid references public.users(id) on delete set null,
  approved_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (end_date >= start_date)
);

-- subscriptions: company billing state
create table if not exists public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  plan_name text not null,
  status subscription_status not null default 'trial',
  trial_start_at timestamptz,
  trial_end_at timestamptz,
  starts_at timestamptz,
  ends_at timestamptz,
  cancelled_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- payments: payment events
create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  subscription_id uuid references public.subscriptions(id) on delete set null,
  amount numeric(12,2) not null,
  currency text not null default 'NGN',
  payment_provider text not null default 'paystack',
  paystack_reference text,
  paystack_transaction_id text,
  status text not null default 'pending',
  paid_at timestamptz,
  raw_payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- paystack reference storage table (explicit requirement)
create table if not exists public.paystack_payment_references (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  payment_id uuid references public.payments(id) on delete set null,
  subscription_id uuid references public.subscriptions(id) on delete set null,
  reference text not null unique,
  access_code text,
  authorization_url text,
  status text not null default 'initialized',
  amount numeric(12,2),
  currency text,
  provider_response jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- audit logs: immutable-ish record of activity
create table if not exists public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references public.companies(id) on delete set null,
  actor_user_id uuid references public.users(id) on delete set null,
  table_name text not null,
  record_id text,
  action text not null, -- INSERT / UPDATE / DELETE / LOGIN / etc
  old_data jsonb,
  new_data jsonb,
  ip_address inet,
  user_agent text,
  created_at timestamptz not null default now()
);

-- =============================
-- 3) Indexes
-- =============================
create index if not exists idx_users_company_role on public.users(company_id, role);
create index if not exists idx_users_auth_user on public.users(auth_user_id);
create index if not exists idx_employees_company_user on public.employees(company_id, user_id);
create index if not exists idx_employees_company_work_email on public.employees(company_id, work_email);
create index if not exists idx_attendance_company_employee_date on public.attendance(company_id, employee_id, attendance_date desc);
create index if not exists idx_payroll_company_employee_period on public.payroll(company_id, employee_id, period_start desc);
create index if not exists idx_leaves_company_employee_status on public.leaves(company_id, employee_id, status);
create index if not exists idx_subscriptions_company_status on public.subscriptions(company_id, status);
create index if not exists idx_payments_company_status on public.payments(company_id, status);
create index if not exists idx_paystack_refs_company_status on public.paystack_payment_references(company_id, status);
create index if not exists idx_audit_logs_company_created on public.audit_logs(company_id, created_at desc);

-- =============================
-- 4) Helper functions
-- =============================

create or replace function public.current_app_user()
returns public.users
language sql
stable
security definer
set search_path = public
as $$
  select u.*
  from public.users u
  where u.auth_user_id = auth.uid()
  limit 1;
$$;

create or replace function public.current_role()
returns app_role
language sql
stable
security definer
set search_path = public
as $$
  select coalesce((select role from public.current_app_user()), 'employee'::app_role);
$$;

create or replace function public.current_company_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select (select company_id from public.current_app_user());
$$;

create or replace function public.is_super_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.current_role() = 'super_admin'::app_role;
$$;

create or replace function public.current_employee_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select e.id
  from public.employees e
  where e.user_id = (select id from public.current_app_user())
  limit 1;
$$;

-- Trial period logic
create or replace function public.is_company_in_trial(p_company_id uuid)
returns boolean
language sql
stable
set search_path = public
as $$
  select exists (
    select 1
    from public.companies c
    where c.id = p_company_id
      and now() between c.trial_start_at and c.trial_end_at
  );
$$;

-- Subscription expiry check logic
create or replace function public.is_company_subscription_active(p_company_id uuid)
returns boolean
language sql
stable
set search_path = public
as $$
  select exists (
    select 1
    from public.subscriptions s
    where s.company_id = p_company_id
      and s.status in ('active', 'trial')
      and (
        (s.status = 'trial' and (s.trial_end_at is null or s.trial_end_at >= now()))
        or
        (s.status = 'active' and (s.ends_at is null or s.ends_at >= now()))
      )
  );
$$;

create or replace function public.refresh_company_subscription_status(p_company_id uuid)
returns void
language plpgsql
set search_path = public
as $$
begin
  update public.companies c
  set subscription_status = case
      when public.is_company_in_trial(c.id) then 'trial'::subscription_status
      when public.is_company_subscription_active(c.id) then 'active'::subscription_status
      else 'expired'::subscription_status
    end,
    updated_at = now()
  where c.id = p_company_id;
end;
$$;

-- =============================
-- 5) Triggers
-- =============================

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function public.write_audit_log()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_company_id uuid;
  v_actor_user_id uuid;
begin
  v_actor_user_id := (select id from public.current_app_user());

  if tg_op = 'DELETE' then
    v_company_id := old.company_id;
    insert into public.audit_logs(company_id, actor_user_id, table_name, record_id, action, old_data, new_data)
    values (v_company_id, v_actor_user_id, tg_table_name, old.id::text, tg_op, to_jsonb(old), null);
    return old;
  else
    v_company_id := new.company_id;
    insert into public.audit_logs(company_id, actor_user_id, table_name, record_id, action, old_data, new_data)
    values (
      v_company_id,
      v_actor_user_id,
      tg_table_name,
      coalesce(new.id::text, old.id::text),
      tg_op,
      case when tg_op = 'UPDATE' then to_jsonb(old) else null end,
      to_jsonb(new)
    );
    return new;
  end if;
end;
$$;

-- updated_at triggers
create trigger trg_companies_updated_at before update on public.companies for each row execute function public.set_updated_at();
create trigger trg_users_updated_at before update on public.users for each row execute function public.set_updated_at();
create trigger trg_employees_updated_at before update on public.employees for each row execute function public.set_updated_at();
create trigger trg_attendance_updated_at before update on public.attendance for each row execute function public.set_updated_at();
create trigger trg_payroll_updated_at before update on public.payroll for each row execute function public.set_updated_at();
create trigger trg_leaves_updated_at before update on public.leaves for each row execute function public.set_updated_at();
create trigger trg_subscriptions_updated_at before update on public.subscriptions for each row execute function public.set_updated_at();
create trigger trg_payments_updated_at before update on public.payments for each row execute function public.set_updated_at();
create trigger trg_paystack_refs_updated_at before update on public.paystack_payment_references for each row execute function public.set_updated_at();

-- audit triggers
create trigger trg_audit_users after insert or update or delete on public.users for each row execute function public.write_audit_log();
create trigger trg_audit_employees after insert or update or delete on public.employees for each row execute function public.write_audit_log();
create trigger trg_audit_attendance after insert or update or delete on public.attendance for each row execute function public.write_audit_log();
create trigger trg_audit_payroll after insert or update or delete on public.payroll for each row execute function public.write_audit_log();
create trigger trg_audit_leaves after insert or update or delete on public.leaves for each row execute function public.write_audit_log();
create trigger trg_audit_subscriptions after insert or update or delete on public.subscriptions for each row execute function public.write_audit_log();
create trigger trg_audit_payments after insert or update or delete on public.payments for each row execute function public.write_audit_log();

-- =============================
-- 6) RLS policies
-- =============================

alter table public.companies enable row level security;
alter table public.users enable row level security;
alter table public.employees enable row level security;
alter table public.attendance enable row level security;
alter table public.payroll enable row level security;
alter table public.leaves enable row level security;
alter table public.subscriptions enable row level security;
alter table public.payments enable row level security;
alter table public.paystack_payment_references enable row level security;
alter table public.audit_logs enable row level security;

-- companies: super admin all; company members see own company
create policy companies_select_policy on public.companies
for select
using (
  public.is_super_admin()
  or id = public.current_company_id()
);

create policy companies_update_policy on public.companies
for update
using (public.is_super_admin() or id = public.current_company_id())
with check (public.is_super_admin() or id = public.current_company_id());

-- users: super admin all, HR manage users in company, employee can read/update self
create policy users_select_policy on public.users
for select
using (
  public.is_super_admin()
  or company_id = public.current_company_id()
);

create policy users_insert_policy on public.users
for insert
with check (
  public.is_super_admin()
  or (public.current_role() = 'hr_admin' and company_id = public.current_company_id())
);

create policy users_update_policy on public.users
for update
using (
  public.is_super_admin()
  or (public.current_role() = 'hr_admin' and company_id = public.current_company_id())
  or auth_user_id = auth.uid()
)
with check (
  public.is_super_admin()
  or company_id = public.current_company_id()
);

-- employees: super admin all, HR manage in company, employee read/update own record
create policy employees_select_policy on public.employees
for select
using (
  public.is_super_admin()
  or (public.current_role() = 'hr_admin' and company_id = public.current_company_id())
  or user_id = (select id from public.current_app_user())
);

create policy employees_insert_policy on public.employees
for insert
with check (
  public.is_super_admin()
  or (public.current_role() = 'hr_admin' and company_id = public.current_company_id())
);

create policy employees_update_policy on public.employees
for update
using (
  public.is_super_admin()
  or (public.current_role() = 'hr_admin' and company_id = public.current_company_id())
  or user_id = (select id from public.current_app_user())
)
with check (
  public.is_super_admin()
  or company_id = public.current_company_id()
);

-- attendance: super admin all, HR full in company, employee only own
create policy attendance_select_policy on public.attendance
for select
using (
  public.is_super_admin()
  or (public.current_role() = 'hr_admin' and company_id = public.current_company_id())
  or employee_id = public.current_employee_id()
);

create policy attendance_write_policy on public.attendance
for all
using (
  public.is_super_admin()
  or (public.current_role() = 'hr_admin' and company_id = public.current_company_id())
)
with check (
  public.is_super_admin()
  or (public.current_role() = 'hr_admin' and company_id = public.current_company_id())
);

-- payroll: super admin all, HR full in company, employee only own select
create policy payroll_select_policy on public.payroll
for select
using (
  public.is_super_admin()
  or (public.current_role() = 'hr_admin' and company_id = public.current_company_id())
  or employee_id = public.current_employee_id()
);

create policy payroll_write_policy on public.payroll
for all
using (
  public.is_super_admin()
  or (public.current_role() = 'hr_admin' and company_id = public.current_company_id())
)
with check (
  public.is_super_admin()
  or (public.current_role() = 'hr_admin' and company_id = public.current_company_id())
);

-- leaves: super admin all, HR full in company, employee manages own requests
create policy leaves_select_policy on public.leaves
for select
using (
  public.is_super_admin()
  or (public.current_role() = 'hr_admin' and company_id = public.current_company_id())
  or employee_id = public.current_employee_id()
);

create policy leaves_insert_policy on public.leaves
for insert
with check (
  public.is_super_admin()
  or (public.current_role() = 'hr_admin' and company_id = public.current_company_id())
  or (company_id = public.current_company_id() and employee_id = public.current_employee_id())
);

create policy leaves_update_policy on public.leaves
for update
using (
  public.is_super_admin()
  or (public.current_role() = 'hr_admin' and company_id = public.current_company_id())
  or (employee_id = public.current_employee_id() and status in ('pending','cancelled'))
)
with check (
  public.is_super_admin()
  or company_id = public.current_company_id()
);

-- subscriptions/payments/paystack refs: super admin all, HR company-scoped read/write
create policy subscriptions_policy on public.subscriptions
for all
using (
  public.is_super_admin()
  or company_id = public.current_company_id()
)
with check (
  public.is_super_admin()
  or company_id = public.current_company_id()
);

create policy payments_policy on public.payments
for all
using (
  public.is_super_admin()
  or company_id = public.current_company_id()
)
with check (
  public.is_super_admin()
  or company_id = public.current_company_id()
);

create policy paystack_refs_policy on public.paystack_payment_references
for all
using (
  public.is_super_admin()
  or company_id = public.current_company_id()
)
with check (
  public.is_super_admin()
  or company_id = public.current_company_id()
);

-- audit logs: super admin all, HR read within company
create policy audit_logs_select_policy on public.audit_logs
for select
using (
  public.is_super_admin()
  or company_id = public.current_company_id()
);

-- =============================
-- 7) Seed Data (sample)
-- =============================
-- NOTE: Replace auth_user_id values with real auth.users IDs in your environment.

insert into public.companies (id, name, slug, email, phone, address, trial_start_at, trial_end_at)
values
  ('11111111-1111-1111-1111-111111111111', 'BaoBab Demo HQ', 'baobab-demo', 'hello@baobab.demo', '+234700000001', 'Lagos, Nigeria', now() - interval '2 days', now() + interval '12 days'),
  ('22222222-2222-2222-2222-222222222222', 'Acme Foods Ltd', 'acme-foods', 'hr@acmefoods.com', '+234700000002', 'Abuja, Nigeria', now() - interval '20 days', now() - interval '6 days')
on conflict (id) do nothing;

insert into public.subscriptions (id, company_id, plan_name, status, trial_start_at, trial_end_at, starts_at, ends_at)
values
  ('33333333-3333-3333-3333-333333333331', '11111111-1111-1111-1111-111111111111', 'Growth', 'trial', now() - interval '2 days', now() + interval '12 days', null, null),
  ('33333333-3333-3333-3333-333333333332', '22222222-2222-2222-2222-222222222222', 'Starter', 'active', null, null, now() - interval '30 days', now() + interval '335 days')
on conflict (id) do nothing;

insert into public.users (id, company_id, auth_user_id, role, full_name, email)
values
  ('44444444-4444-4444-4444-444444444441', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'super_admin', 'System Super Admin', 'superadmin@baobab.hr'),
  ('44444444-4444-4444-4444-444444444442', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'hr_admin', 'Amina Yusuf', 'amina@baobab.demo'),
  ('44444444-4444-4444-4444-444444444443', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'employee', 'Kofi Mensah', 'kofi@baobab.demo')
on conflict (auth_user_id) do nothing;

insert into public.employees (id, company_id, user_id, employee_code, full_name, work_email, department, job_title, hire_date, leave_balance_annual, leave_balance_sick)
values
  ('55555555-5555-5555-5555-555555555551', '11111111-1111-1111-1111-111111111111', '44444444-4444-4444-4444-444444444442', 'BB-0001', 'Amina Yusuf', 'amina@baobab.demo', 'People Ops', 'HR Manager', current_date - 420, 18, 8),
  ('55555555-5555-5555-5555-555555555552', '11111111-1111-1111-1111-111111111111', '44444444-4444-4444-4444-444444444443', 'BB-0002', 'Kofi Mensah', 'kofi@baobab.demo', 'Engineering', 'Software Engineer', current_date - 180, 12, 6)
on conflict (id) do nothing;

insert into public.attendance (company_id, employee_id, attendance_date, check_in_at, check_out_at, status)
values
  ('11111111-1111-1111-1111-111111111111', '55555555-5555-5555-5555-555555555551', current_date - 1, now() - interval '1 day' + interval '9 hours', now() - interval '1 day' + interval '17 hours', 'present'),
  ('11111111-1111-1111-1111-111111111111', '55555555-5555-5555-5555-555555555552', current_date - 1, now() - interval '1 day' + interval '9 hours 10 minutes', now() - interval '1 day' + interval '17 hours 5 minutes', 'present')
on conflict do nothing;

insert into public.payroll (company_id, employee_id, period_start, period_end, basic_salary, allowances, deductions, taxes, currency, paid_at)
values
  ('11111111-1111-1111-1111-111111111111', '55555555-5555-5555-5555-555555555551', date_trunc('month', current_date)::date, (date_trunc('month', current_date) + interval '1 month - 1 day')::date, 3500, 200, 150, 300, 'USD', now()),
  ('11111111-1111-1111-1111-111111111111', '55555555-5555-5555-5555-555555555552', date_trunc('month', current_date)::date, (date_trunc('month', current_date) + interval '1 month - 1 day')::date, 2500, 100, 80, 220, 'USD', now())
on conflict do nothing;

insert into public.leaves (company_id, employee_id, leave_type, start_date, end_date, reason, status, approved_by_user_id, approved_at)
values
  ('11111111-1111-1111-1111-111111111111', '55555555-5555-5555-5555-555555555552', 'annual', current_date + 7, current_date + 9, 'Family event', 'pending', null, null)
on conflict do nothing;

insert into public.payments (company_id, subscription_id, amount, currency, payment_provider, paystack_reference, status, paid_at)
values
  ('22222222-2222-2222-2222-222222222222', '33333333-3333-3333-3333-333333333332', 199.00, 'NGN', 'paystack', 'PSK_REF_001', 'success', now())
on conflict do nothing;

insert into public.paystack_payment_references (company_id, subscription_id, reference, access_code, authorization_url, status, amount, currency)
values
  ('22222222-2222-2222-2222-222222222222', '33333333-3333-3333-3333-333333333332', 'PSK_REF_001', 'ACCESS_CODE_001', 'https://paystack.com/pay/abc', 'success', 199.00, 'NGN')
on conflict (reference) do nothing;

-- apply computed subscription status for seeded tenants
select public.refresh_company_subscription_status('11111111-1111-1111-1111-111111111111');
select public.refresh_company_subscription_status('22222222-2222-2222-2222-222222222222');

-- =============================
-- Table Explanations (quick reference)
-- =============================
-- companies: Tenant master profile + trial/subscription snapshot.
-- users: Identity and role mapping from auth.users to app roles/scopes.
-- employees: HR records tied to users for workforce operations.
-- attendance: Daily in/out and computed working hours.
-- payroll: Pay runs and employee payout components.
-- leaves: Request/approval lifecycle for leave management.
-- subscriptions: Billing lifecycle and validity periods.
-- payments: Captured payment transactions.
-- paystack_payment_references: Dedicated Paystack reference tracking.
-- audit_logs: Change history for compliance and traceability.
