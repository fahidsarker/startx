import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_app/core/api.dart';
import 'package:flutter_app/providers/api_provider.dart';

extension RiverpodExt on WidgetRef {
  Api get api => watch(apiProvider);
}

extension RivRefExt on Ref {
  Api get api => watch(apiProvider);
}
