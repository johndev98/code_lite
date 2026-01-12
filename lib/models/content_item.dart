class ContentItem {
  final String id;
  final String title;
  final String subtitle;
  final String image;
  final String? path;

  const ContentItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    this.path,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      image: json['image'] ?? '',
      path: json['path'],
    );
  }
}
