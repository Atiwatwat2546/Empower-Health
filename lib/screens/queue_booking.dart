import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QueueBookingPage extends StatefulWidget {
  @override
  _QueueBookingPageState createState() => _QueueBookingPageState();
}

class _QueueBookingPageState extends State<QueueBookingPage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _allergyDetailsController =
      TextEditingController();
  final TextEditingController _otherSymptomController =
      TextEditingController(); // เพิ่มฟิลด์กรอกอาการอื่นๆ

  String? _selectedTime;
  String? _selectedSymptom;
  String? _selectedAllergy;
  String? _selectedGender;
  int _selectedAge = 20;
  double _selectedWeight = 50.0;
  double _selectedHeight = 160.0;

  final List<String> _timeSlots = [
    '08:00 - 10:00',
    '10:00 - 12:00',
    '13:00 - 15:00',
    '15:00 - 17:00',
  ];
  final List<String> _symptoms = [
    'ไข้',
    'ไอ',
    'เจ็บคอ',
    'ปวดหัว',
    'คลื่นไส้',
    'อื่นๆ',
  ]; // เพิ่ม "อื่นๆ" ในรายการ
  final List<String> _allergies = [
    'ไม่มี',
    'แพ้ยาบางชนิด',
    'แพ้อาหาร',
    'แพ้ฝุ่น',
  ];
  final List<String> _genders = ['ชาย', 'หญิง', 'ไม่ระบุ'];

  // ฟังก์ชั่นเลือกวัน
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  // บันทึกข้อมูลการจองลง Firestore
  void _saveBookingToFirestore() async {
    if (_dateController.text.trim().isEmpty || _selectedTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("กรุณาเลือกวันและเวลา")));
      return;
    }

    final datePattern = RegExp(r'^\d{1,2}/\d{1,2}/\d{4}$');
    if (!datePattern.hasMatch(_dateController.text)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("รูปแบบวันที่ไม่ถูกต้อง")));
      return;
    }

    DateTime selectedDate;
    try {
      List<String> dateParts = _dateController.text.split('/');
      selectedDate = DateTime(
        int.parse(dateParts[2]), // Year
        int.parse(dateParts[1]), // Month
        int.parse(dateParts[0]), // Day
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาดในการแปลงวันที่")));
      return;
    }

    final now = DateTime.now();
    final selectedTimeParts = _selectedTime!.split(' - ');
    final selectedStartTime = selectedDate.add(
      Duration(
        hours: int.parse(selectedTimeParts[0].split(':')[0]),
        minutes: int.parse(selectedTimeParts[0].split(':')[1]),
      ),
    );

    if (selectedStartTime.isBefore(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ไม่สามารถเลือกเวลาที่เลยไปแล้วได้")),
      );
      return;
    }

    // ตรวจสอบจำนวนการจองใน Firestore
    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('QueueBooking')
            .where('Date', isEqualTo: Timestamp.fromDate(selectedDate))
            .where('Time', isEqualTo: _selectedTime)
            .get();

    if (querySnapshot.docs.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "การจองช่วงเวลาและวันดังกล่าวเต็มแล้ว โปรดเลือกช่วงเวลาอื่นหรือวันอื่น",
          ),
        ),
      );
      return;
    }

    // แสดงตัวโหลดขณะบันทึกข้อมูล
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseFirestore.instance.collection('QueueBooking').add({
        'Date': Timestamp.fromDate(selectedDate),
        'Time': _selectedTime,
        'Symptom':
            _selectedSymptom == 'อื่นๆ'
                ? _otherSymptomController.text
                : _selectedSymptom,
        'Allergy': _selectedAllergy,
        'AllergyDetails': _allergyDetailsController.text.trim(),
        'Gender': _selectedGender,
        'Age': _selectedAge,
        'Weight': _selectedWeight,
        'Height': _selectedHeight,
        'Detail': _detailsController.text.trim(),
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("จองคิวสำเร็จ!")));

      // ล้างข้อมูลหลังจากบันทึกสำเร็จ
      _dateController.clear();
      _detailsController.clear();
      _allergyDetailsController.clear();
      _otherSymptomController.clear();
      setState(() {
        _selectedTime = null;
        _selectedSymptom = null;
        _selectedAllergy = null;
        _selectedGender = null;
        _selectedAge = 20;
        _selectedWeight = 50.0;
        _selectedHeight = 160.0;
      });
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('จองคิวออนไลน์', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 14, 60, 146),
      ),
      body: Container(
        color: const Color.fromARGB(
          255,
          235,
          235,
          235,
        ), // กำหนดสีพื้นหลังที่ต้องการ
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "เลือกวันและเวลาจองคิว",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),

            SizedBox(height: 20),
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "เลือกวันที่",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: _selectDate,
                ),
              ),
            ),

            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedTime,
              hint: Text("เลือกช่วงเวลา"),
              items:
                  _timeSlots.map((String time) {
                    return DropdownMenuItem<String>(
                      value: time,
                      child: Text(time),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTime = value;
                });
              },
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),

            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSymptom,
              hint: Text("เลือกอาการ"),
              items:
                  _symptoms.map((String symptom) {
                    return DropdownMenuItem<String>(
                      value: symptom,
                      child: Text(symptom),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSymptom = value;
                });
              },
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),

            Visibility(
              visible:
                  _selectedSymptom ==
                  'อื่นๆ', // ถ้าเลือก "อื่นๆ" จะทำให้กล่องแสดง
              child: Column(
                children: [
                  SizedBox(height: 10),
                  TextField(
                    controller: _otherSymptomController,
                    decoration: InputDecoration(
                      labelText: "ระบุอาการ",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedAllergy,
              hint: Text("เลือกการแพ้ยา"),
              items:
                  _allergies.map((String allergy) {
                    return DropdownMenuItem<String>(
                      value: allergy,
                      child: Text(allergy),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAllergy = value;
                });
              },
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),

            Visibility(
              visible:
                  _selectedAllergy ==
                  'แพ้ยาบางชนิด', // หากเลือก "แพ้ยาบางชนิด" จะทำให้กล่องแสดง
              child: Column(
                children: [
                  SizedBox(height: 16),
                  TextField(
                    controller: _allergyDetailsController,
                    decoration: InputDecoration(
                      labelText: "ระบุยาที่แพ้",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),
            Text("เพศ", style: TextStyle(color: Colors.black)),
            Row(
              children:
                  _genders.map((gender) {
                    return Expanded(
                      child: RadioListTile<String>(
                        title: Text(gender),
                        value: gender,
                        groupValue: _selectedGender,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                      ),
                    );
                  }).toList(),
            ),

            SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "อายุ",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _selectedAge = int.tryParse(value) ?? 0;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "น้ำหนัก (กก.)",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _selectedWeight = double.tryParse(value) ?? 50.0;
                });
              },
            ),

            SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "ส่วนสูง (ซม.)",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _selectedHeight = double.tryParse(value) ?? 160.0;
                });
              },
            ),

            SizedBox(height: 16),
            TextField(
              controller: _detailsController,
              decoration: InputDecoration(
                labelText: "รายละเอียดเพิ่มเติม",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveBookingToFirestore,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0E3C92),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                minimumSize: Size(1000, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "บันทึกการจอง",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
