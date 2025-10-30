#!/usr/bin/env bash
# Firebase Deployment Script for The Roofing App
# Usage: ./scripts/deploy-firebase.sh [staging|production]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default to staging if no argument provided
ENVIRONMENT=${1:-staging}

echo -e "${BLUE}🚀 Firebase Deployment Script${NC}"
echo -e "${BLUE}Environment: ${ENVIRONMENT}${NC}"
echo

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo -e "${RED}❌ Firebase CLI not found${NC}"
    echo "Install with: npm install -g firebase-tools"
    exit 1
fi

# Check if logged in to Firebase
if ! firebase projects:list &> /dev/null; then
    echo -e "${RED}❌ Not logged in to Firebase${NC}"
    echo "Run: firebase login"
    exit 1
fi

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠️  No .env file found${NC}"
    echo "Copy .env.example to .env and fill in your Supabase credentials"
    echo "Required variables:"
    echo "  REACT_APP_SUPABASE_URL=https://your-project.supabase.co"
    echo "  REACT_APP_SUPABASE_KEY=your-anon-key"
    echo
    read -p "Continue without .env? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Set Firebase project based on environment
if [ "$ENVIRONMENT" = "production" ]; then
    echo -e "${YELLOW}🔄 Switching to production Firebase project${NC}"
    # You'll need to update this with your production project ID
    firebase use production 2>/dev/null || {
        echo -e "${RED}❌ Production Firebase project not configured${NC}"
        echo "Run: firebase use --add"
        echo "Select your production project and alias it as 'production'"
        exit 1
    }
else
    echo -e "${YELLOW}🔄 Switching to staging Firebase project${NC}"
    firebase use default 2>/dev/null || {
        echo -e "${RED}❌ No Firebase project configured${NC}"
        echo "Run: firebase use --add"
        echo "Select your project and alias it as 'default'"
        exit 1
    }
fi

# Show current project
CURRENT_PROJECT=$(firebase use --current)
echo -e "${BLUE}📋 Current Firebase project: ${CURRENT_PROJECT}${NC}"
echo

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}📦 Installing dependencies...${NC}"
    npm install
    echo
fi

# Run linting
echo -e "${YELLOW}🧹 Running linter...${NC}"
npm run lint || {
    echo -e "${RED}❌ Linting failed${NC}"
    echo "Fix linting errors or run with --skip-lint"
    exit 1
}
echo -e "${GREEN}✅ Linting passed${NC}"
echo

# Build the application
echo -e "${YELLOW}🔨 Building application...${NC}"
npm run build || {
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
}
echo -e "${GREEN}✅ Build completed${NC}"
echo

# Check build output
if [ ! -d "dist" ]; then
    echo -e "${RED}❌ Build output directory 'dist' not found${NC}"
    exit 1
fi

BUILD_SIZE=$(du -sh dist | cut -f1)
echo -e "${BLUE}📊 Build size: ${BUILD_SIZE}${NC}"
echo

# Deploy to Firebase
echo -e "${YELLOW}🚀 Deploying to Firebase Hosting...${NC}"
firebase deploy --only hosting || {
    echo -e "${RED}❌ Deployment failed${NC}"
    exit 1
}

echo
echo -e "${GREEN}✅ Deployment successful!${NC}"

# Get the hosting URL
HOSTING_URL=$(firebase hosting:sites:list --json | jq -r '.[0].defaultUrl' 2>/dev/null || echo "")
if [ -n "$HOSTING_URL" ]; then
    echo -e "${BLUE}🌐 Your app is live at: ${HOSTING_URL}${NC}"
else
    echo -e "${BLUE}🌐 Check Firebase Console for your hosting URL${NC}"
fi

echo
echo -e "${GREEN}🎉 Deployment complete!${NC}"

# Environment-specific post-deployment messages
if [ "$ENVIRONMENT" = "production" ]; then
    echo
    echo -e "${YELLOW}📋 Production Deployment Checklist:${NC}"
    echo "  1. Test Google OAuth login flow"
    echo "  2. Verify custom domain DNS (if configured)"
    echo "  3. Check Supabase auth redirect URLs include production domain"
    echo "  4. Test customer/quote/invoice CRUD operations"
    echo "  5. Verify PDF generation works"
    echo "  6. Test email sending (if enabled)"
    echo "  7. Monitor Firebase Console for errors"
else
    echo
    echo -e "${YELLOW}📋 Staging Deployment Notes:${NC}"
    echo "  • This is your staging environment for testing"
    echo "  • Share the URL with stakeholders for approval"
    echo "  • Test all critical user flows before production deployment"
    echo "  • Deploy to production with: ./scripts/deploy-firebase.sh production"
fi

echo
echo -e "${BLUE}📚 Useful commands:${NC}"
echo "  firebase hosting:sites:list    # List hosting sites"
echo "  firebase hosting:channel:list  # List hosting channels"
echo "  firebase hosting:rollback      # Rollback to previous version"
echo "  firebase open hosting:site     # Open site in browser"