part of 'real_debrid.dart';

class RealDebridDownload {
  final String id;
  final String filename;
  final String mimeType;
  final int filesize;
  final String link;
  final String host;
  final int chunks;
  final int crc;
  final String download;
  final int streamable;

  const RealDebridDownload({
    required this.id,
    required this.filename,
    required this.mimeType,
    required this.filesize,
    required this.link,
    required this.host,
    required this.chunks,
    required this.crc,
    required this.download,
    required this.streamable,
  });

  bool get isCrcCheckEnabled => crc > 0;
  bool get isStreamable => streamable > 0;

  RealDebridDownload.fromJson(Map<String, dynamic> json)
    : id = json["id"] as String,
      filename = json["filename"] as String,
      mimeType = json["mimeType"] as String,
      filesize = json["filesize"] as int,
      link = json["link"] as String,
      host = json["host"] as String,
      chunks = json["chunks"] as int,
      crc = json["crc"] as int,
      download = json["download"] as String,
      streamable = json["streamable"] as int;

  @override
  String toString() {
    final buffer = StringBuffer("RealDebridDownload:");
    buffer.writeAll([
      filename,
      mimeType,
      download,
      link,
      host,
      crc,
      streamable,
    ], "|");
    return buffer.toString();
  }
}
