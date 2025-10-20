import 'package:dio/dio.dart';
import 'package:real_debrid/real_debrid_error.dart';

part 'real_debrid_user.dart';
part 'real_debrid_download.dart';
part 'real_debrid_host.dart';

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

  Future<List<RealDebridHost>> get hosts async {
    final response = await _dio.get("/hosts");
    final hosts = response.data as Map<String, dynamic>;
    return <RealDebridHost>[
      for (final url in hosts.keys)
        RealDebridHost.fromJsonAndUrl(url, hosts[url]),
    ];
  }

  Future<void> convertPoints() async {
    final response = await _dio.post("/settings/convertPoints");
    // handle errors
    switch (response.statusCode) {
      case 401:
        throw RealDebridError.badToken;
      case 403:
        throw RealDebridError.permissionDenied;
      case 503:
        throw RealDebridError.serviceUnavailable;
    }
  }

  Future<RealDebridDownload> download(String link, String pass) async {
    final response = await _dio.post(
      "/unrestrict/link",
      data: FormData.fromMap({
        "link": link,
        if (pass.isNotEmpty) "password": pass,
        "remote": 0,
      }),
    );
    // handle errors
    switch (response.statusCode) {
      case 401:
        throw RealDebridError.badToken;
      case 403:
        throw RealDebridError.permissionDenied;
    }
    return RealDebridDownload.fromJson(response.data);
  }
}
