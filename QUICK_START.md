# Website Integration Quick Start

This is your fastest path from downloading this repo to having it live on paulroofs.com.

## ⚡ Quick Setup (5 minutes)

### 1. Environment Setup
```bash
# Copy environment template
cp .env.example .env

# Fill in these two required values in .env:
# REACT_APP_SUPABASE_URL=https://your-project.supabase.co
# REACT_APP_SUPABASE_KEY=your-anon-key
```

### 2. Test Local Build
```bash
npm install
npm run build
npm run preview  # Test the built app locally
```

### 3. Choose Deployment Method

**Option A: Firebase (Recommended)**
```bash
# Windows
scripts\deploy-firebase.bat staging

# Mac/Linux
./scripts/deploy-firebase.sh staging
```

**Option B: Docker**
```bash
# Windows/Mac/Linux
./scripts/deploy-docker.sh deploy
```

## 🎯 Integration Paths

### Path 1: New Supabase Project (Recommended)
**Time: 15 minutes**

1. Create Supabase project → [Guide](docs/supabase-setup.md)
2. Run database schema → Copy `database/schema.sql` to Supabase SQL Editor
3. Configure Google OAuth → [Step-by-step guide](docs/supabase-setup.md#step-4-configure-authentication)
4. Deploy to staging → Run deployment script
5. Test & approve → Deploy to production

### Path 2: Connect Your Existing Backend
**Time: 30-60 minutes**

If you already have a customer/invoice API:

1. **Map your endpoints** to our data structure:
   ```javascript
   // Example: Update src/services/api/customer-service.ts
   const API_BASE = 'https://your-api.com/v1';
   
   export const getCustomers = async () => {
     const response = await fetch(`${API_BASE}/customers`);
     return response.json();
   };
   ```

2. **Update authentication** in `src/hooks/useAuth.tsx`
3. **Test integration** locally
4. **Deploy** using either method above

### Path 3: Hybrid Approach
**Time: 20 minutes**

Keep Supabase for the app, integrate specific features with your systems:

1. **Use Supabase** for main app data (fast setup)
2. **Add webhook/API calls** to sync with your existing systems
3. **Connect email** to your SMTP instead of Gmail API
4. **Customize branding** and domain

## 🚀 Deployment Commands

All scripts are in the `scripts/` folder:

### Firebase Hosting
```bash
# Windows
scripts\deploy-firebase.bat staging     # Deploy to staging
scripts\deploy-firebase.bat production  # Deploy to production

# Mac/Linux  
./scripts/deploy-firebase.sh staging
./scripts/deploy-firebase.sh production
```

### Docker Deployment
```bash
./scripts/deploy-docker.sh build    # Build image
./scripts/deploy-docker.sh run      # Run locally
./scripts/deploy-docker.sh deploy   # Build + run
./scripts/deploy-docker.sh status   # Check status
./scripts/deploy-docker.sh logs     # View logs
```

## 📋 Pre-Flight Checklist

Before contacting your website team, verify:

- [ ] App builds locally (`npm run build`)
- [ ] `.env` file configured with Supabase credentials
- [ ] Firebase CLI installed (`npm install -g firebase-tools`)
- [ ] Docker installed (if using Docker deployment)
- [ ] Domain decision made (app.paulroofs.com vs paulroofs.com)

## 🌐 DNS Setup

Once you know your hosting choice, your website team needs:

### For Firebase Hosting
```
# Staging (app.paulroofs.com)
Type: A
Name: app  
Value: [Firebase will provide IPs]

# Production (paulroofs.com)
Type: A
Name: @
Value: [Firebase will provide IPs]
```

### For Docker/Server Hosting  
```
# Staging (app.paulroofs.com)
Type: A
Name: app
Value: [Your server IP]

# Production (paulroofs.com)  
Type: A
Name: @
Value: [Your server IP]
```

## 🔧 Customization Points

Before deploying, you might want to customize:

### Branding
- **Logo**: Replace files in `public/images/`
- **Colors**: Update `src/index.css` and `tailwind.config.js`
- **Company name**: Search/replace "Rios Roofing" in components

### Features
- **Email provider**: Switch from Gmail API to your SMTP in `src/services/google-service.ts`
- **PDF templates**: Modify `src/components/pdf-render/`
- **Dashboard metrics**: Update `src/services/api/report-service.ts`

### Integrations
- **CRM sync**: Add webhook calls in form submission handlers
- **Website leads**: Connect `quote_request` table to your contact forms
- **Accounting software**: Add export functions in invoice components

## 📞 Getting Help

**Stuck on deployment?**
- Check `DEPLOYMENT_GUIDE.md` for detailed steps
- Run `npm run lint` to catch code issues
- Check browser console for errors

**Need custom integration?**
- Review `src/services/api/` folder for data service patterns
- See `src/hooks/` for React integration patterns
- Check `src/types/` for TypeScript interfaces

**Website team questions?**
- Use templates in `MESSAGE_TEMPLATES.md`
- Share `DEPLOYMENT_GUIDE.md` for technical details
- Reference `docs/supabase-setup.md` for backend setup

## 🎉 Success Criteria

Your integration is complete when:

- [ ] App loads at your staging URL (HTTPS)
- [ ] Google login works
- [ ] Can create/edit customers, quotes, invoices
- [ ] PDF generation works
- [ ] Email sending works (if enabled)
- [ ] Mobile responsive (test on phone)
- [ ] No console errors in browser DevTools

## 📈 Next Steps After Launch

1. **Monitor usage** in Supabase Dashboard
2. **Set up backups** for production data
3. **Add team members** to Supabase project
4. **Configure alerts** for errors or usage limits
5. **Plan feature additions** (calendar sync, advanced reporting, etc.)

---

**Questions?** Reference the full `DEPLOYMENT_GUIDE.md` or the message templates in `MESSAGE_TEMPLATES.md` to communicate with your website team.

**Ready to deploy?** Pick your path above and run the deployment scripts! 🚀