import 'package:flutter/material.dart';
import 'package:sarnmue/pages/manual_page.dart';
import 'package:sarnmue/pages/language_page.dart';
import 'package:sarnmue/pages/gloves_page.dart';
import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';

// 🌟 1. เพิ่ม import สำหรับแสกน Wi-Fi
import 'package:wifi_scan/wifi_scan.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class SmartGloveHome extends StatefulWidget {
  const SmartGloveHome({super.key});

  @override
  State<SmartGloveHome> createState() => _SmartGloveHomeState();
}

class _SmartGloveHomeState extends State<SmartGloveHome> {
  String currentDeviceId = "Not Connected";
  bool _isProvisioning = false;

  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? scannedDeviceId;

  // ==========================================
  // 🌟 3. ฟังก์ชันเช็คสถานะ Online ผ่าน WebSocket
  // ==========================================
  Future<void> _checkDeviceOnlineStatus(String deviceId) async {
    // 1. แสดง Dialog โหลดดิ่งให้รู้ว่ากำลังตรวจสอบ
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 15),
            Text("กำลังตรวจสอบสถานะอุปกรณ์...", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );

    try {
      // 2. พยายามเชื่อมต่อ WebSocket
      final wsBaseUrl = dotenv.env['WEBSOCKET_URL'] ?? 'wss://smb.pon-hub.com/api/glove/ws';
      final wsUrl = Uri.parse('$wsBaseUrl?device_id=$deviceId');
      final channel = WebSocketChannel.connect(wsUrl);

      // ตั้ง Timeout ไว้ที่ 3 วินาที ถ้าต่อได้แสดงว่า Backend รับรู้และออนไลน์
      // (ถ้า Backend คุณส่ง Message กลับมาบอกสถานะด้วย สามารถใช้ await channel.stream.first แทนได้)
      await channel.ready.timeout(const Duration(seconds: 3));

      // 3. ปิด Loading
      if (mounted) Navigator.pop(context);

      // 4. เชื่อมต่อสำเร็จ แสดงว่าออนไลน์แล้ว ไม่ต้องทำ SmartConfig
      setState(() {
        currentDeviceId = deviceId;
      });

      // ปิด channel ไปก่อน หรือจะเก็บไว้รับข้อมูลต่อในอนาคตก็ได้ครับ
      channel.sink.close();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('อุปกรณ์ออนไลน์และพร้อมใช้งาน!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // 3. ปิด Loading (กรณี Timeout หรือเชื่อมต่อไม่สำเร็จ)
      if (mounted) Navigator.pop(context);

      // 4. แสดงว่าออฟไลน์ ให้ไปทำ SmartConfig
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ไม่พบการเชื่อมต่ออุปกรณ์ กรุณาตั้งค่า Wi-Fi (SmartConfig)'),
            backgroundColor: Colors.orange,
          ),
        );
        // เปิดหน้าตั้งค่า Wi-Fi
        _showWifiDialog();
      }
    }
  }

  // ==========================================
  // 🌟 2. ฟังก์ชันสแกนหา Wi-Fi รอบตัว (ของจริง)
  // ==========================================
  Future<List<String>> _scanForRealWifi() async {
    List<String> wifiList = [];

    // ขอสิทธิ์ Location ก่อน (จำเป็นมากสำหรับ Android ในการหา Wi-Fi)
    var status = await Permission.locationWhenInUse.request();
    if (!status.isGranted) {
      return ["กรุณาอนุญาตสิทธิ์ตำแหน่ง (Location)"];
    }

    final canScan = await WiFiScan.instance.canStartScan();
    if (canScan != CanStartScan.yes) {
      return ["ไม่สามารถสแกน Wi-Fi ได้"];
    }

    await WiFiScan.instance.startScan();

    final canGetResults = await WiFiScan.instance.canGetScannedResults();
    if (canGetResults == CanGetScannedResults.yes) {
      final results = await WiFiScan.instance.getScannedResults();
      // ดึงเฉพาะชื่อที่คัดกรองแล้ว ไม่ว่างและไม่ซ้ำ
      for (var network in results) {
        if (network.ssid.isNotEmpty && !wifiList.contains(network.ssid)) {
          wifiList.add(network.ssid);
        }
      }
    }

    if (wifiList.isEmpty) {
      wifiList.add("ไม่พบ Wi-Fi ใกล้เคียง");
    }

    return wifiList;
  }

  // ==========================================
  // 🌟 3. ปรับฟังก์ชันแสดง Pop-up ให้รอผลสแกน Wi-Fi
  // ==========================================
  void _showWifiDialog() {
    // ล้างค่าเก่าก่อนเปิด
    _passwordController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String? localSelectedWifi; // ตัวแปรเก็บค่าที่เลือกใน Dialog

        return FutureBuilder<List<String>>(
          future: _scanForRealWifi(),
          builder: (context, snapshot) {
            List<String> availableWifiList = snapshot.data ?? [];

            // ตรวจสอบว่าโหลดเสร็จและตั้งค่าเริ่มต้น
            if (snapshot.connectionState == ConnectionState.done &&
                localSelectedWifi == null &&
                availableWifiList.isNotEmpty &&
                !availableWifiList.contains("ไม่พบ") &&
                !availableWifiList.contains("กรุณา")) {
              localSelectedWifi = availableWifiList[0];
              _ssidController.text = localSelectedWifi!;
            }

            return StatefulBuilder(
              builder: (context, setStateDialog) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  title: const Text("ตั้งค่าการเชื่อมต่อ",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ส่วนแสดง Device ID
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
                            const Icon(Icons.qr_code_scanner,
                                color: Colors.blue, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "อุปกรณ์: ${scannedDeviceId ?? 'ไม่ระบุ'}",
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
                          "กรุณาเลือก WiFi ที่มือถือของคุณกำลังเชื่อมต่ออยู่ (รองรับ 2.4GHz เท่านั้น)",
                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 15),

                      // 🌟 เช็คสถานะการโหลด ถ้ากำลังสแกนให้แสดง Loading
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 15),
                              Text("กำลังค้นหา Wi-Fi รอบตัวคุณ...",
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      else ...[
                        DropdownButtonFormField<String>(
                          value: localSelectedWifi,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'เลือก WiFi (SSID)',
                            prefixIcon: const Icon(Icons.wifi),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          items: availableWifiList.map((String ssid) {
                            return DropdownMenuItem<String>(
                              value: ssid,
                              child: Text(ssid),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setStateDialog(() {
                              localSelectedWifi = newValue;
                              _ssidController.text = newValue ?? '';
                            });
                          },
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
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() => scannedDeviceId = null);
                        Navigator.pop(context);
                      },
                      child: const Text("ยกเลิก",
                          style: TextStyle(color: Colors.grey)),
                    ),
                    ElevatedButton(
                      // ปิดปุ่มไว้ถ้ายังโหลดไม่เสร็จ
                      onPressed:
                          snapshot.connectionState == ConnectionState.waiting
                              ? null
                              : () {
                                  if (_ssidController.text.isEmpty ||
                                      _ssidController.text.contains("ไม่พบ") ||
                                      _ssidController.text.contains("กรุณา")) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'กรุณาเลือก WiFi ที่ถูกต้องก่อนครับ')),
                                    );
                                    return;
                                  }
                                  Navigator.pop(context);
                                  _startSmartConfig(_ssidController.text,
                                      _passwordController.text);
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
          },
        );
      },
    );
  }

  void _openQRScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ModernQRScanner(),
    ).then((scannedId) {
      if (scannedId != null) {
        setState(() {
          scannedDeviceId = scannedId;
        });
        _showWifiDialog();
      }
    });
  }

  Future<void> _startSmartConfig(String ssid, String password) async {
    setState(() => _isProvisioning = true);
    final provisioner = Provisioner.espTouch();

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
              padding: const EdgeInsets.only(top: 50, bottom: 30),
              color: primaryColor,
              child: const Column(
                children: [
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

                  const SizedBox(height: 20),

                  // ปุ่มวงกลมใหญ่ตรงกลาง สำหรับเริ่ม SmartConfig
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
                                  : "เชื่อมต่อกับถุงมือ",
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

                  const SizedBox(height: 20),

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
                  builder: (context) => const LanguageManualPage()),
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
              icon: Icon(Icons.front_hand), label: 'Gloves'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book), label: 'Manuals'),
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

// ==========================================
// 🌟 คลาสสำหรับหน้าจอแสกน QR Code แบบสวยงาม (ไม่มีการเปลี่ยนแปลง)
// ==========================================
class ModernQRScanner extends StatefulWidget {
  const ModernQRScanner({super.key});

  @override
  State<ModernQRScanner> createState() => _ModernQRScannerState();
}

class _ModernQRScannerState extends State<ModernQRScanner> {
  final MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool isFlashOn = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            child: MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    Navigator.pop(context, barcode.rawValue);
                    break;
                  }
                }
              },
            ),
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: const Color(0xFF2260FF), width: 3),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    spreadRadius: 9999,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "สแกน QR Code ที่ถุงมือ",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                )
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  cameraController.toggleTorch();
                  setState(() {
                    isFlashOn = !isFlashOn;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: isFlashOn
                        ? Colors.white
                        : Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFlashOn ? Icons.flash_on : Icons.flash_off,
                    color: isFlashOn ? Colors.black : Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
