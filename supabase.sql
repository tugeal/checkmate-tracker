-- Checkmate Cafe Tracker: run this whole file once in Supabase > SQL Editor.
-- Before running: change your-email@example.com near the bottom to YOUR email.

-- 1. TABLES -------------------------------------------------------------
create table public.agents (email text primary key, name text, created_at timestamptz not null default now());
create table public.settings (key text primary key, value text not null);
create table public.students (
  id bigint generated always as identity primary key,
  client text not null, name text not null,
  kind text not null check (kind in ('gb','gi','oo','fc')),
  total int not null default 1 check (total between 1 and 30),
  done int not null default 0 check (done >= 0),
  last_attended date, start_date date,
  agent text not null default '', price numeric not null default 0, link text not null default '',
  dates jsonb not null default '[]', created_at timestamptz not null default now());
create table public.flags (
  kind text not null check (kind in ('rem','att','msg')), key text not null, value text not null default '1',
  primary key (kind, key));
create table public.activity_log (
  id bigint generated always as identity primary key, at timestamptz not null default now(),
  actor text, action text not null, student text, details jsonb);

-- 2. WHO IS ALLOWED IN --------------------------------------------------
create function public.is_agent() returns boolean language sql stable security definer set search_path = public
as $$ select exists (select 1 from agents where lower(email) = lower(auth.jwt() ->> 'email')) $$;
create function public.is_listed(p_email text) returns boolean language sql stable security definer set search_path = public
as $$ select exists (select 1 from agents where lower(email) = lower(p_email)) $$;
grant execute on function public.is_listed(text) to anon, authenticated;

-- 3. SECURITY RULES (only listed agents can read or change anything) -----
alter table public.agents enable row level security;
alter table public.settings enable row level security;
alter table public.students enable row level security;
alter table public.flags enable row level security;
alter table public.activity_log enable row level security;
create policy "agents read" on public.agents for select to authenticated using (public.is_agent());
create policy "settings read" on public.settings for select to authenticated using (public.is_agent());
create policy "students all" on public.students for all to authenticated using (public.is_agent()) with check (public.is_agent());
create policy "flags all" on public.flags for all to authenticated using (public.is_agent()) with check (public.is_agent());
create policy "log read" on public.activity_log for select to authenticated using (public.is_agent());

-- 4. ACTIVITY LOG (written automatically by the database, cannot be edited or deleted)
revoke insert, update, delete, truncate on public.activity_log from anon, authenticated;
create function public.log_block() returns trigger language plpgsql
as $$ begin raise exception 'The activity log cannot be changed or deleted.'; end $$;
create trigger log_no_change before update or delete on public.activity_log for each row execute function public.log_block();
create trigger log_no_truncate before truncate on public.activity_log for each statement execute function public.log_block();

create function public.log_students() returns trigger language plpgsql security definer set search_path = public
as $$
declare who text := coalesce(auth.jwt() ->> 'email', 'system'); d jsonb; nm text;
begin
  if tg_op = 'INSERT' then
    insert into activity_log(actor, action, student, details) values (who, 'Added student', new.name || ' (' || new.client || ')', to_jsonb(new));
    return new;
  elsif tg_op = 'UPDATE' then
    nm := new.name || ' (' || new.client || ')';
    select coalesce(jsonb_object_agg(n.key, jsonb_build_array(o.value, n.value)), '{}'::jsonb) into d
      from jsonb_each(to_jsonb(new)) n join jsonb_each(to_jsonb(old)) o on o.key = n.key where n.value is distinct from o.value;
    if d = '{}'::jsonb then return new; end if;
    if (d - 'done' - 'last_attended') = '{}'::jsonb and exists (select 1 from activity_log where actor = who and student = nm
       and action in ('Marked attended', 'Attendance undone') and at > now() - interval '5 seconds') then return new; end if;
    insert into activity_log(actor, action, student, details) values (who, 'Edited student', nm, d);
    return new;
  else
    perform set_config('app.skip', '1', true);
    insert into activity_log(actor, action, student, details) values (who, 'Deleted student', old.name || ' (' || old.client || ')', to_jsonb(old));
    delete from flags where (kind in ('rem', 'att') and split_part(key, '|', 2) = old.id::text) or (kind = 'msg' and key = old.id::text);
    return old;
  end if;
end $$;
create trigger students_log after insert or update or delete on public.students for each row execute function public.log_students();

create function public.log_flags() returns trigger language plpgsql security definer set search_path = public
as $$
declare f public.flags; nm text; a text; who text := coalesce(auth.jwt() ->> 'email', 'system');
begin
  if current_setting('app.skip', true) = '1' then return null; end if;
  f := case when tg_op = 'DELETE' then old else new end;
  select s.name || ' (' || s.client || ')' into nm from students s
    where s.id = (case when f.kind = 'msg' then f.key else split_part(f.key, '|', 2) end)::bigint;
  a := case f.kind
    when 'rem' then case when tg_op = 'DELETE' then 'Reminder undone' else 'Marked as reminded' end
    when 'msg' then case when tg_op = 'DELETE' then 'Message undone' else 'Marked as messaged' end
    else case when tg_op = 'DELETE' then 'Attendance undone' when f.value = 'y' then 'Marked attended' else 'Marked absent' end end;
  insert into activity_log(actor, action, student, details) values (who, a, nm, jsonb_build_object('key', f.key));
  return null;
end $$;
create trigger flags_log after insert or update or delete on public.flags for each row execute function public.log_flags();

-- 5. LIVE UPDATES between agents ---------------------------------------
alter publication supabase_realtime add table public.students, public.flags;

-- 6. YOUR SETTINGS AND FIRST AGENT -------------------------------------
insert into public.settings(key, value) values
 ('zoom', 'https://us06web.zoom.us/j/6955396117?pwd=ojN15Pijy8aDKf2xoMXxGzdAUpf6l1.1'),
 ('cafe', E'📍 Our physical chess café is located in Rigonan st. Brgy Callaguip, Batac City, Ilocos Norte po\nPIN: https://maps.app.goo.gl/SxC3B6Tg9xVV5ewT8');
insert into public.agents(email, name) values ('tundaggeraldaldrian@gmail.com', 'Aldrian');
