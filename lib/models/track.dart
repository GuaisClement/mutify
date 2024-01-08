
class Track {
  final String id;
  final String name;
  final String previewUrl;
  final String artists;
  final String imageUrl;

  const Track(this.id, this.name, this.previewUrl, this.artists, this.imageUrl);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'previewUrl': previewUrl,
      'artists': artists,
      'imageUrl': imageUrl
    };
  }

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(json['id'],
                  json['name'],
                  json['previewUrl'],
                  json['artists'],
                  json['imageUrl']);
  }

}