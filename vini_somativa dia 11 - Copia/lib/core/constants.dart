// lib/core/constants.dart
import 'package:flutter/foundation.dart';

String get kBaseUrl {
  if (kIsWeb) {
    return 'http://localhost:3000';
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:3000';
  } else {
    return 'http://localhost:3000';
  }
}
