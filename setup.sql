-- Startup Journey Recruitment Form: Supabase Schema Setup
-- Optimized for the fields in the latest index.html

-- 1. Create the applications table
create table if not exists applications (
  -- Primary Identity & Searchable Columns
  id text primary key,                       -- Unique ID (e.g., OH-A1B2)
  created_at timestamptz default now(),      -- Submission timestamp
  full_name text not null,                   -- name="fullName"
  email text not null,                       -- name="email"
  phone text,                                -- name="phone"
  domain text not null,                      -- name="domain" (legal, tech, marketing)
  status text not null default 'pending',    -- Status: pending, accepted, rejected
  
  -- Flexible JSON Data Storage
  -- Stores all additional form fields:
  -- - Section 1: links
  -- - Section 2: currentStatus
  -- - Section 3 (Domain Specific): Specialty Areas, Skills, Experience, Contributions
  -- - Section 4: strengths, expectations
  form_data jsonb default '{}'::jsonb,

  -- Constraints
  constraint valid_domain check (domain in ('legal', 'tech', 'marketing')),
  constraint valid_status check (status in ('pending', 'accepted', 'rejected'))
);

-- 2. Security Setup (Row Level Security)
alter table applications enable row level security;

-- Policies for public access and admin management:

-- Allow anyone to submit an application
drop policy if exists "Public Submissions" on applications;
create policy "Public Submissions" on applications for insert with check (true);

-- Allow anyone to view status via Application ID (Tracking)
drop policy if exists "Public Status Tracking" on applications;
create policy "Public Status Tracking" on applications for select using (true);

-- Allow Admin updates (Accept/Reject logic)
-- For production, this should restricted to authenticated admins, 
-- but following the simplified dashboard requirement:
drop policy if exists "Admin Management" on applications;
create policy "Admin Management" on applications for all using (true);

-- 3. Performance Indexes
create index if not exists idx_apps_email on applications(email);
create index if not exists idx_apps_status on applications(status);
create index if not exists idx_apps_domain on applications(domain);
create index if not exists idx_apps_name on applications(full_name);

