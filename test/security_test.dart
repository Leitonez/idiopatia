import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:idiopatia/data/time_codec.dart';
import 'package:idiopatia/services/security_service.dart';

void main() {
  test('formato do PIN', () {
    expect(PinStore.isValidFormat('1234'), isTrue);
    expect(PinStore.isValidFormat('123456'), isTrue);
    expect(PinStore.isValidFormat('123'), isFalse);
    expect(PinStore.isValidFormat('1234567'), isFalse);
    expect(PinStore.isValidFormat('12a4'), isFalse);
  });

  test('hash depende do sal e nunca expõe o PIN', () {
    final s1 = PinStore.newSalt(Random(1));
    final s2 = PinStore.newSalt(Random(2));
    expect(s1, isNot(s2));
    final h = PinStore.hash('1234', s1);
    expect(h, isNot(contains('1234')));
    expect(PinStore.hash('1234', s1), h);
    expect(PinStore.hash('1234', s2), isNot(h));
    expect(PinStore.hash('1235', s1), isNot(h));
  });

  test('TimeCodec preserva a hora de parede', () {
    final d = DateTime(2026, 9, 14, 21, 5, 9);
    expect(TimeCodec.encode(d), '2026-09-14T21:05:09');
    expect(TimeCodec.decode('2026-09-14T21:05:09'), d);
    expect(TimeCodec.decode('2026-09-14T21:05:09-03:00'), d);
    expect(TimeCodec.encodeDate(d), '2026-09-14');
    expect(TimeCodec.decodeNullable(null), isNull);
  });
}
