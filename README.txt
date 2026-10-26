SMART OPD v1.0 - PROTOTYPE

WHAT'S INCLUDED
- index.html: application
- sw.js: offline cache for a properly installed HTTPS website
- manifest.webmanifest: iPhone/iPad home screen app metadata

IMPORTANT: This is an unencrypted prototype, NOT production-ready patient-record software. Test with fictional patients only. It has no authentication, encryption, audit log, consent management, or medically validated prescription checks. Exported JSON backups contain readable patient details.

INSTALL ON IPHONE / IPAD (RECOMMENDED TEST SETUP)
1. Upload the three files to an HTTPS static web host, keeping them together in the same directory. Choose a trusted host, and do not upload patient records or backups. A static site host only serves the application code.
2. Open the HTTPS URL in Safari while connected to the internet.
3. Wait for the app to load. In Safari, tap Share > Add to Home Screen > Add (wording may vary).
4. Open Smart OPD from the Home Screen at least once while online. Then turn on Airplane Mode and confirm that it opens and saves a fictional patient. Service worker installation may take a moment.
5. Keep the app installed and do not clear Safari website data: clearing site data or deleting the home-screen web app can erase locally stored records.
6. Export a backup regularly (Settings & Backup). iOS may save the JSON via Files or the browser's Downloads list. Protect it carefully. This export is NOT encrypted.

QUICK COMPUTER TEST
- Open index.html in a desktop browser. Local-file storage can be unreliable, so this is only for interface testing.

HOW TO USE
1. Settings & Backup: enter clinic/doctor name, registration and contact details.
2. Patients: register a fictional patient.
3. Consultation: select the patient, enter clinical details, medications, lab tests and billing.
4. Save consultation, then print/share the prescription using the iOS print dialog. AirPrint requires a compatible printer on a reachable network. Saving a PDF through the iOS print/share flow may also be possible.
5. History: view saved visits, print past prescriptions.
6. Tap മലയാളം to change interface labels. Medical free-text can be entered in Malayalam using the iOS keyboard.

LIMITATIONS
- No editing or deleting existing patient records or visits.
- No prescription safety checks, e-prescribing, e-signatures, authentication or encrypted data.
- Records live in browser localStorage and may be removed by iOS storage management or website-data deletion. There is no automatic sync or backup.
- Backup restore REPLACES all local records.
- No tax invoice or regulatory compliance certification.
- Printing relies on the device's iOS print dialog; not every printer works offline.
- Use an HTTPS deployment for reliable offline installation; opening a local HTML file in iOS Files is not equivalent to installing an offline web app.
