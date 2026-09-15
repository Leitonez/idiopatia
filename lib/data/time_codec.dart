/// Codifica datas como hora local ("relógio de parede") mais o deslocamento
/// UTC em minutos, para que um registro feito às 21h continue aparecendo
/// às 21h mesmo que o aparelho mude de fuso horário.
class TimeCodec {
  TimeCodec._();

  static String _two(int n) => n.toString().padLeft(2, '0');

  /// Formato: `2026-09-14T21:05:00` (sem fuso).
  static String encode(DateTime dt) {
    final l = dt.isUtc ? dt.toLocal() : dt;
    return '${l.year.toString().padLeft(4, '0')}-${_two(l.month)}-${_two(l.day)}'
        'T${_two(l.hour)}:${_two(l.minute)}:${_two(l.second)}';
  }

  static int offsetMinutes(DateTime dt) =>
      (dt.isUtc ? dt.toLocal() : dt).timeZoneOffset.inMinutes;

  /// Interpreta a string como hora local do aparelho atual.
  static DateTime decode(String value) {
    final s = value.length > 19 ? value.substring(0, 19) : value;
    return DateTime.parse(s);
  }

  static DateTime? decodeNullable(String? value) =>
      value == null || value.isEmpty ? null : decode(value);

  /// Apenas a data, sem hora: `2026-09-14`.
  static String encodeDate(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-${_two(dt.month)}-${_two(dt.day)}';

  static DateTime decodeDate(String value) => DateTime.parse(value);
}
