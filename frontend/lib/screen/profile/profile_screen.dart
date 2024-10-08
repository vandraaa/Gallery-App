import 'package:gallery_app/alert/confirmPopupCenter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gallery_app/constant/constant.dart';
import 'package:gallery_app/screen/auth/service/auth_service.dart';
import 'package:gallery_app/screen/home/home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = '';
  String userEmail = '';
  String userPassword = '';
  bool isLoading = true;
  bool isLoadingSubmit = false;
  final Color blueAccentShade700 = Colors.blueAccent.withOpacity(0.8);
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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

    _nameController.text = userName;
    _emailController.text = userEmail;
  }

  String getInitials(String name) {
    List<String> nameParts = name.split(' ');

    if (nameParts.length > 2) {
      nameParts = nameParts.sublist(0, 2);
    }

    return nameParts.map((e) => e[0]).join().toUpperCase();
  }

  Future<void> updateUser(
      BuildContext context, String name, String email, String password) async {
    setState(() {
      isLoadingSubmit = true;
    });

    final url = Uri.parse('$baseUrl/users');
    final headers = {
      "Access-Control-Allow-Origin": "*",
      'Content-Type': 'application/json',
      'Accept': '*/*',
    };

    final body = json.encode(
      {
        "name": name,
        "email": email,
        "password": password,
      }
    );

    try {
      final response = await http.patch(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message']),
          ),
        );

        String? newToken = responseData['token'];

        if (newToken != null) {
          final service = AuthService();
          await service.saveToken(newToken);
        }

        setState(() {
          isLoadingSubmit = false;
        });
      } else {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message']),
          ),
        );
        setState(() {
          isLoadingSubmit = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingSubmit = false;
      });
      print(e);
    }
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final password = _passwordController.text;

      updateUser(context, name, userEmail, password);
      print(
          "Updating profile with Name: $userName, Email: $userEmail, Password: $userPassword");
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
                  'Name',
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
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your name',
                      filled: true,
                      fillColor: Color.fromARGB(255, 225, 228, 235),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 10.0),
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
                        return 'Name cannot be empty';
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
                    controller: _emailController,
                    decoration: const InputDecoration(
                      // hintText: 'Masukkan Email',
                      filled: true,
                      fillColor: Color.fromARGB(255, 225, 228, 235),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 10.0),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      errorStyle: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Poppins'),
                    ),
                    enabled: false,
                  ),
                  const SizedBox(height: 3.0),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Email tidak dapat di ganti!",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12.0,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
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
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your password',
                      filled: true,
                      fillColor: Color.fromARGB(255, 225, 228, 235),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 10.0),
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
                        return 'Password cannot be empty';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters';
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
                        _formKey.currentState!.save();
                        // _updateProfile();
                        confirmPopupCenter(
                          context, 
                          'Update Profile', 
                          'Are you sure you want to update your profile?', 
                          'Save', 
                          _updateProfile
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.lightBlue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: const StadiumBorder(),
                    ),
                    child: isLoadingSubmit
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
      pageBuilder: (context, animation, secondaryAnimation) =>
          const HomeScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
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
