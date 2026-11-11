-- Sheet, Singil! upgrade. Run in Supabase: SQL Editor > New query > Run. Safe to run again.
-- Every account is its own private section. Adds archived students, removes the approval/roles system.

-- 1) Archived students
alter table students add column if not exists inactive boolean not null default false;

-- 2) Remove the old approval/roles system (no longer used)
drop trigger if exists on_auth_user_created on auth.users;
drop function if exists public.handle_new_user();

-- 3) Each account only sees its own data
do $$ declare t text; begin
  foreach t in array array['students','attendance','contributions','payments'] loop
    execute format('drop policy if exists "own rows" on %I', t);
    execute format('drop policy if exists "role read" on %I', t);
    execute format('drop policy if exists "role access" on %I', t);
    execute format('create policy "own rows" on %I for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid())', t);
  end loop;
end $$;
drop table if exists roles;
drop function if exists public.my_role();

-- 4) One attendance record per date, per account
alter table attendance drop constraint if exists attendance_date_key;
alter table attendance drop constraint if exists attendance_user_id_date_key;
delete from attendance a using attendance b
  where a.user_id = b.user_id and a.date = b.date
    and (coalesce(a.saved_at,'epoch'), a.id::text) < (coalesce(b.saved_at,'epoch'), b.id::text);
alter table attendance add constraint attendance_user_id_date_key unique (user_id, date);
