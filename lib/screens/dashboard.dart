import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'notification_service.dart'; // เพิ่มการ import notification_service.dart

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final CollectionReference _queueCollection = FirebaseFirestore.instance
      .collection('QueueBooking');

  // สร้างตัวแปรสำหรับบริการแจ้งเตือน
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _deleteExpiredBookings(); // ลบข้อมูลที่เลยเวลาอัตโนมัติ
    _notificationService.initializeNotifications(); // เริ่มต้นการแจ้งเตือน
  }

  // ฟังก์ชันลบการจองที่หมดอายุ
  void _deleteExpiredBookings() async {
    QuerySnapshot snapshot = await _queueCollection.get();
    DateTime now = DateTime.now();

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      var date = (data['Date'] as Timestamp?)?.toDate();

      if (date != null && date.isBefore(now)) {
        await _queueCollection.doc(doc.id).delete();
        print("ลบการจองที่เลยเวลาแล้ว: ${doc.id}");
      }
    }
  }

  void _deleteBooking(String docId) async {
    try {
      await _queueCollection.doc(docId).delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("ลบการจองสำเร็จ!")));
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาดในการลบ: $error")));
    }
  }

  // ฟังก์ชันนี้จะถูกใช้ในการส่งการแจ้งเตือน 1 ชั่วโมงก่อนนัดหมาย
  void _scheduleNotification(DateTime dateTime) {
    _notificationService.scheduleNotification(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(color: Color.fromARGB(255, 157, 211, 255)),
        ),
        backgroundColor: Color.fromARGB(255, 30, 89, 179),
      ),
      body: Column(
        children: [
          // ช่องแสดงข้อมูลสุขภาพ (ด้านบน)
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 30, 89, 179),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.health_and_safety,
                      size: 36,
                      color: Color.fromARGB(255, 157, 211, 255),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Empower Health",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 157, 211, 255),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  "ดูแลสุขภาพของคุณอย่างเต็มที่ ด้วยการตรวจสุขภาพที่เหมาะสมและการติดตามอย่างต่อเนื่อง",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 157, 211, 255),
                  ),
                ),
                SizedBox(height: 20),
                // ข้อมูลประวัติการเข้ารับบริการ
                Text(
                  "ประวัติการเข้ารับการบริการ",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 157, 211, 255),
                  ),
                ),
                SizedBox(height: 10),
                _buildHistoryRow("2025-03-22", "ตรวจสุขภาพประจำปี"),
                _buildHistoryRow("2025-02-15", "ตรวจร่างกายทั่วไป"),
                SizedBox(height: 20),
                // สถิติสุขภาพล่าสุด
                Text(
                  "สถิติสุขภาพล่าสุด",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 157, 211, 255),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatRow("น้ำหนัก: 70kg"),
                        _buildStatRow("ความดัน: 120/80 mmHg"),
                        _buildStatRow("อุณหภูมิ: 36.5°C"),
                      ],
                    ),
                    Icon(
                      Icons.trending_up,
                      size: 36,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // ช่องแสดงรายการการจอง (ด้านล่าง)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  _queueCollection
                      .orderBy('Date', descending: false)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: SpinKitThreeBounce(
                      color: Colors.blue, // หรือสีที่คุณต้องการ
                      size: 50.0, // ขนาดของ spinkit
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("ไม่มีการจองคิว"));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var data = doc.data() as Map<String, dynamic>;

                    var date = (data['Date'] as Timestamp?)?.toDate();
                    var time = data['Time'] ?? "-";
                    var symptom = data['Symptom'] ?? "ไม่มีอาการ";
                    var detail = data['Detail'] ?? "ไม่มีรายละเอียด";

                    // ตั้งค่าการแจ้งเตือน 1 ชั่วโมงก่อนนัดหมาย
                    if (date != null) {
                      _scheduleNotification(date);
                    }

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                      child: ListTile(
                        title: Text(
                          date != null
                              ? "วันที่: ${date.day}/${date.month}/${date.year}"
                              : "ไม่พบวันที่",
                        ),
                        subtitle: Text("เวลา: $time\nอาการ: $symptom"),
                        trailing: Icon(Icons.arrow_forward_ios, size: 18),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: Text(
                                    "รายละเอียดการจอง",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 21, 19, 128),
                                    ),
                                  ),
                                  content: Text(
                                    "วันที่: ${date?.day}/${date?.month}/${date?.year}\n"
                                    "เวลา: $time\n"
                                    "อาการ: $symptom\n"
                                    "รายละเอียด: $detail",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 21, 19, 128),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("ปิด"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                          context,
                                        ); // ปิด Dialog หลักก่อน
                                        showDialog(
                                          context: context,
                                          builder:
                                              (context) => AlertDialog(
                                                title: Text(
                                                  "ยืนยันการลบ",
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                content: Text(
                                                  "คุณแน่ใจหรือไม่ว่าต้องการลบการจองนี้?",
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          context,
                                                        ),
                                                    child: Text("ยกเลิก"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      _deleteBooking(
                                                        doc.id,
                                                      ); // ลบข้อมูลจริง
                                                    },
                                                    child: Text(
                                                      "ยืนยัน",
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        );
                                      },
                                      child: Text(
                                        "ลบ",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันสร้างช่องประวัติการบริการ
  Widget _buildHistoryRow(String date, String service) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 13, 26, 99),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            size: 20,
            color: Color.fromARGB(255, 157, 211, 255),
          ),
          SizedBox(width: 10),
          Text(
            "$date: $service",
            style: TextStyle(
              fontSize: 16,
              color: Color.fromARGB(255, 157, 211, 255),
            ),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันสร้างช่องแสดงสถิติ
  Widget _buildStatRow(String stat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(Icons.info, size: 18, color: Color.fromARGB(255, 157, 211, 255)),
          SizedBox(width: 10),
          Text(
            stat,
            style: TextStyle(
              fontSize: 16,
              color: Color.fromARGB(255, 157, 211, 255),
            ),
          ),
        ],
      ),
    );
  }
}
