class Manual {
  final String id;
  final String name;
  final String description;
  final String signMethod;
  final String url;

  Manual({
    required this.id,
    required this.name,
    required this.description,
    required this.signMethod,
    required this.url,
  });

  factory Manual.fromJson(Map<String, dynamic> json) {
    return Manual(
      id: json['_id'],
      name: json['name'],
      description: json['description'] ?? '',
      signMethod: json['sign_method'] ?? '',
      url: json['url'] ?? '',
    );
  }
}