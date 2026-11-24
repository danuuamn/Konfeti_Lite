import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ticket_controller.dart';
import '../core/formatters.dart';
import '../models/ticket_model.dart';
import 'ticket_qr_screen.dart';

class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TicketController ticketCtrl = Get.find<TicketController>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0C0A14),
        appBar: AppBar(
          title: const Text('Tiket Saya'),
          backgroundColor: const Color(0xFF0C0A14),
          bottom: const TabBar(
            indicatorColor: Color(0xFFEC4899),
            indicatorWeight: 3,
            labelColor: Color(0xFFEC4899),
            unselectedLabelColor: Color(0xFF94A3B8),
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(text: 'Tiket Aktif'),
              Tab(text: 'Riwayat Konser'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(() => ticketCtrl.activeTickets, ticketCtrl),
            _buildList(() => ticketCtrl.historyTickets, ticketCtrl),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<TicketModel> Function() getTickets, TicketController ctrl) {
    return Obx(() {
      if (ctrl.tickets.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.confirmation_number_outlined, size: 64, color: const Color(0xFF64748B).withOpacity(0.5)),
                const SizedBox(height: 16),
                const Text(
                  'Belum ada tiket konser yang dibeli.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                ),
              ],
            ),
          ),
        );
      }

      final tickets = getTickets();
      if (tickets.isEmpty) {
        return const Center(
          child: Text('Tidak ada tiket di kategori ini.', style: TextStyle(color: Color(0xFF64748B))),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: tickets.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF161326),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF262040)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: ticket.isActive ? () => Get.to(() => TicketQrScreen(ticket: ticket)) : null,
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            ticket.eventTitle,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _statusColor(ticket).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            ticket.isActive ? ticket.tierName : _statusLabel(ticket),
                            style: TextStyle(color: _statusColor(ticket), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ticket.artist,
                      style: const TextStyle(color: Color(0xFFEC4899), fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, size: 14, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            ticket.venueName,
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Text(ticket.eventDate, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                      ],
                    ),
                    const Divider(color: Color(0xFF262040), height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Formatters.rupiah(ticket.priceIdr),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                        ),
                        if (ticket.isActive)
                          const Row(
                          children: [
                            Icon(Icons.qr_code_2_rounded, size: 16, color: Color(0xFF8B5CF6)),
                            SizedBox(width: 4),
                            Text(
                              'Lihat Tiket QR →',
                              style: TextStyle(color: Color(0xFF8B5CF6), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        if (ticket.isPending)
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => ctrl.continuePayment(ticket),
                                child: const Text('Bayar', style: TextStyle(color: Color(0xFFEC4899), fontWeight: FontWeight.bold)),
                              ),
                              TextButton(
                                onPressed: () => ctrl.refreshPending(showMessage: true),
                                child: const Text('Cek Status', style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Color _statusColor(TicketModel t) {
    if (t.isPending) return const Color(0xFFF59E0B);
    if (t.isFailed) return const Color(0xFFEF4444);
    return const Color(0xFF10B981);
  }

  String _statusLabel(TicketModel t) {
    if (t.isPending) return 'Menunggu Pembayaran';
    if (t.isFailed) return 'Gagal / Kedaluwarsa';
    return t.tierName;
  }
}
