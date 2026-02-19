import 'package:flutter/material.dart';

class VocabularyDetailPage extends StatelessWidget {
  final String titleThai;
  final String titleEng;
  final String imagePath;
  final String signMethod;

  const VocabularyDetailPage({
    super.key,
    required this.titleThai,
    required this.titleEng,
    required this.imagePath,
    required this.signMethod,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2260FF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ส่วนบน: ใช้ Stack เพื่อจัดการส่วนหัวและรูปภาพที่ซ้อนกัน
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // 1. พื้นหลังสีฟ้า (Header) - ลบ height ออกเพื่อให้ยืดตามข้อความ
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 50,
                    bottom: 100,
                  ), // เพิ่ม bottom padding ให้รูปมีที่วาง
                  color: primaryColor,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          titleThai,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          titleEng,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. รูปภาพประกอบ (ขนาดเล็กลงและจัดวางกึ่งกลาง)
                // 2. รูปภาพประกอบ (ขนาดเล็กลงและจัดวางกึ่งกลาง)
                Positioned(
                  top: 180,
                  child: Container(
                    width: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: AspectRatio(
                      aspectRatio: 3 / 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: imagePath.startsWith('http')
                            ? Image.network(
                                imagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _placeholder(),
                              )
                            : _placeholder(),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 200),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Transform.translate(
                offset: const Offset(0, -40),
                child: Column(
                  // บังคับให้ Column จัดเรียงลูกๆ ชิดซ้ายทั้งหมด
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "วิธีการทำ:",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    // ใช้ Container หรือ SizedBox ครอบเพื่อให้แน่ใจว่าพื้นที่กางเต็มความกว้าง
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        // ใช้ .trim() เพื่อตัดช่องว่างหน้า-หลังที่อาจติดมาจาก Database
                        signMethod.trim().isNotEmpty
                            ? signMethod.trim()
                            : "ไม่มีรายละเอียดวิธีการทำ",
                        textAlign: TextAlign.left, // บังคับตัวหนังสือชิดซ้าย
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: Colors.grey[300],
    child: const Icon(Icons.image, size: 80, color: Colors.white),
  );
}
