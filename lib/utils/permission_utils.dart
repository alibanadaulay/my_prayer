  import 'package:geolocator/geolocator.dart';
  import 'package:permission_handler/permission_handler.dart';
  import 'package:logger/logger.dart';
import 'package:geocoding/geocoding.dart';



class PermissionUtils {
  final _geolocatorPlatform = GeolocatorPlatform.instance;
  final Logger log= Logger();


  Future<bool> requestPermission() async{
    final bool permission = await Permission.location.request().isGranted;
    log.i(permission);
    if(permission){
      return true;
    }
    return false;

    // bool isLocationEnable = await _geolocatorPlatform.isLocationServiceEnabled();
    // LocationPermission permissions =  await _geolocatorPlatform.checkPermission();

    // if(!isLocationEnable || permissions == LocationPermission.deniedForever){
    //   return false;
    // }

    // if(permissions == LocationPermission.denied){
    //   permissions = await _geolocatorPlatform.requestPermission();
    //   if (permissions == LocationPermission.denied) {
    //     return false;
    //   }
    // }
    // return true;
  }



  Future<Position?> getCurrentPosition() async {
    final hasPermission = await requestPermission();
    log.i(hasPermission);
    if (!hasPermission) {
      return null;
    }
    return await _geolocatorPlatform.getCurrentPosition();
   
  }

  Future<String?> getCityName(Position? position) async {
    try{
    if(position == null){
      return null;
    }
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
 if (placemarks.isNotEmpty) {
      String city = placemarks[0].locality ?? 'Unknown';
      return city;
    } else {
            return null;
    }
    } catch(e){
      return null;
    }

  }
}