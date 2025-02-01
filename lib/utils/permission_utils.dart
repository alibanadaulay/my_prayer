import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';

class PermissionUtils {
  final _geolocatorPlatform = GeolocatorPlatform.instance;

  Future<bool> requestPermission() async {
    final bool permission = await Permission.location.request().isGranted;
    if (permission) {
      return true;
    }
    return false;
  }

  static Future<bool> requestNotification() async {
    final bool permission = await Permission.notification.request().isGranted;
    if (permission) {
      return true;
    }
    return false;
  }

  Future<Position?> getCurrentPosition() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      return null;
    }
    return await _geolocatorPlatform.getCurrentPosition();
  }

  Future<Placemark?> getCityName(Position? position) async {
    try {
      if (position == null) {
        return null;
      }
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        return placemarks[0];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
