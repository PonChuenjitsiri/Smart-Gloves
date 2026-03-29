import 'package:flutter/material.dart';
import 'package:cepfrontend/pages/manual_page.dart';
import 'package:cepfrontend/pages/language_page.dart';
import 'package:cepfrontend/pages/gloves_page.dart';
import 'package:esp_smartconfig/esp_smartconfig.dart'; // 🌟 เพิ่ม import นี้
import 'package:mobile_scanner/mobile_scanner.dart';

class SmartGloveHome extends StatefulWidget {
  const SmartGloveHome({super.key});

  @override
  State<SmartGloveHome> createState() => _SmartGloveHomeState();
}

class _SmartGloveHomeState extends State<SmartGloveHome> {
  String currentDeviceId = "Not Connected";
  bool _isProvisioning = false; // 🌟 เพิ่มสถานะกำลังค้นหาบอร์ด

  // ตัวแปรเก็บค่า WiFi
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ==========================================
  // 🌟 ฟังก์ชันแสดง Pop-up ให้กรอก WiFi
  // ==========================================
  // ==========================================
  // 🌟 ฟังก์ชันแสดง Pop-up ให้กรอก WiFi (ฉบับโชว์ Device ID)
  // ==========================================
  void _showWifiDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // ป้องกันการกดปิดโดยไม่ตั้งใจ
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("ตั้งค่าการเชื่อมต่อ",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🌟 แสดง Device ID ที่สแกนมาได้
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.qr_code_scanner, color: Colors.blue, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "อุปกรณ์: ${scannedDeviceId ?? 'ไม่ระบุ'}", // โชว์ MAC ที่สแกนได้
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Text(
                  "กรุณากรอก WiFi ที่มือถือของคุณกำลังเชื่อมต่ออยู่ (รองรับ 2.4GHz เท่านั้น)",
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 15),
              TextField(
                controller: _ssidController,
                decoration: InputDecoration(
                  labelText: 'ชื่อ WiFi (SSID)',
                  prefixIcon: const Icon(Icons.wifi),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'รหัสผ่าน WiFi',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => scannedDeviceId = null); // เคลียร์ค่า ID ทิ้ง
                Navigator.pop(context);
              },
              child: const Text("ยกเลิก", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); 
                _startSmartConfig(
                    _ssidController.text, _passwordController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2260FF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("เริ่มเชื่อมต่อ",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  String? scannedDeviceId; // 🌟 เก็บค่า ID ที่สแกนได้จาก QR

// ==========================================
// 🌟 1. ฟังก์ชันเปิดกล้องสแกน QR Code
// ==========================================
  void _openQRScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black, // เปลี่ยนพื้นหลังเป็นสีดำให้ดูเหมือนกล้อง
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8, // ขยายให้สูงขึ้นหน่อย
        child: Column(
          children: [
            // 🌟 เพิ่มส่วนหัวบอกผู้ใช้
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("สแกน QR Code ที่ถุงมือ", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))
                ],
              ),
            ),
            // ตัวสแกน
            Expanded(
              child: MobileScanner(
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (barcode.rawValue != null) {
                      setState(() {
                        scannedDeviceId = barcode.rawValue;
                      });
                      Navigator.pop(context); // ปิดกล้อง
                      _showWifiDialog(); // 🌟 พอกล้องปิด จะเปิดหน้ากรอก WiFi ทันที
                      break;
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

// ==========================================
// 🌟 2. ปรับฟังก์ชัน SmartConfig ให้ "กรอง" เฉพาะ ID ที่สแกนมา
// ==========================================
  Future<void> _startSmartConfig(String ssid, String password) async {
  setState(() => _isProvisioning = true);
  final provisioner = Provisioner.espTouch();

  // ✅ ลบ "final subscription =" ออก เหลือแค่การเรียก listen ตรงๆ
  provisioner.listen((response) { 
    String macFromBoard = response.bssid
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join('')
        .toUpperCase();
    String detectedId = "GLOVE_$macFromBoard";

    if (scannedDeviceId == null || detectedId == scannedDeviceId) {
      setState(() {
        currentDeviceId = detectedId;
        _isProvisioning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('เชื่อมต่อตรงรุ่นสำเร็จ!'),
            backgroundColor: Colors.green),
      );
      provisioner.stop();
    }
  });

  await provisioner.start(ProvisioningRequest.fromStrings(
    ssid: ssid,
    bssid: '00:00:00:00:00:00',
    password: password,
  ));
}

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor != Colors.transparent
        ? Theme.of(context).primaryColor
        : const Color(0xFF2260FF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 60),
              color: primaryColor,
              child: Column(
                children: const [
                  Text(
                    "สารมือ",
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "ให้ทุกการสื่อสารเป็นไปได้",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("เปลี่ยนภาษามือให้เป็นเสียง..."),
                  const Text("เชื่อมต่อถุงมือของคุณเพื่อเริ่มต้น"),

                  const SizedBox(height: 20),

                  // กล่องแสดงสถานะ Device ID ปัจจุบัน
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: currentDeviceId == "Not Connected"
                          ? Colors.grey[200]
                          : Colors.green[50],
                      border: Border.all(
                        color: currentDeviceId == "Not Connected"
                            ? Colors.grey[400]!
                            : Colors.green,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          currentDeviceId == "Not Connected"
                              ? Icons.phonelink_off
                              : Icons.phonelink_setup,
                          color: currentDeviceId == "Not Connected"
                              ? Colors.grey[600]
                              : Colors.green,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Device ID",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: currentDeviceId == "Not Connected"
                                      ? Colors.grey[600]
                                      : Colors.green[800],
                                ),
                              ),
                              Text(
                                currentDeviceId,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: currentDeviceId == "Not Connected"
                                      ? Colors.black54
                                      : Colors.green[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ==========================================
                  // 🌟 ปุ่มวงกลมใหญ่ตรงกลาง สำหรับเริ่ม SmartConfig
                  // ==========================================
                  Center(
                    child: GestureDetector(
                      onTap: _isProvisioning ? null : _openQRScanner,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _isProvisioning ? 160 : 180,
                        height: _isProvisioning ? 160 : 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              _isProvisioning ? Colors.grey[400] : primaryColor,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (_isProvisioning ? Colors.grey : primaryColor)
                                      .withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isProvisioning)
                              const CircularProgressIndicator(
                                  color: Colors.white)
                            else
                              const Icon(Icons.wifi_tethering,
                                  size: 60, color: Colors.white),
                            const SizedBox(height: 10),
                            Text(
                              _isProvisioning
                                  ? "กำลังค้นหา\nถุงมือ..."
                                  : "ส่งรหัส WiFi\nให้ถุงมือ",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  Row(
                    children: [
                      _buildMenuButton(
                        context,
                        "วิธีการใช้แอพ",
                        Icons.lightbulb,
                        Colors.grey[200]!,
                        const ManualPage(),
                      ),
                      const SizedBox(width: 15),
                      _buildMenuButton(
                        context,
                        "คู่มือภาษา",
                        Icons.book,
                        Colors.grey[200]!,
                        const LanguageManualPage(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "ติดต่อรับบริการและข้อมูลข่าวสาร",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  _buildContactCard(
                    "มูลนิธิอนุเคราะห์คนหูหนวกในพระบรมราชินูปถัมภ์",
                    "02-241-5169",
                    "Deafthaifoundation",
                    "info@deafthai.org",
                  ),
                  const SizedBox(height: 15),
                  _buildContactCard(
                    "สมาคมคนหูหนวกแห่งประเทศไทย ",
                    "02-012-7459",
                    "สมาคมคนหูหนวกแห่งประเทศไทย ",
                    "nadt.info@gmail.com",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LanguageManualPage(),
              ),
            );
          } else if (index == 0) {
            if (currentDeviceId == "Not Connected") {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('กรุณาเชื่อมต่อถุงมือก่อนใช้งาน'),
                    backgroundColor: Colors.orange),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        GlovesPage(deviceId: currentDeviceId)),
              );
            }
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.front_hand),
            label: 'Gloves',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Manuals',
          ),
        ],
        currentIndex: 1,
        selectedItemColor: const Color(0xFF2260FF),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon,
      Color bgColor, Widget targetPage) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => targetPage));
          },
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: bgColor, borderRadius: BorderRadius.circular(15)),
            child: Row(
              children: [
                Icon(icon, size: 30, color: Colors.grey[700]),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w500))),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(
      String title, String phone, String facebook, String email) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Color(0xFF2260FF), fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _contactItem(Icons.phone, phone),
          if (facebook.isNotEmpty) _contactItem(Icons.facebook, facebook),
          _contactItem(Icons.email, email),
        ],
      ),
    );
  }

  Widget _contactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
