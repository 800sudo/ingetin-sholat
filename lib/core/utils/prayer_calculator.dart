import 'dart:math' as math;

import '../constants/app_constants.dart';
import '../constants/indonesia_cities_data.dart';

class CityLocation {
  final String id;
  final String name;
  final String province;
  final String region; // Sumatera, Jawa & Banten, Bali & Nusa Tenggara, Kalimantan, Sulawesi, Maluku & Papua
  final double latitude;
  final double longitude;
  final double timezone;

  const CityLocation({
    required this.id,
    required this.name,
    required this.province,
    this.region = 'Jawa & Banten',
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  String get timezoneLabel {
    if (timezone == 7.0) return 'WIB (GMT+7)';
    if (timezone == 8.0) return 'WITA (GMT+8)';
    if (timezone == 9.0) return 'WIT (GMT+9)';
    return 'GMT+${timezone.toInt()}';
  }

  static List<CityLocation> get presets => kAllIndonesianCities;

  static CityLocation defaultCity = kAllIndonesianCities.firstWhere(
    (c) => c.id == 'indramayu',
    orElse: () => kAllIndonesianCities[0],
  );

  static CityLocation findById(String id) {
    return kAllIndonesianCities.firstWhere(
      (c) => c.id == id,
      orElse: () => defaultCity,
    );
  }
}

class PrayerScheduleResult {
  final DateTime date;
  final CityLocation location;
  final Map<PrayerType, DateTime> prayerTimes;

  PrayerScheduleResult({
    required this.date,
    required this.location,
    required this.prayerTimes,
  });

  DateTime getTime(PrayerType type) => prayerTimes[type]!;
}

/// Kalkulator Waktu Sholat berbasis posisi matahari (Astronomical Formula)
/// Mengikuti standar hisab Kemenag RI / standard fiqh:
/// - Subuh: sudut matahari -20 derajat
/// - Imsak: 10 menit sebelum Subuh
/// - Terbit / Syuruq: sudut -0.833 derajat
/// - Dzuhur: saat matahari tepat di meridian (zawal + 2 menit ihtiyat)
/// - Ashar: bayangan objek = panjang objek + bayangan saat dzuhur (Syafi'i)
/// - Maghrib: terbenamnya matahari (sudut -0.833 derajat + 2 menit ihtiyat)
/// - Isya: sudut matahari -18 derajat
class PrayerCalculator {
  static const double _degToRad = math.pi / 180.0;
  static const double _radToDeg = 180.0 / math.pi;

  static double _sin(double d) => math.sin(d * _degToRad);
  static double _cos(double d) => math.cos(d * _degToRad);
  static double _tan(double d) => math.tan(d * _degToRad);
  static double _acos(double x) => math.acos(x) * _radToDeg;
  static double _atan(double x) => math.atan(x) * _radToDeg;

  /// Hitung waktu sholat untuk suatu tanggal dan lokasi tertentu
  static PrayerScheduleResult calculate({
    required DateTime date,
    required CityLocation location,
    double subuhAngle = 20.0,
    double isyaAngle = 18.0,
  }) {
    final year = date.year;
    final month = date.month;
    final day = date.day;

    // Julian Date
    final jd = _julianDate(year, month, day);
    final d = jd - 2451545.0;

    // Mean anomaly & solar ecliptic longitude
    final g = (357.529 + 0.98560028 * d) % 360.0;
    final q = (280.459 + 0.98564736 * d) % 360.0;
    final l = (q + 1.915 * _sin(g) + 0.020 * _sin(2 * g)) % 360.0;

    // Obliquity of the ecliptic
    final e = 23.439 - 0.00000036 * d;

    // Sun's Right Ascension & Declination
    final lRad = l * _degToRad;
    final eRad = e * _degToRad;
    final raRad = math.atan2(math.cos(eRad) * math.sin(lRad), math.cos(lRad));
    var ra = (raRad * _radToDeg) / 15.0;
    while (ra < 0) {
      ra += 24.0;
    }
    while (ra >= 24) {
      ra -= 24.0;
    }

    final sinDecl = math.sin(eRad) * math.sin(lRad);
    final decl = math.asin(sinDecl) * _radToDeg;

    // Equation of Time (in hours)
    var eqt = q / 15.0 - ra;
    while (eqt > 12) {
      eqt -= 24;
    }
    while (eqt < -12) {
      eqt += 24;
    }

    // Midday (Dzuhur) in UTC
    final noonUtc = 12.0 - eqt - (location.longitude / 15.0);
    final noonLocal = noonUtc + location.timezone;

    // Waktu Dzuhur ditambah 2 menit sebagai ihtiyat (kehati-hatian)
    final dzuhurHour = noonLocal + (2.0 / 60.0);

    // Hour angle for Subuh (alpha = -subuhAngle)
    final subuhHourAngle = _hourAngle(-subuhAngle, location.latitude, decl);
    final subuhHour = noonLocal - (subuhHourAngle / 15.0);

    // Hour angle for Sunrise (alpha = -0.833)
    final sunriseHourAngle = _hourAngle(-0.833, location.latitude, decl);
    final sunriseHour = noonLocal - (sunriseHourAngle / 15.0);

    // Hour angle for Sunset / Maghrib (alpha = -0.833) + 2 min ihtiyat
    final sunsetHourAngle = _hourAngle(-0.833, location.latitude, decl);
    final sunsetHour = noonLocal + (sunsetHourAngle / 15.0) + (2.0 / 60.0);

    // Hour angle for Ashar (Syafi'i: shadow factor = 1)
    final asharAlt = _atan(
      1.0 / (1.0 + _tan((location.latitude - decl).abs())),
    );
    final asharHourAngle = _hourAngle(asharAlt, location.latitude, decl);
    final asharHour = noonLocal + (asharHourAngle / 15.0) + (2.0 / 60.0);

    // Hour angle for Isya (alpha = -isyaAngle) + 2 min ihtiyat
    final isyaHourAngle = _hourAngle(-isyaAngle, location.latitude, decl);
    final isyaHour = noonLocal + (isyaHourAngle / 15.0) + (2.0 / 60.0);

    // Imsak: 10 menit sebelum Subuh
    final imsakHour = subuhHour - (10.0 / 60.0);

    final map = <PrayerType, DateTime>{
      PrayerType.imsak: _hourToDateTime(date, imsakHour),
      PrayerType.subuh: _hourToDateTime(date, subuhHour),
      PrayerType.syuruq: _hourToDateTime(date, sunriseHour),
      PrayerType.dzuhur: _hourToDateTime(date, dzuhurHour),
      PrayerType.ashar: _hourToDateTime(date, asharHour),
      PrayerType.maghrib: _hourToDateTime(date, sunsetHour),
      PrayerType.isya: _hourToDateTime(date, isyaHour),
    };

    return PrayerScheduleResult(
      date: date,
      location: location,
      prayerTimes: map,
    );
  }

  static double _julianDate(int year, int month, int day) {
    var y = year;
    var m = month;
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        day +
        b -
        1524.5;
  }

  static double _hourAngle(double alt, double lat, double decl) {
    final num = _sin(alt) - _sin(lat) * _sin(decl);
    final den = _cos(lat) * _cos(decl);
    var val = num / den;
    if (val > 1.0) val = 1.0;
    if (val < -1.0) val = -1.0;
    return _acos(val);
  }

  static DateTime _hourToDateTime(DateTime date, double decimalHour) {
    var totalMinutes = (decimalHour * 60).round();
    while (totalMinutes < 0) {
      totalMinutes += 24 * 60;
    }
    while (totalMinutes >= 24 * 60) {
      totalMinutes -= 24 * 60;
    }
    final hour = totalMinutes ~/ 60;
    final minute = totalMinutes % 60;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}
