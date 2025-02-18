#!/bin/bash

# Step 1: Build the Flutter app
flutter build apk --release

# Step 2: Check if the build was successful
if [ $? -ne 0 ]; then
    echo "Flutter build failed. Exiting."
    exit 1
fi

# Step 3: Upload the APK to Google Drive
# Path to the generated APK
FILE_PATH="build/app/outputs/flutter-apk/app-release.apk"

# Check if the APK file exists
if [ ! -f "$FILE_PATH" ]; then
    echo "APK file not found at $FILE_PATH. Exiting."
    exit 1
fi

# Call the Python script to upload the file
# Make sure to provide the correct path to the Python script
python3 /Users/jmrealubit/AndroidStudioProjects/freezebook/upload_to_drive.py "$FILE_PATH"