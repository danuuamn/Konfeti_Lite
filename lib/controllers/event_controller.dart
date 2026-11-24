import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../models/event_model.dart';
import '../services/local_db_service.dart';
import '../services/location_service.dart';
import '../services/spotify_service.dart';

class EventController extends GetxController {
  final RxList<EventModel> events = <EventModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  final Rx<Position?> userPosition = Rx<Position?>(null);
  final RxMap<String, String> artistImages = <String, String>{}.obs;
  final RxString locationStatus = 'Mencari lokasi GPS...'.obs;

  @override
  void onInit() {
    super.onInit();
    loadEvents();
    refreshLocation();
  }

  void loadEvents() {
    isLoading.value = true;
    try {
      final list = LocalDbService.getEvents();
      events.assignAll(list);
      loadArtistImages();
    } finally {
      isLoading.value = false;
    }
  }

  // Ambil foto artis dari Spotify untuk tiap event.
  Future<void> loadArtistImages() async {
    for (final e in events) {
      if (artistImages.containsKey(e.artist)) continue;
      final url = await SpotifyService.getArtistImage(e.artist);
      if (url != null) artistImages[e.artist] = url;
    }
  }

  Future<void> refreshLocation() async {
    try {
      final pos = await LocationService.getCurrentPosition();
      if (pos != null) {
        userPosition.value = pos;
        locationStatus.value = 'GPS Aktif: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
      } else {
        locationStatus.value = 'GPS tidak aktif atau izin lokasi ditolak';
      }
    } catch (_) {
      locationStatus.value = 'Gagal mengakses GPS';
    }
  }

  String? getDistanceToEvent(EventModel event) {
    final pos = userPosition.value;
    if (pos == null) return null;

    final meters = LocationService.calculateDistance(
      startLatitude: pos.latitude,
      startLongitude: pos.longitude,
      endLatitude: event.latitude,
      endLongitude: event.longitude,
    );
    return LocationService.formatDistance(meters);
  }

  List<EventModel> get filteredEvents {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return events;
    return events.where((e) {
      return e.title.toLowerCase().contains(q) ||
          e.artist.toLowerCase().contains(q) ||
          e.venueName.toLowerCase().contains(q);
    }).toList();
  }
}
