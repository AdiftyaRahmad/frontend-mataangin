@echo off
echo ========================================
echo Regenerate Firebase API Keys
echo ========================================
echo.
echo This will generate new API keys for:
echo - Android
echo - iOS
echo - Web
echo.
pause

echo.
echo Running FlutterFire configure...
echo.

dart pub global run flutterfire_cli:flutterfire configure

echo.
echo ========================================
echo Done!
echo ========================================
echo.
echo File lib/firebase_options.dart has been generated with new API keys.
echo.
echo Next steps:
echo 1. Check lib/firebase_options.dart
echo 2. Test your app: flutter run -d chrome
echo 3. Set additional restrictions in Google Cloud Console
echo.
pause
