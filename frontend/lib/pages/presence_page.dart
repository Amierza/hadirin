import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/controllers/presence_controller.dart';
import 'package:frontend/shared/theme.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart' as latLng2;
import 'package:get_storage/get_storage.dart';

class PresencePage extends StatefulWidget {
  const PresencePage({super.key});

  @override
  State<PresencePage> createState() => _PresencePageState();
}

class _PresencePageState extends State<PresencePage> {
  File? _image;
  final PresenceController presenceController = Get.put(PresenceController());
  final ImagePicker _picker = ImagePicker();
  final GetStorage box = GetStorage();

  @override
  void initState() {
    super.initState();
    presenceController.checkLocationPermission();
    _checkAttendanceStatus();
  }

  Future<void> _openCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _checkAttendanceStatus() {
    // Check if user has already checked out today
    if (presenceController.isCheckedOutToday()) {
      Get.snackbar(
        'Info',
        'You have already completed attendance for today',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _submitCheckIn() {
    if (presenceController.isCheckedOutToday()) {
      Get.snackbar(
        'Error',
        'You have already completed attendance for today',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_image == null) {
      Get.snackbar('Error', 'Please take a photo first');
      return;
    }
    presenceController.checkIn(_image!);
  }

  void _submitCheckOut() {
    if (presenceController.isCheckedOutToday()) {
      Get.snackbar(
        'Error',
        'You have already completed attendance for today',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_image == null) {
      Get.snackbar('Error', 'Please take a photo first');
      return;
    }
    presenceController.checkOut(_image!);
  }

  void _clearStorage() {
    // Clear all attendance-related storage values
    box.remove('current_att_id');
    box.remove('last_check_in_time');
    box.remove('is_checked_in');
    box.remove('check_out_status');
    box.remove('last_check_out_time');
    box.remove('attendance_completed'); // Add this line to clear the status

    // Call the controller's method to clear attendance data
    presenceController.clearAttendanceData();

    // Reset the image state
    setState(() {
      _image = null;
    });

    // Show success message
    Get.snackbar(
      'Success',
      'Storage cleared successfully',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearStorage,
            tooltip: 'Clear Storage',
          ),
        ],
      ),
      body: Obx(() {
        if (presenceController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final isAttendanceCompleted = presenceController.isCheckedOutToday();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: isAttendanceCompleted ? null : _openCamera,
                    child: AbsorbPointer(
                      absorbing: isAttendanceCompleted,
                      child:
                          _image != null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(
                                  _image!,
                                  height: 250,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              )
                              : Container(
                                height: 250,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(20),
                                  color:
                                      isAttendanceCompleted
                                          ? Colors.grey[200]
                                          : null,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      size: 50,
                                      color:
                                          isAttendanceCompleted
                                              ? Colors.grey
                                              : null,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      isAttendanceCompleted
                                          ? 'Attendance completed for today'
                                          : 'Tap to take attendance photo',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            isAttendanceCompleted
                                                ? Colors.grey
                                                : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!presenceController.isCheckedIn.value &&
                      !isAttendanceCompleted)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitCheckIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('CHECK IN'),
                      ),
                    )
                  else if (presenceController.isCheckedIn.value &&
                      !isAttendanceCompleted)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitCheckOut,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: dangerColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('CHECK OUT'),
                      ),
                    )
                  else if (isAttendanceCompleted)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Attendance completed',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: latLng2.LatLng(
                    presenceController.userPosition.value?.latitude ??
                        presenceController.targetLatitude,
                    presenceController.userPosition.value?.longitude ??
                        presenceController.targetLongitude,
                  ),
                  initialZoom: 16,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: latLng2.LatLng(
                          presenceController.targetLatitude,
                          presenceController.targetLongitude,
                        ),
                        width: 80,
                        height: 80,
                        child: Icon(
                          Icons.location_pin,
                          size: 40,
                          color: dangerColor,
                        ),
                      ),
                      if (presenceController.userPosition.value != null)
                        Marker(
                          point: latLng2.LatLng(
                            presenceController.userPosition.value!.latitude,
                            presenceController.userPosition.value!.longitude,
                          ),
                          width: 80,
                          height: 80,
                          child: Icon(
                            Icons.person_pin_circle,
                            size: 40,
                            color: primaryColor,
                          ),
                        ),
                    ],
                  ),
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: latLng2.LatLng(
                          presenceController.targetLatitude,
                          presenceController.targetLongitude,
                        ),
                        radius: presenceController.radiusMeter,
                        color: primaryColor.withOpacity(0.2),
                        borderColor: primaryColor,
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
