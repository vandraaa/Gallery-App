import 'package:flutter/material.dart';
import '../../components/sign_in_form.dart';
import '../../components/sign_up_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final PageController _pageController = PageController();
  bool _isSignIn = true;

  void _toggleView() {
    setState(() {
      _isSignIn = !_isSignIn;
    });
    _isSignIn ? _pageController.jumpToPage(0) : _pageController.jumpToPage(1);
  }

  void _handleSignUpSuccess() {
    setState(() {
      _isSignIn = true;
    });
    _pageController.jumpToPage(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.05),
                      Text(
                        _isSignIn ? "Login" : "Sign Up",
                        style: const TextStyle(
                          fontSize: 32.0,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.05),
                      Expanded(
                        child: SizedBox(
                          height: constraints.maxHeight * 0.6,
                          child: PageView(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              SignInForm(
                                onToggle: _toggleView,
                              ),
                              SignUpForm(
                                onSignUpSucess: _handleSignUpSuccess,
                                onToggle: _toggleView,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
