import 'package:flutter/material.dart';
import 'package:sarnmue/services/api_service.dart';
import 'package:sarnmue/models/manual_model.dart';
// 🌟 เปลี่ยนมาใช้ VLC
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class VocabularyDetailPage extends StatefulWidget {
  final String id;
  final String titleThai;
  final String titleEng;
  final String imagePath;
  final String signMethod;
  final String category;

  const VocabularyDetailPage({
    super.key,
    required this.id,
    required this.titleThai,
    required this.titleEng,
    required this.imagePath,
    required this.signMethod,
    this.category = "ทั่วไป",
  });

  @override
  State<VocabularyDetailPage> createState() => _VocabularyDetailPageState();
}

class _VocabularyDetailPageState extends State<VocabularyDetailPage> {
  late Future<Manual> futureManualDetail;

  // 🌟 ใช้ Controller ของ VLC
  VlcPlayerController? _vlcViewController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    futureManualDetail = ApiService().fetchManualById(widget.id);

    futureManualDetail.then((manual) {
      // 🌟 FIX 1: เช็กให้ชัวร์ว่ามีลิงก์วิดีโอจริงๆ และต้องเป็น http เท่านั้น
      final vidUrl = manual.videoUrl.trim();
      print("🎯 VLC กำลังพยายามโหลดลิงก์นี้: $vidUrl"); // <--- เพิ่มบรรทัดนี้
      if (vidUrl.isNotEmpty && vidUrl.startsWith('http')) {
        _vlcViewController = VlcPlayerController.network(
          vidUrl,
          hwAcc: HwAcc.disabled,
          autoPlay: false,
        );

        _vlcViewController!.addListener(_vlcListener);

        setState(() {
          _isVideoInitialized = true;
        });
      }
    }).catchError((error) {
      print("Error loading detail: $error");
    });
  }

  // 🌟 ฟังก์ชัน Listener สำหรับจัดการสถานะวิดีโอ
  void _vlcListener() {
    if (!mounted || _vlcViewController == null) return;

    // ถ้าวิดีโอเล่นจบแล้ว ให้สั่ง stop() เพื่อรีเซ็ตสถานะ
    if (_vlcViewController!.value.playingState == PlayingState.ended) {
      _vlcViewController!.stop();
    }
  }

  @override
  void dispose() {
    // 🌟 1. ถอด Listener ออกก่อน
    _vlcViewController?.removeListener(_vlcListener);

    // 🌟 2. สั่งหยุดและทำลาย VLC (ไม่ต้องใช้ async/await)
    _vlcViewController?.stopRendererScanning();
    _vlcViewController?.dispose();

    // 🌟 3. เรียก super.dispose() เป็น "บรรทัดสุดท้าย" เสมอ!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2260FF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<Manual>(
        future: futureManualDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: primaryColor));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "เกิดข้อผิดพลาดในการโหลดข้อมูล: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final manual = snapshot.data;

          return SingleChildScrollView(
            child: Column(
              children: [
                // 🌟 FIX 1: New Layout Structure
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // 1. Blue Header Background (Fixed height paints behind the content)
                    Container(
                      height: 280,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                      ),
                    ),

                    // 2. All Content
                    Column(
                      children: [
                        const SizedBox(height: 60),

                        // Back Button
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new,
                                  color: Colors.white, size: 35),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),

                        // Title Text (ภาษาไทย)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            manual?.titleThai ?? widget.titleThai,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),

                        const SizedBox(
                            height: 5), // ระยะห่างระหว่างภาษาไทยและอังกฤษ

                        // 🌟 เพิ่ม Title Text (ภาษาอังกฤษ) ตรงนี้ครับ
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            manual?.titleEng ??
                                widget.titleEng, // ดึงภาษาอังกฤษมาแสดง
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize:
                                  22, // ขนาดเล็กลงมาหน่อยเพื่อแยกความสำคัญ
                              fontWeight: FontWeight.w500,
                              color: Colors
                                  .white70, // สีขาวแบบโปร่งแสงให้ดูเป็นคำบรรยายรอง
                            ),
                          ),
                        ),

                        const SizedBox(
                            height:
                                20), // Pushes the video down (ปรับลดลงนิดหน่อยเพื่อชดเชยบรรทัดที่เพิ่มมา)

                        // 3. The Video Card (Now in normal flow, so it gets 100% of touches!)
                        Container(
                          width: 200,
                          height: 360,
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
                            // 🌟 แก้ไขตรงนี้: เปลี่ยนจาก 3/4 เป็นสัดส่วนที่แคบและสูงขึ้น (เช่น 9/16 หรือ 2/3)
                            // ลอง 9/16 ก่อน ถ้ายาวไปลอง 2/3 หรือ 10/16 ครับ
                            aspectRatio: 9 / 16,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: _buildMediaWidget(manual),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 50), // Normal spacing to the text below

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.accessibility_new,
                              color: primaryColor, size: 28),
                          const SizedBox(width: 10),
                          const Text(
                            "วิธีการทำ:",
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: primaryColor),
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
                          border:
                              Border.all(color: primaryColor.withOpacity(0.1)),
                        ),
                        child: Text(
                          (manual?.signMethod ?? widget.signMethod)
                                  .trim()
                                  .isNotEmpty
                              ? (manual?.signMethod ?? widget.signMethod).trim()
                              : "ไม่มีรายละเอียดวิธีการทำ",
                          style: const TextStyle(
                              fontSize: 18,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMediaWidget(Manual? manual) {
    // 🎬 กรณีที่ 1: มีวิดีโอที่พร้อมใช้งาน
    if (_isVideoInitialized && _vlcViewController != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          // Layer 1 (Bottom): VlcPlayer + FittedBox (แก้ขอบดำถาวร)
          Positioned.fill(
            child: ValueListenableBuilder<VlcPlayerValue>(
              valueListenable: _vlcViewController!,
              builder: (context, value, child) {
                // 1. ดึงขนาดวิดีโอจริง ถ้าเน็ตยังโหลดไม่เสร็จให้ใช้ค่า 300x400 ไปก่อน
                final double videoWidth =
                    value.size.width > 0 ? value.size.width : 300;
                final double videoHeight =
                    value.size.height > 0 ? value.size.height : 400;

                // 2. ใช้ FittedBox + BoxFit.cover บังคับขยายเต็มพื้นที่และตัดขอบดำออก
                // โครงสร้างนี้จะคงที่เสมอ ทำให้ VLC ไม่โดนทำลายและไม่แครช
                return FittedBox(
                  fit: BoxFit.cover, // 🎯 หัวใจหลักของการแก้ขอบดำ
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: videoWidth,
                    height: videoHeight,
                    child: VlcPlayer(
                      controller: _vlcViewController!,
                      aspectRatio: videoWidth /
                          videoHeight, // ให้ VLC วาดตามสัดส่วนวิดีโอจริงไปเลย
                      placeholder: const SizedBox(
                        width: 300,
                        height: 400,
                        child: Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF2260FF)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ▶️ Layer 2 (Middle): Visual Play & Buffering Button
          ValueListenableBuilder<VlcPlayerValue>(
            valueListenable: _vlcViewController!,
            builder: (context, value, child) {
              // ถ้ากำลังบัฟเฟอร์ให้โชว์ที่หมุนๆ
              if (value.playingState == PlayingState.buffering) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              // ถ้าไม่ได้เล่นอยู่ ให้โชว์ปุ่ม Play
              if (value.playingState != PlayingState.playing) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow,
                        size: 60, color: Colors.white),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // 🛡️ Layer 3 (Top): Invisible Touch Receiver
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (_vlcViewController == null) return;
                // สลับสถานะ Play/Pause
                if (_vlcViewController!.value.playingState ==
                    PlayingState.playing) {
                  _vlcViewController!.pause();
                } else {
                  _vlcViewController!.play();
                }
              },
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      );
    }

    // 🖼️ กรณีที่ 2: ไม่มีวิดีโอ ให้แสดงรูปภาพแทน
    String imageUrl = (manual != null && manual.imageUrl.trim().isNotEmpty)
        ? manual.imageUrl.trim()
        : widget.imagePath.trim();

    if (imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('http')) {
        // ถ้ารูปมาจากอินเทอร์เน็ต
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            // 🌟 ป้องกันหน้าจอขาวระหว่างรอโหลดรูป
            if (loadingProgress == null) return child;
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF2260FF)));
          },
          errorBuilder: (context, error, stackTrace) => _placeholder(),
        );
      } else {
        // ถ้ารูปมาจาก assets ในเครื่อง
        return Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _placeholder(),
        );
      }
    }

    // ❌ กรณีที่ 3: ไม่มีทั้งวิดีโอ ไม่มีทั้งรูปภาพ ให้แสดงภาพเทาๆ แทน
    return _placeholder();
  }

  Widget _placeholder() => Container(
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
            SizedBox(height: 8),
            Text("กำลังโหลด...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
}
