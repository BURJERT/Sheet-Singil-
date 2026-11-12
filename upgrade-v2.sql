-- Sheet, Singil! upgrade v2. Run in Supabase: SQL Editor > New query > Run. Safe to run again.
-- Adds: irregular students, "applies to" choices for contributions, and subjects for attendance.
-- Run this BEFORE you upload the new website files.

-- 1) Irregular students
alter table students add column if not exists irregular boolean not null default false;

-- 2) Contributions: who they apply to (all / regular / irregular / person)
alter table contributions add column if not exists student_ids jsonb not null default '[]';
update contributions set applies_to = 'all' where applies_to is null or applies_to = 'class';

-- 3) Attendance: a subject (or class name) per record, and who it was taken for
alter table attendance add column if not exists subject text not null default '';
alter table attendance add column if not exists scope text not null default 'all';

-- 4) Several attendance records per day: one per subject
alter table attendance drop constraint if exists attendance_user_id_date_key;
alter table attendance drop constraint if exists attendance_date_key;
alter table attendance drop constraint if exists attendance_user_id_date_subject_key;
alter table attendance add constraint attendance_user_id_date_subject_key unique (user_id, date, subject);
