import 'package:flutter/material.dart';
import 'package:gallery_app/screen/auth/auth_screen.dart';
import 'package:gallery_app/screen/auth/service/auth_service.dart';
import 'package:gallery_app/screen/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = '';
  bool isLoading = true;

  // Fungsi untuk memuat data pengguna dari AuthService
  Future<void> _loadUserData() async {
    final authService = AuthService();
    final userData = await authService.getUserData();
    setState(() {
      userName = userData['name'] ?? 'Loading...';
      isLoading = false;
    });
  }

  String getInitials(String name) {
    List<String> nameParts = name.split(' ');

    if (nameParts.length > 2) {
      nameParts = nameParts.sublist(0, 2);
    }

    return nameParts.map((e) => e[0]).join().toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _handleLogout() async {
    final authService = AuthService();
    await authService.removeToken();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
                Text(
                  userName,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'profile') {
                  Navigator.of(context).pushReplacement(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const ProfileScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                } else if (value == 'logout') {
                  _handleLogout();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person, color: Colors.blueAccent),
                      SizedBox(width: 10),
                      Text(
                        'Profile',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.redAccent),
                      SizedBox(width: 10),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              offset: const Offset(0, 43),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blueAccent.shade700,
                child: Text(
                  getInitials(userName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Text('Selamat datang, $userName!'),
      ),
    );
  }
}
