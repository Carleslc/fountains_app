extension DateFormatter on DateTime {
  static DateTime? parseOrNull(String? dt) =>
      dt != null ? DateTime.parse(dt) : null;
}
