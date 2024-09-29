import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gallery_app/constant/constant.dart';
import 'package:gallery_app/screen/auth/service/auth_service.dart';

class SignInForm extends StatefulWidget {
  final VoidCallback onToggle;

  SignInForm({required this.onToggle});

  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> loginUser(
      BuildContext context, String email, String password) async {
    setState(() {
      isLoading = true;
    });
    final url = Uri.parse(baseUrl + '/users/login');
    final headers = {
      "Access-Control-Allow-Origin": "*",
      'Content-Type': 'application/json',
      'Accept': '*/*',
    };
    final body = json.encode({"email": email, "password": password});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        await AuthService().saveToken(responseData['token']);
        print('Login berhasil: ${responseData['token']}');
        await AuthService().getUserData();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Login berhasil, selamat datang ${responseData['data']['name']}!'),
        ));

        setState(() {
          _emailController.clear();
          _passwordController.clear();
        });
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Email atau password salah.'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal login: ${response.body}'),
        ));
      }
    } catch (e) {
      print('Error: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Terjadi kesalahan: ${e.toString()}'),
      ));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
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
                hintText: 'Masukkan Email',
                filled: true,
                fillColor: Color(0xFFF5FCF9),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Email harus diisi';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Email tidak valid';
                }
                return null;
              },
              keyboardType: TextInputType.emailAddress,
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
              controller: _passwordController,
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
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Password harus diisi';
                }
                return null;
              },
              keyboardType: TextInputType.visiblePassword,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  loginUser(
                      context, _emailController.text, _passwordController.text);
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
                      "Masuk",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 14.0,
                      ),
                    ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: widget.onToggle,
              child: Text(
                "Belum punya akun? Daftar",
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
