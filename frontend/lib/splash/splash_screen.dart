import 'package:flutter/material.dart';
import 'package:gallery_app/screen/auth/auth_screen.dart';
import 'package:gallery_app/screen/home/home_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isAnimationCompleted = false;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
  }

  void startFadeOut() {
    if (_isAnimationCompleted) {
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          _opacity = 0.0;
        });

        Future.delayed(const Duration(milliseconds: 500), () {
          navigateToNextScreen();
        });
      });
    }
  }

  Future<void> navigateToNextScreen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token != null) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              AuthScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 500),
        child: Center(
          child: LottieBuilder.asset(
            "assets/splash_screen/splash.json",
            animate: true,
            repeat: false,
            onLoaded: (composition) {
              Future.delayed(composition.duration, () {
                _isAnimationCompleted = true;
                startFadeOut();
              });
            },
          ),
        ),
      ),
    );
  }
}
