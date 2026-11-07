-- Sheet, Singil! upgrade. Run in Supabase: SQL Editor > New query > Run. Safe to run again.
-- Adds: archived students, roles (admin / officer / pending), automatic account approval list,
--       and one attendance record per date.

-- 1) Archived students
alter table students add column if not exists inactive boolean not null default false;

-- 2) Roles. New sign-ups are created automatically as 'pending' until the admin approves them in the app.
create table if not exists roles (
  user_id uuid primary key references auth.users on delete cascade,
  role text not null
);
alter table roles add column if not exists email text;
alter table roles drop constraint if exists roles_role_check;
update roles set role = 'officer' where role in ('attendance','treasurer');
alter table roles add constraint roles_role_check check (role in ('admin','officer','pending'));
alter table roles enable row level security;

create or replace function public.my_role() returns text
language sql stable security definer set search_path = public
as $$ select role from public.roles where user_id = auth.uid() $$;

-- Every new account gets a 'pending' row automatically.
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public
as $$ begin
  insert into public.roles (user_id, role, email) values (new.id, 'pending', new.email)
  on conflict (user_id) do nothing;
  return new;
end $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- Existing accounts: add missing rows and emails.
insert into roles (user_id, role, email) select id, 'pending', email from auth.users
  on conflict (user_id) do nothing;
update roles r set email = u.email from auth.users u where r.user_id = u.id and r.email is distinct from u.email;

drop policy if exists "read own role" on roles;
drop policy if exists "admin manage roles" on roles;
create policy "read own role" on roles for select to authenticated using (user_id = auth.uid());
create policy "admin manage roles" on roles for all to authenticated
  using (my_role() = 'admin') with check (my_role() = 'admin');

-- 3) Role-based rules for the data tables
do $$ declare t text; begin
  foreach t in array array['students','attendance','contributions','payments'] loop
    execute format('drop policy if exists "own rows" on %I', t);
    execute format('drop policy if exists "role read" on %I', t);
    execute format('drop policy if exists "role access" on %I', t);
  end loop;
end $$;
create policy "role read" on students for select to authenticated using (my_role() in ('admin','officer'));
create policy "role access" on students for all to authenticated
  using (my_role() = 'admin') with check (my_role() = 'admin');
create policy "role access" on attendance for all to authenticated
  using (my_role() in ('admin','officer')) with check (my_role() in ('admin','officer'));
create policy "role access" on contributions for all to authenticated
  using (my_role() in ('admin','officer')) with check (my_role() in ('admin','officer'));
create policy "role access" on payments for all to authenticated
  using (my_role() in ('admin','officer')) with check (my_role() in ('admin','officer'));

-- 4) One attendance record per date (shared by all officers).
-- If two records ever exist for the same date, the newest one is kept.
alter table attendance drop constraint if exists attendance_user_id_date_key;
delete from attendance a using attendance b
  where a.date = b.date and (coalesce(a.saved_at,'epoch'), a.id::text) < (coalesce(b.saved_at,'epoch'), b.id::text);
alter table attendance drop constraint if exists attendance_date_key;
alter table attendance add constraint attendance_date_key unique (date);

-- 5) MAKE YOURSELF ADMIN: replace the email with the one you sign in with, then run.
insert into roles (user_id, role, email)
select id, 'admin', email from auth.users where email = 'YOUR_EMAIL_HERE'
on conflict (user_id) do update set role = 'admin';
