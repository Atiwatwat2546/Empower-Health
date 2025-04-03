import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'package:my_app/screens/signup_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  bool _rememberMe = false;
  bool _obscurePassword = true; // สถานะซ่อน/แสดงรหัสผ่าน
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).requestFocus(_emailFocusNode);
    });
  }

  Future<void> _loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = prefs.getString("remembered_email") ?? "";
      _rememberMe = prefs.getBool("remember_me") ?? false;
    });
  }

  Future<void> _signIn() async {
    try {
      // ล็อกอินกับ Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // ดึงข้อมูลผู้ใช้จาก Firebase Authentication
      User? user = userCredential.user;
      if (user != null) {
        // ตรวจสอบ status ใน Firestore
        var userDoc =
            await FirebaseFirestore.instance
                .collection('User')
                .doc(user.uid)
                .get();

        if (userDoc.exists) {
          // ถ้า status เป็น 'yes'
          if (userDoc.data()?['status'] == 'yes') {
            // บันทึกข้อมูล email ใน SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            if (_rememberMe) {
              await prefs.setString(
                "remembered_email",
                _emailController.text.trim(),
              );
            } else {
              await prefs.remove("remembered_email");
            }
            await prefs.setBool("remember_me", _rememberMe);

            // ไปยังหน้า HomePage
            Navigator.pushAndRemoveUntil(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) => HomePage(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
              (Route<dynamic> route) => false, // ลบทุกหน้าก่อนหน้านี้ออก
            );

            // แสดง FlutterToast แจ้งเตือนเข้าสู่ระบบสำเร็จ
            Fluttertoast.showToast(
              msg: "เข้าสู่ระบบสำเร็จ!",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
          } else {
            // ถ้า status ไม่ใช่ 'yes'
            setState(() {
              _errorMessage = "บัญชีนี้ยังไม่ได้รับการอนุมัติ";
            });

            Fluttertoast.showToast(
              msg: "บัญชีนี้ยังไม่ได้รับการอนุมัติ",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          }
        } else {
          setState(() {
            _errorMessage = "ไม่พบข้อมูลผู้ใช้ในระบบ";
          });

          Fluttertoast.showToast(
            msg: "ไม่พบข้อมูลผู้ใช้ในระบบ",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });

      Fluttertoast.showToast(
        msg: "เกิดข้อผิดพลาด: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _resetPassword() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController _resetEmailController =
            TextEditingController();
        return AlertDialog(
          title: Text(
            "Reset Password",
            style: TextStyle(color: Colors.blue[900]),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Enter your email to receive a password reset link.",
                style: TextStyle(color: Colors.blue[900]),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _resetEmailController,
                decoration: InputDecoration(labelText: "Email"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // ปิด Popup
              },
              child: Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _auth.sendPasswordResetEmail(
                    email: _resetEmailController.text.trim(),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Password reset email sent! Please check your email.",
                        style: TextStyle(color: Colors.blue[900]),
                      ),
                    ),
                  );
                  Navigator.pop(context); // ปิด Popup หลังจากส่งอีเมลสำเร็จ
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString()}")),
                  );
                }
              },
              child: Text(
                "Send Reset Email",
                style: TextStyle(color: Colors.blue[900]),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
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
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 8,
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    decoration: InputDecoration(labelText: "Email"),
                    onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: "Password",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.blue[900],
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    onSubmitted: (_) => _signIn(),
                  ),
                  SizedBox(height: 10),

                  // ✅ Remember Me Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (newValue) {
                          setState(() {
                            _rememberMe = newValue!;
                          });
                        },
                      ),
                      Text(
                        "Remember Me",
                        style: TextStyle(color: Colors.blue[900], fontSize: 18),
                      ),
                    ],
                  ),

                  if (_errorMessage != null) ...[
                    SizedBox(height: 10),
                    Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                  ],
                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      padding: EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      minimumSize: Size(200, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Login",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),

                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                    child: Text(
                      "Don't have an account? Sign up",
                      style: TextStyle(color: Colors.blue[900]),
                    ),
                  ),

                  SizedBox(height: 10),
                  // ปุ่ม Forgot Password
                  TextButton(
                    onPressed: _resetPassword,
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.blue[900]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
