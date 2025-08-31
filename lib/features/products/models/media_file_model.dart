import 'package:equatable/equatable.dart';

class MediaFile extends Equatable {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String scope;
  final String uri;
  final String url;
  final String fileName;
  final String mimetype;
  final int size;
  final String? userId;

  const MediaFile({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.scope,
    required this.uri,
    required this.url,
    required this.fileName,
    required this.mimetype,
    required this.size,
    this.userId,
  });

  factory MediaFile.fromJson(Map<String, dynamic> json) {
    return MediaFile(
      id: json['id']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      scope: json['scope']?.toString() ?? '',
      uri: json['uri']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      fileName: json['fileName']?.toString() ?? '',
      mimetype: json['mimetype']?.toString() ?? '',
      size: json['size'] is int ? json['size'] : int.tryParse(json['size']?.toString() ?? '0') ?? 0,
      userId: json['userId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'scope': scope,
      'uri': uri,
      'url': url,
      'fileName': fileName,
      'mimetype': mimetype,
      'size': size,
      'userId': userId,
    };
  }

  @override
  List<Object?> get props => [
    id,
    createdAt,
    updatedAt,
    scope,
    uri,
    url,
    fileName,
    mimetype,
    size,
    userId,
  ];

  @override
  String toString() {
    return 'MediaFile(id: $id, fileName: $fileName, url: $url)';
  }
}
