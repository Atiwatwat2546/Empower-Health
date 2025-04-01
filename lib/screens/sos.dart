import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SOSPage extends StatefulWidget {
  @override
  _SOSPageState createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage> {
  bool _isSendingSOS = false;
  TextEditingController _helpController = TextEditingController();

  Future<void> _confirmAndSendSOS() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("ยืนยันการส่ง SOS",style: TextStyle(color: Colors.red),),
          content: Text("คุณแน่ใจหรือไม่ว่าต้องการส่ง SOS?",style: TextStyle(color: Colors.red),),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("ยกเลิก",style: TextStyle(color: Colors.red),),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _sendSOS();
              },
              child: Text("ยืนยัน",style: TextStyle(color: Colors.blue),),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendSOS() async {
    if (_helpController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "โปรดระบุประเภทความช่วยเหลือ",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      _isSendingSOS = true;
    });

    try {
      Position position = await _getCurrentLocation();
      await FirebaseFirestore.instance.collection('SOS_alert').add({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'help_type': _helpController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Fluttertoast.showToast(
        msg: "🚨 SOS ถูกส่งแล้ว! เจ้าหน้าที่กำลังดำเนินการ",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "ไม่สามารถส่ง SOS ได้: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }

    setState(() {
      _isSendingSOS = false;
      _helpController.clear();
    });
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SOS ขอความช่วยเหลือ'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: Container(
                color: const Color.fromARGB(255, 224, 224, 224), 
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.warning, size: 80, color: Colors.red),
                    SizedBox(height: 10),
                    Text(
                      "หากคุณต้องการความช่วยเหลือ\nกรุณากดปุ่มส่ง SOS\nเพื่อส่งคำร้องและตำแหน่งของคุณให้กับเจ้าหน้าที่",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _helpController,
              decoration: InputDecoration(
                labelText: "ระบุประเภทความช่วยเหลือ",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.help_outline),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 20),
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _isSendingSOS ? null : _confirmAndSendSOS,
              child: _isSendingSOS
                  ? SpinKitThreeBounce(
                      color: Colors.white,
                      size: 30.0,
                    ) 
                  : Text(
                      '📢 ส่ง SOS',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
