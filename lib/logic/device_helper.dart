import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

/// Gets a unique device identifier and model for device fingerprint registration.
Future<Map<String, String>> getDeviceInfo() async {
  final deviceInfo = DeviceInfoPlugin();
  try {
    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      return {
        'device_id': android.id,
        'device_model': '${android.manufacturer} ${android.model}',
      };
    } else if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      return {
        'device_id': ios.identifierForVendor ?? ios.name,
        'device_model': '${ios.name} ${ios.model}',
      };
    }
  } catch (e) {
    return {
      'device_id': 'unknown-${DateTime.now().millisecondsSinceEpoch}',
      'device_model': 'Unknown',
    };
  }
  return {
    'device_id': 'unknown',
    'device_model': 'Unknown',
  };
}
