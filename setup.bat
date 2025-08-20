@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

IF "%~1"=="" (
    echo Uso: setup nuevo_nombre_proyecto
    exit /b 1
)

SET NEW_NAME=%~1
SET BUNDLE_ID=com.example.%NEW_NAME%
SET OLD_NAME=mvc_template
SET OLD_PATH=android\app\src\main\kotlin\com\example\%OLD_NAME%
SET NEW_PATH=android\app\src\main\kotlin\com\example\%NEW_NAME%

@REM :: Renombrar carpeta del proyecto
@REM FOR %%F IN (.) DO SET CURRENT_DIR=%%~nxF
@REM echo Renombrando proyecto de !CURRENT_DIR! a %NEW_NAME%
@REM cd ..
@REM ren !CURRENT_DIR! %NEW_NAME%
@REM cd %NEW_NAME%

:: Reemplazar en pubspec.yaml
powershell -Command "(Get-Content pubspec.yaml) -replace '%OLD_NAME%', '%NEW_NAME%' | Set-Content pubspec.yaml"

:: Reemplazar en Android (Gradle y manifests)
powershell -Command "(Get-Content android\app\build.gradle.kts) -replace '%OLD_NAME%', '%NEW_NAME%' | Set-Content android\app\build.gradle.kts"
powershell -Command "(Get-Content android\app\src\main\AndroidManifest.xml) -replace '%OLD_NAME%', '%NEW_NAME%' | Set-Content android\app\src\main\AndroidManifest.xml"
powershell -Command "(Get-Content %OLD_PATH%\MainActivity.kt) -replace '%OLD_NAME%', '%NEW_NAME%' | Set-Content %OLD_PATH%\MainActivity.kt"

:: Renombrar directorio de Kotlin
ren "%OLD_PATH%" "%NEW_NAME%"

powershell -Command "Get-ChildItem -Path . -Recurse -Include *.dart | ForEach-Object { (Get-Content $_.FullName) -replace '%OLD_NAME%', '%NEW_NAME%' | Set-Content $_.FullName }"

:: Activar rename y cambiar nombre y bundleId
call dart pub global activate rename
call dart pub global run rename setAppName --targets ios,android,macos,windows,linux --value "%NEW_NAME%"
call dart pub global run rename setBundleId --targets ios,android,macos,windows,linux --value "%BUNDLE_ID%"

echo Proyecto renombrado correctamente a %NEW_NAME%.
ENDLOCAL
