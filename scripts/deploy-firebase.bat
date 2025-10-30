@echo off
REM Firebase Deployment Script for Windows (PowerShell/CMD)
REM Usage: scripts\deploy-firebase.bat [staging|production]

setlocal enabledelayedexpansion

REM Default to staging if no argument provided
set ENVIRONMENT=%1
if "%ENVIRONMENT%"=="" set ENVIRONMENT=staging

echo 🚀 Firebase Deployment Script
echo Environment: %ENVIRONMENT%
echo.

REM Check if Firebase CLI is installed
firebase --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Firebase CLI not found
    echo Install with: npm install -g firebase-tools
    exit /b 1
)

REM Check if logged in to Firebase
firebase projects:list >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Not logged in to Firebase
    echo Run: firebase login
    exit /b 1
)

REM Check if .env file exists
if not exist ".env" (
    echo ⚠️  No .env file found
    echo Copy .env.example to .env and fill in your Supabase credentials
    echo Required variables:
    echo   REACT_APP_SUPABASE_URL=https://your-project.supabase.co
    echo   REACT_APP_SUPABASE_KEY=your-anon-key
    echo.
    set /p continue="Continue without .env? (y/N) "
    if /i not "!continue!"=="y" exit /b 1
)

REM Set Firebase project based on environment
if "%ENVIRONMENT%"=="production" (
    echo 🔄 Switching to production Firebase project
    firebase use production >nul 2>&1
    if %errorlevel% neq 0 (
        echo ❌ Production Firebase project not configured
        echo Run: firebase use --add
        echo Select your production project and alias it as 'production'
        exit /b 1
    )
) else (
    echo 🔄 Switching to staging Firebase project
    firebase use default >nul 2>&1
    if %errorlevel% neq 0 (
        echo ❌ No Firebase project configured
        echo Run: firebase use --add
        echo Select your project and alias it as 'default'
        exit /b 1
    )
)

REM Show current project
for /f "tokens=*" %%i in ('firebase use --current') do set CURRENT_PROJECT=%%i
echo 📋 Current Firebase project: %CURRENT_PROJECT%
echo.

REM Install dependencies if needed
if not exist "node_modules" (
    echo 📦 Installing dependencies...
    call npm install
    if %errorlevel% neq 0 (
        echo ❌ npm install failed
        exit /b 1
    )
    echo.
)

REM Run linting
echo 🧹 Running linter...
call npm run lint
if %errorlevel% neq 0 (
    echo ❌ Linting failed
    echo Fix linting errors and try again
    exit /b 1
)
echo ✅ Linting passed
echo.

REM Build the application
echo 🔨 Building application...
call npm run build
if %errorlevel% neq 0 (
    echo ❌ Build failed
    exit /b 1
)
echo ✅ Build completed
echo.

REM Check build output
if not exist "dist" (
    echo ❌ Build output directory 'dist' not found
    exit /b 1
)

echo 📊 Build completed successfully
echo.

REM Deploy to Firebase
echo 🚀 Deploying to Firebase Hosting...
firebase deploy --only hosting
if %errorlevel% neq 0 (
    echo ❌ Deployment failed
    exit /b 1
)

echo.
echo ✅ Deployment successful!
echo 🌐 Check Firebase Console for your hosting URL
echo.
echo 🎉 Deployment complete!

REM Environment-specific post-deployment messages
if "%ENVIRONMENT%"=="production" (
    echo.
    echo 📋 Production Deployment Checklist:
    echo   1. Test Google OAuth login flow
    echo   2. Verify custom domain DNS (if configured^)
    echo   3. Check Supabase auth redirect URLs include production domain
    echo   4. Test customer/quote/invoice CRUD operations
    echo   5. Verify PDF generation works
    echo   6. Test email sending (if enabled^)
    echo   7. Monitor Firebase Console for errors
) else (
    echo.
    echo 📋 Staging Deployment Notes:
    echo   • This is your staging environment for testing
    echo   • Share the URL with stakeholders for approval
    echo   • Test all critical user flows before production deployment
    echo   • Deploy to production with: scripts\deploy-firebase.bat production
)

echo.
echo 📚 Useful commands:
echo   firebase hosting:sites:list    # List hosting sites
echo   firebase hosting:channel:list  # List hosting channels
echo   firebase hosting:rollback      # Rollback to previous version
echo   firebase open hosting:site     # Open site in browser

endlocal