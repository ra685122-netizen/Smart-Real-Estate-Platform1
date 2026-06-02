enum MessageType { text, image, video, audio, file, propertyCard, location }

enum MessageStatus { sending, sent, delivered, read }

class ChatMessage {
  final int id;
  final int senderId;
  final int receiverId;
  final String message;
  final String senderName;
  final String? senderAvatar;
  final DateTime createdAt;
  final bool isRead;
  final MessageType type;
  final String? mediaUrl;
  final String? mediaThumb;
  final double? mediaDuration;
  final int? replyToId;
  final String? replyToText;
  final List<String> reactions;
  final MessageStatus status;
  final int? propertyId;
  final String? propertyTitle;
  final String? propertyImage;
  final double? propertyPrice;
  final double? latitude;
  final double? longitude;
  final bool isLocalFile;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.senderName,
    this.senderAvatar,
    required this.createdAt,
    this.isRead = false,
    this.type = MessageType.text,
    this.mediaUrl,
    this.mediaThumb,
    this.mediaDuration,
    this.replyToId,
    this.replyToText,
    List<String>? reactions,
    this.status = MessageStatus.read,
    this.propertyId,
    this.propertyTitle,
    this.propertyImage,
    this.propertyPrice,
    this.latitude,
    this.longitude,
    this.isLocalFile = false,
  }) : reactions = reactions ?? [];

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: int.parse(json['id'].toString()),
      senderId: int.parse(json['sender_id'].toString()),
      receiverId: json['receiver_id'] != null
          ? int.parse(json['receiver_id'].toString())
          : 0,
      message: json['message'] ?? '',
      senderName: json['sender_name'] ?? 'Unknown',
      senderAvatar: json['sender_avatar'],
      createdAt:
          DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
      isRead: json['is_read'] == true || json['is_read'] == 1,
      status: (json['is_read'] == true || json['is_read'] == 1)
          ? MessageStatus.read
          : MessageStatus.delivered,
    );
  }

  static ChatConversation conversationFromJson(Map<String, dynamic> json) {
    return ChatConversation(
      conversationId: int.tryParse(json['conversation_id'].toString()) ?? 0,
      userId: int.parse(json['other_user_id'].toString()),
      userName: json['other_user_name'] ?? 'Unknown',
      userAvatar: json['other_user_avatar'],
      lastMessage: json['last_message'] ?? '',
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.tryParse(json['last_message_time'].toString()) ??
              DateTime.now()
          : DateTime.now(),
      unreadCount: int.tryParse(json['unread_count'].toString()) ?? 0,
      propertyId: json['property_id'] != null
          ? int.tryParse(json['property_id'].toString())
          : null,
      propertyTitle: json['property_title'],
    );
  }

  bool get isMediaMessage =>
      type == MessageType.image ||
      type == MessageType.video ||
      type == MessageType.audio;

  ChatMessage copyWith({
    MessageStatus? status,
    List<String>? reactions,
    bool? isRead,
  }) {
    return ChatMessage(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      message: message,
      senderName: senderName,
      senderAvatar: senderAvatar,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      type: type,
      mediaUrl: mediaUrl,
      mediaThumb: mediaThumb,
      mediaDuration: mediaDuration,
      replyToId: replyToId,
      replyToText: replyToText,
      reactions: reactions ?? this.reactions,
      status: status ?? this.status,
      propertyId: propertyId,
      propertyTitle: propertyTitle,
      propertyImage: propertyImage,
      propertyPrice: propertyPrice,
      latitude: latitude,
      longitude: longitude,
      isLocalFile: isLocalFile,
    );
  }
}

class ChatConversation {
  final int conversationId;
  final int userId;
  final String userName;
  final String? userAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final int? propertyId;
  final String? propertyTitle;
  final bool isOnline;
  final bool isTyping;
  final MessageType lastMessageType;

  ChatConversation({
    this.conversationId = 0,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.propertyId,
    this.propertyTitle,
    this.isOnline = false,
    this.isTyping = false,
    this.lastMessageType = MessageType.text,
  });
}
