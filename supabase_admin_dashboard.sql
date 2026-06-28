-- Supabase setup for admin dashboard + applications + content manager.
-- Run this in Supabase Dashboard > SQL Editor after creating an Auth user for the admin.

-- 1) Admin allow-list
create table if not exists public.admin_users (
    user_id uuid primary key references auth.users(id) on delete cascade,
    email text unique not null,
    created_at timestamptz not null default now()
);

alter table public.admin_users enable row level security;

create or replace function public.is_site_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
    select exists (
        select 1
        from public.admin_users
        where user_id = auth.uid()
    );
$$;

revoke all on function public.is_site_admin() from public;
grant execute on function public.is_site_admin() to authenticated;

drop policy if exists "Admins can view admin users" on public.admin_users;
create policy "Admins can view admin users"
on public.admin_users
for select
to authenticated
using (public.is_site_admin());

-- 2) Applications table for placement/internship requests
create table if not exists public.applications (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    email text not null,
    phone text not null,
    application_type text not null,
    qualification text not null,
    preferred_role text,
    skills text not null,
    resume_link text,
    message text not null,
    source text default 'website_application_form',
    page_url text,
    user_agent text,
    status text not null default 'new',
    created_at timestamptz not null default now()
);

alter table public.applications enable row level security;

drop policy if exists "Allow public application inserts" on public.applications;
create policy "Allow public application inserts"
on public.applications
for insert
to anon
with check (
    length(trim(name)) >= 2
    and position('@' in email) > 1
    and length(trim(phone)) >= 8
    and length(trim(application_type)) >= 2
    and length(trim(qualification)) >= 2
    and length(trim(skills)) >= 2
    and length(trim(message)) >= 10
);

-- 3) Admin policies for contact messages and applications
drop policy if exists "Admins can view contact messages" on public.contact_messages;
create policy "Admins can view contact messages"
on public.contact_messages
for select
to authenticated
using (public.is_site_admin());

drop policy if exists "Admins can update contact messages" on public.contact_messages;
create policy "Admins can update contact messages"
on public.contact_messages
for update
to authenticated
using (public.is_site_admin())
with check (public.is_site_admin());

drop policy if exists "Admins can view applications" on public.applications;
create policy "Admins can view applications"
on public.applications
for select
to authenticated
using (public.is_site_admin());

drop policy if exists "Admins can update applications" on public.applications;
create policy "Admins can update applications"
on public.applications
for update
to authenticated
using (public.is_site_admin())
with check (public.is_site_admin());

-- 4) Website content tables managed from admin.html
create table if not exists public.site_services (
    id uuid primary key default gen_random_uuid(),
    title text not null,
    category text,
    summary text not null,
    url text,
    sort_order integer not null default 10,
    is_active boolean not null default true,
    created_at timestamptz not null default now()
);

create table if not exists public.site_resources (
    id uuid primary key default gen_random_uuid(),
    title text not null,
    category text,
    summary text not null,
    url text,
    icon_class text,
    icon_library text default 'fontawesome',
    icon_name text default 'fa-solid fa-book-open-reader',
    link_label text default 'Explore',
    sort_order integer not null default 10,
    is_active boolean not null default true,
    created_at timestamptz not null default now()
);

create table if not exists public.site_publications (
    id uuid primary key default gen_random_uuid(),
    title text not null,
    category text,
    journal text,
    publication_year integer,
    summary text not null,
    url text,
    link_label text default 'View Paper',
    sort_order integer not null default 10,
    is_active boolean not null default true,
    created_at timestamptz not null default now()
);

alter table public.site_services enable row level security;
alter table public.site_resources enable row level security;
alter table public.site_publications enable row level security;

drop policy if exists "Admins can manage services" on public.site_services;
create policy "Admins can manage services"
on public.site_services
for all
to authenticated
using (public.is_site_admin())
with check (public.is_site_admin());

drop policy if exists "Admins can manage resources" on public.site_resources;
create policy "Admins can manage resources"
on public.site_resources
for all
to authenticated
using (public.is_site_admin())
with check (public.is_site_admin());

drop policy if exists "Public can view active resources" on public.site_resources;
create policy "Public can view active resources"
on public.site_resources
for select
to anon
using (is_active = true);

drop policy if exists "Admins can manage publications" on public.site_publications;
create policy "Admins can manage publications"
on public.site_publications
for all
to authenticated
using (public.is_site_admin())
with check (public.is_site_admin());

drop policy if exists "Public can view active publications" on public.site_publications;
create policy "Public can view active publications"
on public.site_publications
for select
to anon
using (is_active = true);

-- 5) After creating an admin user in Authentication, run this by replacing the email:
-- insert into public.admin_users (user_id, email)
-- select id, email from auth.users where email = 'sandip@example.com'
-- on conflict (user_id) do nothing;
