import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/event_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/event_controller.dart';
import '../core/formatters.dart';
import '../models/event_model.dart';
import '../models/spotify_model.dart';
import '../services/spotify_service.dart';
import 'checkout_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final EventController _eventController = Get.find<EventController>();

  TicketTier? _selectedTier;
  List<SpotifyTrack> _spotifyTracks = [];
  bool _isLoadingTracks = true;

  final AudioPlayer _player = AudioPlayer();
  String? _playingId;

  @override
  void initState() {
    super.initState();
    if (widget.event.tiers.isNotEmpty) {
      _selectedTier = widget.event.tiers.first;
    }
    _loadSpotifyTracks();

    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playingId = null);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadSpotifyTracks() async {
    final tracks = await SpotifyService.getArtistTracks(widget.event.artist);
    if (mounted) {
      setState(() {
        _spotifyTracks = tracks;
        _isLoadingTracks = false;
      });
    }
  }

  Future<void> _openMaps() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${widget.event.latitude},${widget.event.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final distance = _eventController.getDistanceToEvent(event);

    return Scaffold(
      backgroundColor: const Color(0xFF0C0A14),
      appBar: AppBar(
        title: Text(event.title),
        backgroundColor: const Color(0xFF0C0A14),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                EventImage(event: event, height: 200, iconSize: 64),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      event.category,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            event.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.mic_external_on_rounded, size: 16, color: Color(0xFFEC4899)),
              const SizedBox(width: 6),
              Text(
                event.artist,
                style: const TextStyle(color: Color(0xFFEC4899), fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF161326),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF262040)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: Color(0xFF8B5CF6), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Waktu Konser', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                          Text(event.eventDate, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(color: Color(0xFF262040), height: 20),
                Row(
                  children: [
                    const Icon(Icons.place_rounded, color: Color(0xFF06B6D4), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Lokasi Tempat', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                          Text(event.venueName, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                          if (distance != null)
                            Text(
                              '📍 Jarak dari lokasimu: $distance',
                              style: const TextStyle(color: Color(0xFF06B6D4), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.directions, color: Color(0xFF06B6D4)),
                      tooltip: 'Buka di Google Maps',
                      onPressed: _openMaps,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF121A15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF1DB954).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.library_music_rounded, color: Color(0xFF1DB954), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Dengarkan Lagu Artis di Spotify',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_isLoadingTracks)
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF1DB954), strokeWidth: 2)),
                  )
                else
                  Column(
                    children: _spotifyTracks.map((track) {
                      final isPlaying = _playingId == track.id;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                color: const Color(0xFF1DB954),
                                size: 30,
                              ),
                              onPressed: () async {
                                if (track.previewUrl == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Lagu: "${track.name}" (${track.artist})')),
                                  );
                                  return;
                                }
                                if (isPlaying) {
                                  await _player.stop();
                                  setState(() => _playingId = null);
                                } else {
                                  await _player.stop();
                                  await _player.play(UrlSource(track.previewUrl!));
                                  setState(() => _playingId = track.id);
                                }
                              },
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    track.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    track.artist,
                                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('Pilih Kategori Tiket', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),
          Column(
            children: widget.event.tiers.map((tier) {
              final isSelected = _selectedTier?.id == tier.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF231D3E) : const Color(0xFF161326),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF262040),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: ListTile(
                  onTap: () => setState(() => _selectedTier = tier),
                  title: Text(tier.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                  subtitle: Text(tier.description, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  trailing: Text(
                    Formatters.rupiah(tier.priceIdr),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected ? const Color(0xFF10B981) : Colors.white,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          Container(
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
              onPressed: () {
                final tier = _selectedTier ?? widget.event.tiers.first;
                Get.to(() => CheckoutScreen(event: widget.event, tier: tier));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Lanjut ke Pembayaran', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
