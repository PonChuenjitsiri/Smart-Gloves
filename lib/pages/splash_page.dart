import 'package:flutter/material.dart';
import 'package:sarnmue/pages/home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // หน่วงเวลา 3 วินาทีแล้วย้ายไปหน้า Home
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SmartGloveHome()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2260FF), // สีฟ้าหลักของคุณ
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ส่วนรูปมือ (ใช้ Icon แทนได้ถ้ายังไม่อยากใช้รูป)
            const Icon(
              Icons.front_hand,
              size: 150,
              color: Color(0xFFD9D9D9), // สีเทาอ่อนตามรูป
            ),
            const SizedBox(height: 20),
            // ตัวหนังสือ "สารมือ"
            const Text(
              "สารมือ",
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Taviraj',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
