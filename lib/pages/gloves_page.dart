import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_tts/flutter_tts.dart';

class GlovesPage extends StatefulWidget {
  
  final String deviceId; // 1. เพิ่มตัวแปรรับค่า Device ID

  // 2. บังคับให้ตอนเรียกหน้านี้ ต้องส่ง deviceId มาด้วย
  const GlovesPage({super.key, required this.deviceId});

  @override
  State<GlovesPage> createState() => _GlovesPageState();
}

class MessageBubble {
  final String thaiText;
  final String engText;
  final DateTime time;

  MessageBubble({
    required this.thaiText,
    required this.engText,
    required this.time,
  });
}

class _GlovesPageState extends State<GlovesPage> {
  final FlutterTts _flutterTts = FlutterTts();
  WebSocketChannel? _channel;
  final ScrollController _scrollController = ScrollController();

  // สถานะจาก Backend
  String gloveStatus = "offline";
  String activityState = "idle";
  bool isRecording = false; // สำหรับเช็คว่ากำลังทำท่าทางอยู่หรือไม่
  String calRound = "0";     // สำหรับโหมด Calibrate
  bool isWsConnected = false;

  // รายการข้อความที่แปลแล้ว (ใส่ Mockup เริ่มต้นไว้ 1 ประโยค)
  List<MessageBubble> messages = [
    // MessageBubble(
    //   thaiText: "สวัสดีครับ",
    //   engText: "Hello",
    //   time: DateTime.now(),
    // )
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
    _connectWS();
  }

  void _initTts() async {
    // 1. Use the system default engine (Do not force any specific engine)
    
    // 2. Await speech completion so overlapping speech doesn't cancel out
    await _flutterTts.awaitSpeakCompletion(true);

    // 3. Set basic properties
    await _flutterTts.setVolume(1.0);      // ความดังเสียงสูงสุด (1.0)
    await _flutterTts.setSpeechRate(0.5);  // ความเร็วในการพูด (0.0 - 1.0)
    await _flutterTts.setPitch(1.0);       // ระดับเสียง

    // 4. Check if Thai is available, then set it
    var isAvailable = await _flutterTts.isLanguageAvailable("th-TH");
    if (isAvailable) {
      await _flutterTts.setLanguage("th-TH");
      print("TTS: th-TH is set successfully.");
    } else {
      print("TTS: th-TH is not available on this device! Trying default Thai.");
      await _flutterTts.setLanguage("th");
    }
  }

  // สร้างฟังก์ชันเฉพาะสำหรับเรียกให้พูด
  Future<void> _speakText(String text) async {
    if (text.isNotEmpty) {
      try {
        var result = await _flutterTts.speak(text);
        print("TTS Speak Result: $result for text: $text");
      } catch (e) {
        print("TTS Speak Error: $e");
      }
    }
  }

  

  void _connectWS() {
    // แก้ตรงนี้ นำ widget.deviceId มาต่อ String
    final url = Uri.parse('ws://smb.pon-hub.com/api/glove/ws?device_id=${widget.deviceId}');
    
    print("Attempting to connect to WS: $url");

    try {
      _channel = WebSocketChannel.connect(url);
      _channel!.stream.listen(
        (message) {
          print("📥 Received WS message: $message"); // Debug print to see incoming raw data

          try {
            final data = jsonDecode(message);
            
            setState(() {
              isWsConnected = true;
              gloveStatus = data['status'] ?? gloveStatus;
              activityState = data['state'] ?? activityState;
              isRecording = data['recording'] ?? false;
              calRound = data['round']?.toString() ?? "0";
              
              // 2. Add message to Chat if it's marked as complete and has text
              if (data['complete'] == true && 
                  data['thai_word'] != null && 
                  data['thai_word'].toString().isNotEmpty) {
                
                messages.add(MessageBubble(
                  thaiText: data['thai_word'],
                  engText: data['eng_word'] ?? "",
                  time: DateTime.now(),
                ));
                
                _speakText(data['thai_word']);
                
                // 3. Auto-scroll to bottom
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });
              }
            });
          } catch (e) {
            print("❌ Error parsing JSON: $e");
          }
        },
        onDone: () {
          print("⚠️ WS Disconnected (onDone)");
          _handleDisconnect();
        },
        onError: (e) {
          print("❌ WS Error (onError): $e");
          _handleDisconnect();
        },
      );
    } catch (e) {
      print("❌ WS Connection Exception: $e");
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

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isOnline = gloveStatus == "online";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // สีพื้นหลังอ่อนๆ ให้เหมือนแอพแชท
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isOnline ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "Gloves Chat",
              style: TextStyle(
                color: Color(0xFF2260FF),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ส่วนแจ้งเตือนสถานะต่างๆ ไว้ด้านบน (เช่น กำลัง Calibrate หรือ กำลังรับค่า)
            if (activityState == "calibrate" || isRecording) 
              _buildStatusHeader(),

            // --- ส่วนประวัติข้อความแบบแชท ---
            Expanded(
              child: messages.isEmpty && activityState != "calibrate"
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return _buildChatBubble(messages[index]);
                      },
                    ),
            ),

            // --- พื้นที่ด้านล่างสุดแสดงสถานะภาพรวม ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
              ),
              child: Row(
                children: [
                  Icon(
                    isOnline ? Icons.front_hand : Icons.do_not_touch,
                    color: isOnline ? const Color(0xFF2260FF) : Colors.grey,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isOnline ? "Glove Connected" : "Glove Disconnected",
                    style: TextStyle(
                      color: isOnline ? const Color(0xFF2260FF) : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    if (activityState == "calibrate") {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        color: Colors.orange.withOpacity(0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
            ),
            const SizedBox(width: 10),
            Text(
              "Calibration Round $calRound - กรุณาทำท่าทางตามกำหนด",
              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }
    
    if (isRecording) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        color: const Color(0xFF2260FF).withOpacity(0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: Colors.red[500], shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              "กำลังรับค่าภาษามือ...",
              style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            "Waiting for gestures...",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "ข้อความที่แปลได้จะแสดงที่นี่",
            style: TextStyle(
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(MessageBubble message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // จัดให้อยู่ทางขวาเสมอ
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ปุ่มกดฟังเสียง ซ่อนอยู่ข้างๆ บับเบิ้ล
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, size: 24, color: Colors.grey),
            onPressed: () {
              print("Speaker button pressed for: ${message.thaiText}");
              _speakText(message.thaiText);
            },
            padding: const EdgeInsets.all(8),
            splashRadius: 24,
          ),
          const SizedBox(width: 8),
          
          // ตัวกล่องข้อความ
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF2260FF), // สีฟ้าหลักของแอพคุณ
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(4), // ติ่งชี้ไปทางขวา
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.thaiText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (message.engText.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      message.engText,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.time),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}