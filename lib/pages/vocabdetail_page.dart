import 'package:flutter/material.dart';
import 'package:cepfrontend/services/api_service.dart';
import 'package:cepfrontend/models/manual_model.dart';
import 'package:video_player/video_player.dart';

class VocabularyDetailPage extends StatefulWidget {
  final String id;
  final String titleThai;
  final String titleEng;
  final String imagePath;
  final String signMethod;
  final String category; // เพิ่มตัวแปร category

  const VocabularyDetailPage({
    super.key,
    required this.id,
    required this.titleThai,
    required this.titleEng,
    required this.imagePath,
    required this.signMethod,
    this.category = "ทั่วไป", // กำหนดค่าเริ่มต้น
  });

  @override
  State<VocabularyDetailPage> createState() => _VocabularyDetailPageState();
}

class _VocabularyDetailPageState extends State<VocabularyDetailPage> {
  late Future<Manual> futureManualDetail;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    futureManualDetail = ApiService().fetchManualById(widget.id);
    futureManualDetail.then((manual) {
      if (manual.videoUrl.isNotEmpty) {
        _videoController = VideoPlayerController.network(manual.videoUrl)
          ..initialize().then((_) {
            setState(() {
              _isVideoInitialized = true;
            });
            // Removed auto-play so user has to click to play
            _videoController!.setLooping(true); // Keep looping when they do play it
          }).catchError((error) {
            print("Video initialization error: $error");
            setState(() {
              _isVideoInitialized = false;
            });
          });
          
        _videoController!.addListener(() {
          if (mounted) setState(() {});
        });
      }
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
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
              child: CircularProgressIndicator(color: primaryColor),
            );
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
                              manual?.titleThai ?? widget.titleThai,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),

                    // 2. Video Player หรือ ภาพประกอบ
                    Positioned(
                      top: 200, // ปรับค่าจาก 180 เป็น 240 เพื่อให้รูปอยู่ต่ำลง
                      child: Container(
                        width: 250, // ขยายขนาดรูปเล็กน้อย
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
                            child: _buildMediaWidget(manual),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ระยะห่างเพื่อให้พ้นตัวรูปภาพที่ลอยอยู่
                const SizedBox(height: 250),

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
                          (manual?.signMethod ?? widget.signMethod).trim().isNotEmpty
                              ? (manual?.signMethod ?? widget.signMethod).trim()
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
          );
        },
      ),
    );
  }

  Widget _buildMediaWidget(Manual? manual) {
    if (_isVideoInitialized && _videoController != null) {
      return Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          // 1. The Video Player wrapped in a GestureDetector
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                _videoController!.value.isPlaying
                    ? _videoController!.pause()
                    : _videoController!.play();
              });
            },
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController!.value.size.width,
                height: _videoController!.value.size.height,
                child: VideoPlayer(_videoController!),
              ),
            ),
          ),
          
          // 2. The Play Button Overlay (Passes taps down)
          if (!_videoController!.value.isPlaying)
            IgnorePointer( // <-- Crucial: Lets taps pass through to the GestureDetector
              child: Container(
                color: Colors.black45,
                child: Center(
                  child: Icon( // Changed from IconButton to Icon since we handle taps in the wrapper
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              ),
            ),
        ],
      );
    } else if (manual != null && manual.imageUrl.isNotEmpty && manual.imageUrl.startsWith('http')) {
       return Image.network(
          manual.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _placeholder(),
        );
    } else if (widget.imagePath.isNotEmpty && widget.imagePath.startsWith('http')) {
        return Image.network(
          widget.imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _placeholder(),
        );
    } else {
      return _placeholder();
    }
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

