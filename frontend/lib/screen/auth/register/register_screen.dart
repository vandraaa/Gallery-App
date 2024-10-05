import 'package:flutter/material.dart';
import 'package:gallery_app/alert/alert.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gallery_app/constant/constant.dart';

class SignUpForm extends StatefulWidget {
  final VoidCallback onSignUpSucess;
  final VoidCallback onToggle;

  SignUpForm({required this.onSignUpSucess, required this.onToggle});

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _isLoading = false;

  Future<void> signUpUser(
      BuildContext context, String name, String email, String password) async {
    setState(() {
      _isLoading = true;
    });
    final url = Uri.parse(baseUrl + '/users');
    final headers = {
      "Access-Control-Allow-Origin": "*",
      'Content-Type': 'application/json',
      'Accept': '*/*',
    };
    final body =
        json.encode({"name": name, "email": email, "password": password});

    try {
      final response = await http.post(url, headers: headers, body: body);
      final responseData = json.decode(response.body)['message'];

      if (response.statusCode == 201) {
        showAlert(context, responseData, true);
        setState(() {
          _nameController.clear();
          _emailController.clear();
          _passwordController.clear();
        });

        widget.onSignUpSucess();
      } else {
        showAlert(context, responseData, false);
      }
    } catch (e) {
      print('Error: ${e.toString()}');
      showAlert(context, e.toString(), false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
              TextFormField(
                controller: _nameController,
                focusNode: _nameFocus,
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
                        fontFamily: 'Poppins')),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Nama Lengkap harus diisi';
                  }
                  return null;
                },
                keyboardType: TextInputType.name,
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
                focusNode: _emailFocus,
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
                        fontFamily: 'Poppins')),
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
                focusNode: _passwordFocus,
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
                        fontFamily: 'Poppins')),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Password harus diisi';
                  } else if (value.length < 6) {
                    return 'Password minimal 6 karakter';
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
                    signUpUser(context, _nameController.text,
                        _emailController.text, _passwordController.text);
                    FocusScope.of(context).unfocus();
                  }
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: const StadiumBorder(),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.0,
                        ),
                      )
                    : const Text(
                        "Daftar",
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
                  "Sudah punya akun? Masuk",
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
