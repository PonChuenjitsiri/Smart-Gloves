import 'package:flutter/material.dart';

class ManualPage extends StatelessWidget {
  const ManualPage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2260FF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Header สีฟ้าพร้อมปุ่มย้อนกลับ ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 50, bottom: 30, left: 10),
              color: primaryColor,
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          "Application Manual",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Taviraj', // เรียกใช้ฟอนต์ที่นี่
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "วิธีการใช้งานแอพพลิเคชัน:",
                    style: TextStyle(
                      fontFamily: 'Taviraj',
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // --- เนื้อหาคู่มือ ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "ขั้นตอนการเชื่อมต่อ:",
                    style: TextStyle(
                      fontFamily: 'Taviraj',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildInstructionImage(Icons.settings),
                  
                  const SizedBox(height: 20),
                  _buildStepText("1. เข้าการตั้งค่าในโทรศัพท์ของคุณ"),
                  _buildStepText("2. ไปที่เมนู \"Wi-Fi\""),
                  _buildStepText("3. เลือกตัวเลือกที่เป็นชื่ออุปกรณ์ \"Smart-Gloves\""),
                  _buildStepText("4. เชื่อมต่อสำเร็จ"),
                  
                  const SizedBox(height: 30),
                  const Text(
                    "การเริ่มต้นใช้งาน:",
                    style: TextStyle(
                      fontFamily: 'Taviraj',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildInstructionImage(Icons.touch_app),
                  
                  const SizedBox(height: 20),
                  _buildStepText("5. กลับมาที่แอพพลิเคชัน ไปที่ Navbar \"Gloves\""),
                  _buildStepText("6. ตรวจสอบสถานะการเชื่อมต่อ ต้องเป็น \"Online\""),
                  _buildStepText("7. หากเป็น \"Offline\" ให้ไปตรวจสอบสถานะการเชื่อมต่ออีกครั้ง"),
                  _buildStepText("8. หากเป็น \"Online\" ให้ทำการรีเซ็ตค่าถุงมือแล้วเริ่มใช้งาน"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionImage(IconData icon) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Icon(icon, size: 80, color: const Color(0xFF2260FF)),
    );
  }

  Widget _buildStepText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Taviraj', // เรียกใช้ฟอนต์ที่นี่
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }
}