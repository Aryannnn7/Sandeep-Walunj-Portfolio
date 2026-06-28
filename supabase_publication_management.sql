-- Publication Management setup.
-- Run this once in Supabase Dashboard > SQL Editor.
-- It upgrades site_publications for dynamic Research section rendering.

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

alter table public.site_publications add column if not exists journal text;
alter table public.site_publications add column if not exists publication_year integer;
alter table public.site_publications add column if not exists link_label text default 'View Paper';
alter table public.site_publications enable row level security;

drop policy if exists "Public can view active publications" on public.site_publications;
create policy "Public can view active publications"
on public.site_publications
for select
to anon
using (is_active = true);

-- Keep the admin policy if admin_users/is_site_admin already exists.
drop policy if exists "Admins can manage publications" on public.site_publications;
create policy "Admins can manage publications"
on public.site_publications
for all
to authenticated
using (public.is_site_admin())
with check (public.is_site_admin());

-- Seed existing visible publications. These insert only if the title is not already present.
insert into public.site_publications
    (title, category, journal, publication_year, summary, url, link_label, sort_order, is_active)
select
    'Enhancing Speed of SQL Database Operations using GPU',
    'Database GPU',
    'IEEE',
    2015,
    'Published in the 2015 International Conference on Pervasive Computing.',
    'https://doi.org/10.1109/PERVASIVE.2015.7087144',
    'View DOI',
    10,
    true
where not exists (
    select 1 from public.site_publications
    where title = 'Enhancing Speed of SQL Database Operations using GPU'
);

insert into public.site_publications
    (title, category, journal, publication_year, summary, url, link_label, sort_order, is_active)
select
    'Accelerate Execution of CUDA Programs for Non GPU Users',
    'CUDA Cloud GPU',
    'IRJET',
    2015,
    'Research on using GPU in the cloud for CUDA programmers without local GPU hardware.',
    'https://www.irjet.net/archives/V2/i3/Irjet-v2i3272.pdf',
    'View PDF',
    20,
    true
where not exists (
    select 1 from public.site_publications
    where title = 'Accelerate Execution of CUDA Programs for Non GPU Users'
);

insert into public.site_publications
    (title, category, journal, publication_year, summary, url, link_label, sort_order, is_active)
select
    'Enhancing Speed of XML Data Mining on GPU',
    'XML Data Mining',
    'IJCSN',
    2016,
    'GPU-based research work focused on improving XML data mining performance.',
    'https://ijcsn.org/IJCSN-2016/5-2/Enhancing-Speed-of-XML-Data-Mining-on-GPU.pdf',
    'View PDF',
    30,
    true
where not exists (
    select 1 from public.site_publications
    where title = 'Enhancing Speed of XML Data Mining on GPU'
);

insert into public.site_publications
    (title, category, journal, publication_year, summary, url, link_label, sort_order, is_active)
select
    'Data Glove Controlled Virtual Musical Instruments',
    'Human Computer Interaction',
    'IJASEAT',
    2014,
    'Research paper on gesture-based interaction for playing virtual musical instruments.',
    'https://iraj.in/journal/IJASEAT/paper_detail.php?name=Data_Glove_Controlled_Virtual_Musical_Instruments&paper_id=627',
    'View Paper',
    40,
    true
where not exists (
    select 1 from public.site_publications
    where title = 'Data Glove Controlled Virtual Musical Instruments'
);

insert into public.site_publications
    (title, category, journal, publication_year, summary, url, link_label, sort_order, is_active)
select
    'Transfer Time Optimization Between CPU and GPU for Virus Signature Scanning',
    'GPU Security',
    'Springer',
    2019,
    'Book chapter on GPU acceleration and CPU-GPU data transfer optimization.',
    'https://doi.org/10.1007/978-981-15-0111-1_6',
    'View Chapter',
    50,
    true
where not exists (
    select 1 from public.site_publications
    where title = 'Transfer Time Optimization Between CPU and GPU for Virus Signature Scanning'
);

insert into public.site_publications
    (title, category, journal, publication_year, summary, url, link_label, sort_order, is_active)
select
    'Accelerate the Execution of Graph Processing Using GPU',
    'Graph Processing',
    'Springer',
    2018,
    'Springer publication focused on GPU-based acceleration for graph processing.',
    'https://doi.org/10.1007/978-981-13-1742-2_13',
    'View Chapter',
    60,
    true
where not exists (
    select 1 from public.site_publications
    where title = 'Accelerate the Execution of Graph Processing Using GPU'
);
