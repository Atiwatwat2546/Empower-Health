import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/screens/sos.dart';
import 'queue_booking.dart';
import 'dashboard.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  String userName = ''; // ตัวแปรเก็บชื่อผู้ใช้

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
    _getUserName();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _getUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      userName = user?.displayName ?? 'User';
    });
  }

  Future<bool> _onWillPop(BuildContext context) async {
    return false;  // ป้องกันการย้อนกลับ
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 30, 89, 179),
          title: Row(
            children: [
              Text(
                'Empower Health',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Text(
                userName,  // แสดงชื่อผู้ใช้
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 40),
                  _buildButton(context, 'จองคิว', QueueBookingPage()),
                  SizedBox(height: 16),
                  _buildButton(context, 'Dashboard', DashboardPage()),
                  SizedBox(height: 16),
                  _buildSOSButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Widget page) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[900],
        textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () async {
        await Firebase.initializeApp();
        _navigateWithFadeTransition(context, page);
      },
      child: Text(text),
    );
  }

  Widget _buildSOSButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        _navigateWithFadeTransition(context, SOSPage());
      },
      child: Text('SOS'),
    );
  }

  void _navigateWithFadeTransition(BuildContext context, Widget page) {
    Navigator.push(context, PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: page,
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ));
  }
}