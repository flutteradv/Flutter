sed -i -e "s/GOOGLE_MAPS_API_KEY/${GOOGLE_MAPS_API_KEY}/g" android/app/src/AndroidManifest.xml
sed -i -e "s/GOOGLE_MAPS_API_KEY/${GOOGLE_MAPS_API_KEY}/g" ios/Runner/AppDelegate.m
sed -i -e "s/BUILD_NUMBER/${BITRISE_BUILD_NUMBER}/g" lib/screens/login_screen.dart
sed -i -e "s/APP_VERSION_NUMBER/0.2.0/g" lib/screens/login_screen.dart
sed -i -e "s/BUILD_NUMBER/${BITRISE_BUILD_NUMBER}/g" lib/screens/settings.dart
sed -i -e "s/APP_VERSION_NUMBER/0.2.0/g" lib/screens/settings.dart