@echo off
echo ========================================
echo Get SHA-1 Fingerprint for Android
echo ========================================
echo.

echo Checking debug keystore...
echo.

cd %USERPROFILE%\.android

if not exist debug.keystore (
    echo ❌ Debug keystore not found!
    echo.
    echo Creating debug keystore...
    keytool -genkey -v -keystore debug.keystore -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 -storepass android -keypass android -dname "CN=Android Debug,O=Android,C=US"
    echo.
)

echo.
echo 📋 Debug SHA-1 Fingerprint:
echo ========================================
keytool -list -v -keystore debug.keystore -alias androiddebugkey -storepass android -keypass android | findstr SHA1

echo.
echo ========================================
echo.
echo Copy SHA-1 value di atas (format: XX:XX:XX:...)
echo Paste ke Google Cloud Console > Android API Key > SHA-1 fingerprint
echo.
pause
