# Requirements Document

## Introduction

HET Consultancy is a production-ready Flutter mobile application for a solar energy consultancy business. The app enables the company's internal teams (Admin, Sales, Engineer, Accounts) to manage clients, generate professional quotation PDFs, track solar installation projects, conduct site surveys, and store documents — all from a single Android-first application backed by Supabase and local Hive storage.

The application follows a modular architecture (`lib/core/`, `lib/features/`, `lib/services/`, `lib/models/`, `lib/screens/`, `lib/widgets/`) using Flutter + Dart, Riverpod state management, GoRouter navigation, Material 3 design, and is APK-ready for Android deployment.

---

## Glossary

- **App**: The HET Consultancy Flutter application.
- **Admin**: A user with the Admin role who has full access to all features including unlocking quotations.
- **Sales**: A user with the Sales role who can manage clients and quotations.
- **Engineer**: A user with the Engineer role who can manage projects and site surveys.
- **Accounts**: A user with the Accounts role who can view quotations and financial data.
- **Client**: A record representing a customer or lead in the system.
- **Quotation**: A formal solar energy proposal document generated for a client.
- **Quotation_Item**: A line item within a quotation (panel, inverter, accessories, etc.).
- **Project**: A solar installation project linked to an approved quotation.
- **Survey_Report**: A site survey record containing photos, measurements, and engineer notes for a client.
- **Document_Vault**: A per-client folder structure storing quotations, bills, photos, and certificates.
- **AuthService**: The service responsible for authentication and session management via Supabase.
- **QuotationService**: The service responsible for creating, updating, locking, and generating PDFs for quotations.
- **ClientService**: The service responsible for CRUD operations on client records.
- **ProjectService**: The service responsible for managing project stages and timelines.
- **SurveyService**: The service responsible for uploading and retrieving site survey data.
- **DocumentService**: The service responsible for storing and retrieving documents in the Document Vault.
- **SettingsService**: The service responsible for managing company-level settings.
- **PDF_Generator**: The component responsible for rendering A4 quotation PDFs using the `pdf` and `printing` packages.
- **Lock_Badge**: A visual indicator displayed on a locked quotation.
- **Proposal_Number**: A unique identifier assigned to each quotation.
- **Supabase**: The cloud backend providing database, authentication, and file storage.
- **Hive**: The local on-device storage library used for offline caching.
- **GoRouter**: The navigation library managing all route transitions in the App.
- **Riverpod**: The state management library used throughout the App.
- **Material_3**: The design system used for all UI components.

---

## Requirements

### Requirement 1: User Authentication

**User Story:** As a team member, I want to log in with my email and password, so that I can access the features relevant to my role.

#### Acceptance Criteria

1. THE AuthService SHALL provide a login screen as the initial route when no authenticated session exists.
2. WHEN a user submits valid credentials, THE AuthService SHALL authenticate the user against Supabase and navigate to the Dashboard.
3. WHEN a user submits invalid credentials, THE AuthService SHALL display a descriptive error message without navigating away from the login screen.
4. THE App SHALL support the following demo accounts with pre-assigned roles:
   - `admin@het.com` / `Admin123` → Admin role
   - `sales@het.com` / `Sales123` → Sales role
   - `engineer@het.com` / `Engineer123` → Engineer role
   - `accounts@het.com` / `Accounts123` → Accounts role
5. WHEN a user is authenticated, THE AuthService SHALL persist the session using Hive so the user remains logged in across app restarts.
6. WHEN a user logs out, THE AuthService SHALL clear the local session and navigate to the login screen.
7. IF the Supabase authentication service is unreachable, THEN THE AuthService SHALL display a network error message and allow retry.

---

### Requirement 2: Role-Based Access Control

**User Story:** As an Admin, I want access controls enforced by role, so that team members only see and perform actions appropriate to their responsibilities.

#### Acceptance Criteria

1. THE App SHALL enforce role-based access control for all features based on the authenticated user's role.
2. WHILE a user with the Admin role is authenticated, THE App SHALL grant access to all features including client management, quotation management, project tracking, site surveys, document vault, settings, and quotation unlocking.
3. WHILE a user with the Sales role is authenticated, THE App SHALL grant access to client management, quotation creation and editing, project viewing, and document vault.
4. WHILE a user with the Engineer role is authenticated, THE App SHALL grant access to project tracking, site survey submission, and document vault.
5. WHILE a user with the Accounts role is authenticated, THE App SHALL grant access to quotation viewing, project viewing, and document vault in read-only mode.
6. IF a user attempts to access a feature outside their role permissions, THEN THE App SHALL display an access-denied message and redirect to the Dashboard.

---

### Requirement 3: Bottom Navigation

**User Story:** As a user, I want a persistent bottom navigation bar, so that I can switch between the main sections of the app quickly.

#### Acceptance Criteria

1. THE App SHALL display a bottom navigation bar with five tabs: Dashboard, Clients, Quotations, Projects, and Settings.
2. WHEN a user taps a bottom navigation tab, THE GoRouter SHALL navigate to the corresponding screen without resetting the state of other tabs.
3. THE App SHALL highlight the currently active tab in the bottom navigation bar using the primary Dark Blue color.
4. WHILE a user with the Accounts role is authenticated, THE App SHALL display the Quotations tab in read-only mode.

---

### Requirement 4: Dashboard

**User Story:** As a user, I want a dashboard overview, so that I can quickly assess the current state of the business.

#### Acceptance Criteria

1. THE App SHALL display a Dashboard screen containing summary cards for: Total Clients, Pending Quotations, Approved Projects, Revenue, and Surveys.
2. WHEN the Dashboard screen loads, THE App SHALL fetch the latest summary data from Supabase and update each summary card.
3. THE App SHALL display a Recent Activities list on the Dashboard showing the most recent client additions, quotation status changes, and project stage updates.
4. IF the data fetch fails, THEN THE App SHALL display the last cached values from Hive and show a stale-data indicator.
5. WHERE chart rendering is supported on the device, THE App SHALL display optional visual charts for revenue and project status distribution.

---

### Requirement 5: Client Management

**User Story:** As a Sales team member, I want to create and manage client records, so that I can track every lead and customer through the sales pipeline.

#### Acceptance Criteria

1. THE ClientService SHALL store client records with the following fields: Client Name, Phone, Email, Address, Site, Capacity (kW), Proposal Number, and Status.
2. THE App SHALL support the following Status values for a client: Lead, Survey Pending, Quotation Sent, Approved, Completed, and Cancelled.
3. WHEN a user creates a new client record with all required fields, THE ClientService SHALL persist the record to Supabase and update the local Hive cache.
4. WHEN a user submits a client record with missing required fields (Client Name, Phone), THE App SHALL display a field-level validation error and prevent submission.
5. WHEN a user edits an existing client record, THE ClientService SHALL update the record in Supabase and reflect the change immediately in the client list.
6. WHEN a user deletes a client record, THE ClientService SHALL remove the record from Supabase and the local Hive cache after the user confirms the deletion.
7. THE App SHALL provide a search bar on the Clients screen that filters the client list by Client Name, Phone, or Email in real time.
8. THE App SHALL provide a filter control on the Clients screen that filters the client list by Status.
9. IF the Supabase write operation fails during client creation or update, THEN THE ClientService SHALL retain the change in a local pending queue and retry when connectivity is restored.

---

### Requirement 6: Quotation Generator

**User Story:** As a Sales team member, I want to generate detailed solar energy quotations, so that I can provide professional proposals to clients.

#### Acceptance Criteria

1. THE QuotationService SHALL store quotation records with the following customer detail fields: Customer Name, Phone, Address, Email, Proposal Number, and Date.
2. THE QuotationService SHALL store the following technical specification fields per quotation: Solar Capacity (kW), Panel Brand, Panel Wattage, Panel Quantity, Inverter Brand, and Inverter Quantity.
3. THE QuotationService SHALL store the following component fields per quotation: Structure, DCDB, ACDB, Lightning Arrestor, Earthing, Cable, and Accessories.
4. THE QuotationService SHALL store the following commercial fields per quotation: Price, Tax, Subsidy, Installation Time (days), Bank Details, Terms, Warranty, and Notes.
5. WHEN a user saves a quotation with all required fields populated, THE QuotationService SHALL persist the quotation and its line items to the `quotations` and `quotation_items` Supabase tables.
6. WHEN a user saves a quotation with missing required fields (Customer Name, Proposal Number, Solar Capacity, Price), THE App SHALL display field-level validation errors and prevent saving.
7. THE App SHALL auto-generate a unique Proposal Number for each new quotation following the format `HET-YYYY-NNNN` where YYYY is the current year and NNNN is a zero-padded sequential number.
8. WHEN a user edits a quotation in Draft or Submitted state, THE QuotationService SHALL save the updated version and maintain the same Proposal Number.

---

### Requirement 7: PDF Generation

**User Story:** As a Sales team member, I want to generate a professional A4 PDF quotation, so that I can share it with clients via download, print, or WhatsApp.

#### Acceptance Criteria

1. THE PDF_Generator SHALL produce a 4-page A4 PDF document from a quotation record.
2. THE PDF_Generator SHALL render Page 1 with: Company Logo, Header, Company Address, Proposal Number, Date, Subject line, Introduction letter, Customer Details table, and Managing Partner Signature.
3. THE PDF_Generator SHALL render Page 2 as "LIST OF DELIVERABLES" containing a Bill of Materials table with columns: SR NO, DESCRIPTION, and QTY.
4. THE PDF_Generator SHALL render Page 3 as "PRICE & DELIVERY" containing: Price table, Subsidy section, Bank Details, Installation Days, and Notes.
5. THE PDF_Generator SHALL render Page 4 with: Terms & Conditions, Warranty information, and Footer signature.
6. WHEN a user taps "Preview PDF", THE App SHALL render the PDF and display it in an in-app preview using the `printing` package.
7. WHEN a user taps "Download PDF", THE App SHALL save the generated PDF to the device's local storage and display a confirmation message with the file path.
8. WHEN a user taps "Share PDF", THE App SHALL open the platform share sheet with the generated PDF attached.
9. WHEN a user taps "WhatsApp Share", THE App SHALL open WhatsApp with the generated PDF attached, if WhatsApp is installed on the device.
10. IF WhatsApp is not installed on the device, THEN THE App SHALL display a message indicating WhatsApp is not available and offer the standard share sheet instead.
11. THE PDF_Generator SHALL use the company logo, GST number, bank details, and terms template stored in the SettingsService when rendering the PDF.
12. WHEN a quotation is in Locked state, THE PDF_Generator SHALL include a "LOCKED" watermark on all pages of the generated PDF.

---

### Requirement 8: Quotation Lock Feature

**User Story:** As an Admin, I want to lock approved quotations, so that finalized proposals cannot be accidentally modified.

#### Acceptance Criteria

1. THE QuotationService SHALL support the following quotation states: Draft, Submitted, Approved, and Locked.
2. WHEN a quotation transitions to Locked state, THE App SHALL display a Lock_Badge on the quotation card and detail screen.
3. WHILE a quotation is in Locked state, THE App SHALL disable all edit controls on the quotation detail screen for all roles.
4. WHILE a user with the Admin role is authenticated, THE App SHALL display an "Unlock" button on a Locked quotation.
5. WHEN an Admin taps "Unlock" on a Locked quotation, THE QuotationService SHALL transition the quotation to Approved state and log the unlock action with a timestamp and Admin user ID.
6. WHEN a quotation is edited after being unlocked, THE QuotationService SHALL create a new version record preserving the previous Locked version.
7. THE App SHALL display the version history of a quotation, showing each version's state, timestamp, and the user who made the change.

---

### Requirement 9: Project Tracker

**User Story:** As an Engineer, I want to track the progress of solar installation projects through defined stages, so that the team has visibility into each project's status.

#### Acceptance Criteria

1. THE ProjectService SHALL support the following project stages in order: Survey, Quotation, Approval, Installation, and Completed.
2. THE App SHALL display a timeline UI for each project showing all stages, with the current stage highlighted and completed stages marked.
3. WHEN a user advances a project to the next stage, THE ProjectService SHALL update the project record in Supabase with the new stage and a timestamp.
4. WHEN a project reaches the Completed stage, THE ProjectService SHALL update the linked client's Status to Completed.
5. THE App SHALL display a list of all projects on the Projects screen, filterable by stage.
6. IF a project stage update fails, THEN THE ProjectService SHALL retain the pending update in the local Hive cache and retry when connectivity is restored.

---

### Requirement 10: Site Survey

**User Story:** As an Engineer, I want to record site survey data including photos and measurements, so that the team has accurate on-site information for each client.

#### Acceptance Criteria

1. THE SurveyService SHALL store survey records per client with the following fields: Photos (multiple), Measurements, Roof Notes, GPS Location (latitude and longitude), and Engineer Notes.
2. WHEN an Engineer submits a survey, THE SurveyService SHALL upload photos to Supabase Storage and persist the survey record to the `survey_reports` table.
3. THE App SHALL allow the Engineer to capture photos using the device camera via the `image_picker` package or select existing photos from the device gallery.
4. THE App SHALL capture the device's GPS coordinates automatically when a survey is created, with the Engineer able to override the coordinates manually.
5. WHEN a survey record is saved, THE SurveyService SHALL link the survey to the corresponding client record by client ID.
6. IF photo upload fails, THEN THE SurveyService SHALL store the photos locally in Hive and retry the upload when connectivity is restored.

---

### Requirement 11: Document Vault

**User Story:** As a user, I want to store and retrieve client documents in organized folders, so that all project-related files are accessible in one place.

#### Acceptance Criteria

1. THE DocumentService SHALL organize documents in per-client folders supporting the following document types: Quotations, Bills, Photos, and Certificates.
2. WHEN a user uploads a document, THE DocumentService SHALL store the file in Supabase Storage under the corresponding client folder and record the metadata in the `documents` table.
3. THE App SHALL allow users to upload documents using the `file_picker` package, supporting PDF, image (JPG, PNG), and common document formats.
4. WHEN a user taps a document in the vault, THE App SHALL open a preview or download the file to the device.
5. THE App SHALL display the document list for a client grouped by document type (Quotations, Bills, Photos, Certificates).
6. IF a document upload fails, THEN THE DocumentService SHALL display an error message and allow the user to retry the upload.

---

### Requirement 12: Settings

**User Story:** As an Admin, I want to configure company-wide settings, so that all generated documents and the app reflect accurate company information.

#### Acceptance Criteria

1. THE SettingsService SHALL store the following company settings: Company Logo, GST Number, Bank Details, Terms Template, Quotation Template, Signature Image, and Dark Mode preference.
2. WHEN an Admin uploads a Company Logo, THE SettingsService SHALL store the image in Supabase Storage and update the logo reference used by the PDF_Generator.
3. WHEN an Admin uploads a Signature Image, THE SettingsService SHALL store the image in Supabase Storage and update the signature reference used by the PDF_Generator.
4. WHEN an Admin saves updated Bank Details or Terms Template, THE SettingsService SHALL persist the changes to Supabase and update the local Hive cache immediately.
5. WHEN a user toggles Dark Mode in Settings, THE App SHALL switch the theme between light and dark mode and persist the preference using Hive.
6. THE App SHALL apply the Dark Mode preference on startup before rendering any screen to prevent a flash of incorrect theme.
7. IF the settings fetch from Supabase fails on startup, THEN THE SettingsService SHALL load the last cached settings from Hive.

---

### Requirement 13: App Theme and UI

**User Story:** As a user, I want a modern, professional UI, so that the app reflects the quality of the consultancy brand.

#### Acceptance Criteria

1. THE App SHALL use Material_3 as the design system for all UI components.
2. THE App SHALL use Dark Blue (`#0D1B2A`) as the primary color and Solar Orange (`#F4A261`) as the accent color throughout the UI.
3. THE App SHALL use White (`#FFFFFF`) as the default background color in light mode.
4. THE App SHALL use rounded cards with a border radius of 12dp or greater for all card components.
5. THE App SHALL support responsive layouts that adapt to both phone and tablet screen sizes.
6. WHEN the device screen width exceeds 600dp, THE App SHALL display a two-column layout for list screens (Clients, Quotations, Projects).
7. THE App SHALL support both light and dark themes, with the active theme determined by the user's Settings preference.

---

### Requirement 14: Offline Support and Data Sync

**User Story:** As a field engineer, I want the app to work with limited connectivity, so that I can record surveys and view data even without an internet connection.

#### Acceptance Criteria

1. THE App SHALL cache client records, quotations, and project data in Hive on successful Supabase fetch operations.
2. WHILE the device has no network connectivity, THE App SHALL display cached data from Hive and show a connectivity indicator in the UI.
3. WHEN network connectivity is restored, THE App SHALL automatically sync any pending writes (client updates, survey submissions, document uploads) from the local Hive queue to Supabase.
4. THE App SHALL display a sync status indicator showing the number of pending operations when offline writes are queued.
5. IF a sync conflict is detected (the same record was modified both locally and remotely), THEN THE App SHALL present the user with a conflict resolution prompt showing both versions.

---

### Requirement 15: Database Schema

**User Story:** As a developer, I want a well-defined database schema, so that all data is stored consistently and relationships are enforced.

#### Acceptance Criteria

1. THE Supabase database SHALL contain the following tables: `users`, `clients`, `quotations`, `quotation_items`, `projects`, `survey_reports`, `documents`, and `settings`.
2. THE `users` table SHALL store: user ID (UUID, primary key), email, role (Admin/Sales/Engineer/Accounts), full name, and created_at timestamp.
3. THE `clients` table SHALL store: client ID (UUID, primary key), user_id (foreign key to users), client name, phone, email, address, site, capacity, proposal number, status, created_at, and updated_at.
4. THE `quotations` table SHALL store: quotation ID (UUID, primary key), client_id (foreign key to clients), proposal number, status (Draft/Submitted/Approved/Locked), version number, all customer detail fields, all technical specification fields, all commercial fields, created_by (foreign key to users), created_at, and updated_at.
5. THE `quotation_items` table SHALL store: item ID (UUID, primary key), quotation_id (foreign key to quotations), SR NO, description, quantity, and unit price.
6. THE `projects` table SHALL store: project ID (UUID, primary key), client_id (foreign key to clients), quotation_id (foreign key to quotations), current stage, stage history (JSONB), created_at, and updated_at.
7. THE `survey_reports` table SHALL store: survey ID (UUID, primary key), client_id (foreign key to clients), engineer_id (foreign key to users), photo URLs (array), measurements, roof notes, GPS latitude, GPS longitude, engineer notes, created_at, and updated_at.
8. THE `documents` table SHALL store: document ID (UUID, primary key), client_id (foreign key to clients), document type (Quotation/Bill/Photo/Certificate), file URL, file name, uploaded_by (foreign key to users), created_at.
9. THE `settings` table SHALL store: settings ID (UUID, primary key), company logo URL, GST number, bank details (JSONB), terms template, quotation template, signature URL, and updated_at.
