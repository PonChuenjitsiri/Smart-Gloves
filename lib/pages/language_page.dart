import 'package:flutter/material.dart';
import 'package:cepfrontend/pages/search_page.dart';
import 'package:cepfrontend/pages/vocabdetail_page.dart';
import 'package:cepfrontend/services/api_service.dart';
import 'package:cepfrontend/models/manual_model.dart';

class LanguageManualPage extends StatefulWidget {
  const LanguageManualPage({super.key});

  @override
  State<LanguageManualPage> createState() => _LanguageManualPageState();
}

class _LanguageManualPageState extends State<LanguageManualPage> {
  late Future<List<Manual>> futureManuals;
  int currentPage = 1;
  final int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    futureManuals = ApiService().fetchManuals();
  }

  // ฟังก์ชันคำนวณว่าจะโชว์เลขหน้าไหนบ้าง (เช่น 4 5 6)
  List<int> _getVisiblePages(int totalPages) {
    if (totalPages <= 3) {
      return List.generate(totalPages, (i) => i + 1);
    }
    if (currentPage <= 2) return [1, 2, 3];
    if (currentPage >= totalPages - 1)
      return [totalPages - 2, totalPages - 1, totalPages];
    return [currentPage - 1, currentPage, currentPage + 1];
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2260FF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Manuals",
          style: TextStyle(
            color: primaryColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: primaryColor),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LanguageSearchPage(),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Manual>>(
        future: futureManuals,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          List<Manual> allManuals = snapshot.data ?? [];
          int totalPages = (allManuals.length / itemsPerPage).ceil();

          int startIndex = (currentPage - 1) * itemsPerPage;
          int endIndex = startIndex + itemsPerPage;
          if (endIndex > allManuals.length) endIndex = allManuals.length;

          List<Manual> displayedManuals = allManuals.sublist(
            startIndex,
            endIndex,
          );

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  itemCount: displayedManuals.length,
                  itemBuilder: (context, index) =>
                      _buildVocabularyCard(context, displayedManuals[index]),
                ),
              ),

              // --- Pagination UI ---
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ปุ่มถอยหลัง
                        _buildPageArrow(
                          Icons.arrow_back_ios,
                          isEnabled: currentPage > 1,
                          onTap: () => setState(() => currentPage--),
                        ),

                        // รายการตัวเลขหน้า (แบบเลื่อนตาม)
                        ..._getVisiblePages(totalPages).map(
                          (page) => _buildPageNumber(
                            page.toString(),
                            isActive: currentPage == page,
                            onTap: () => setState(() => currentPage = page),
                          ),
                        ),

                        // ปุ่มไปข้างหน้า
                        _buildPageArrow(
                          Icons.arrow_forward_ios,
                          isEnabled: currentPage < totalPages,
                          onTap: () => setState(() => currentPage++),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "หน้า $currentPage จาก $totalPages",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // แก้ไข Card ให้ขนาดคงที่ (ความสูง 120)
  Widget _buildVocabularyCard(BuildContext context, Manual manual) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VocabularyDetailPage(
            titleThai: manual.name,
            titleEng: manual.description,
            imagePath: manual.url,
            signMethod: manual.signMethod,
          ),
        ),
      ),
      child: Container(
        height: 120, // ล็อกความสูงคงที่
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFD9E4FF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: manual.url.startsWith('http')
                    ? Image.network(
                        manual.url,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // จัดให้อยู่กลางแนวตั้ง
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    manual.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2260FF),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    manual.description,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    maxLines: 2, // โชว์ได้ 2 บรรทัดถ้าข้อความยาว
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: Colors.grey[300],
    child: const Icon(Icons.image, color: Colors.grey),
  );

  Widget _buildPageNumber(
    String label, {
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2260FF) : Colors.white,
          border: Border.all(color: const Color(0xFF2260FF)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF2260FF),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPageArrow(
    IconData icon, {
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isEnabled ? Colors.grey[200] : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isEnabled ? Colors.black87 : Colors.grey[400],
        ),
      ),
    );
  }
}
