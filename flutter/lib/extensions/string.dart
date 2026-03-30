extension StrExt on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  String toMaxLength(int maxLenth) {
    if (length <= maxLenth) return this;
    return '${substring(0, maxLenth)}...';
  }
}
