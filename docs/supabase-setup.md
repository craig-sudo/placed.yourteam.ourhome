# Supabase Project Setup Guide

This guide walks through setting up a new Supabase project for The Roofing App.

## Step 1: Create Supabase Project

1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Click "New project"
3. Choose your organization
4. Fill in project details:
   - **Name**: `paulroofs-app` (or your preferred name)
   - **Database Password**: Use a strong password (save this!)
   - **Region**: Choose closest to your users
   - **Pricing Plan**: Start with Free tier
5. Click "Create new project"
6. Wait 2-3 minutes for project setup

## Step 2: Get Connection Details

Once your project is ready:

1. Go to **Settings** → **API**
2. Copy these values to your `.env` file:
   ```bash
   REACT_APP_SUPABASE_URL=https://your-project-id.supabase.co
   REACT_APP_SUPABASE_KEY=your-anon-public-key
   ```

## Step 3: Set Up Database Schema

1. Go to **SQL Editor** in your Supabase dashboard
2. Click "New query"
3. Copy and paste the contents of `database/schema.sql`
4. Click "Run" to execute the SQL
5. Verify tables were created in **Table Editor**

## Step 4: Configure Authentication

### Enable Google OAuth
1. Go to **Authentication** → **Providers**
2. Find "Google" and click to configure
3. Set "Enabled" to ON
4. You'll need to set up Google OAuth credentials:

### Google Cloud Console Setup
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project or select existing
3. Enable APIs:
   - Go to **APIs & Services** → **Library**
   - Enable: Gmail API, Google Drive API, Google Calendar API (optional but recommended)
4. Configure OAuth consent screen:
   - **APIs & Services** → **OAuth consent screen**
   - Choose "External" for user type
   - Fill in app name: "Paul Roofs App"
   - Add your email as developer contact
   - Add scopes:
     - `https://www.googleapis.com/auth/gmail.send`
     - `https://www.googleapis.com/auth/gmail.readonly`
     - `https://www.googleapis.com/auth/drive.file`
     - `https://www.googleapis.com/auth/calendar.events`
5. Create OAuth credentials:
   - **APIs & Services** → **Credentials**
   - Click "Create Credentials" → "OAuth 2.0 Client IDs"
   - Application type: "Web application"
   - Name: "Paul Roofs App"
   - Authorized redirect URIs: `https://your-project-id.supabase.co/auth/v1/callback`
   - Copy Client ID and Client Secret

### Back to Supabase
1. In **Authentication** → **Providers** → **Google**:
   - **Client ID**: Paste from Google Cloud Console
   - **Client Secret**: Paste from Google Cloud Console
   - Click "Save"

## Step 5: Configure Site URLs

1. Go to **Authentication** → **Settings**
2. Set **Site URL** to your production domain:
   - Staging: `https://app.paulroofs.com`
   - Production: `https://paulroofs.com` (or keep subdomain)
3. Add **Additional Redirect URLs**:
   - `http://localhost:5173` (for local development)
   - `https://app.paulroofs.com` (staging)
   - `https://paulroofs.com` (production, if using root domain)
4. Click "Save"

## Step 6: Set Up Row Level Security (Optional but Recommended)

Once you have users, you can enable RLS for data security:

1. Go to **Authentication** → **Policies**
2. For each table, create policies:
   ```sql
   -- Example policy for customer table
   ALTER TABLE customer ENABLE ROW LEVEL SECURITY;
   
   CREATE POLICY "Users can view own customers" ON customer
   FOR SELECT USING (auth.uid() IS NOT NULL);
   
   CREATE POLICY "Users can insert own customers" ON customer  
   FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
   
   CREATE POLICY "Users can update own customers" ON customer
   FOR UPDATE USING (auth.uid() IS NOT NULL);
   ```

## Step 7: Test Connection

1. Copy `.env.example` to `.env`
2. Fill in your Supabase URL and anon key
3. Run the app locally:
   ```bash
   npm install
   npm run start
   ```
4. Try to sign in with Google
5. Check if you can create a customer record

## Step 8: Production Considerations

### Database Backups
- Free tier: 7 days of backups
- Paid tiers: 30+ days
- Consider setting up additional backup automation

### Monitoring
- Set up email alerts in **Settings** → **Notifications**
- Monitor usage in **Settings** → **Usage**

### Performance
- Add database indexes for frequently queried columns (already included in schema.sql)
- Consider upgrading to paid tier for better performance if needed

### Security
- Enable RLS on all tables in production
- Review and tighten authentication policies
- Consider enabling 2FA for your Supabase account

## Troubleshooting

### Common Issues

**"Invalid API key"**
- Double-check the anon key in your .env file
- Make sure you're using the anon key, not the service role key

**Google OAuth not working**
- Verify redirect URLs match exactly in both Google Cloud Console and Supabase
- Check that Google APIs are enabled
- Ensure OAuth consent screen is configured

**Database connection errors**
- Check if your IP is allowed (Supabase allows all IPs by default)
- Verify the database URL is correct
- Try connecting from Supabase SQL Editor first

**"Failed to fetch" errors**
- Check CORS settings in **Settings** → **API**
- Add your domain to allowed origins

### Getting Help

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Discord](https://discord.supabase.com)
- [Google Cloud Console Help](https://cloud.google.com/support)

## Next Steps

Once Supabase is configured:
1. Deploy your app (Firebase or Docker)
2. Update production redirect URLs
3. Test all features end-to-end
4. Set up monitoring and alerts
5. Consider enabling database backups for production