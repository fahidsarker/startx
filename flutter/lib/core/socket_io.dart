// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatSocket {
  late IO.Socket socket;

  void connect(String wsUrl, String token) {
    socket = IO.io(wsUrl).connect();
    socket.onConnect((_) {
      socket.emit('auth', {'token': token});
    });
    socket.onReconnect((_) {
      socket.emit('auth', {'token': token});
    });
  }

  void subscribe(String chatId) {
    socket.emit('subscribe', {'chatId': chatId});
  }

  void typingStart(String chatId) {
    socket.emit('typing:start', {'chatId': chatId});
  }

  void typingStop(String chatId) {
    socket.emit('typing:stop', {'chatId': chatId});
  }

  void dispose() {
    socket.dispose();
  }
}
