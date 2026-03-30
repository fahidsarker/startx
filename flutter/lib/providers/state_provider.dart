import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:async';

class StateProvider<T> extends Notifier<T> {
  final T _initialState;
  Timer? _debounceTimer;
  static const Duration debounceDuration = Duration(milliseconds: 500);
  StateProvider(this._initialState);

  static NotifierProvider<StateProvider<T>, T> of<T>(T initState) =>
      NotifierProvider<StateProvider<T>, T>(() => StateProvider<T>(initState));

  @override
  T build() => _initialState;

  @override
  set state(T newState) => super.state = newState;

  void debounceSet(T query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(debounceDuration, () {
      state = query;
      _debounceTimer?.cancel();
      _debounceTimer = null;
    });
  }
}
