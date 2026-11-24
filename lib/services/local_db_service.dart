import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_model.dart';
import '../models/ticket_model.dart';
import '../models/user_model.dart';

class LocalDbService {
  static const String _kEventsBox = 'konfeti_events_box';
  static const String _kTicketsBox = 'konfeti_tickets_box';
  static const String _kUsersBox = 'konfeti_users_box';

  static const String _spIsLoggedIn = 'sp_is_logged_in';
  static const String _spUserEmail = 'sp_user_email';
  static const String _spUserName = 'sp_user_name';

  static Future<void> init() async {
    await Hive.initFlutter();

    await Hive.openBox(_kEventsBox);
    await Hive.openBox(_kTicketsBox);
    await Hive.openBox(_kUsersBox);

    await _seedDefaultEventsIfEmpty();
  }

  static Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final box = Hive.box(_kUsersBox);

    UserModel? foundUser;
    for (var key in box.keys) {
      final raw = box.get(key);
      if (raw != null) {
        final map = jsonDecode(raw.toString()) as Map<String, dynamic>;
        if (map['email'] == email) {
          foundUser = UserModel.fromJson(map);
          break;
        }
      }
    }

    if (foundUser == null && email == 'user@example.com' && password == 'password123') {
      foundUser = UserModel(id: 1, name: 'Budi Santoso', email: email, password: password);
      await box.put(email, jsonEncode(foundUser.toJson()));
    }

    if (foundUser == null) {
      throw Exception('Email belum terdaftar. Silakan daftar akun terlebih dahulu.');
    }

    if (foundUser.password != password) {
      throw Exception('Password salah. Silakan coba lagi.');
    }

    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_spIsLoggedIn, true);
    await sp.setString(_spUserEmail, foundUser.email);
    await sp.setString(_spUserName, foundUser.name);

    return foundUser;
  }

  static Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final box = Hive.box(_kUsersBox);

    if (box.containsKey(email)) {
      throw Exception('Email ini sudah terdaftar. Silakan login.');
    }

    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
      email: email,
      password: password,
    );

    await box.put(email, jsonEncode(newUser.toJson()));

    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_spIsLoggedIn, true);
    await sp.setString(_spUserEmail, newUser.email);
    await sp.setString(_spUserName, newUser.name);

    return newUser;
  }

  static Future<UserModel?> getCurrentUserSession() async {
    final sp = await SharedPreferences.getInstance();
    final isLoggedIn = sp.getBool(_spIsLoggedIn) ?? false;
    if (!isLoggedIn) return null;

    final email = sp.getString(_spUserEmail) ?? '';
    final name = sp.getString(_spUserName) ?? '';

    return UserModel(id: 1, name: name, email: email);
  }

  static Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_spIsLoggedIn);
    await sp.remove(_spUserEmail);
    await sp.remove(_spUserName);
  }

  static List<EventModel> getEvents() {
    final box = Hive.box(_kEventsBox);
    final List<EventModel> list = [];

    for (var key in box.keys) {
      final raw = box.get(key);
      if (raw != null) {
        final map = jsonDecode(raw.toString()) as Map<String, dynamic>;
        list.add(EventModel.fromJson(map));
      }
    }

    return list;
  }

  static Future<TicketModel> bookTicket({
    required EventModel event,
    required TicketTier tier,
    required int qty,
    required String buyerName,
    required String buyerNik,
    required String ticketCode,
    String state = 'pending',
    String redirectUrl = '',
  }) async {
    final box = Hive.box(_kTicketsBox);

    final ticket = TicketModel(
      ticketCode: ticketCode,
      eventId: event.id,
      eventTitle: event.title,
      artist: event.artist,
      venueName: event.venueName,
      tierName: tier.name,
      priceIdr: tier.priceIdr * qty,
      buyerName: buyerName,
      buyerNik: buyerNik,
      orderDate: 'Hari ini',
      eventDate: event.eventDate,
      state: state,
      redirectUrl: redirectUrl,
    );

    await box.put(ticket.ticketCode, jsonEncode(ticket.toJson()));

    return ticket;
  }

  static Future<void> updateTicketState(String ticketCode, String state) async {
    final box = Hive.box(_kTicketsBox);
    final raw = box.get(ticketCode);
    if (raw == null) return;
    final map = jsonDecode(raw.toString()) as Map<String, dynamic>;
    map['state'] = state;
    await box.put(ticketCode, jsonEncode(map));
  }

  static List<TicketModel> getMyTickets() {
    final box = Hive.box(_kTicketsBox);
    final List<TicketModel> list = [];

    for (var key in box.keys) {
      final raw = box.get(key);
      if (raw != null) {
        final map = jsonDecode(raw.toString()) as Map<String, dynamic>;
        list.add(TicketModel.fromJson(map));
      }
    }

    return list.reversed.toList();
  }

  static Future<void> _seedDefaultEventsIfEmpty() async {
    final box = Hive.box(_kEventsBox);
    if (box.isNotEmpty) return;

    final defaultEvents = [
      EventModel(
        id: 1,
        title: 'Music of the Spheres World Tour',
        artist: 'Coldplay',
        category: 'Konser Pop Rock',
        venueName: 'Gelora Bung Karno (GBK), Jakarta',
        latitude: -6.2185,
        longitude: 106.8026,
        priceIdr: 800000,
        imageUrl: 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=800',
        eventDate: 'Sabtu, 15 Agustus 2026',
        tiers: const [
          TicketTier(id: 1, name: 'Festival (Standing)', priceIdr: 800000, description: 'Area depan panggung'),
          TicketTier(id: 2, name: 'CAT 1 (Seated)', priceIdr: 1250000, description: 'Tribun tengah bernomor'),
          TicketTier(id: 3, name: 'VIP Infinity', priceIdr: 2500000, description: 'Akses khusus & merchandise'),
        ],
      ),
      EventModel(
        id: 2,
        title: 'Tunggu Aku di Yogyakarta',
        artist: 'Sheila on 7',
        category: 'Konser Pop Populer',
        venueName: 'Stadion Kridosono, Yogyakarta',
        latitude: -7.7876,
        longitude: 110.3754,
        priceIdr: 350000,
        imageUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800',
        eventDate: 'Minggu, 20 September 2026',
        tiers: const [
          TicketTier(id: 4, name: 'Festival A', priceIdr: 350000, description: 'Area lapangan tengah'),
          TicketTier(id: 5, name: 'VIP Seated', priceIdr: 750000, description: 'Tribun nyaman dengan tempat duduk'),
        ],
      ),
      EventModel(
        id: 3,
        title: 'Menari Dengan Bayangan Live',
        artist: 'Hindia',
        category: 'Konser Indie Alternatif',
        venueName: 'Jogja Expo Center (JEC), Yogyakarta',
        latitude: -7.7981,
        longitude: 110.4079,
        priceIdr: 250000,
        imageUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800',
        eventDate: 'Jumat, 9 Oktober 2026',
        tiers: const [
          TicketTier(id: 6, name: 'Presale Festival', priceIdr: 250000, description: 'Tiket presale terbatas'),
          TicketTier(id: 7, name: 'Regular Festival', priceIdr: 350000, description: 'Tiket reguler'),
        ],
      ),
      EventModel(
        id: 4,
        title: 'Tur Manusia 2026',
        artist: 'Tulus',
        category: 'Konser Akustik & Pop',
        venueName: 'ICE BSD City, Tangerang',
        latitude: -6.3023,
        longitude: 106.6378,
        priceIdr: 500000,
        imageUrl: 'https://images.unsplash.com/photo-1465847899084-d164df4dedc6?w=800',
        eventDate: 'Sabtu, 28 November 2026',
        tiers: const [
          TicketTier(id: 8, name: 'Tribun Reguler', priceIdr: 500000, description: 'Tribun tempat duduk'),
          TicketTier(id: 9, name: 'Diamond VIP', priceIdr: 1500000, description: 'Baris terdepan panggung'),
        ],
      ),
    ];

    for (var event in defaultEvents) {
      await box.put(event.id.toString(), jsonEncode(event.toJson()));
    }
  }
}
