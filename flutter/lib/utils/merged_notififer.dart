import 'package:flutter/foundation.dart';

// ValueNotifier<R> mergeNotifiers<R, X extends Record>(X notifiers) {}
class Merged2Notififer<R, A, B> extends ValueNotifier<R> {
  final ValueNotifier<A> notifierA;
  final ValueNotifier<B> notifierB;
  final R Function(A, B) compute;

  Merged2Notififer(this.notifierA, this.notifierB, this.compute)
    : super(compute(notifierA.value, notifierB.value)) {
    notifierA.addListener(_onChange);
    notifierB.addListener(_onChange);
  }

  void _onChange() {
    value = compute(notifierA.value, notifierB.value);
  }

  @override
  void dispose() {
    notifierA.removeListener(_onChange);
    notifierB.removeListener(_onChange);
    super.dispose();
  }
}

class Merged3Notififer<R, A, B, C> extends ValueNotifier<R> {
  final ValueNotifier<A> notifierA;
  final ValueNotifier<B> notifierB;
  final ValueNotifier<C> notifierC;
  final R Function(A, B, C) compute;

  Merged3Notififer(this.notifierA, this.notifierB, this.notifierC, this.compute)
    : super(compute(notifierA.value, notifierB.value, notifierC.value)) {
    notifierA.addListener(_onChange);
    notifierB.addListener(_onChange);
    notifierC.addListener(_onChange);
  }

  void _onChange() {
    value = compute(notifierA.value, notifierB.value, notifierC.value);
  }

  @override
  void dispose() {
    notifierA.removeListener(_onChange);
    notifierB.removeListener(_onChange);
    notifierC.removeListener(_onChange);
    super.dispose();
  }
}

class Merged4Notififer<R, A, B, C, D> extends ValueNotifier<R> {
  final ValueNotifier<A> notifierA;
  final ValueNotifier<B> notifierB;
  final ValueNotifier<C> notifierC;
  final ValueNotifier<D> notifierD;
  final R Function(A, B, C, D) compute;

  Merged4Notififer(
    this.notifierA,
    this.notifierB,
    this.notifierC,
    this.notifierD,
    this.compute,
  ) : super(
        compute(
          notifierA.value,
          notifierB.value,
          notifierC.value,
          notifierD.value,
        ),
      ) {
    notifierA.addListener(_onChange);
    notifierB.addListener(_onChange);
    notifierC.addListener(_onChange);
    notifierD.addListener(_onChange);
  }

  void _onChange() {
    value = compute(
      notifierA.value,
      notifierB.value,
      notifierC.value,
      notifierD.value,
    );
  }

  @override
  void dispose() {
    notifierA.removeListener(_onChange);
    notifierB.removeListener(_onChange);
    notifierC.removeListener(_onChange);
    notifierD.removeListener(_onChange);
    super.dispose();
  }
}
