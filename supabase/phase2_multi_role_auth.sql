-- Multi-role login setup for Baobab HR.
-- Roles supported by app routing/screens: super_admin, hr, employee.

create table if not exists public.users (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid unique not null references auth.users(id) on delete cascade,
  email text not null unique,
  role text not null check (role in ('super_admin', 'hr', 'employee')),
  company_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.set_updated_at_timestamp()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_users_updated_at on public.users;
create trigger trg_users_updated_at
before update on public.users
for each row
execute function public.set_updated_at_timestamp();

-- Automatically create a profile row when a new auth user signs up.
create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  meta_role text;
begin
  meta_role := coalesce(new.raw_user_meta_data ->> 'role', 'employee');

  insert into public.users (auth_user_id, email, role)
  values (
    new.id,
    coalesce(new.email, ''),
    case
      when meta_role in ('super_admin', 'hr', 'employee') then meta_role
      else 'employee'
    end
  )
  on conflict (auth_user_id) do update
  set
    email = excluded.email,
    role = excluded.role,
    updated_at = now();

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_auth_user();

alter table public.users enable row level security;

-- Users can read/update only their own profile row.
drop policy if exists "users_select_own" on public.users;
create policy "users_select_own"
on public.users
for select
using (auth.uid() = auth_user_id);

drop policy if exists "users_update_own" on public.users;
create policy "users_update_own"
on public.users
for update
using (auth.uid() = auth_user_id)
with check (auth.uid() = auth_user_id);

-- Seed test accounts (run after creating auth users manually).
-- update public.users set role = 'super_admin' where email = 'superadmin@baobabhr.com';
-- update public.users set role = 'hr' where email = 'hr@baobabhr.com';
-- update public.users set role = 'employee' where email = 'employee@baobabhr.com';
