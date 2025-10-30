#!/usr/bin/env node
/**
 * Environment Validation Script
 * Checks if all required environment variables are set correctly
 */

const fs = require('fs');
const path = require('path');

// Colors for console output
const colors = {
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  reset: '\x1b[0m'
};

function log(color, message) {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

function checkEnvironment() {
  log('blue', '🔍 Validating environment configuration...\n');

  // Check if .env file exists
  const envPath = path.join(process.cwd(), '.env');
  const envExamplePath = path.join(process.cwd(), '.env.example');

  if (!fs.existsSync(envPath)) {
    log('yellow', '⚠️  No .env file found');
    
    if (fs.existsSync(envExamplePath)) {
      log('blue', '💡 Found .env.example - copying to .env...');
      fs.copyFileSync(envExamplePath, envPath);
      log('green', '✅ Created .env file from template');
      log('yellow', '⚠️  Please fill in your Supabase credentials in .env');
      return false;
    } else {
      log('red', '❌ No .env.example found either');
      log('yellow', '💡 Create .env with these variables:');
      log('blue', '   REACT_APP_SUPABASE_URL=https://your-project.supabase.co');
      log('blue', '   REACT_APP_SUPABASE_KEY=your-anon-key');
      return false;
    }
  }

  // Read .env file
  const envContent = fs.readFileSync(envPath, 'utf8');
  const envVars = {};
  
  envContent.split('\n').forEach(line => {
    const [key, ...valueParts] = line.split('=');
    if (key && valueParts.length > 0) {
      envVars[key.trim()] = valueParts.join('=').trim();
    }
  });

  // Required environment variables
  const requiredVars = [
    {
      name: 'REACT_APP_SUPABASE_URL',
      pattern: /^https:\/\/[a-z0-9]+\.supabase\.co$/,
      description: 'Supabase project URL'
    },
    {
      name: 'REACT_APP_SUPABASE_KEY',
      pattern: /^eyJ[A-Za-z0-9-_=]+\.[A-Za-z0-9-_=]+\.?[A-Za-z0-9-_.+/=]*$/,
      description: 'Supabase anon key (JWT format)'
    }
  ];

  let allValid = true;

  log('blue', '📋 Checking required variables:');

  requiredVars.forEach(({ name, pattern, description }) => {
    const value = envVars[name];
    
    if (!value) {
      log('red', `❌ ${name} is missing`);
      log('yellow', `   Description: ${description}`);
      allValid = false;
    } else if (!pattern.test(value)) {
      log('red', `❌ ${name} format is invalid`);
      log('yellow', `   Description: ${description}`);
      log('yellow', `   Current value: ${value.substring(0, 20)}...`);
      allValid = false;
    } else {
      log('green', `✅ ${name}`);
    }
  });

  console.log();

  if (allValid) {
    log('green', '🎉 All environment variables are valid!');
    
    // Additional checks
    log('blue', '📋 Additional information:');
    
    const supabaseUrl = envVars['REACT_APP_SUPABASE_URL'];
    if (supabaseUrl) {
      const projectId = supabaseUrl.split('//')[1].split('.')[0];
      log('blue', `   Supabase Project ID: ${projectId}`);
    }
    
    log('blue', '   Environment variables will be embedded at build time');
    log('blue', '   Ready for: npm run build');
    
    return true;
  } else {
    log('red', '❌ Environment validation failed');
    log('yellow', '\n💡 To get your Supabase credentials:');
    log('blue', '   1. Go to https://app.supabase.com');
    log('blue', '   2. Select your project (or create new)');
    log('blue', '   3. Go to Settings → API');
    log('blue', '   4. Copy "Project URL" to REACT_APP_SUPABASE_URL');
    log('blue', '   5. Copy "anon public" key to REACT_APP_SUPABASE_KEY');
    
    return false;
  }
}

// Run validation
const isValid = checkEnvironment();
process.exit(isValid ? 0 : 1);