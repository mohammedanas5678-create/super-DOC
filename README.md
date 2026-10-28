# Ai-techDoc Pro — Heal Bay multi-device cloud PILOT

This is a deployable **starter application**, not a running cloud service or a clinically approved EMR. Do **not** use real identifiable patient information until security/privacy assessment, staff training, backup/restore drills, RLS penetration testing, legal review and iPad A5 print testing are complete.

## Architecture

- Static frontend (`index.html`, `app.js`, Heal Bay logo) on HTTPS GitHub Pages.
- Supabase Auth: email/password for individually provisioned staff accounts.
- Supabase PostgreSQL: patients, consultations, appointments, invoices, saved medicine/lab presets.
- RLS on all tables with clinic-scoped roles: `admin`, `doctor`, `reception`, `billing`.
- Online-first: read refresh every 30 seconds, optional realtime changes, no offline writes or conflict merges.
- Database-generated numeric patient and invoice serials. Note: PostgreSQL identity numbers can have gaps after failed transactions; they remain unique.
- A5 portrait printable prescriptions and invoices, with a single-page height warning.

## Setup

1. Create a new Supabase project under an organization account with MFA. Select an appropriate region and configure backup/retention/security settings. Do not put patient data in a personal/test project.
2. In Supabase SQL Editor run `schema.sql` once in the new empty project. **Review the SQL with your security engineer first.**
3. In Supabase Dashboard > Authentication > Users, create staff users by invite or admin action. Do not enable public signup. Confirm their email addresses and configure MFA/strong authentication.
4. In SQL Editor create the clinic and staff membership (replace placeholders with real user UUIDs from Auth > Users):

   ```sql
   insert into public.clinics(name) values ('Heal Bay') returning id;
   insert into public.staff(user_id,clinic_id,role)
   values ('YOUR_AUTH_USER_UUID','YOUR_CLINIC_UUID','admin');
   -- Repeat for doctor/reception/billing roles with each staff member's own UUID.
   ```

5. Upload `index.html`, `app.js` and `assets/logo.png` to a **separate** GitHub Pages repository (recommended: `Ai-techDoc-Cloud-Pilot`) to avoid overwriting the current single-iPad version. The optional `config.example.js` is not required; URL and publishable key are entered in the browser.
6. Open the HTTPS page on each device, enter Supabase project URL and **publishable key** (`sb_publishable_...`, never `sb_secret_...` or service-role), and sign in with each user's credentials.
7. Test using **fictional patients only**: staff access restrictions, serial numbering under concurrent registration, overlapping appointments, prescriptions, invoice permissions, printing, login persistence, logout, network loss, and database backup restore.

## Important security and operational limitations

- Supabase encrypts network traffic using TLS and manages encryption at rest, but this prototype does **not** provide end-to-end client-side encryption. The hosted database service can process patient data. This is different from the previous single-iPad passphrase-encrypted vault.
- No clinical-grade audit log, no immutable finalized prescriptions, no electronic signatures, no granular consent, no automatic backup export/restore UI, no multi-line invoices, no fiscal compliance guarantee, no SMS reminders, no server-side appointment conflict constraint, no migration utility, no automated tests of RLS, and no clinical decision support.
- The UI loads the Supabase JavaScript SDK from a third-party ESM CDN. Before production, bundle a pinned and reviewed dependency locally with a reproducible build and Content Security Policy; avoid loading executable third-party code into a clinical system.
- Cloud access is **not offline-first**. There are no offline edits; network outages require a documented clinic downtime workflow.
- `created_at` timestamps and daily counts can differ at midnight due to timezone handling; set clinic timezone policy and verify reporting before use.
- Admin role membership is provisioned through the Supabase SQL dashboard, not self-service; protect dashboard access. Never publish the service-role key.
- Schema does not include a dedicated audit history or data-retention workflow. These are release blockers.
- Current app reads at most 1,000 rows per table; add server-side pagination and database reports before scaling.
- This pilot is **not automatically connected** to your existing encrypted iPad records. Export/import needs a separately reviewed migration process; never upload the old unencrypted backup to GitHub.

Reference: https://supabase.com/docs/guides/database/postgres/row-level-security
