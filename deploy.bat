@echo off
echo === Deploying to Netlify ===
echo Step 1: Checking netlify-cli...
call npx netlify-cli --version 2>&1
echo.
echo Step 2: Deploying...
cd /d D:\Projects\gongyu_guanjia
call npx netlify-cli deploy --prod --dir=build\web 2>&1
echo.
echo Done.
