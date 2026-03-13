import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_tts/flutter_tts.dart';

class GlovesPage extends StatefulWidget {
  const GlovesPage({super.key});

  @override
  State<GlovesPage> createState() => _GlovesPageState();
}

class _GlovesPageState extends State<GlovesPage> {
  final FlutterTts _flutterTts = FlutterTts();
  WebSocketChannel? _channel;

  // สถานะจาก Backend
  String gloveStatus = "offline";
  String activityState = "idle";
  String thaiWord = "";
  String engWord = "";
  bool isRecording = false; // สำหรับเช็คว่ากำลังทำท่าทางอยู่หรือไม่
  String calRound = "0";     // สำหรับโหมด Calibrate
  bool isWsConnected = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _connectWS();
  }

  void _initTts() async {
    await _flutterTts.setLanguage("th-TH");
  }

  void _connectWS() {
    // แก้ไข IP ให้ตรงกับเครื่อง Backend ของคุณ (10.0.2.2 สำหรับ Android Emulator)
    final url = Uri.parse('ws://10.0.2.2:8000/api/glove/ws?device_id=default');

    try {
      _channel = WebSocketChannel.connect(url);
      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          setState(() {
            isWsConnected = true;
            gloveStatus = data['status'];
            activityState = data['state'];
            
            // อัปเดตคำแปลเฉพาะเมื่อมีข้อมูลส่งมา (ช่วยให้ค้างคำเก่าไว้ได้)
            if (data['thai_word'] != null && data['thai_word'].toString().isNotEmpty) {
              thaiWord = data['thai_word'];
              engWord = data['eng_word'] ?? "";
            }
            
            isRecording = data['recording'] ?? false;
            calRound = data['round']?.toString() ?? "0";
          });

          // พูดอัตโนมัติเมื่อแปลเสร็จ (complete: true)
          if (data['complete'] == true && thaiWord.isNotEmpty) {
            _flutterTts.speak(thaiWord);
          }
        },
        onDone: () => _handleDisconnect(),
        onError: (e) => _handleDisconnect(),
      );
    } catch (e) {
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    if (mounted) {
      setState(() {
        isWsConnected = false;
        gloveStatus = "offline";
      });
    }
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isOnline = gloveStatus == "online";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Gloves",
          style: TextStyle(
            color: Color(0xFF2260FF),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // --- ส่วนแสดงผลกลางหน้าจอ (Dynamic Content) ---
            _buildMainDisplay(),

            const Spacer(flex: 3),

            // --- ปุ่มสถานะด้านล่าง (Online / Offline) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Container(
                width: double.infinity,
                height: 65,
                decoration: BoxDecoration(
                  color: isOnline ? const Color(0xFF2260FF) : const Color(0xFF757575),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Center(
                  child: Text(
                    isOnline ? "Online" : "Offline",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMainDisplay() {
    // 1. กรณีโหมด Calibrate
    if (activityState == "calibrate") {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Color(0xFF2260FF)),
          const SizedBox(height: 20),
          Text(
            "Calibration Round $calRound",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text("กรุณาทำท่าทางตามที่กำหนด", style: TextStyle(color: Colors.grey)),
        ],
      );
    }

    // 2. กรณีที่กำลังทำท่าทาง (isRecording) หรือ มีคำแปลค้างอยู่ (thaiWord)
    if (isRecording || thaiWord.isNotEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ส่วนแจ้งเตือนเมื่อกำลังทำท่าทาง
          if (isRecording)
            Padding(
              padding: const EdgeInsets.only(bottom: 20), 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // const Icon(Icons.circle, color: Colors.red, size: 12),
                  const SizedBox(width: 8),
                  Text(
                    "กรุณาทำท่าทางภาษามือ",
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

          Text(
            thaiWord,
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            engWord,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.black,                                                                                                                                                                           
            ),
          ),
          
          // แสดงปุ่มลำโพงเฉพาะเมื่อแปลเสร็จแล้ว (ไม่ได้กำลังอัด)
          if (!isRecording && thaiWord.isNotEmpty) ...[
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () => _flutterTts.speak(thaiWord),
              child: const Icon(
                Icons.volume_up_rounded,
                size: 80,
                color: Colors.black,
              ),
            ),
          ],
        ],
      );
    }

    // 3. สถานะเริ่มต้น (Idle)
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.front_hand,
          size: 180,
          color: Colors.black,
        ),
        const SizedBox(height: 40),
        const Text(
          "Hi There",
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.bold,
            fontFamily: 'Serif',
          ),
        ),
      ],
    );
  }
}