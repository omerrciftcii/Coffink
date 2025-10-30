#!/bin/bash

# Alternative Deployment Script for Coffink Web App
# This script provides multiple deployment options when Firebase Hosting fails

echo "Coffink Web App - Alternative Deployment Options"
echo "================================================"

# Option 1: Simple HTTP Server (for local testing)
echo "Option 1: Local Testing with Python HTTP Server"
echo "Run: cd build/web && python -m http.server 8000"
echo "Then visit: http://localhost:8000"
echo ""

# Option 2: Using surge.sh (npm install -g surge)
echo "Option 2: Deploy with Surge.sh"
echo "1. Install surge: npm install -g surge"
echo "2. Run: surge build/web --domain your-app-name.surge.sh"
echo ""

# Option 3: Using Vercel
echo "Option 3: Deploy with Vercel"
echo "1. Install Vercel CLI: npm install -g vercel"
echo "2. Run: vercel build/web"
echo ""

# Option 4: Using Netlify
echo "Option 4: Deploy with Netlify"
echo "1. Install Netlify CLI: npm install -g netlify-cli"
echo "2. Run: netlify deploy --dir=build/web --prod"
echo ""

# Option 5: Manual GitHub Pages setup
echo "Option 5: Manual GitHub Pages"
echo "1. Push to GitHub repository"
echo "2. Enable GitHub Pages in repository settings"
echo "3. Select source as GitHub Actions"
echo "4. Use the provided .github/workflows/deploy.yml"
echo ""

echo "For immediate testing, start with Option 1!"