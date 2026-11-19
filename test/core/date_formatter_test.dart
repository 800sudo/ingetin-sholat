import 'package:flutter_test/flutter_test.dart';
import 'package:pengingat_azhan/core/utils/date_formatter.dart';

void main() {
  test('IslamicDateHelper converts 19 November 2026 to Jumadil Akhir 1448 H', () {
    final date = DateTime(2026, 11, 19);
    final hijri = IslamicDateHelper.getHijriDate(date);
    expect(hijri, contains('1448 H'));
    expect(hijri, contains('Jumadil Akhir'));
    // ignore: avoid_print
    print('Converted Hijri Date: $hijri');
  });
}

