-- Resource Management setup.
-- Run this once in Supabase Dashboard > SQL Editor.
-- It upgrades site_resources for dynamic Learning Materials rendering.

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

alter table public.site_resources add column if not exists icon_class text;
alter table public.site_resources add column if not exists icon_library text default 'fontawesome';
alter table public.site_resources add column if not exists icon_name text default 'fa-solid fa-book-open-reader';
alter table public.site_resources add column if not exists link_label text default 'Explore';
alter table public.site_resources enable row level security;

drop policy if exists "Public can view active resources" on public.site_resources;
create policy "Public can view active resources"
on public.site_resources
for select
to anon
using (is_active = true);

drop policy if exists "Admins can manage resources" on public.site_resources;
create policy "Admins can manage resources"
on public.site_resources
for all
to authenticated
using (public.is_site_admin())
with check (public.is_site_admin());

insert into public.site_resources
    (title, category, summary, url, icon_class, icon_library, icon_name, link_label, sort_order, is_active)
select *
from (values
    ('C Programming', 'programming', 'Fundamentals & advanced concepts', 'https://sites.google.com/site/sandipwalunjcprogramming/', 'icon-c', 'devicon', 'devicon-c-plain', 'Explore', 10, true),
    ('C++', 'programming', 'Object-oriented programming', 'https://sites.google.com/site/sandipwalunjc/', 'icon-cpp', 'devicon', 'devicon-cplusplus-plain', 'Explore', 20, true),
    ('OOP & Multicore', 'programming core', 'Object oriented & multicore programming', 'https://sites.google.com/site/objectorienteddatastructures/', 'icon-oop', 'fontawesome', 'fa-solid fa-cubes', 'Explore', 30, true),
    ('Data Structures', 'core', 'Trees, graphs, lists & more', 'https://sites.google.com/site/sandipwalunjdatastructures/', 'icon-dsa', 'fontawesome', 'fa-solid fa-diagram-project', 'Explore', 40, true),
    ('Java Programming', 'programming', 'Core Java & advanced topics', 'https://sites.google.com/site/javaprogrammingsandipwalunj/', 'icon-java', 'devicon', 'devicon-java-plain', 'Explore', 50, true),
    ('Design & Analysis of Algorithms', 'core', 'Algorithm strategies & complexity', 'https://sites.google.com/site/advancedalgorithmsaa/', 'icon-algo', 'fontawesome', 'fa-solid fa-chart-line', 'Explore', 60, true),
    ('Theory of Computation', 'core', 'Automata, languages & Turing', 'https://sites.google.com/site/theoryofcomputation1/', 'icon-toc', 'fontawesome', 'fa-solid fa-atom', 'Explore', 70, true),
    ('Compiler Design', 'core systems', 'Principles of compiler design', 'https://sites.google.com/site/compilerdesignsam/', 'icon-compiler', 'fontawesome', 'fa-solid fa-gear', 'Explore', 80, true),
    ('CUDA Programming', 'systems research', 'GPU computing & parallel processing', 'https://sites.google.com/site/cudaprogramming1/', 'icon-cuda', 'fontawesome', 'fa-solid fa-microchip', 'Explore', 90, true),
    ('Dot Net', 'programming', 'ASP.NET, C#.NET framework', 'https://sites.google.com/site/sandipwalunjdotnet/home', 'icon-dotnet', 'devicon', 'devicon-dotnetcore-plain', 'Explore', 100, true),
    ('Discrete Mathematics', 'core', 'Logic, sets & combinatorics', 'https://www.sites.google.com/site/walunjsmnetworking/', 'icon-math', 'fontawesome', 'fa-solid fa-square-root-variable', 'Explore', 110, true),
    ('Distributed OS', 'systems', 'Distributed operating systems', 'https://sites.google.com/site/advancedoperatingsystemsaos/', 'icon-os', 'fontawesome', 'fa-solid fa-server', 'Explore', 120, true),
    ('Advanced DBMS', 'systems', 'Database management systems', 'https://sites.google.com/site/advanceddbms11/', 'icon-dbms', 'fontawesome', 'fa-solid fa-database', 'Explore', 130, true),
    ('Python Programming', 'programming', 'Python fundamentals & applications', 'https://sites.google.com/site/advancedcomputerarchitecture11/', 'icon-python', 'devicon', 'devicon-python-plain', 'Explore', 140, true),
    ('Image Processing', 'research', 'Digital image processing techniques', 'https://sites.google.com/site/imageprocessing81/', 'icon-image', 'fontawesome', 'fa-solid fa-image', 'Explore', 150, true)
) as seed(title, category, summary, url, icon_class, icon_library, icon_name, link_label, sort_order, is_active)
where not exists (
    select 1
    from public.site_resources existing
    where existing.title = seed.title
);
