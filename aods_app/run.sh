#!/bin/bash
# รัน Flutter Web พร้อม disable CORS สำหรับ development
flutter run -d chrome \
  --web-browser-flag "--disable-web-security" \
  --web-browser-flag "--user-data-dir=/tmp/flutter-chrome"
