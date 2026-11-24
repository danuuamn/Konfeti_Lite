import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/event_model.dart';
import '../models/ticket_model.dart';
import '../services/local_db_service.dart';
import '../services/midtrans_service.dart';
import '../services/notification_service.dart';
import 'auth_controller.dart';

class TicketController extends GetxController with WidgetsBindingObserver {
  final RxList<TicketModel> tickets = <TicketModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isChecking = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    loadTickets();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  // Dipanggil saat pengguna kembali dari halaman Midtrans ke aplikasi.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refreshPending();
  }

  void loadTickets() {
    isLoading.value = true;
    try {
      final list = LocalDbService.getMyTickets();
      tickets.assignAll(list);
    } finally {
      isLoading.value = false;
    }
  }

  // Tiket aktif + tiket yang masih menunggu pembayaran.
  List<TicketModel> get activeTickets =>
      tickets.where((t) => t.isActive || t.isPending).toList();

  List<TicketModel> get historyTickets =>
      tickets.where((t) => !t.isActive && !t.isPending).toList();

  // 1) buat transaksi di Midtrans, 2) simpan tiket berstatus pending,
  // 3) buka halaman pembayaran Midtrans.
  Future<bool> startPayment({
    required EventModel event,
    required TicketTier tier,
    required int qty,
    required String buyerName,
    required String buyerNik,
  }) async {
    isLoading.value = true;
    try {
      final code = 'KNF-${DateTime.now().millisecondsSinceEpoch}';
      final email = Get.find<AuthController>().currentUser.value?.email ?? '';

      final snap = await MidtransService.createTransaction(
        orderId: code,
        price: tier.priceIdr,
        qty: qty,
        itemName: '${event.title} - ${tier.name}',
        customerName: buyerName,
        customerEmail: email,
      );

      await LocalDbService.bookTicket(
        event: event,
        tier: tier,
        qty: qty,
        buyerName: buyerName,
        buyerNik: buyerNik,
        ticketCode: code,
        state: 'pending',
        redirectUrl: snap.redirectUrl,
      );
      loadTickets();

      await _openUrl(snap.redirectUrl);
      return true;
    } catch (e) {
      Get.snackbar('Gagal', e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> continuePayment(TicketModel ticket) => _openUrl(ticket.redirectUrl);

  Future<void> _openUrl(String url) async {
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok) Get.snackbar('Gagal', 'Tidak bisa membuka halaman pembayaran.');
  }

  // Tanya ke Midtrans status tiap tiket pending. Kalau sudah dibayar: tiket jadi aktif + notifikasi.
  Future<void> refreshPending({bool showMessage = false}) async {
    if (isChecking.value) return;
    final pending = tickets.where((t) => t.isPending).toList();
    if (pending.isEmpty) {
      if (showMessage) Get.snackbar('Info', 'Tidak ada pembayaran yang menunggu.');
      return;
    }

    isChecking.value = true;
    var changed = false;
    try {
      for (final t in pending) {
        try {
          final status = await MidtransService.checkStatus(t.ticketCode);
          if (status == 'paid') {
            await LocalDbService.updateTicketState(t.ticketCode, 'active');
            await NotificationService.instance.showImmediateNotification(
              id: t.ticketCode.hashCode & 0x7fffffff,
              title: 'Pembayaran Berhasil! 🎉',
              body: 'Tiket "${t.eventTitle}" kini aktif di menu Tiket Saya.',
            );
            changed = true;
          } else if (status == 'failed') {
            await LocalDbService.updateTicketState(t.ticketCode, 'failed');
            changed = true;
          }
        } catch (_) {
          // jaringan putus: biarkan pending, coba lagi nanti
        }
      }
    } finally {
      isChecking.value = false;
    }

    if (changed) loadTickets();
    if (showMessage) {
      Get.snackbar(
        changed ? 'Status diperbarui' : 'Belum dibayar',
        changed ? 'Cek tab Tiket Aktif atau Riwayat.' : 'Selesaikan pembayaran di halaman Midtrans.',
      );
    }
  }
}
