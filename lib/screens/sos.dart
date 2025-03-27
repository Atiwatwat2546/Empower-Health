import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SOSPage extends StatefulWidget {
  @override
  _SOSPageState createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage> {
  bool _isSendingSOS = false;

  // ฟังก์ชันในการส่ง SOS
  Future<void> _sendSOS() async {
    setState(() {
      _isSendingSOS = true;
    });

    // ขอพิกัดปัจจุบัน
    Position position = await _getCurrentLocation();

    // ignore: unnecessary_null_comparison
    if (position != null) {
      // ส่งข้อมูลไปยัง Firestore
      FirebaseFirestore.instance.collection('SOS_alert').add({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // แสดงข้อความแจ้งเตือน
      Fluttertoast.showToast(
        msg: "🚨 ส่งสัญญาณขอความช่วยเหลือแล้ว!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } else {
      // ถ้าไม่สามารถรับพิกัดได้
      Fluttertoast.showToast(
        msg: "ไม่สามารถรับพิกัดได้",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }

    setState(() {
      _isSendingSOS = false;
    });
  }

  // ฟังก์ชันในการขอพิกัดปัจจุบัน
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // ตรวจสอบการให้สิทธิ์ในการเข้าถึงตำแหน่ง
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    // รับพิกัดปัจจุบัน
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SOS'),
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            backgroundColor: Colors.red,
          ),
          onPressed: _isSendingSOS ? null : _sendSOS, // ปิดปุ่มเมื่อกำลังส่ง SOS
          child: Text(
            _isSendingSOS ? 'กำลังส่ง...' : 'ส่ง SOS',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
    );
  }
}