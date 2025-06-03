#!/bin/bash

# Script to fix the BoringSSL-GRPC compiler flag issue with Xcode 16
# This removes the problematic -GCC_WARN_INHIBIT_ALL_WARNINGS flag

echo "Fixing BoringSSL-GRPC compiler flag issue..."

# Find the BoringSSL-GRPC.xcconfig file
XCCONFIG_FILE=$(find ./ios -name "BoringSSL-GRPC.xcconfig" 2>/dev/null)

if [ -z "$XCCONFIG_FILE" ]; then
  echo "BoringSSL-GRPC.xcconfig file not found. Trying to find the .podspec file instead..."
  
  # Find the BoringSSL-GRPC.podspec file
  PODSPEC_FILE=$(find ./ios -name "BoringSSL-GRPC.podspec" 2>/dev/null)
  
  if [ -z "$PODSPEC_FILE" ]; then
    echo "Could not find BoringSSL-GRPC files. Trying another approach..."
    
    # Try to modify the build settings directly
    cd ios
    echo "Running pod update..."
    pod update
    
    echo "Creating post-install hook to fix the issue..."
    cat > fix_podfile.rb << 'EOL'
require 'xcodeproj'

project_path = 'Pods/Pods.xcodeproj'
project = Xcodeproj::Project.open(project_path)

target = project.targets.find { |t| t.name == 'BoringSSL-GRPC' }
if target
  target.build_configurations.each do |config|
    if config.build_settings['OTHER_CFLAGS'] && config.build_settings['OTHER_CFLAGS'].include?('-GCC_WARN_INHIBIT_ALL_WARNINGS')
      puts "Removing -GCC_WARN_INHIBIT_ALL_WARNINGS from #{config.name}"
      config.build_settings['OTHER_CFLAGS'] = config.build_settings['OTHER_CFLAGS'].reject { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
    end
  end
  project.save
  puts "Fixed BoringSSL-GRPC compiler flags"
else
  puts "BoringSSL-GRPC target not found"
end
EOL
    
    echo "Running the fix script..."
    ruby fix_podfile.rb
    cd ..
    echo "Fix applied. Try building the app again."
    exit 0
  fi
  
  echo "Found podspec file: $PODSPEC_FILE"
  echo "Modifying the podspec file to remove the problematic flag..."
  sed -i '' "s/-GCC_WARN_INHIBIT_ALL_WARNINGS//g" "$PODSPEC_FILE"
  
  echo "Running pod install to apply changes..."
  cd ios
  pod install
  cd ..
else
  echo "Found xcconfig file: $XCCONFIG_FILE"
  echo "Modifying the xcconfig file to remove the problematic flag..."
  sed -i '' "s/-GCC_WARN_INHIBIT_ALL_WARNINGS//g" "$XCCONFIG_FILE"
  
  echo "Running pod install to apply changes..."
  cd ios
  pod install
  cd ..
fi

echo "Fix completed. Try building your app again." 