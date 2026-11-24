import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/ticket_controller.dart';
import '../core/formatters.dart';
import '../models/event_model.dart';

class CheckoutScreen extends StatefulWidget {
  final EventModel event;
  final TicketTier tier;

  const CheckoutScreen({super.key, required this.event, required this.tier});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TicketController _ticketCtrl = Get.find<TicketController>();
  final AuthController _authCtrl = Get.find<AuthController>();

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController =
      TextEditingController(text: _authCtrl.currentUser.value?.name ?? '');
  final TextEditingController _nikController =
      TextEditingController(text: '3171012345678901');

  int _qty = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _nikController.dispose();
    super.dispose();
  }

  int get _totalPrice => widget.tier.priceIdr * _qty;

  Future<void> _submitOrder() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await _ticketCtrl.startPayment(
      event: widget.event,
      tier: widget.tier,
      qty: _qty,
      buyerName: _nameController.text.trim(),
      buyerNik: _nikController.text.trim(),
    );

    if (success) {
      Get.back();
      Get.snackbar(
        'Menuju Pembayaran Midtrans',
        'Selesaikan pembayaran, lalu kembali ke aplikasi. Tiket aktif setelah pembayaran berhasil.',
        backgroundColor: const Color(0xFF8B5CF6),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0A14),
      appBar: AppBar(
        title: const Text('Konfirmasi Pemesanan'),
        backgroundColor: const Color(0xFF0C0A14),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF161326),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF262040)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.event.artist,
                      style: const TextStyle(color: Color(0xFFEC4899), fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const Divider(color: Color(0xFF262040), height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Kategori: ${widget.tier.name}', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white70)),
                        Text(Formatters.rupiah(widget.tier.priceIdr), style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              const Text('Data Pemesan (KTP)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap Sesuai KTP',
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF161326),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF282342)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF282342)),
                  ),
                ),
                validator: (v) => (v == null || v.trim().length < 3) ? 'Nama minimal 3 huruf' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nikController,
                keyboardType: TextInputType.number,
                maxLength: 16,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: '16 Digit NIK KTP',
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFF161326),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF282342)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF282342)),
                  ),
                ),
                validator: (v) => (v == null || v.trim().length != 16) ? 'NIK harus 16 digit angka' : null,
              ),
              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF161326),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF262040)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Jumlah Tiket', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFEC4899)),
                          onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                        ),
                        Text('$_qty', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF8B5CF6)),
                          onPressed: _qty < 5 ? () => setState(() => _qty++) : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF161326),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.4)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.payment_rounded, color: Color(0xFF06B6D4), size: 24),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pembayaran Instan (Midtrans)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                          Text('Bayar lewat Midtrans, tiket terbit setelah pembayaran berhasil', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Pembayaran', style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
                  Text(
                    Formatters.rupiah(_totalPrice),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              Obx(() {
                return Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _ticketCtrl.isLoading.value ? null : _submitOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _ticketCtrl.isLoading.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Bayar dengan Midtrans', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
