-- Run in a NEW Supabase project, never against existing production data.
create extension if not exists pgcrypto;
create table public.clinics (id uuid primary key default gen_random_uuid(), name text not null, created_at timestamptz not null default now());
create table public.staff (user_id uuid primary key references auth.users(id) on delete cascade, clinic_id uuid not null references public.clinics(id), role text not null check(role in ('admin','doctor','reception','billing')), active boolean not null default true);
create index staff_clinic_idx on public.staff(clinic_id);
create function public.has_clinic_role(c uuid, roles text[]) returns boolean language sql stable security definer set search_path='' as $$select exists(select 1 from public.staff s where s.user_id=(select auth.uid()) and s.clinic_id=c and s.active and s.role=any(roles))$$;
revoke all on function public.has_clinic_role(uuid,text[]) from public,anon;
grant execute on function public.has_clinic_role(uuid,text[]) to authenticated;
create table public.patients (id uuid primary key default gen_random_uuid(), clinic_id uuid not null references public.clinics(id), serial bigint generated always as identity, name text not null, age integer check(age between 0 and 125), sex text, phone text, allergies text, created_at timestamptz not null default now(), unique(clinic_id,serial));
create table public.visits (id uuid primary key default gen_random_uuid(), clinic_id uuid not null references public.clinics(id), patient_id uuid not null references public.patients(id), visit_date date not null default current_date, bp text, pulse text, diagnosis text, complaints text, findings text, meds jsonb not null default '[]', labs jsonb not null default '[]', advice text, created_by uuid default auth.uid(), created_at timestamptz not null default now());
create table public.appointments (id uuid primary key default gen_random_uuid(), clinic_id uuid not null references public.clinics(id), patient_id uuid not null references public.patients(id), starts_at timestamptz not null, duration_minutes integer not null default 15 check(duration_minutes between 5 and 240), reason text, status text not null default 'Scheduled' check(status in ('Scheduled','Arrived','Completed','Cancelled')), created_at timestamptz not null default now());
create table public.invoices (id uuid primary key default gen_random_uuid(), clinic_id uuid not null references public.clinics(id), patient_id uuid not null references public.patients(id), serial bigint generated always as identity, issued_on date not null default current_date, service text not null, qty integer not null check(qty>0), rate numeric(12,2) not null check(rate>=0), discount numeric(12,2) not null default 0 check(discount>=0), tax_percent numeric(5,2) not null default 0 check(tax_percent between 0 and 100), status text not null default 'Unpaid' check(status in ('Paid','Unpaid')), method text, created_at timestamptz not null default now(), unique(clinic_id,serial), check(discount<=qty*rate));
create table public.presets (id uuid primary key default gen_random_uuid(), clinic_id uuid not null references public.clinics(id), kind text not null check(kind in ('med','lab')), title text not null, details jsonb not null default '{}');
-- Prevent mismatched clinic/patient links even when user can access both clinics.
create function public.patient_same_clinic() returns trigger language plpgsql set search_path='' as $$begin if not exists(select 1 from public.patients p where p.id=new.patient_id and p.clinic_id=new.clinic_id) then raise exception 'Patient belongs to another clinic'; end if; return new; end$$;
create trigger visit_patient_clinic before insert or update on public.visits for each row execute function public.patient_same_clinic();
create trigger appointment_patient_clinic before insert or update on public.appointments for each row execute function public.patient_same_clinic();
create trigger invoice_patient_clinic before insert or update on public.invoices for each row execute function public.patient_same_clinic();
-- All tables default deny; no anonymous table access.
alter table public.clinics enable row level security;
alter table public.staff enable row level security;
alter table public.patients enable row level security;
alter table public.visits enable row level security;
alter table public.appointments enable row level security;
alter table public.invoices enable row level security;
alter table public.presets enable row level security;
revoke all on public.clinics,public.staff,public.patients,public.visits,public.appointments,public.invoices,public.presets from anon,authenticated;
grant select on public.clinics,public.staff,public.patients,public.visits,public.appointments,public.invoices,public.presets to authenticated;
grant insert on public.patients,public.visits,public.appointments,public.invoices,public.presets to authenticated;
grant update on public.appointments,public.invoices to authenticated;
grant delete on public.presets to authenticated;
grant usage on all sequences in schema public to authenticated;
create policy clinics_read on public.clinics for select to authenticated using(public.has_clinic_role(id,array['admin','doctor','reception','billing']));
create policy staff_read on public.staff for select to authenticated using(user_id=(select auth.uid()) or public.has_clinic_role(clinic_id,array['admin']));
create policy patients_read on public.patients for select to authenticated using(public.has_clinic_role(clinic_id,array['admin','doctor','reception','billing']));
create policy patients_insert on public.patients for insert to authenticated with check(public.has_clinic_role(clinic_id,array['admin','doctor','reception']));
create policy visits_read on public.visits for select to authenticated using(public.has_clinic_role(clinic_id,array['admin','doctor']));
create policy visits_insert on public.visits for insert to authenticated with check(public.has_clinic_role(clinic_id,array['admin','doctor']) and created_by=(select auth.uid()));
create policy appts_read on public.appointments for select to authenticated using(public.has_clinic_role(clinic_id,array['admin','doctor','reception']));
create policy appts_insert on public.appointments for insert to authenticated with check(public.has_clinic_role(clinic_id,array['admin','doctor','reception']));
create policy appts_update on public.appointments for update to authenticated using(public.has_clinic_role(clinic_id,array['admin','doctor','reception'])) with check(public.has_clinic_role(clinic_id,array['admin','doctor','reception']));
create policy invoices_read on public.invoices for select to authenticated using(public.has_clinic_role(clinic_id,array['admin','billing']));
create policy invoices_insert on public.invoices for insert to authenticated with check(public.has_clinic_role(clinic_id,array['admin','billing']));
create policy invoices_update on public.invoices for update to authenticated using(public.has_clinic_role(clinic_id,array['admin','billing'])) with check(public.has_clinic_role(clinic_id,array['admin','billing']));
create policy presets_read on public.presets for select to authenticated using(public.has_clinic_role(clinic_id,array['admin','doctor']));
create policy presets_insert on public.presets for insert to authenticated with check(public.has_clinic_role(clinic_id,array['admin','doctor']));
create policy presets_delete on public.presets for delete to authenticated using(public.has_clinic_role(clinic_id,array['admin','doctor']));
-- Important: staff and clinic creation are administrator-only operations via SQL dashboard.
-- Provision users in Authentication > Users, then add staff memberships with the SQL dashboard.
-- Do not place a service_role/secret key in any browser file.
