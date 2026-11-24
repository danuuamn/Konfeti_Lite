class TicketTier {
  final int id;
  final String name;
  final int priceIdr;
  final String description;

  const TicketTier({
    required this.id,
    required this.name,
    required this.priceIdr,
    this.description = '',
  });

  factory TicketTier.fromJson(Map<String, dynamic> json) {
    return TicketTier(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '') as String,
      priceIdr: (json['price_idr'] as num?)?.toInt() ?? 0,
      description: (json['description'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price_idr': priceIdr,
      'description': description,
    };
  }
}

class EventModel {
  final int id;
  final String title;
  final String artist;
  final String category;
  final String venueName;
  final double latitude;
  final double longitude;
  final int priceIdr;
  final String imageUrl;
  final String eventDate;
  final List<TicketTier> tiers;

  EventModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.category,
    required this.venueName,
    required this.latitude,
    required this.longitude,
    required this.priceIdr,
    required this.imageUrl,
    required this.eventDate,
    required this.tiers,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final rawTiers = json['tiers'] as List? ?? [];
    final tiers = rawTiers
        .map((t) => TicketTier.fromJson(Map<String, dynamic>.from(t as Map)))
        .toList();

    return EventModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '') as String,
      artist: (json['artist'] ?? '') as String,
      category: (json['category'] ?? 'Konser') as String,
      venueName: (json['venue_name'] ?? '') as String,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      priceIdr: (json['price_idr'] as num?)?.toInt() ?? 0,
      imageUrl: (json['image_url'] ?? '') as String,
      eventDate: (json['event_date'] ?? '') as String,
      tiers: tiers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'category': category,
      'venue_name': venueName,
      'latitude': latitude,
      'longitude': longitude,
      'price_idr': priceIdr,
      'image_url': imageUrl,
      'event_date': eventDate,
      'tiers': tiers.map((t) => t.toJson()).toList(),
    };
  }
}
