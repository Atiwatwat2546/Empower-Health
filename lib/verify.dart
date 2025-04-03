import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_app/screens/login_page.dart';

class VerifyEmailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? ''; // ดึงอีเมลจาก currentUser

    return Scaffold(
      appBar: AppBar(
        title: Text("Verify Your Email"),
        backgroundColor: Colors.blue[900],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ข้อความแจ้งอีเมลที่ส่งไป
              Text(
                "A confirmation email has been sent to the email address ($userEmail). Please check your inbox and confirm your email to complete your registration.",
                style: TextStyle(fontSize: 16, color: Colors.blue[900]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              // ใช้ StreamBuilder เพื่อตรวจสอบสถานะการยืนยันอีเมลแบบเรียลไทม์
              StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  final user = snapshot.data;
                  if (user != null && user.emailVerified) {
                    // หากอีเมลได้รับการยืนยันแล้ว
                    _updateStatusToYes(user.uid); // อัพเดต status เป็น 'yes' ใน Firestore
                    Future.delayed(Duration.zero, () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Email successfully verified!")),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage()),
                      );
                    });
                    return Text('Email Verified');
                  } else {
                    // หากยังไม่ได้ยืนยันอีเมล
                    return Text('Please verify your email!');
                  }
                },
              ),
              SizedBox(height: 20),
              // ปุ่มตรวจสอบการยืนยัน
              ElevatedButton(
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    // ตรวจสอบการยืนยันอีเมล
                    await user.reload(); // รีเฟรชสถานะของผู้ใช้
                    if (user.emailVerified) {
                      // หากอีเมลได้รับการยืนยันแล้ว
                      _updateStatusToYes(user.uid); // อัพเดต status เป็น 'yes' ใน Firestore
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Email successfully verified!")),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage()),
                      );
                    } else {
                      // หากอีเมลยังไม่ได้รับการยืนยัน
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please verify your email!")),
                      );
                    }
                  }
                },
                child: Text("Check Verification Status"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ฟังก์ชันที่ใช้ในการอัพเดต status ของผู้ใช้ใน Firestore เป็น 'yes'
  Future<void> _updateStatusToYes(String uid) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    await userRef.update({'status': 'yes'});  // อัพเดตสถานะเป็น 'yes'
  }
}
