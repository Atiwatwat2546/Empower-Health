import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:my_app/FadeTransition.dart';
import 'firebase_options.dart';
import 'screens/queue_booking.dart';
import 'screens/dashboard.dart';
import 'screens/login_page.dart';
import 'package:flutter_svg/svg.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
  runApp(EmpowerApp());
}

class EmpowerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // ปิด Debug Banner ตรงนี้
      title: 'Health Power',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'K2D',
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
          labelLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with  SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOutCubic),
    );
    Future.delayed(Duration(seconds: 3), () {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 98, 160, 226),
              Color.fromARGB(255, 2, 11, 138),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: SvgPicture.asset(
                          'assets/images/health-svgrepo-com.svg',
                          height: 180,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
              SizedBox(height: 16),
              Text(
                'Empower Health',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              SizedBox(height: 100),
              SpinKitThreeBounce (color: Colors.white, size: 50.0),
            ],
          ),
        ),
      ),
    );
  }
}
