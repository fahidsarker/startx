import 'package:socket_io_client/socket_io_client.dart';

/// Socket.IO event names and ack suffixes aligned with
/// `express-js/src/ws/ws.ts` (`DEFAULT_EVENTS` and `${event}:success|failure`).
class AppSocketEvents {
  const AppSocketEvents({
    this.auth = 'auth',
    this.roomSubscribe = 'room:subscribe',
    this.roomUnsubscribe = 'room:unsubscribe',
  });

  final String auth;
  final String roomSubscribe;
  final String roomUnsubscribe;

  String get authSuccess => '$auth:success';
  String get authFailure => '$auth:failure';
  String get roomSubscribeSuccess => '$roomSubscribe:success';
  String get roomSubscribeFailure => '$roomSubscribe:failure';
  String get roomUnsubscribeSuccess => '$roomUnsubscribe:success';
  String get roomUnsubscribeFailure => '$roomUnsubscribe:failure';
}

typedef AppSocketAck = void Function(String message);

/// Thin client for the template WebSocket protocol (token auth + room join/leave).
class AppSocket {
  AppSocket(
    this.socket, {
    this.events = const AppSocketEvents(),
    this.roomIdField = 'roomId',
  });

  final Socket socket;
  final AppSocketEvents events;

  /// Server default in `ws.ts` (`roomIdField`); must match when using custom field server-side.
  final String roomIdField;

  /// Same payload as server `extractToken` / `handleAuth`.
  void emitAuth(String token) {
    socket.emit(events.auth, {'token': token});
  }

  /// Emits [events.roomSubscribe] with `{ [roomIdField]: roomId }`; listens for one ack.
  void subscribeToRoom(
    String roomId, {
    AppSocketAck? onSuccess,
    AppSocketAck? onFailure,
  }) {
    socket.once(events.roomSubscribeSuccess, (data) {
      onSuccess?.call(_messageFromAck(data) ?? '');
    });
    socket.once(events.roomSubscribeFailure, (data) {
      onFailure?.call(_messageFromAck(data) ?? '');
    });
    socket.emit(events.roomSubscribe, {roomIdField: roomId});
  }

  /// Emits [events.roomUnsubscribe] with `{ [roomIdField]: roomId }`; listens for one ack.
  void unsubscribeFromRoom(
    String roomId, {
    AppSocketAck? onSuccess,
    AppSocketAck? onFailure,
  }) {
    socket.once(events.roomUnsubscribeSuccess, (data) {
      onSuccess?.call(_messageFromAck(data) ?? '');
    });
    socket.once(events.roomUnsubscribeFailure, (data) {
      onFailure?.call(_messageFromAck(data) ?? '');
    });
    socket.emit(events.roomUnsubscribe, {roomIdField: roomId});
  }

  /// Subscribe to arbitrary server-emitted events (e.g. broadcasts to a joined room).
  void subscribe<T>(String event, void Function(T data) onData) {
    socket.on(event, (data) {
      if (data is T) {
        onData(data);
      }
    });
  }

  void dispose() {
    socket.clearListeners();
  }

  static String? _messageFromAck(dynamic data) {
    if (data is Map) {
      final m = data['message'];
      if (m is String) return m;
    }
    return null;
  }
}
