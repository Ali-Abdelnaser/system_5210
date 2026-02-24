import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  final String id;
  final String title;
  final String body;
  final String? titleEn;
  final String? bodyEn;
  final String? imageUrl;
  final String? actionUrl;
  final DateTime timestamp;
  final bool isRead;
  final bool isLiked;
  final String type; // 'tip', 'streak', 'broadcast', etc.

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.titleEn,
    this.bodyEn,
    this.imageUrl,
    this.actionUrl,
    required this.timestamp,
    this.isRead = false,
    this.isLiked = false,
    this.type = 'tip',
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    String? titleEn,
    String? bodyEn,
    String? imageUrl,
    String? actionUrl,
    DateTime? timestamp,
    bool? isRead,
    bool? isLiked,
    String? type,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      titleEn: titleEn ?? this.titleEn,
      bodyEn: bodyEn ?? this.bodyEn,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isLiked: isLiked ?? this.isLiked,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'titleEn': titleEn,
      'bodyEn': bodyEn,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'isLiked': isLiked,
      'type': type,
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      titleEn: map['titleEn'] as String?,
      bodyEn: map['bodyEn'] as String?,
      imageUrl: map['imageUrl'] as String?,
      actionUrl: map['actionUrl'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      isRead: map['isRead'] as bool? ?? false,
      isLiked: map['isLiked'] as bool? ?? false,
      type: map['type'] as String? ?? 'tip',
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    titleEn,
    bodyEn,
    imageUrl,
    actionUrl,
    timestamp,
    isRead,
    isLiked,
    type,
  ];
}
