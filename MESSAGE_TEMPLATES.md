# Quick Message Templates for paulroofs.com Team

## Template 1: Full Email (Detailed)

**Subject:** Integrating roofing web app into paulroofs.com — deployment plan & info needed

Hi [Team/Contact Name],

We're integrating a new web application into our paulroofs.com presence to manage customers, quotes, invoices, jobs, and leads. I need your help with hosting and DNS to get this deployed smoothly.

### What We're Integrating
- **App:** React/TypeScript SPA (Vite build) for roofing business operations
- **Backend:** Supabase (Postgres database + Google OAuth authentication)
- **Optional Features:** Email via Gmail API, document storage via Google Drive, calendar scheduling
- **Build Output:** Static files in `/dist` folder (standard SPA with client-side routing)

### Proposed Rollout Plan
- **Staging:** `app.paulroofs.com` (for testing and approval)
- **Production:** Either `paulroofs.com` (root domain) or keep `app.paulroofs.com` and link from main site
- **Zero-downtime:** SPA routing handled automatically (all routes rewrite to /index.html)

### Hosting Options (Need Your Input)

**Option A: Firebase Hosting** (Recommended)
- Pros: Automatic SSL, global CDN, zero ops overhead, generous free tier
- Deployment: `firebase deploy` after build
- DNS: CNAME/A records to Firebase IPs (provided by Firebase Console)

**Option B: Docker + Nginx on Your Server**
- Pros: Full control, can colocate with other services
- Deployment: Docker image via registry or SSH
- DNS: A-record to your server IP

### Information We Need From You

1. **DNS Provider & Access**
   - Who manages DNS? (GoDaddy, Cloudflare, Route 53, Namecheap, etc.)
   - Can you add DNS records, or should we coordinate with your provider?

2. **Current paulroofs.com Stack**
   - What's the main site running on? (WordPress, static site, custom CMS, etc.)
   - Any CDN or reverse proxy in front? (Cloudflare, nginx, etc.)
   - Are there any CORS/security constraints we should know about?

3. **Hosting Preference**
   - Firebase Hosting (fast to deploy) or your server (Docker/Nginx)?
   - If server: OS, container runtime, reverse proxy setup

4. **Domain Placement Decision**
   - Staging at `app.paulroofs.com` (confirmed)
   - Production: use root domain `paulroofs.com` or keep app on subdomain `app.paulroofs.com`?

5. **If Using Custom Backend (Optional)**
   - Do you have an existing API for customers/quotes/invoices we should integrate with?
   - If yes: API base URL, authentication method, available endpoints

### DNS Changes We'll Request (After Hosting Confirmed)

**For Staging (app.paulroofs.com):**
- Firebase: `A` records to Firebase IPs + `TXT` for verification
- Server: `A` record to your server IP

**For Production (paulroofs.com):**
- Firebase: `A` records for apex domain, `A` or `CNAME` for www
- Server: `A` record for apex, `CNAME` for www

*Exact records will be provided once hosting is chosen.*

### Timeline
- **Staging deployment:** 1–2 business days after hosting/DNS confirmation
- **Production cutover:** 0–1 day after staging approval
- **Total:** ~2–3 business days from go-ahead to production

### Environment & Security
- **Build-time variables:** `REACT_APP_SUPABASE_URL` and `REACT_APP_SUPABASE_KEY` (public anon key, safe to expose)
- **OAuth redirects:** Will add final domain(s) to Supabase and Google Cloud Console
- **SPA routing:** All routes rewrite to `/index.html` (already configured in firebase.json and Dockerfile)
- **SSL/HTTPS:** Automatic with Firebase; you'll handle if self-hosting

### Next Steps
Please confirm:
1. Hosting preference: Firebase or your server?
2. DNS provider name and who will add records
3. Production domain preference: root (`paulroofs.com`) or subdomain (`app.paulroofs.com`)?
4. Any custom backend integration needed?

Once I have this information, I'll:
- Provide exact DNS records
- Deploy to staging environment
- Walk through final production cutover

**Attached:** `DEPLOYMENT_GUIDE.md` with full technical details, checklists, and deployment commands.

Thanks,  
[Your Name]  
[Title/Role]  
[Email/Phone]

---

## Template 2: Short Version (Email/Slack)

**Subject:** paulroofs.com app integration — hosting & DNS info needed

Hi [Team],

We're deploying a new React app for customers/quotes/invoices to paulroofs.com. Need your help with hosting and DNS.

**Plan:**
- Staging at `app.paulroofs.com`
- Production at `paulroofs.com` (or keep app subdomain)
- Host on Firebase (recommended) or your server via Docker

**Need from you:**
1. DNS provider and who can add records
2. Hosting preference (Firebase vs your server)
3. Production domain choice (root vs app subdomain)
4. Current site stack (WordPress/static/CMS)

**Timeline:** Staging live in 1–2 days after confirmation; production shortly after approval.

Once you confirm, I'll send exact DNS records and deploy staging.

See attached `DEPLOYMENT_GUIDE.md` for full details.

Thanks!

---

## Template 3: Ultra-Short (Slack DM)

Hey [Name] 👋

Integrating a new app into paulroofs.com. Need quick answers:

1. DNS: who manages it? (GoDaddy/Cloudflare/etc)
2. Hosting: Firebase (recommended) or your server?
3. Domain: root (paulroofs.com) or subdomain (app.paulroofs.com)?

Deploy plan: app.paulroofs.com → test → production
Timeline: 2–3 days total

Attached deployment guide with full details 📎

---

## Template 4: If They Ask "What Will This Do?"

**The app provides:**
- Customer database and management
- Quote generation with PDF export
- Invoice creation and payment tracking
- Job/project tracking
- Lead management from website inquiries
- Dashboard with business analytics
- Email quotes/invoices directly via Gmail
- Google Calendar integration for appointments
- Secure Google OAuth login (no passwords to manage)

**What users see:**
1. Visit app.paulroofs.com (or paulroofs.com)
2. Click "Sign in with Google"
3. Access dashboard with customers, quotes, invoices, jobs, leads
4. Create/edit/send documents
5. Track business metrics in real-time

**What you (admin) get:**
- Centralized customer data
- Professional PDF quotes/invoices
- Payment tracking
- Lead conversion tracking
- Email automation for quotes/invoices
- Mobile-responsive (works on phone/tablet)
- Secure, role-based access

---

## Template 5: Technical Details Only (For DevOps/IT)

**Integration Specs:**

```yaml
App Type: React 18.3 SPA (Vite 6.x build)
Output: Static files in /dist (index.html + chunked JS/CSS)
Routing: Client-side (requires SPA rewrite: /* → /index.html)
Build Size: ~2.5 MB gzipped (split into chunks)
Runtime: Static serving only (no Node.js server required)

Backend: Supabase (Postgres + Auth + Storage)
External APIs: Gmail API, Drive API, Calendar API (via OAuth)

Deployment Options:
1. Firebase Hosting
   - Config: firebase.json (already included)
   - Deploy: firebase deploy --only hosting
   - DNS: A records to Firebase IPs (auto-SSL)

2. Docker + Nginx
   - Dockerfile: multi-stage (node:latest → ubuntu + nginx)
   - Port: 80
   - nginx.conf: SPA rewrite included (etc/nginx.conf)
   - Deploy: docker build + docker run or registry push

Environment Variables (Build-time, Vite):
- REACT_APP_SUPABASE_URL (e.g., https://xxx.supabase.co)
- REACT_APP_SUPABASE_KEY (anon public key, safe to expose)

DNS Requirements:
- Staging: app.paulroofs.com → A/CNAME per host
- Production: paulroofs.com + www → A/CNAME per host
- TTL: 3600 recommended for flexibility

SPA Rewrites:
- Firebase: configured in firebase.json (rewrites: [{ source: "**", destination: "/index.html" }])
- Nginx: configured in etc/nginx.conf (try_files $uri /index.html)

Security:
- No server-side secrets in build
- Auth via Supabase (JWT tokens in localStorage)
- CORS: Configure in Supabase dashboard for production domain
- CSP: None required (no inline scripts/styles by default)

Monitoring:
- Supabase Dashboard: DB usage, auth metrics, API calls
- Firebase Console: Hosting traffic, errors (if Firebase)
- Browser DevTools: Network tab for API debugging
```

**Build Test Results:**
- ✅ `npm install` – 748 packages, 0 vulnerabilities
- ✅ `npm run build` – Success, 2.5 MB dist output
- ✅ `npm run lint` – Clean, no errors

**Next:** Confirm hosting + DNS provider → deploy staging → validate → production cutover

---

## Which Template to Use?

- **New to web dev / non-technical team:** Use Template 1 (Full Email)
- **Experienced but need context:** Use Template 2 (Short Version)
- **Quick turnaround / familiar team:** Use Template 3 (Ultra-Short)
- **Stakeholders asking "why?":** Use Template 4 (What Will This Do)
- **DevOps/IT team:** Use Template 5 (Technical Specs)

---

## After Sending, Expect These Questions:

**Q:** How much will Firebase cost?  
**A:** Generous free tier (10 GB storage, 360 MB/day transfer). Typical usage for small roofing company: $0–5/month.

**Q:** Can we keep our existing WordPress site?  
**A:** Yes. If production is at `paulroofs.com`, we can move WordPress to `www.paulroofs.com` or vice versa. Or keep app at `app.paulroofs.com` and link from main site.

**Q:** What if we want to change hosting later?  
**A:** Easy. Build output (`/dist`) is standard static files. Can move to Netlify, Vercel, S3, Cloudflare Pages, or any web server.

**Q:** Do we need to migrate data?  
**A:** Only if you have existing customer/quote/invoice data. Supabase has import tools, or we can write migration scripts.

**Q:** How do we update the app?  
**A:** Run `npm run build` + `firebase deploy` (or `docker build` + push to registry). Takes ~2 minutes.

**Q:** What about backups?  
**A:** Supabase has automatic daily backups (7 days free tier, 30+ days paid). Can also export DB on-demand.

---

**Files to attach when sending:**
- `DEPLOYMENT_GUIDE.md` – Full technical guide
- `.env.example` – Environment variable template

**Ready to send!** Pick the template that fits your audience and fire away. 🚀
