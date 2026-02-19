import 'package:flutter/material.dart';
import 'package:cepfrontend/pages/manual_page.dart';
import 'package:cepfrontend/pages/language_page.dart';
import 'package:cepfrontend/pages/gloves_page.dart';

class SmartGloveHome extends StatelessWidget {
  const SmartGloveHome({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GlovesPage()),
            );
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

  Widget _buildMenuButton(
    BuildContext context,
    String title,
    IconData icon,
    Color bgColor,
    Widget targetPage,
  ) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => targetPage),
            );
          },
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Icon(icon, size: 30, color: Colors.grey[700]),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(
    String title,
    String phone,
    String facebook,
    String email,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF2260FF),
              fontWeight: FontWeight.bold,
            ),
          ),
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
