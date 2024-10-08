import 'package:flutter/material.dart';
import 'package:gallery_app/screen/auth/auth_screen.dart';
import 'package:gallery_app/screen/home/home_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:gallery_app/screen/auth/service/auth_service.dart';

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
    final AuthService authService = AuthService();
    final String token = await authService.getToken();

    if (token != null && token.isNotEmpty) {
      final bool isExpired = await authService.isExpired(token);

      if (isExpired) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                AuthScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      }
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => AuthScreen(),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
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
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Created by Kevin Andra',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
