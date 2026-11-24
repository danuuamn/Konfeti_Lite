import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../core/formatters.dart';
import '../models/ticket_model.dart';

class TicketQrScreen extends StatelessWidget {
  final TicketModel ticket;

  const TicketQrScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0A14),
      appBar: AppBar(
        title: const Text('Tiket Masuk Digital'),
        backgroundColor: const Color(0xFF0C0A14),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF161326),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF262040)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.confirmation_number_rounded, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket.eventTitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ticket.artist,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Kategori Tiket', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(ticket.tierName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Total Pembayaran', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(Formatters.rupiah(ticket.priceIdr), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF10B981))),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined, size: 16, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(ticket.venueName, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 6),
                          Text(ticket.eventDate, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                      const Divider(color: Color(0xFF262040), height: 28),

                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: QrImageView(
                          data: ticket.ticketCode,
                          version: QrVersions.auto,
                          size: 190.0,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1A34),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.4)),
                        ),
                        child: Text(
                          ticket.ticketCode,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: Color(0xFF8B5CF6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tunjukkan kode QR ini ke petugas pintu masuk konser.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
