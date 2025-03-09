import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/controllers/presence_controller.dart';
import 'package:frontend/shared/theme.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

class PresencePage extends StatefulWidget {
  @override
  State<PresencePage> createState() => _PresencePageState();
}

class _PresencePageState extends State<PresencePage> {
  File? _image;
  final PresenceController presenceController = Get.put(PresenceController());
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _openCamera();
  }

  Future<void> _openCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  bool _isWithinCheckInTime() {
    final now = DateTime.now();
    final startTime = DateTime(now.year, now.month, now.day, 6, 0);
    final endTime = DateTime(now.year, now.month, now.day, 10, 0);
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  void _submitCheckIn() {
    if (_image == null) {
      Get.snackbar('Error', 'Silakan ambil foto terlebih dahulu');
      return;
    }
    presenceController.isLoading.value = true;
    Future.delayed(Duration(seconds: 2), () {
      presenceController.isLoading.value = false;
      Get.snackbar('Sukses', 'Absen masuk berhasil');
    });
  }

  void _submitCheckOut() {
    if (_image == null) {
      Get.snackbar('Error', 'Silakan ambil foto terlebih dahulu');
      return;
    }
    presenceController.isLoading.value = true;
    Future.delayed(Duration(seconds: 2), () {
      presenceController.isLoading.value = false;
      Get.snackbar('Sukses', 'Absen keluar berhasil');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Presence View')),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _openCamera,
                  child:
                      _image != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              _image!,
                              height: 250,
                              width: 350,
                              fit: BoxFit.cover,
                            ),
                          )
                          : Container(
                            height: 250,
                            width: 350,
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Icon(Icons.camera_alt_rounded, size: 50),
                            ),
                          ),
                ),
                const SizedBox(height: 20),
                Obx(() {
                  if (presenceController.isLoading.value) {
                    return CircularProgressIndicator();
                  }
                  if (!presenceController.isCheckedIn.value) {
                    return ElevatedButton(
                      onPressed: _submitCheckIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: backgroundColor,
                      ),
                      child: Text('Absen Masuk'),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                }),
                const SizedBox(height: 10),
                Obx(() {
                  if (presenceController.isLoading.value) {
                    return CircularProgressIndicator();
                  }
                  if (presenceController.isCheckedIn.value) {
                    return ElevatedButton(
                      onPressed: _submitCheckOut,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dangerColor,
                        foregroundColor: backgroundColor,
                      ),
                      child: Text('Absen Keluar'),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                }),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(-7.275613, 112.791183),
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80,
                      height: 80,
                      point: LatLng(-7.275613, 112.791183),
                      child: Icon(
                        Icons.location_on_sharp,
                        size: 50,
                        color: dangerColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
