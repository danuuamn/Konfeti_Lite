import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/event_controller.dart';
import '../controllers/ticket_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authCtrl = Get.find<AuthController>();
    final EventController eventCtrl = Get.find<EventController>();
    final TicketController ticketCtrl = Get.find<TicketController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0C0A14),
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        backgroundColor: const Color(0xFF0C0A14),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Container(
            padding: const EdgeInsets.all(18.0),
            decoration: BoxDecoration(
              color: const Color(0xFF161326),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF262040)),
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 32, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Obx(() {
                    final user = authCtrl.currentUser.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Pengguna Konfeti',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? 'email@example.com',
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161326),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF262040)),
                  ),
                  child: Column(
                    children: [
                      Obx(() => Text(
                            '${ticketCtrl.tickets.length}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6)),
                          )),
                      const SizedBox(height: 2),
                      const Text('Tiket Saya', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161326),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF262040)),
                  ),
                  child: Column(
                    children: [
                      Obx(() => Text(
                            '${eventCtrl.events.length}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFEC4899)),
                          )),
                      const SizedBox(height: 2),
                      const Text('Konser Tersedia', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF161326),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF262040)),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, color: Color(0xFF06B6D4), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Koordinat Lokasi Kamu',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Obx(() {
                        final pos = eventCtrl.userPosition.value;
                        if (pos == null) {
                          return const Text('GPS belum terdeteksi', style: TextStyle(color: Color(0xFF64748B), fontSize: 11));
                        }
                        return Text(
                          'Lat: ${pos.latitude.toStringAsFixed(4)}, Lng: ${pos.longitude.toStringAsFixed(4)}',
                          style: const TextStyle(color: Color(0xFF06B6D4), fontSize: 11, fontWeight: FontWeight.bold),
                        );
                      }),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Color(0xFF8B5CF6), size: 20),
                  onPressed: () => eventCtrl.refreshLocation(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF161326),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF262040)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline_rounded, color: Color(0xFF94A3B8), size: 20),
                  title: const Text('Bantuan & FAQ', style: TextStyle(color: Colors.white, fontSize: 13)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B)),
                  onTap: () {},
                ),
                const Divider(color: Color(0xFF262040), height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: Color(0xFF94A3B8), size: 20),
                  title: const Text('Kebijakan Privasi', style: TextStyle(color: Colors.white, fontSize: 13)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B)),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Keluar dari Akun', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.12),
                foregroundColor: Colors.red,
                elevation: 0,
                side: BorderSide(color: Colors.red.withOpacity(0.3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Get.defaultDialog(
                  title: 'Konfirmasi Keluar',
                  titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  middleText: 'Apakah kamu yakin ingin keluar dari akun?',
                  textConfirm: 'Keluar',
                  textCancel: 'Batal',
                  confirmTextColor: Colors.white,
                  buttonColor: Colors.red,
                  onConfirm: () {
                    Get.back();
                    authCtrl.logout();
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
