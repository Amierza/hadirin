import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/config/config.dart';
import 'package:frontend/controllers/user_controller.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/widgets/navbar.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.put(UserController());
    userController.fetchUserDetail();
    final assetsUrl = Config.assetsKey;

    return Scaffold(
      backgroundColor: secondaryBackgroundColor,
      appBar: AppBar(title: Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Obx(() {
          final user = userController.user.value;
          return Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      '$assetsUrl/user/${user?.userPhoto}',
                      height: 138,
                      width: 125,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/muka_presensi.png',
                          height: 138,
                          width: 125,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.userName ?? "",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: semiBold,
                            color: primaryTextColor,
                          ),
                        ),
                        Text(
                          user?.userEmail ?? "",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            iconColor: Colors.white,
                          ),
                          onPressed: () {
                            Get.toNamed('/edit_profile');
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Edit Profile',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  Get.toNamed('/presence_history');
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Text(
                      'Riwayat Absensi',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: medium,
                        color: primaryTextColor,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dangerColor,
                    foregroundColor: Colors.white,
                    iconColor: Colors.white,
                  ),
                  onPressed: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Log Out',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: regular,
                            color: Colors.white,
                          ),
                        ),
                        Icon(Icons.output_rounded, size: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onItemTapped: (index) {},
        currentIndex: 3,
      ),
    );
  }
}
