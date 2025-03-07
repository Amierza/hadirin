import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class PresenceController extends GetxController {
  var isLoading = false.obs;
  var isCheckedIn = false.obs;

  // Koordinat tujuan Unair Kampus C
  final double targetLatitude = -7.275613; 
  final double targetLongitude = 112.791183; 
  final double radiusMeter = 200; 

  Future<Position?> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Error', 'GPS tidak aktif. Silakan aktifkan GPS.');
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Error', 'Izin lokasi ditolak.');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('Error', 'Izin lokasi ditolak permanen.');
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  Future<bool> _isWithinRadius() async {
    Position? userPosition = await _getUserLocation();
    if (userPosition == null) return false;

    double distance = _calculateDistance(
      userPosition.latitude,
      userPosition.longitude,
      targetLatitude,
      targetLongitude,
    );

    return distance <= radiusMeter;
  }

  Future<void> checkIn() async {
    isLoading.value = true;
    bool withinRadius = await _isWithinRadius();
    if (!withinRadius) {
      Get.snackbar('Error', 'Anda berada di luar radius absensi.');
      isLoading.value = false;
      return;
    }

    await Future.delayed(Duration(seconds: 2));
    isCheckedIn.value = true;
    Get.snackbar('Sukses', 'Absen masuk berhasil');
    isLoading.value = false;
  }

  Future<void> checkOut() async {
    isLoading.value = true;
    bool withinRadius = await _isWithinRadius();
    if (!withinRadius) {
      Get.snackbar('Error', 'Anda berada di luar radius absensi.');
      isLoading.value = false;
      return;
    }

    await Future.delayed(Duration(seconds: 2));
    isCheckedIn.value = false;
    Get.snackbar('Sukses', 'Absen keluar berhasil');
    isLoading.value = false;
  }
}