import 'package:flutter/material.dart';

class VocabularyDetailPage extends StatelessWidget {
  final String titleThai;
  final String titleEng;
  final String imagePath;
  final String signMethod;
  final String category; // เพิ่มตัวแปร category

  const VocabularyDetailPage({
    super.key,
    required this.titleThai,
    required this.titleEng,
    required this.imagePath,
    required this.signMethod,
    this.category = "ทั่วไป", // กำหนดค่าเริ่มต้น
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2260FF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ส่วนบน: Header & Image
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // 1. พื้นหลัง Header สีฟ้า
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 60, // เพิ่มพื้นที่ด้านบน
                    bottom: 120, // เพิ่มพื้นที่ด้านล่างเพื่อให้รูปวางต่ำลง
                  ),
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      // ปุ่ม Back ขนาดใหญ่ขึ้น
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: IconButton(
                            icon: const Icon(
                              Icons
                                  .arrow_back_ios_new, // ใช้ไอคอนที่ดูโมเดิร์นขึ้น
                              color: Colors.white,
                              size: 35, // ปรับปุ่มให้ใหญ่ขึ้นตามต้องการ
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                      // หัวข้อภาษาไทย
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          titleThai,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // หัวข้อภาษาอังกฤษ
                      Text(
                        titleEng,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // แสดงหมวดหมู่ (Category Badge)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "หมวดหมู่: $category",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. รูปภาพประกอบ (เลื่อนลงมาต่ำกว่าเดิม)
                Positioned(
                  top: 260, // ปรับค่าจาก 180 เป็น 240 เพื่อให้รูปอยู่ต่ำลง
                  child: Container(
                    width: 200, // ขยายขนาดรูปเล็กน้อย
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: AspectRatio(
                      aspectRatio: 3 / 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child:
                            imagePath.isNotEmpty && imagePath.startsWith('http')
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

            // ระยะห่างเพื่อให้พ้นตัวรูปภาพที่ลอยอยู่
            const SizedBox(height: 220),

            // ส่วนเนื้อหาด้านล่าง
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.accessibility_new,
                        color: primaryColor,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "วิธีการทำ:",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F5FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: primaryColor.withOpacity(0.1)),
                    ),
                    child: Text(
                      signMethod.trim().isNotEmpty
                          ? signMethod.trim()
                          : "ไม่มีรายละเอียดวิธีการทำ",
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: Colors.grey[200],
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
        SizedBox(height: 8),
        Text("ไม่มีรูปภาพ", style: TextStyle(color: Colors.grey)),
      ],
    ),
  );
}
