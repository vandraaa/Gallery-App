import 'package:flutter/material.dart';
import 'package:gallery_app/screen/auth/service/auth_service.dart';
import 'package:gallery_app/screen/home/home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = '';
  String userEmail = '';
  String userPassword = '';
  bool isLoading = true;
  final Color blueAccentShade700 = Colors.blueAccent.withOpacity(0.8);
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = AuthService();
    final userData = await authService.getUserData();
    setState(() {
      userName = userData['name'] ?? 'Loading...';
      userEmail = userData['email'] ?? 'Loading...';
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

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      // Add logic to update user profile with the values from the text fields
      print("Updating profile with Name: $userName, Email: $userEmail, Password: $userPassword");
      // You can call your AuthService to update the user data here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(_createRoute());
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blueAccent,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            getInitials(userName),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Nama Lengkap',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14.5,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6.0),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: TextEditingController(text: userName),
                    decoration: const InputDecoration(
                      hintText: 'Masukkan Nama Lengkap',
                      filled: true,
                      fillColor: Color(0xFFF5FCF9),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      errorStyle: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Poppins'),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Nama Lengkap harus diisi';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.name,
                    onChanged: (value) {
                      userName = value; 
                    },
                  ),
                  const SizedBox(height: 16.0),
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Email',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14.5,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  TextFormField(
                    controller: TextEditingController(text: userEmail),
                    decoration: const InputDecoration(
                      hintText: 'Masukkan Email',
                      filled: true,
                      fillColor: Color(0xFFF5FCF9),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      errorStyle: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Poppins'),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Email harus diisi';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Email tidak valid';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      userEmail = value; 
                    },
                  ),
                  const SizedBox(height: 16.0),
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Password',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14.5,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan Password',
                      filled: true,
                      fillColor: Color(0xFFF5FCF9),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      errorStyle: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Poppins'),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Password harus diisi';
                      } else if (value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.visiblePassword,
                    onChanged: (value) {
                      userPassword = value; 
                    },
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _updateProfile();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.lightBlue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: const StadiumBorder(),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.0,
                            ),
                          )
                        : const Text(
                            "Simpan",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 14.0,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
