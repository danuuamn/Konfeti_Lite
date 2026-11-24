import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0A14),
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: const Color(0xFF0C0A14),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Banner Pengingat Notifikasi
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFF161326),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF262040)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.notifications_active_rounded, color: Color(0xFF8B5CF6), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Pusat Notifikasi & Pengingat',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Uji coba fitur notifikasi langsung saat tiket terbit atau jadwalkan pengingat konser sebelum acara dimulai:',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.flash_on_rounded, size: 18),
                    label: const Text('Tes Notifikasi Langsung', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      await NotificationService.instance.showImmediateNotification(
                        title: 'Tiket Berhasil Dipesan! 🎵',
                        body: 'Selamat! Tiket konser kamu telah siap di menu Tiket Saya.',
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifikasi langsung dikirimkan!')),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.schedule_rounded, color: Color(0xFFEC4899), size: 18),
                    label: const Text('Setel Pengingat Konser (10 Detik)', style: TextStyle(color: Color(0xFFEC4899), fontSize: 13, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFEC4899)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      final scheduledDate = DateTime.now().add(const Duration(seconds: 10));
                      try {
                        await NotificationService.instance.scheduleNotification(
                          id: 99,
                          title: 'Pengingat Konser Dimulai ⏰',
                          body: 'Konser musik favoritmu akan segera dimulai dalam waktu dekat!',
                          scheduledDate: scheduledDate,
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pengingat konser disetel untuk 10 detik lagi!')),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal menyetel pengingat: $e')),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          const Text('Aktivitas Terbaru', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF161326),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF262040)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF8B5CF6), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Selamat Datang di Konfeti!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                      SizedBox(height: 2),
                      Text('Jelajahi konser musik dan pesan tiket favoritmu.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                    ],
                  ),
                ),
                const Text('Baru saja', style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
