import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class GlovesPage extends StatefulWidget {
  const GlovesPage({super.key});

  @override
  State<GlovesPage> createState() => _GlovesPageState();
}

class _GlovesPageState extends State<GlovesPage> {
  final FlutterTts _flutterTts = FlutterTts();
  
  // จำลองสเตตัสการเชื่อมต่อ (ในอนาคตเชื่อมกับ Bluetooth/WiFi)
  bool isOnline = false; 
  
  // จำลองคำที่ได้รับจากถุงมือ (ถ้าเป็น null คือยังไม่มีการทำท่าทาง)
  Map<String, String>? currentSignal; 

  // ฟังก์ชันพูดออกเสียง
  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage("th-TH");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2260FF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Gloves", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- ส่วนแสดงผลกลางหน้าจอ (รูปภาพ + ข้อความ) ---
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (currentSignal == null) ...[
                    // กรณีที่ 1: ยังไม่มีการทำท่าทาง (รูปที่ 6)
                    // Image.asset('assets/hand_icon.png', height: 200, color: Colors.black),
                    Icon(
                      Icons.front_hand,
                      size: 160.0,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Hi There",
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, fontFamily: 'Taviraj'),
                    ),
                  ] else ...[
                    // กรณีที่ 2: มีการรับค่าและแปลผล (รูปที่ 5)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(currentSignal!['img']!, height: 250),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      currentSignal!['thai']!,
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      currentSignal!['eng']!,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Taviraj'),
                    ),
                    const SizedBox(height: 10),
                    // ปุ่มลำโพง Text to Speech
                    IconButton(
                      icon: const Icon(Icons.volume_up, size: 50, color: Colors.black),
                      onPressed: () => _speak(currentSignal!['thai']!),
                    ),
                  ],
                ],
              ),
            ),

            // --- ส่วนปุ่มสเตตัส Online/Offline ด้านล่าง ---
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: GestureDetector(
                onTap: () {
                  // ทดลองกดเพื่อเปลี่ยนสถานะ (Mockup)
                  setState(() {
                    isOnline = !isOnline;
                    if (isOnline) {
                      // จำลองว่าพอ Online แล้วมีคำว่า "สวัสดี" เข้ามา
                      currentSignal = {"thai": "สวัสดี", "eng": "Hello", "img": "assets/hello_image.jpg"};
                    } else {
                      currentSignal = null;
                    }
                  });
                },
                child: Container(
                  width: 250,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isOnline ? primaryColor : Colors.grey[600],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isOnline ? "Online" : "Offline",
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}