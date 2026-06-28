-- Supabase setup for the website contact form.
-- Run this once in Supabase Dashboard > SQL Editor.

create table if not exists public.contact_messages (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    email text not null,
    topic text not null,
    subject text,
    message text not null,
    source text default 'website_contact_form',
    page_url text,
    user_agent text,
    status text not null default 'new',
    created_at timestamptz not null default now()
);

alter table public.contact_messages enable row level security;

drop policy if exists "Allow public contact form inserts" on public.contact_messages;

create policy "Allow public contact form inserts"
on public.contact_messages
for insert
to anon
with check (
    length(trim(name)) >= 2
    and position('@' in email) > 1
    and length(trim(topic)) >= 2
    and length(trim(message)) >= 10
);

-- No select/update/delete policy is added for anon users.
-- That means website visitors can submit enquiries, but cannot read messages.
