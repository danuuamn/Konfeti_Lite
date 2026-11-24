import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/app_config.dart';

class SnapResult {
  final String token;
  final String redirectUrl;

  SnapResult({required this.token, required this.redirectUrl});
}

class MidtransService {
  static Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization':
            'Basic ${base64Encode(utf8.encode('${AppConfig.midtransServerKey}:'))}',
      };

  // Membuat transaksi Snap. Hasilnya redirect_url = halaman pembayaran Midtrans.
  static Future<SnapResult> createTransaction({
    required String orderId,
    required int price,
    required int qty,
    required String itemName,
    required String customerName,
    required String customerEmail,
  }) async {
    if (AppConfig.midtransServerKey.isEmpty) {
      throw Exception('Midtrans Server Key belum diisi di lib/core/app_config.dart');
    }

    final name = itemName.length > 50 ? itemName.substring(0, 50) : itemName;
    final customer = <String, dynamic>{'first_name': customerName};
    if (customerEmail.isNotEmpty) customer['email'] = customerEmail;

    final body = {
      'transaction_details': {'order_id': orderId, 'gross_amount': price * qty},
      'item_details': [
        {'id': orderId, 'price': price, 'quantity': qty, 'name': name},
      ],
      'customer_details': customer,
    };

    final response = await http
        .post(
          Uri.parse(AppConfig.midtransSnapUrl),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Midtrans error ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return SnapResult(
      token: data['token'] as String,
      redirectUrl: data['redirect_url'] as String,
    );
  }

  // Mengembalikan 'paid', 'pending', atau 'failed'.
  static Future<String> checkStatus(String orderId) async {
    final response = await http
        .get(
          Uri.parse('${AppConfig.midtransStatusUrl}/${Uri.encodeComponent(orderId)}/status'),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) return 'pending';

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['status_code'] == '404') return 'pending';

    switch (data['transaction_status']) {
      case 'settlement':
      case 'capture':
        return 'paid';
      case 'deny':
      case 'cancel':
      case 'expire':
      case 'failure':
        return 'failed';
      default:
        return 'pending';
    }
  }
}
