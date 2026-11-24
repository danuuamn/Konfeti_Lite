import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/event_controller.dart';
import '../core/formatters.dart';
import '../models/event_model.dart';
import 'event_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EventController eventCtrl = Get.find<EventController>();
    final AuthController authCtrl = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0C0A14),
      appBar: AppBar(
        titleSpacing: 20,
        backgroundColor: const Color(0xFF0C0A14),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.confirmation_number_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KONFETI',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
                Obx(() => Text(
                      'Halo, ${authCtrl.currentUser.value?.name ?? "Penikmat Musik"}!',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    )),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            tooltip: 'Perbarui Data',
            onPressed: () {
              eventCtrl.loadEvents();
              eventCtrl.refreshLocation();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF8B5CF6),
        backgroundColor: const Color(0xFF161326),
        onRefresh: () async {
          eventCtrl.loadEvents();
          await eventCtrl.refreshLocation();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF161326),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF262040)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.near_me_rounded, color: Color(0xFF06B6D4), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(() => Text(
                          eventCtrl.locationStatus.value,
                          style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
                  ),
                  GestureDetector(
                    onTap: () => eventCtrl.refreshLocation(),
                    child: const Text(
                      'Cari Ulang',
                      style: TextStyle(
                        color: Color(0xFF8B5CF6),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            TextField(
              onChanged: (val) => eventCtrl.searchQuery.value = val,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari artis, nama konser, atau kota...',
                hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                suffixIcon: Obx(() {
                  if (eventCtrl.searchQuery.value.isNotEmpty) {
                    return IconButton(
                      icon: const Icon(Icons.clear, color: Color(0xFF94A3B8), size: 18),
                      onPressed: () => eventCtrl.searchQuery.value = '',
                    );
                  }
                  return const SizedBox.shrink();
                }),
                filled: true,
                fillColor: const Color(0xFF161326),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF282342)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF282342)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'FESTIVAL MUSIK 2026',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Pesan Tiket Resmi Lebih Cepat & Mudah',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Dapatkan tiket resmi dengan konfirmasi instan.',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.music_note_rounded, color: Colors.white, size: 28),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Konser Mendatang',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Obx(() => Text(
                      '${eventCtrl.filteredEvents.length} Acara',
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    )),
              ],
            ),
            const SizedBox(height: 12),

            Obx(() {
              final events = eventCtrl.filteredEvents;

              if (events.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(
                    child: Text('Tidak ada konser ditemukan.', style: TextStyle(color: Color(0xFF64748B))),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: events.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final event = events[index];
                  final distance = eventCtrl.getDistanceToEvent(event);

                  return _buildConcertCard(context, event, distance);
                },
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildConcertCard(BuildContext context, EventModel event, String? distance) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161326),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF262040)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Get.to(() => EventDetailScreen(event: event)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  event.imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 160,
                    color: const Color(0xFF1E1A34),
                    child: const Center(
                      child: Icon(Icons.music_note_rounded, size: 48, color: Color(0xFF64748B)),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, const Color(0xFF161326).withOpacity(0.9)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      event.category,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (distance != null)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFF06B6D4), size: 12),
                          const SizedBox(width: 4),
                          Text(
                            distance,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.mic_external_on_rounded, size: 14, color: Color(0xFFEC4899)),
                      const SizedBox(width: 4),
                      Text(
                        event.artist,
                        style: const TextStyle(color: Color(0xFFEC4899), fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined, size: 14, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.venueName,
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFF282342), height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Mulai dari', style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
                          Text(
                            Formatters.rupiah(event.priceIdr),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Pesan Tiket',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
