#!/bin/bash

# Get the current date in MM.DD format
current_date=$(date +'%m.%d')

# Define the base version
base_version="1.$current_date.1"

# Construct the full version string
full_version="v.$base_version+1"

# Update pubspec.yaml
sed -i "s/version: .*/version: $full_version/" pubspec.yaml

echo "Updated version to $full_version"