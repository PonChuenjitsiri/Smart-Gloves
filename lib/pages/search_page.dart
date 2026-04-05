import 'package:flutter/material.dart';
import 'package:sarnmue/services/api_service.dart';
import 'package:sarnmue/models/manual_model.dart';
import 'package:sarnmue/pages/vocabdetail_page.dart';

class LanguageSearchPage extends StatefulWidget {
  const LanguageSearchPage({super.key});

  @override
  State<LanguageSearchPage> createState() => _LanguageSearchPageState();
}

class _LanguageSearchPageState extends State<LanguageSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  List<Manual> _allVocab = [];
  List<Manual> _filteredResults = [];
  List<String> _categories = ["ทั้งหมด"];
  String _selectedCategory = "ทั้งหมด";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      final data = await ApiService().fetchManuals();
      // ดึงหมวดหมู่ที่ไม่ซ้ำกันออกมาทำ Filter Tabs
      final uniqueCats = data.map((e) => e.category).toSet().toList();
      uniqueCats.sort();

      setState(() {
        _allVocab = data;
        _categories = ["ทั้งหมด", ...uniqueCats];
        _isLoading = false;
        _applyFilter(); // กรองเริ่มต้น
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Search Error: $e");
    }
  }

  // ฟังก์ชันกรองข้อมูลทั้งจาก "คำค้นหา" และ "หมวดหมู่"
  void _applyFilter() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredResults = _allVocab.where((item) {
        bool matchesCategory = (_selectedCategory == "ทั้งหมด") ||
            (item.category == _selectedCategory);
        bool matchesQuery = query.isEmpty ||
            item.titleThai.toLowerCase().contains(query) ||
            item.titleEng.toLowerCase().contains(query);
        return matchesCategory && matchesQuery;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2260FF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // --- Header & Search Bar ---
          Container(
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 15,
              left: 10,
              right: 10,
            ),
            color: primaryColor,
            child: Column(
              children: [
                Row(
                  children: [
                    // ปุ่ม Back ปรับขนาดเป็น 35 และใช้ไอคอนแบบใหม่
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 35,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        "Search",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 15),
                // ช่อง Search
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => _applyFilter(),
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: "ค้นหาคำศัพท์ภาษามือ",
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // --- Category Filter Bar (Horizontal) ---
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      String cat = _categories[index];
                      bool isSelected = _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = cat;
                            _applyFilter();
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected ? primaryColor : Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // --- ส่วนแสดงผล ---
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  )
                : _filteredResults.isEmpty
                    ? _buildEmptyState()
                    : _buildResultsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 120, color: Colors.grey[200]),
          Text(
            _searchController.text.isEmpty
                ? "พิมพ์เพื่อค้นหาหรือเลือกหมวดหมู่"
                : "ไม่พบข้อมูลที่ค้นหา",
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return GridView.builder(
      padding: const EdgeInsets.all(15),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 Columns
        crossAxisSpacing: 15, // Space between columns
        mainAxisSpacing: 15, // Space between rows
        childAspectRatio: 0.6, // Adjust this ratio if the text gets cut off
      ),
      itemCount: _filteredResults.length,
      itemBuilder: (context, index) {
        final item = _filteredResults[index];
        return _buildVocabCard(item);
      },
    );
  }

  Widget _buildVocabCard(Manual manual) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VocabularyDetailPage(
            id: manual.id,
            titleThai: manual.titleThai,
            titleEng: manual.titleEng,
            imagePath: manual.imageUrl,
            signMethod: manual.signMethod,
            category: manual.category,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFD9E4FF), // พื้นหลังการ์ดสีฟ้าอ่อน
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Image Section ---
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: manual.imageUrl.isNotEmpty
                    ? Image.network(
                        manual.imageUrl,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorBuilder: (c, e, s) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),

            // --- Title & Category Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Column(
                children: [
                  // 1. คำศัพท์ภาษาไทย (ตัวหนา สีน้ำเงิน)
                  Text(
                    manual.titleThai,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2260FF),
                    ),
                  ),
                  const SizedBox(height: 2),

                  // 2. คำศัพท์ภาษาอังกฤษ (สีเทา)
                  Text(
                    manual.titleEng,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 3. ป้าย Label หมวดหมู่ (พื้นหลังสีขาว ขอบมน)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      manual.category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
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
}

Widget _placeholder() => Container(
      color: Colors.grey[300],
      child: const Icon(Icons.image, color: Colors.grey),
    );
