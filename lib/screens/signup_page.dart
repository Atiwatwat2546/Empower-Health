import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  String? _gender = 'Male';
  bool _isChecked = false;
  String? _errorMessage;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _signUpSuccess = false;
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (!_isChecked)
      return setState(
        () => _errorMessage = 'You must accept the Terms & Conditions!',
      );
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      return setState(() => _errorMessage = 'Passwords do not match!');
    }

    // Show loading indicator
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear previous error messages
    });

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      await FirebaseFirestore.instance
          .collection('User')
          .doc(userCredential.user!.uid)
          .set({
            'fullName': _fullNameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'dob': _dobController.text.trim(),
            'gender': _gender,
            'email': _emailController.text.trim(),
          });

      setState(() {
        _signUpSuccess = true;
        _isLoading = false; // Hide loading indicator
      });

      // Wait for 2 seconds and then navigate to the login page
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false; // Hide loading indicator if there's an error
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(
        () =>
            _dobController.text =
                "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}",
      );
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscureText = false,
    VoidCallback? toggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon:
            toggleVisibility != null
                ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: toggleVisibility,
                )
                : null,
      ),
    );
  }

  // Helper Functions for Formatting
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue[900], // เปลี่ยนสีหัวข้อเป็นน้ำเงิน
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        content,
        style: TextStyle(
          color: Colors.blue[900], // เปลี่ยนสีเนื้อหาเป็นน้ำเงิน
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF62A0E2), Color(0xFF020B8A)],
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
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildTextField("Email", _emailController),
                  _buildTextField(
                    "Password",
                    _passwordController,
                    obscureText: !_isPasswordVisible,
                    toggleVisibility:
                        () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        ),
                  ),
                  _buildTextField(
                    "Confirm Password",
                    _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    toggleVisibility:
                        () => setState(
                          () =>
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible,
                        ),
                  ),
                  _buildTextField("Full Name", _fullNameController),
                  _buildTextField("Phone Number", _phoneController),
                  GestureDetector(
                    onTap: _selectDate,
                    child: AbsorbPointer(
                      child: _buildTextField("Date of Birth", _dobController),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        "Gender: ",
                        style: TextStyle(color: Colors.blue[900]),
                      ),
                      ...["Male", "Female", "Not specified"].map(
                        (g) => Row(
                          children: [
                            Radio(
                              value: g,
                              groupValue: _gender,
                              onChanged: (val) => setState(() => _gender = val),
                            ),
                            Text(g, style: TextStyle(color: Colors.blue[900])),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: _isChecked,
                        onChanged:
                            (val) => setState(() => _isChecked = val ?? false),
                      ),
                      GestureDetector(
                        onTap:
                            () => showDialog(
                              context: context,
                              builder:
                                  (_) => AlertDialog(
                                    title: Text(
                                      "Privacy Policy",
                                      style: TextStyle(
                                        color: Colors.blue[900],
                                      ), // เปลี่ยนสีหัวข้อ
                                    ),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildSectionTitle(
                                            "Effective Date: [25/03/2025]",
                                          ),
                                          _buildSectionTitle("1. Introduction"),
                                          _buildSectionContent(
                                            "Welcome to Empower Health. Your privacy is important to us. "
                                            "This Privacy Policy explains how we collect, use, and protect your personal data when you use our application.",
                                          ),
                                          _buildSectionTitle(
                                            "2. Information We Collect",
                                          ),
                                          _buildSectionContent(
                                            "We may collect the following types of information:\n\n"
                                            "- Personal Information: Name, email address, phone number, and other details you provide.\n"
                                            "- Usage Data: Information about how you use the app, including interactions and preferences.\n"
                                            "- Device Information: IP address, device type, and operating system details.",
                                          ),
                                          _buildSectionTitle(
                                            "3. How We Use Your Information",
                                          ),
                                          _buildSectionContent(
                                            "We use the collected information to:\n\n"
                                            "- Provide and improve our services.\n"
                                            "- Personalize user experience.\n"
                                            "- Ensure security and prevent fraud.\n"
                                            "- Communicate important updates.",
                                          ),
                                          _buildSectionTitle(
                                            "4. Data Sharing and Disclosure",
                                          ),
                                          _buildSectionContent(
                                            "We do not sell or rent your personal data. However, we may share it with:\n\n"
                                            "- Service providers assisting in app functionality.\n"
                                            "- Legal authorities if required by law.",
                                          ),
                                          _buildSectionTitle(
                                            "5. Data Security",
                                          ),
                                          _buildSectionContent(
                                            "We implement security measures to protect your personal data. "
                                            "However, no method of transmission over the internet is 100% secure.",
                                          ),
                                          _buildSectionTitle("6. Your Rights"),
                                          _buildSectionContent(
                                            "You have the right to:\n\n"
                                            "- Access, update, or delete your personal information.\n"
                                            "- Opt-out of certain data collection practices.",
                                          ),
                                          _buildSectionTitle(
                                            "7. Changes to This Policy",
                                          ),
                                          _buildSectionContent(
                                            "We may update this Privacy Policy from time to time. Any changes will be notified within the app.",
                                          ),
                                          _buildSectionTitle("8. Contact Us"),
                                          _buildSectionContent(
                                            "If you have any questions about this Privacy Policy, please contact us at [Your Contact Email].",
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          "OK",
                                          style: TextStyle(
                                            color: Colors.blue[900],
                                          ), // ปรับสีปุ่ม OK เป็นน้ำเงิน
                                        ),
                                      ),
                                    ],
                                  ),
                            ),
                        child: Text(
                          "I accept the Terms & Conditions",
                          style: TextStyle(
                            color: Colors.blue[900],
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_errorMessage != null)
                    Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                  if (_signUpSuccess)
                    Text(
                      "Sign Up Successful!",
                      style: TextStyle(color: Colors.green),
                    ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed:
                        () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginPage()),
                        ),
                    child: Text(
                      "Already have an account? Log in here.",
                      style: TextStyle(color: Colors.blue[900]),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      padding: EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      minimumSize: Size(1000, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isLoading
                            ? SpinKitThreeBounce(
                              color: Colors.white,
                              size: 50.0,
                            )
                            : Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
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
