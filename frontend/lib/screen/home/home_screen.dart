import 'package:flutter/material.dart';
import 'package:gallery_app/alert/alert.dart';
import 'package:gallery_app/alert/confirmPopupCenter.dart';
import 'package:gallery_app/screen/auth/auth_screen.dart';
import 'package:gallery_app/screen/auth/service/auth_service.dart';
import 'package:gallery_app/screen/home/content/album_content.dart';
import 'package:gallery_app/screen/home/content/favorite_content.dart';
import 'package:gallery_app/screen/home/content/home_content.dart';
import 'package:gallery_app/screen/home/content/trash_content.dart';
import 'package:gallery_app/screen/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, required this.initialIndex});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int userId = 0;
  String userName = '';
  bool isLoading = true;
  int _selectedIndex = 0;

  Future<void> _loadUserData() async {
    final authService = AuthService();
    final userData = await authService.getUserData();
    setState(() {
      userName = userData['name'] ?? 'Loading...';
      userId = userData['userId'] ?? 'Loading...';
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
    _selectedIndex = widget.initialIndex;
  }

  void _handleLogout() async {
    final authService = AuthService();
    try {
      await authService.removeToken();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => AuthScreen()),
      );
      showAlert(context, 'Logout Success', true);
    } catch (e) {
      showAlert(context, 'Logout Failed', false);
    }
  }

  Widget _getSelectedWidget() {
    switch (_selectedIndex) {
      case 0:
        return HomeContent(userId: userId);
      case 1:
        return AlbumContent(userId: userId);
      case 2:
        return FavoriteContent(userId: userId);
      case 3:
        return TrashContent(userId: userId);
      default:
        return HomeContent(userId: userId);
    }
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
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const ProfileScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                } else if (value == 'logout') {
                  confirmPopupCenter(
                    context, 
                    'Are you sure?', 
                    'Are you sure you want to log out?', 
                    'Yes, Log out', 
                    _handleLogout
                  );
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
      body: _getSelectedWidget(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'All',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_album),
            label: 'Album',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delete),
            label: 'Trash',
          ),
        ],
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: const Color.fromRGBO(158, 158, 158, 1),
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}
