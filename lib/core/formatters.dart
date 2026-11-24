import 'package:intl/intl.dart';

class Formatters {
  static String rupiah(int amount) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(amount);
  }

  static String date(DateTime dateTime) {
    final local = dateTime.toLocal();
    final formatter = DateFormat('EEEE, dd MMM yyyy', 'id_ID');
    try {
      return formatter.format(local);
    } catch (_) {
      return '${local.day}/${local.month}/${local.year}';
    }
  }

  static String time(DateTime dateTime) {
    final local = dateTime.toLocal();
    final formatter = DateFormat('HH:mm');
    return '${formatter.format(local)} WIB';
  }

  static String distance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }
}
