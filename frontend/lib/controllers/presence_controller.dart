import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class PresenceController extends GetxController {
  var isLoading = false.obs;
  var isCheckedIn = false.obs;
  var userPosition = Rx<Position?>(null); // Untuk menyimpan posisi pengguna

  // Koordinat tujuan Unair Kampus C
  final double targetLatitude = -7.266422;
  final double targetLongitude = 112.783539;
  final double radiusMeter = 200;

  // Cek izin lokasi dan aktifkan GPS
  Future<void> checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Error', 'GPS tidak aktif. Silakan aktifkan GPS.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Error', 'Izin lokasi ditolak.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('Error', 'Izin lokasi ditolak permanen.');
      return;
    }

    await _getUserLocation();
  }

  // Ambil posisi pengguna
  Future<void> _getUserLocation() async {
    try {
      isLoading.value = true;
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      userPosition.value = position;
    } catch (e) {
      Get.snackbar('Error', 'Gagal mendapatkan lokasi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Hitung jarak antara posisi pengguna dan target
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // Cek apakah pengguna berada dalam radius
  Future<bool> _isWithinRadius() async {
    if (userPosition.value == null) return false;

    double distance = _calculateDistance(
      userPosition.value!.latitude,
      userPosition.value!.longitude,
      targetLatitude,
      targetLongitude,
    );

    return distance <= radiusMeter;
  }

  // Logika check-in
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

  // Logika check-out
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