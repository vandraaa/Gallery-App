import 'package:flutter/material.dart';
import 'package:gallery_app/services/auth_service.dart';

class SignInForm extends StatefulWidget {
  final VoidCallback onToggle;

  const SignInForm({super.key, required this.onToggle});

  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    if (_formKey.currentState!.validate()) {
      await signIn(context, _emailController.text, _passwordController.text);
    }

    setState(() {
      _isLoading = false;
    });
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
                onPressed: _handleSignIn,
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
                        "Masuk",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                        ),
                      ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: widget.onToggle,
                child: const Text(
                  "Belum punya akun? Daftar",
                  style: TextStyle(
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
