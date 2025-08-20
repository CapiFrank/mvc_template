#!/bin/bash

if [ -z "$1" ]; then
  echo "Uso: ./setup.sh nuevo_nombre_proyecto"
  exit 1
fi

NEW_NAME=$1
BUNDLE_ID="com.example.$NEW_NAME"
OLD_NAME="mvc_template"

# Renombrar carpeta principal del proyecto
OLD_DIR=$(basename "$(pwd)")
cd ..
mv "$OLD_DIR" "$NEW_NAME"
cd "$NEW_NAME"

# Reemplazar en pubspec.yaml
sed -i "s/$OLD_NAME/$NEW_NAME/g" pubspec.yaml

# Reemplazar en Android (Gradle y manifest)
sed -i "s/$OLD_NAME/$NEW_NAME/g" android/app/build.gradle
sed -i "s/$OLD_NAME/$NEW_NAME/g" android/app/src/main/AndroidManifest.xml

# Renombrar directorio Kotlin
OLD_PATH="android/app/src/main/kotlin/com/example/$OLD_NAME"
NEW_PATH="android/app/src/main/kotlin/com/example/$NEW_NAME"
mv "$OLD_PATH" "$NEW_PATH"

# Activar rename y cambiar nombre y bundleId
dart pub global activate rename
dart pub global run rename setAppName --targets ios,android,macos,windows,linux --value "$NEW_NAME"
dart pub global run rename setBundleId --targets ios,android,macos,windows,linux --value "$BUNDLE_ID"

echo "Proyecto renombrado correctamente a $NEW_NAME"
