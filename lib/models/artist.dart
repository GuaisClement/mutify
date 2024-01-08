
class Artist {
  final String id;
  final String name;
  final String imageUrl;

  const Artist(this.id, this.name, this.imageUrl);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl
    };
  }

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(json['id'],
        json['name'],
        json['imageUrl']);
  }

}