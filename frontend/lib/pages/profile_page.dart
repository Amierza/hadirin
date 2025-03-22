import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/pages/edit_profile_page.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/widgets/dialog_signout.dart';
import 'package:frontend/widgets/navbar.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryBackgroundColor,
      appBar: AppBar(title: Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/muka_presensi.png',
                    height: 138,
                    width: 125,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ahmad Mirza Rafiq Azmi',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: medium,
                        color: primaryTextColor,
                      ),
                    ),
                    Text(
                      '187231059',
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditProfilePage()),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.repeat, size: 18),
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
              ],
            ),
            const SizedBox(height: 30),
            Container(
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
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: dangerColor,
                foregroundColor: Colors.white,
                iconColor: Colors.white,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SignoutDialog();
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Log out',
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
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onItemTapped: (index) {},
        currentIndex: 3,
      ),
    );
  }
}
