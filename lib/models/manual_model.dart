class Manual {
  final String id;
  final String titleThai;
  final String titleEng;
  final String label;
  final String category;
  final String signMethod;
  final String imageUrl;
  final String videoUrl;

  Manual({
    required this.id,
    required this.titleThai,
    required this.titleEng,
    required this.label,
    required this.category,
    required this.signMethod,
    required this.imageUrl,
    this.videoUrl = '',
  });

  factory Manual.fromJson(Map<String, dynamic> json) {
    return Manual(
      // ตรวจสอบว่า _id มาเป็น String หรือ Map (ในกรณี MongoDB บางครั้งส่งเป็น {'$oid': '...'})
      id: json['_id']?.toString() ?? '', 
      titleThai: json['titleThai'] ?? '',
      titleEng: json['titleEng'] ?? '',
      label: json['label'] ?? '',
      category: json['category'] ?? '',
      signMethod: json['signMethod'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
    );
  }
}