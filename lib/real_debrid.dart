import 'package:dio/dio.dart';
import 'package:real_debrid/real_debrid_error.dart';

class RealDebrid {
  final String token;
  final Dio _dio;

  RealDebrid({required this.token}) : _dio = Dio() {
    setupDio();
  }

  void setupDio() {
    _dio.options.baseUrl = "https://api.real-debrid.com/rest/1.0/";
    _dio.options.headers = {"Authorization": "Bearer $token"};
  }

  Future<RealDebridUser> get user async {
    final response = await _dio.get("/user");
    // handle errors
    switch (response.statusCode) {
      case 401:
        throw RealDebridError.badToken;
      case 403:
        throw RealDebridError.permissionDenied;
    }
    return RealDebridUser.fromJson(response.data);
  }
}

class RealDebridUser {
  final int id;
  final String username;
  final String email;
  final String locale;
  final String expiration;

  /// User type, see [RealDebridUserType]
  final RealDebridUserType type;

  /// User fidelity points
  final int points;

  /// User avatar Url
  final String avatar;

  /// User premium time left in seconds
  final int premium;

  const RealDebridUser({
    required this.id,
    required this.username,
    required this.email,
    required this.locale,
    required this.expiration,
    required this.type,
    required this.points,
    required this.avatar,
    required this.premium,
  });

  Duration get premiumTimeLeft => Duration(seconds: premium);
  DateTime get expirationDate => DateTime.parse(expiration);

  RealDebridUser.fromJson(Map<String, dynamic> json)
    : id = json["id"] as int,
      points = json["points"] as int,
      premium = json["premium"] as int,
      username = json["username"] as String,
      email = json["email"] as String,
      locale = json["locale"] as String,
      avatar = json["avatar"] as String,
      expiration = json["expiration"] as String,
      type = RealDebridUserType.fromJson(json["type"] as String);

  @override
  String toString() {
    final buffer = StringBuffer("RealDebridUser:");
    buffer.writeAll([
      username,
      email,
      id,
      type.name,
      expirationDate,
      "${premiumTimeLeft.inDays}d",
    ], "|");
    return buffer.toString();
  }
}

enum RealDebridUserType {
  free,
  premium;

  static RealDebridUserType fromJson(String value) => switch (value) {
    "premium" => premium,
    "free" => free,
    _ => free,
  };
}
