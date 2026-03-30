import 'package:flutter_app/core/constants.dart';
import 'package:flutter_app/providers/api_provider.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/socket_io/ripple_socket.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socket_io_client/socket_io_client.dart';
part 'socket_io_provider.g.dart';

class WSConnectStatus {
  final bool isConnected;
  final bool isAuthenticated;

  WSConnectStatus({required this.isConnected, required this.isAuthenticated});
  WSConnectStatus copyWith({bool? isConnected, bool? isAuthenticated}) {
    return WSConnectStatus(
      isConnected: isConnected ?? this.isConnected,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

@riverpod
class SocketIoInit extends _$SocketIoInit {
  late final Socket socket;
  @override
  WSConnectStatus build(String wsUrl, String token) {
    socket = io(wsUrl);
    socket.onConnect((_) => _onConnect());
    socket.onReconnect((_) => _onConnect());
    socket.onDisconnect((_) => _onDisconnect());

    socket.connect();

    ref.onDispose(() {
      socket.dispose();
    });

    return WSConnectStatus(isConnected: false, isAuthenticated: false);
  }

  void _onConnect() {
    // print(
    //   '>>>>> CONNECTED:: ${socket.id}, with URL: ${wsUrl}, token: ${token}',
    // );
    state = state.copyWith(isConnected: true);
    socket.emit('auth', {'token': token});

    socket.on('auth:success', (_) {
      state = state.copyWith(isAuthenticated: true);
    });

    socket.on('auth:failure', (_) {
      state = state.copyWith(isAuthenticated: false);
    });
  }

  void _onDisconnect() {
    print('>>>>> DISCONNECTED:: ${socket.id}');
    state = state.copyWith(isConnected: false, isAuthenticated: false);
  }
}

@riverpod
WSConnectStatus rippleSocketStatus(Ref ref) {
  final auth = ref.watch(authProvider);
  if (auth == null) {
    return WSConnectStatus(isConnected: false, isAuthenticated: false);
  }
  return ref.watch(socketIoInitProvider(API_URL, auth.token));
}

@riverpod
AppSocket? rippleSocket(Ref ref) {
  final auth = ref.watch(authProvider);
  if (auth == null) {
    return null;
  }
  final status = ref.watch(rippleSocketStatusProvider);
  if (!status.isConnected || !status.isAuthenticated) {
    return null;
  }
  final socket = ref
      .watch(socketIoInitProvider(API_URL, auth.token).notifier)
      .socket;
  final rippleSoc = AppSocket(socket);
  ref.onDispose(() {
    rippleSoc.dispose();
  });
  return rippleSoc;
}
