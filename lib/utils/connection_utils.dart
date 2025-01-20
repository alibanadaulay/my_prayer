import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionUtils {

   ConnectionUtils._privateConstructor();
  final Connectivity _connectivity = Connectivity();


  static final ConnectionUtils _instance = ConnectionUtils._privateConstructor();

  factory ConnectionUtils() {
    return _instance;
  }

  Future<bool> getConnection () async {
        final result =  await _connectivity.checkConnectivity();
return result.contains(ConnectivityResult.mobile) || result.contains(ConnectivityResult.wifi);
  }
}