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
  List<Manual> _allManuals = [];
  List<Manual> _filteredManuals = [];
  List<String> _categories = ["ทั้งหมด"];
  String _selectedCategory = "ทั้งหมด";

  int currentPage = 1;
  final int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    futureManuals = ApiService().fetchManuals();
    futureManuals.then((data) {
      if (mounted) {
        final uniqueCats = data.map((e) => e.category).toSet().toList();
        uniqueCats.sort();
        setState(() {
          _allManuals = data;
          _categories = ["ทั้งหมด", ...uniqueCats];
          _filteredManuals = data;
        });
      }
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      currentPage = 1;
      if (category == "ทั้งหมด") {
        _filteredManuals = _allManuals;
      } else {
        _filteredManuals = _allManuals
            .where((m) => m.category == category)
            .toList();
      }
    });
  }

  List<int> _getVisiblePages(int totalPages) {
    if (totalPages <= 3) return List.generate(totalPages, (i) => i + 1);
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
        // ปรับขนาดปุ่ม Back ให้เท่ากับหน้า Detail
        leading: IconButton(
          padding: const EdgeInsets.only(left: 20),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: primaryColor,
            size: 35,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Manuals",
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: primaryColor, size: 28),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LanguageSearchPage(),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Category Filter Bar ---
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedCategory == _categories[index];
                return GestureDetector(
                  onTap: () => _filterByCategory(_categories[index]),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryColor
                          : const Color(0xFFF0F5FF),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      _categories[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : primaryColor,
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

          // --- List Data & Pagination ---
          Expanded(
            child: FutureBuilder<List<Manual>>(
              future: futureManuals,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    _allManuals.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }

                if (_filteredManuals.isEmpty) {
                  return const Center(child: Text("ไม่มีข้อมูลในหมวดหมู่นี้"));
                }

                int totalPages = (_filteredManuals.length / itemsPerPage)
                    .ceil();
                int displayPages = totalPages < 1 ? 1 : totalPages;

                int startIndex = (currentPage - 1) * itemsPerPage;
                int endIndex =
                    (startIndex + itemsPerPage > _filteredManuals.length)
                    ? _filteredManuals.length
                    : startIndex + itemsPerPage;

                List<Manual> displayedItems = _filteredManuals.sublist(
                  startIndex,
                  endIndex,
                );

                return Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, 
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.75, // <--- Change from 0.85 to 0.75 or 0.7 to make cards taller
                        ),
                        itemCount: displayedItems.length,
                        itemBuilder: (context, index) => _buildVocabularyCard(
                          context,
                          displayedItems[index],
                        ),
                      ),
                    ),

                    // --- Pagination Controls ---
                    _buildPaginationUI(displayPages),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationUI(int displayPages) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildArrowBtn(
                Icons.arrow_back_ios,
                currentPage > 1,
                () => setState(() => currentPage--),
              ),

              ..._getVisiblePages(displayPages).map((p) => _buildPageNum(p)),

              _buildArrowBtn(
                Icons.arrow_forward_ios,
                currentPage < displayPages,
                () => setState(() => currentPage++),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            "หน้า $currentPage จาก $displayPages",
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildVocabularyCard(BuildContext context, Manual manual) {
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
          color: const Color(0xFFD9E4FF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section
            // Image Section
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: manual.imageUrl.isNotEmpty
                    ? Image.network(
                        manual.imageUrl,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter, // <--- Add this line
                        errorBuilder: (c, e, s) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            
            // Title Section (Thai Only)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                manual.titleThai,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2260FF),
                ),
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

  Widget _buildPageNum(int page) {
    bool isAct = currentPage == page;
    return GestureDetector(
      onTap: () => setState(() => currentPage = page),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 35,
        height: 35,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isAct ? const Color(0xFF2260FF) : Colors.white,
          border: Border.all(color: const Color(0xFF2260FF)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          "$page",
          style: TextStyle(
            color: isAct ? Colors.white : const Color(0xFF2260FF),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildArrowBtn(IconData icon, bool enable, VoidCallback tap) {
    return IconButton(
      onPressed: enable ? tap : null,
      icon: Icon(icon, size: 16, color: enable ? Colors.black : Colors.grey),
    );
  }
}
