-- Sheet, Singil! database. Run once in Supabase: SQL Editor > New query > Run.
create table students (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  name text not null,
  created_at timestamptz default now()
);
create table attendance (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  date date not null,
  marks jsonb not null default '{}',
  names jsonb not null default '{}',
  saved_at timestamptz default now(),
  unique (user_id, date)
);
create table contributions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  name text not null,
  amount numeric(12,2) not null check (amount > 0),
  due date,
  notes text default '',
  applies_to text default 'class',
  created date default current_date
);
create table payments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  contribution_id uuid not null references contributions on delete cascade,
  student_id uuid not null references students on delete cascade,
  amount numeric(12,2) not null check (amount > 0),
  date date not null
);
create index on payments (contribution_id, student_id);

-- Each signed-in teacher can only see and change their own rows.
do $$ declare t text; begin
  foreach t in array array['students','attendance','contributions','payments'] loop
    execute format('alter table %I enable row level security', t);
    execute format('create policy "own rows" on %I for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid())', t);
  end loop;
end $$;
