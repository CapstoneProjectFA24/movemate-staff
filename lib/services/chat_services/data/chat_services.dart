import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movemate_staff/services/chat_services/models/chat_model.dart';

class ChatManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String bookingId;
  final String currentUserId;
  final String currentUserRole;

  ChatManager({
    required this.bookingId,
    required this.currentUserId,
    required this.currentUserRole,
  });

  Future<String?> findExistingConversation(String customerId) async {
    try {
      final QuerySnapshot conversations = await _firestore
          .collection('bookings')
          .doc(bookingId)
          .collection('conversations')
          .where('participants.user.id', isEqualTo: customerId)
          .where('participants.staff.id', isEqualTo: currentUserId)
          .limit(1)
          .get();

      if (conversations.docs.isNotEmpty) {
        return conversations.docs.first.id;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to find conversation: $e');
    }
  }

  // Get or create conversation
  Future<String> getOrCreateConversation(
      String customerId, StaffRole staffRole) async {
    try {
      // First check if conversation exists
      final existingConversationId = await findExistingConversation(customerId);

      if (existingConversationId != null) {
        return existingConversationId;
      }

      // If no conversation exists, create new one
      final conversationRef = await _firestore
          .collection('bookings')
          .doc(bookingId)
          .collection('conversations')
          .add({
        'createdAt': FieldValue.serverTimestamp(),
        'participants': {
          'user': {
            'id': customerId,
            'role': 'customer',
          },
          'staff': {
            'id': currentUserId,
            'role': staffRole.toString().split('.').last,
          },
        },
        'status': 'active',
      });

      return conversationRef.id;
    } catch (e) {
      throw Exception('Failed to get or create conversation: $e');
    }
  } // Stream all conversations for the booking

  Stream<List<Conversation>> getAllConversations() {
    return _firestore
        .collection('bookings')
        .doc(bookingId)
        .collection('conversations')
        .orderBy('lastMessage.timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Conversation.fromFirestore(doc))
          .toList();
    });
  }

  // Send message in conversation
  Future<void> sendMessage(String conversationId, String content,
      {List<String>? attachments}) async {
    try {
      final messageRef = _firestore
          .collection('bookings')
          .doc(bookingId)
          .collection('conversations')
          .doc(conversationId)
          .collection('messages');

      final message = {
        'content': content,
        'attachments': attachments ?? [],
        'senderId': currentUserId,
        'senderRole': currentUserRole,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'sent',
      };

      await messageRef.add(message);

      // Update last message in conversation
      await _firestore
          .collection('bookings')
          .doc(bookingId)
          .collection('conversations')
          .doc(conversationId)
          .update({
        'lastMessage': message,
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Stream messages for specific conversation
  Stream<List<Message>> getMessages(String conversationId) {
    return _firestore
        .collection('bookings')
        .doc(bookingId)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();
    });
  }
}
