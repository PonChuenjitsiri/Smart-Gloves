import 'package:flutter/material.dart';
import 'package:cepfrontend/services/api_service.dart';
import 'package:cepfrontend/models/manual_model.dart';
import 'package:cepfrontend/pages/vocabdetail_page.dart';

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
        bool matchesCategory =
            (_selectedCategory == "ทั้งหมด") ||
            (item.category == _selectedCategory);
        bool matchesQuery =
            query.isEmpty ||
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
    return ListView.builder(
      padding: const EdgeInsets.all(20),
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
            titleThai: manual.titleThai,
            titleEng: manual.titleEng,
            imagePath: manual.imageUrl,
            signMethod: manual.signMethod,
            category: manual.category, // ส่ง category ไปด้วย
          ),
        ),
      ),
      child: Container(
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
              child: SizedBox(
                width: 80,
                height: 80,
                child: manual.imageUrl.isNotEmpty
                    ? Image.network(
                        manual.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) =>
                            const Icon(Icons.image, color: Colors.grey),
                      )
                    : const Icon(Icons.image, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    manual.titleThai,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2260FF),
                    ),
                  ),
                  Text(
                    manual.titleEng,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  // ป้ายหมวดหมู่เล็กๆ ใน Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      manual.category,
                      style: const TextStyle(  
                        fontSize: 10, 
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
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
