@echo off
echo ========================================
echo Git History Cleanup Script
echo ========================================
echo.
echo WARNING: This will rewrite Git history!
echo Make sure you have backed up your repository.
echo.
pause

echo.
echo Creating backup...
cd ..
if exist frontend-mataangin-backup (
    echo Backup already exists. Skipping...
) else (
    xcopy /E /I frontend-mataangin frontend-mataangin-backup
    echo Backup created at: frontend-mataangin-backup
)

cd frontend-mataangin

echo.
echo Removing firebase_options.dart from Git tracking...
git rm --cached lib/firebase_options.dart

echo.
echo Committing .gitignore changes...
git add .gitignore
git add lib/firebase_options.dart.template
git add SETUP_FIREBASE.md
git add URGENT_SECURITY_STEPS.md
git commit -m "security: Remove firebase_options.dart from Git and add to .gitignore"

echo.
echo ========================================
echo IMPORTANT: Next Steps
echo ========================================
echo.
echo 1. The file is now removed from future commits
echo 2. However, it still exists in Git history
echo 3. To completely remove from history, you need to:
echo.
echo    Option A: Use git filter-repo (recommended)
echo    pip install git-filter-repo
echo    git filter-repo --path lib/firebase_options.dart --invert-paths
echo.
echo    Option B: Use BFG Repo-Cleaner
echo    Download from: https://rtyley.github.io/bfg-repo-cleaner/
echo.
echo 4. After cleaning history, force push:
echo    git push origin --force --all
echo.
echo 5. MOST IMPORTANT: Revoke old API keys in Firebase Console!
echo.
pause
