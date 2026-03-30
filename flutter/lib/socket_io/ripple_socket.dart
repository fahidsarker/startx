import 'package:socket_io_client/socket_io_client.dart' as IO;

class AppSocket {
  final IO.Socket socket;

  AppSocket(this.socket);

  void subscribe<T>(String event, Function(T) onData) {
    socket.on(event, (data) {
      if (data is T) {
        onData(data);
      }
    });
  }

  void dispose() {
    socket.clearListeners();
  }

  void subscribeToChatRoom(
    String chatId,
    Function(Map<String, dynamic>) onMessage,
  ) {
    socket.emit('chat:subscribe', {'chatId': chatId});
    subscribe<Map<String, dynamic>>('chat:$chatId:new-message', onMessage);
  }

  void unSubscribeFromChatRoom(String chatId) {
    socket.emit('chat:unsubscribe', {'chatId': chatId});
  }

  void subscribeToNewChatCreations(Function(Map<String, dynamic>) onMessage) {
    subscribe<Map<String, dynamic>>('chat-list:new-chat', onMessage);
  }

  void subscribeToChatUpdates(Function(Map<String, dynamic>) onMessage) {
    subscribe<Map<String, dynamic>>('chat-list:update-last-message', onMessage);
  }

  void subscribeToOnlinePresence(
    String userId,
    Function(Map<String, dynamic>) onPresenceChange,
  ) {
    socket.emit('presence:subscribe', {'userId': userId});
    subscribe<Map<String, dynamic>>(
      'presence:$userId:change',
      onPresenceChange,
    );
  }

  void unsubscribeToOnlinePresence(String userId) {
    socket.emit('presence:unsubscribe', {'userId': userId});
  }

  void subscribeToTypingIndicator(
    String chatId,
    Function(Map<String, dynamic>) onTyping,
  ) {
    socket.emit('typing:subscribe', {'chatId': chatId});
    subscribe<Map<String, dynamic>>('typing:$chatId:change', onTyping);
  }

  void unsubscribeFromTypingIndicator(String chatId) {
    socket.emit('typing:unsubscribe', {'chatId': chatId});
  }

  void notifyTyping(String chatId, String userId, bool isTyping) {
    socket.emit('typing:notify', {
      'chatId': chatId,
      'userId': userId,
      'isTyping': isTyping,
    });
  }
}
