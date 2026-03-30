import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_app/core/constants.dart';
import 'package:flutter_app/extensions/context.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/providers/socket_io_provider.dart';
import 'package:flutter_app/socket_io/app_socket.dart';

const _kWsEvents = AppSocketEvents();

class EchoDemoScreen extends HookConsumerWidget {
  const EchoDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final controller = useTextEditingController();
    final log = useState<List<String>>([]);

    if (auth == null) {
      return const SizedBox.shrink();
    }

    final status = ref.watch(socketIoInitProvider(API_URL, auth.token));
    final socket =
        ref.read(socketIoInitProvider(API_URL, auth.token).notifier).socket;

    useEffect(() {
      void onReply(dynamic data) {
        final reply = EchoReply.fromPayload(data);
        if (reply == null) return;
        if (reply.error != null) {
          log.value = [...log.value, 'Error: ${reply.error}'];
        } else if (reply.message != null) {
          log.value = [...log.value, '< ${reply.message}'];
        }
      }

      socket.on(_kWsEvents.echoReply, onReply);
      return () => socket.off(_kWsEvents.echoReply, onReply);
    }, [socket]);

    final ready = status.isConnected && status.isAuthenticated;

    void send() {
      final text = controller.text.trim();
      if (text.isEmpty || !ready) return;
      AppSocket(socket, events: _kWsEvents).emitEcho(text);
      log.value = [...log.value, '> $text'];
      controller.clear();
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(context.defPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Socket.IO echo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              ready
                  ? 'The server echoes your text and appends a random suffix.'
                  : 'Waiting for socket (connected: ${status.isConnected}, '
                      'authenticated: ${status.isAuthenticated})…',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    enabled: ready,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Message',
                    ),
                    onSubmitted: (_) => send(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: ready ? send : null,
                  child: const Text('Send'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Log', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: log.value.length,
                  itemBuilder: (_, i) => SelectableText(log.value[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
