# Paul Roofs Integration & Deployment Guide

**Project:** The Roofing App for paulroofs.com  
**Date:** October 22, 2025  
**Status:** Pre-deployment Planning

---

## Executive Summary

We're integrating a production-ready React/TypeScript web application for managing roofing operations (customers, quotes, invoices, jobs, leads) into the paulroofs.com web presence.

**Tech Stack:**
- Frontend: React 18 + TypeScript + Vite
- Backend: Supabase (Postgres + Auth + Storage)
- UI: Tailwind CSS + Radix UI + shadcn/ui
- Features: PDF generation, Google APIs (Gmail/Drive/Calendar), Dashboard analytics

**Deployment Timeline:**
- Staging: 1–2 business days after hosting confirmation
- Production: 0–1 day after staging approval

---

## Proposed Deployment Architecture

### Option A: Firebase Hosting (Recommended)
**Why:** Automatic SSL, global CDN, zero-config SPA routing, free tier generous  
**Best for:** Fast deployment, minimal ops overhead

```
User → Firebase CDN → Static React App (dist/)
                          ↓
                    Supabase API (auth, data, storage)
                          ↓
                    Google APIs (optional: Gmail, Drive, Calendar)
```

**Deployment Steps:**
1. Build app: `npm run build` → creates `dist/` folder
2. Deploy to Firebase: `firebase deploy --only hosting`
3. Add custom domain via Firebase Console
4. Update DNS records (provided below)

### Option B: Docker + Nginx on Your Server
**Why:** Full control, can colocate with other services  
**Best for:** Existing VPS/container infrastructure

```
User → Your Server (Nginx:80) → Static React App (dist/)
                                      ↓
                                Supabase API (auth, data, storage)
                                      ↓
                                Google APIs (optional)
```

**Deployment Steps:**
1. Build Docker image: `docker build -t paulroofs-app .`
2. Deploy to server via registry or SSH
3. Run container: `docker run -p 80:80 paulroofs-app`
4. Update DNS A-record to server IP

---

## Environment Configuration

### Required Environment Variables
All variables are read at **build time** via Vite (`envPrefix: 'REACT_APP_'`):

```bash
# Copy .env.example to .env and fill in values

# Supabase Configuration (required)
REACT_APP_SUPABASE_URL=https://your-project.supabase.co
REACT_APP_SUPABASE_KEY=your-anon-public-key
```

**Where to get Supabase credentials:**
1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Select your project (or create new)
3. Settings → API
4. Copy "Project URL" → `REACT_APP_SUPABASE_URL`
5. Copy "anon public" key → `REACT_APP_SUPABASE_KEY`

**Security Note:** The anon key is safe to expose publicly; Supabase Row Level Security (RLS) enforces access control.

---

## Supabase Setup Checklist

### 1. Database Schema
The app expects these tables (see `src/lib/db-tables.ts`):
- `customer` – Customer records
- `customer_type` – Customer types/categories
- `invoice` – Invoices
- `invoice_line_service` – Invoice line items
- `invoice_payment` – Payment records
- `invoice_status` – Invoice status lookup
- `quote` – Quotes
- `quote_line_item` – Quote line items
- `quote_request` – Inbound quote requests (from website)
- `quote_request_status` – Status lookup
- `quote_status` – Quote status lookup
- `service` – Available services/products
- `projects` – Job/project tracking

**Action Required:** Import schema from existing project or provide SQL migrations.

### 2. Authentication Setup
- **Method:** Google OAuth (already configured in `src/hooks/useAuth.tsx`)
- **Required Scopes:**
  ```
  https://www.googleapis.com/auth/gmail.send
  https://www.googleapis.com/auth/gmail.readonly
  https://www.googleapis.com/auth/drive.file
  https://www.googleapis.com/auth/calendar.events
  ```

**Supabase Configuration Steps:**
1. Supabase Dashboard → Authentication → Providers → Google
2. Enable Google provider
3. Add OAuth Client ID/Secret from Google Cloud Console
4. Set Redirect URL to: `https://your-project.supabase.co/auth/v1/callback`
5. Update "Site URL" to your production domain (e.g., `https://app.paulroofs.com`)
6. Add production domain to "Redirect URLs" list

### 3. Google Cloud Console Setup (if using Google APIs)
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create or select project
3. Enable APIs:
   - Gmail API
   - Google Drive API
   - Google Calendar API
4. Configure OAuth Consent Screen
5. Add Authorized Redirect URIs:
   - `https://your-project.supabase.co/auth/v1/callback`
   - `https://app.paulroofs.com` (production)
   - `https://paulroofs.com` (if using root domain)

---

## DNS Configuration

### Staging Environment: `app.paulroofs.com`

#### For Firebase Hosting:
```
Type: A
Name: app
Value: 151.101.1.195, 151.101.65.195
TTL: 3600

Type: TXT
Name: app
Value: (Firebase will provide verification string)
TTL: 3600
```
**Note:** Firebase Console will provide exact IP addresses when you add custom domain.

#### For Docker/Server Hosting:
```
Type: A
Name: app
Value: [YOUR_SERVER_IP]
TTL: 3600
```

### Production Environment: `paulroofs.com`

#### Option 1: Root Domain with Firebase
```
Type: A
Name: @
Value: 151.101.1.195, 151.101.65.195
TTL: 3600

Type: A
Name: www
Value: 151.101.1.195, 151.101.65.195
TTL: 3600
```

#### Option 2: Root Domain with Your Server
```
Type: A
Name: @
Value: [YOUR_SERVER_IP]
TTL: 3600

Type: CNAME
Name: www
Value: paulroofs.com
TTL: 3600
```

**Propagation Time:** 5 minutes to 48 hours (typically 1–4 hours)

---

## Pre-Deployment Checklist

### Infrastructure & Access
- [ ] Choose hosting: Firebase or Docker/Server
- [ ] Confirm DNS provider and access (GoDaddy, Cloudflare, Route 53, etc.)
- [ ] Decide staging subdomain: `app.paulroofs.com` (recommended)
- [ ] Decide production placement: root (`paulroofs.com`) or subdomain (`app.paulroofs.com`)
- [ ] If Docker: confirm server OS, container runtime, reverse proxy setup

### Supabase Backend
- [ ] Create Supabase project (or provide existing credentials)
- [ ] Import database schema (tables listed above)
- [ ] Enable Google OAuth in Supabase Auth settings
- [ ] Set Site URL to production domain
- [ ] Add redirect URLs for all domains (staging + production)
- [ ] Copy `REACT_APP_SUPABASE_URL` and `REACT_APP_SUPABASE_KEY`

### Google OAuth (Optional but Recommended)
- [ ] Create Google Cloud project
- [ ] Enable Gmail API, Drive API, Calendar API
- [ ] Configure OAuth consent screen
- [ ] Add authorized redirect URIs (Supabase callback URL)
- [ ] Note: No additional env vars needed—Supabase manages Google tokens

### Local Build Verification
- [ ] Create `.env` file with Supabase credentials
- [ ] Run `npm install` (already done ✓)
- [ ] Run `npm run build` (already done ✓)
- [ ] Run `npm run lint` (already done ✓)
- [ ] Verify `dist/` folder created successfully

### Post-Deployment Validation
- [ ] App loads at staging URL (HTTPS)
- [ ] Google OAuth login flow works
- [ ] Can create/view customers
- [ ] Can create/view quotes
- [ ] Can create/view invoices
- [ ] PDF generation works (quotes/invoices)
- [ ] Email sending works (if enabled)
- [ ] No console errors in browser DevTools
- [ ] Mobile responsive (test on phone/tablet)

---

## Integration with Existing Systems

### Current Integration Points
The app currently integrates with:
1. **Supabase Postgres** – All data storage
2. **Supabase Auth** – Google OAuth
3. **Google Gmail API** – Send invoices/quotes via email
4. **Google Drive API** – Optional document uploads
5. **Google Calendar API** – Optional appointment scheduling

### Custom Backend Integration (Alternative)
If you prefer to use your own API instead of Supabase:

**Files to modify:**
- `src/lib/supabase-client.ts` – Swap Supabase client with your API client
- `src/services/api/*.ts` – Update service methods to call your endpoints
- `src/hooks/useAuth.tsx` – Replace Supabase auth with your auth flow

**API Endpoints Needed:**
```
Customers:
  GET    /api/customers          - List customers
  GET    /api/customers/:id      - Get customer details
  POST   /api/customers          - Create customer
  PUT    /api/customers/:id      - Update customer
  DELETE /api/customers/:id      - Delete customer

Quotes:
  GET    /api/quotes             - List quotes
  GET    /api/quotes/:id         - Get quote details
  POST   /api/quotes             - Create quote
  PUT    /api/quotes/:id         - Update quote
  DELETE /api/quotes/:id         - Delete quote

Invoices:
  GET    /api/invoices           - List invoices
  GET    /api/invoices/:id       - Get invoice details
  POST   /api/invoices           - Create invoice
  PUT    /api/invoices/:id       - Update invoice
  DELETE /api/invoices/:id       - Delete invoice
  POST   /api/invoices/:id/pay   - Record payment

Services:
  GET    /api/services           - List available services/products

Auth:
  POST   /api/auth/login         - Login
  POST   /api/auth/logout        - Logout
  GET    /api/auth/session       - Get current session
```

**Note:** If custom API integration is desired, we can create an adapter layer in ~1 day.

---

## Deployment Commands

### Firebase Hosting

```powershell
# One-time setup
npm install -g firebase-tools
firebase login

# Switch to your Firebase project (not the template's project)
firebase use --add
# Select your project from list, alias it as "default"

# Build and deploy
npm run build
firebase deploy --only hosting

# View live site
firebase open hosting:site
```

### Docker Deployment

```powershell
# Build image
docker build -t paulroofs-app:latest .

# Test locally
docker run --rm -p 8080:80 --name paulroofs-test paulroofs-app:latest
# Open http://localhost:8080

# Push to registry (if using one)
docker tag paulroofs-app:latest your-registry.com/paulroofs-app:latest
docker push your-registry.com/paulroofs-app:latest

# On server (via SSH):
docker pull your-registry.com/paulroofs-app:latest
docker stop paulroofs-app || true
docker rm paulroofs-app || true
docker run -d -p 80:80 --name paulroofs-app --restart unless-stopped \
  your-registry.com/paulroofs-app:latest
```

---

## Rollback Plan

### Firebase Hosting
```powershell
# List deployment history
firebase hosting:channel:list

# Rollback to previous version
firebase hosting:rollback
```

### Docker
```powershell
# Keep previous image tagged
docker tag paulroofs-app:latest paulroofs-app:backup

# Rollback
docker stop paulroofs-app
docker rm paulroofs-app
docker run -d -p 80:80 --name paulroofs-app paulroofs-app:backup
```

---

## Support & Troubleshooting

### Common Issues

**Issue:** "Failed to fetch" errors on API calls  
**Solution:** Check CORS in Supabase Dashboard → Settings → API → CORS. Add your domain.

**Issue:** Google OAuth redirect fails  
**Solution:** Verify redirect URLs in both Supabase and Google Cloud Console match exactly.

**Issue:** Build fails with TypeScript errors  
**Solution:** Run `npm run lint` to see errors; fix or suppress with `// @ts-expect-error`.

**Issue:** Environment variables not working  
**Solution:** Ensure `.env` is in project root and vars start with `REACT_APP_`. Restart dev server or rebuild.

**Issue:** PDF generation fails  
**Solution:** Check browser console for `@react-pdf/renderer` errors. Verify data structure matches PDF templates.

### Monitoring Recommendations
- **Supabase Dashboard:** Monitor database usage, auth errors, API calls
- **Firebase Console:** Track hosting traffic, functions (if added later)
- **Browser DevTools:** Check Network tab for failed requests
- **Sentry/LogRocket:** Consider adding for production error tracking

---

## Next Steps

### Immediate Actions Required
1. **Review this document** and confirm hosting preference (Firebase vs Docker)
2. **Provide DNS access** or confirm who will add records
3. **Set up Supabase project** (or provide existing credentials)
4. **Create `.env` file** with Supabase credentials
5. **Choose domain strategy:** `app.paulroofs.com` vs `paulroofs.com`

### After Confirmation
1. Configure Firebase project (if Firebase hosting)
2. Add staging DNS records
3. Deploy to staging
4. Validate all features
5. Add production DNS records
6. Deploy to production
7. Final QA and handoff

---

## Contact & Questions

For questions about this deployment, reply with:
- Specific question or blocker
- Hosting preference (if not decided)
- DNS provider name
- Timeline constraints

**Files in this repo:**
- `/.env.example` – Template for environment variables
- `/firebase.json` – Firebase Hosting config (SPA rewrites)
- `/Dockerfile` – Production Docker image config
- `/docs/firebase-deployment.md` – Detailed Firebase guide
- `/docs/google-services-integration.md` – Google APIs setup

---

**Document Version:** 1.0  
**Last Updated:** October 22, 2025  
**Prepared by:** GitHub Copilot  
**Project Repository:** `roofing-webapp-main`
