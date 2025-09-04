
class Coffee {
  final String id;
  final String name;
  final String description;
  final String imageUrl;

  Coffee({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  factory Coffee.fromMap(Map<String, dynamic> data, String documentId) {
    return Coffee(
      id: documentId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}
