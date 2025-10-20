part of 'real_debrid.dart';

class RealDebridHost {
  final String url;
  final String id;
  final String name;
  final String image;

  const RealDebridHost({
    required this.url,
    required this.id,
    required this.name,
    required this.image,
  });

  RealDebridHost.fromJsonAndUrl(this.url, Map<String, dynamic> json)
    : id = json["id"] as String,
      name = json["name"] as String,
      image = json["image"] as String;
}
