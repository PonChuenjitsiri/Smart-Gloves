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
  
  // เปลี่ยนจากข้อมูลจำลองเป็น List ของ Manual Model
  List<Manual> _allVocab = [];
  List<Manual> _filteredResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData(); // โหลดข้อมูลทั้งหมดมาเตรียมไว้
  }

  // ดึงข้อมูลทั้งหมดจาก API มาเก็บไว้ในเครื่องเพื่อใช้ค้นหา
  Future<void> _loadAllData() async {
    try {
      final data = await ApiService().fetchManuals(); // อาจต้องสร้าง Method ใหม่ใน Service ที่ไม่จำกัด 10 ตัว
      setState(() {
        _allVocab = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("Search Error: $e");
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredResults = [];
      } else {
        // ค้นหาจากชื่อ (name) หรือคำอธิบาย (description)
        _filteredResults = _allVocab
            .where((item) => 
                item.name.toLowerCase().contains(query.toLowerCase()) ||
                item.description.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
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
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 10, right: 10),
            color: primaryColor,
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        "Search",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    autofocus: true, // ให้คีย์บอร์ดเด้งขึ้นมาทันที
                    decoration: const InputDecoration(
                      hintText: "ค้นหาคำศัพท์ภาษามือ",
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- ผลการค้นหา ---
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _searchController.text.isEmpty
                  ? _buildInitialState() 
                  : _buildResultsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 150, color: Colors.grey[200]),
          const Text("เลือกค้นหาภาษามือที่คุณสนใจ", style: TextStyle(color: Colors.grey, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    if (_filteredResults.isEmpty) {
      return const Center(child: Text("ไม่พบข้อมูล"));
    }
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
            titleThai: manual.name,
            titleEng: "", // หรือใช้ manual.description
            imagePath: manual.url,
            signMethod: manual.signMethod,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFD9E4FF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 80, height: 80,
                child: manual.url.startsWith('http')
                  ? Image.network(manual.url, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image))
                  : const Icon(Icons.image),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(manual.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2260FF))),
                  Text(manual.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
                  const Text("คลิกเพื่อดูรายละเอียด...", style: TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}