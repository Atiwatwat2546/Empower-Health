import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
                    _updateStatusInFirestore(user.uid); // ใช้ uid เพื่ออ้างอิง path เอกสาร
                    Future.delayed(Duration.zero, () {
                      Fluttertoast.showToast(
                        msg: "Email successfully verified!",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.CENTER,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
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
                      _updateStatusInFirestore(user.uid); // ใช้ uid เพื่ออ้างอิง path เอกสาร
                      Fluttertoast.showToast(
                        msg: "Email successfully verified!",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.CENTER,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage()),
                      );
                    } else {
                      // หากอีเมลยังไม่ได้รับการยืนยัน
                      Fluttertoast.showToast(
                        msg: "Please verify your email!",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.CENTER,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
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

  // ฟังก์ชันที่ใช้ในการอัพเดต status ของผู้ใช้ใน Firestore
  Future<void> _updateStatusInFirestore(String userUid) async {
    final userRef = FirebaseFirestore.instance.collection('User').doc(userUid); // ใช้ uid เพื่ออ้างอิง path ของเอกสาร

    // ตรวจสอบว่าเอกสารมีอยู่หรือไม่
    final docSnapshot = await userRef.get();
    if (docSnapshot.exists) {
      print("Document exists, updating status to 'yes'..."); // พิมพ์ข้อมูลเพื่อดีบัก
      // หากเอกสารมีอยู่ อัพเดต status เป็น 'yes'
      await userRef.update({'status': 'yes'}).then((_) {
        print("Status updated successfully!");
      }).catchError((e) {
        print("Error updating status: $e");
      });
    } else {
      print("Document not found, user UID: $userUid");
    }
  }
}
