import 'package:intl/intl.dart';

class IslamicDateHelper {
  /// Konversi kalender Masehi ke Hijriah berbasis algoritma astronomis Ummul Qura & Hisab
  static String getHijriDate(DateTime date, {int adjustmentDays = 0}) {
    final effectiveDate = date.add(Duration(days: adjustmentDays));
    var y = effectiveDate.year;
    var m = effectiveDate.month;
    var d = effectiveDate.day;

    if (m < 3) {
      y -= 1;
      m += 12;
    }

    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    final jd =
        (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        d +
        b -
        1524.5;

    // Epok Hijriah: JD 1948439.5 = 1 Muharram 1 H (16 Juli 622 M)
    final epoch = 1948439.5;
    final daysSinceEpoch = (jd - epoch).floor();

    // Siklus 30 tahun = 10631 hari
    final cycle = (daysSinceEpoch / 10631).floor();
    var cycleDays = daysSinceEpoch - (cycle * 10631);

    var yearInCycle = ((cycleDays - 1) / 354.366).floor();
    if (yearInCycle > 29) yearInCycle = 29;
    if (yearInCycle < 0) yearInCycle = 0;

    var daysBeforeYear =
        (yearInCycle * 354) + ((yearInCycle * 11 + 3) / 30).floor();
    var dayOfYear = cycleDays - daysBeforeYear;

    if (dayOfYear <= 0) {
      yearInCycle--;
      daysBeforeYear =
          (yearInCycle * 354) + ((yearInCycle * 11 + 3) / 30).floor();
      dayOfYear = cycleDays - daysBeforeYear;
    }

    final hYear = cycle * 30 + yearInCycle + 1;

    // Panjang bulan Hijriah berseling 30 dan 29 hari
    final isLeap = ((11 * hYear + 14) % 30) < 11;
    final monthLengths = [
      30,
      29,
      30,
      29,
      30,
      29,
      30,
      29,
      30,
      29,
      30,
      isLeap ? 30 : 29,
    ];

    var hMonth = 1;
    var hDay = dayOfYear;

    for (int i = 0; i < 12; i++) {
      if (hDay <= monthLengths[i]) {
        hMonth = i + 1;
        break;
      }
      hDay -= monthLengths[i];
    }

    const hijriMonths = [
      'Muharram',
      'Safar',
      'Rabiul Awwal',
      'Rabiul Akhir',
      'Jumadil Awwal',
      'Jumadil Akhir',
      'Rajab',
      'Sya\'ban',
      'Ramadhan',
      'Syawwal',
      'Dzulqa\'dah',
      'Dzulhijjah',
    ];

    final monthName = (hMonth >= 1 && hMonth <= 12)
        ? hijriMonths[hMonth - 1]
        : 'Jumadil Akhir';

    return '$hDay $monthName $hYear H';
  }

  static String getIndonesianFullDate(DateTime date) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];

    return '$dayName, ${date.day} $monthName ${date.year}';
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static String formatDuration(Duration duration) {
    if (duration.isNegative) return '00:00:00';
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
