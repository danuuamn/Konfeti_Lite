import 'package:get/get.dart';
import '../models/event_model.dart';
import '../models/ticket_model.dart';
import '../services/local_db_service.dart';
import '../services/notification_service.dart';

class TicketController extends GetxController {
  final RxList<TicketModel> tickets = <TicketModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTickets();
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

  List<TicketModel> get activeTickets =>
      tickets.where((t) => t.isActive).toList();

  List<TicketModel> get historyTickets =>
      tickets.where((t) => !t.isActive).toList();

  Future<bool> bookTicket({
    required EventModel event,
    required TicketTier tier,
    required int qty,
    required String buyerName,
    required String buyerNik,
  }) async {
    isLoading.value = true;
    try {
      await LocalDbService.bookTicket(
        event: event,
        tier: tier,
        qty: qty,
        buyerName: buyerName,
        buyerNik: buyerNik,
      );

      await NotificationService.instance.showImmediateNotification(
        title: 'Tiket Berhasil Dipesan! 🎉',
        body: 'Selamat! $qty tiket ${tier.name} untuk "${event.title}" telah terbit di menu Tiket Saya.',
      );

      loadTickets();
      return true;
    } catch (e) {
      Get.snackbar('Gagal', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
