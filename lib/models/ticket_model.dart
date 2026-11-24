class TicketModel {
  final String ticketCode;
  final int eventId;
  final String eventTitle;
  final String artist;
  final String venueName;
  final String tierName;
  final int priceIdr;
  final String buyerName;
  final String buyerNik;
  final String orderDate;
  final String eventDate;
  final String state;

  TicketModel({
    required this.ticketCode,
    required this.eventId,
    required this.eventTitle,
    required this.artist,
    required this.venueName,
    required this.tierName,
    required this.priceIdr,
    required this.buyerName,
    required this.buyerNik,
    required this.orderDate,
    required this.eventDate,
    this.state = 'active',
  });

  bool get isActive => state == 'active';

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      ticketCode: (json['ticket_code'] ?? '') as String,
      eventId: (json['event_id'] as num?)?.toInt() ?? 0,
      eventTitle: (json['event_title'] ?? '') as String,
      artist: (json['artist'] ?? '') as String,
      venueName: (json['venue_name'] ?? '') as String,
      tierName: (json['tier_name'] ?? 'General') as String,
      priceIdr: (json['price_idr'] as num?)?.toInt() ?? 0,
      buyerName: (json['buyer_name'] ?? '') as String,
      buyerNik: (json['buyer_nik'] ?? '') as String,
      orderDate: (json['order_date'] ?? '') as String,
      eventDate: (json['event_date'] ?? '') as String,
      state: (json['state'] ?? 'active') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticket_code': ticketCode,
      'event_id': eventId,
      'event_title': eventTitle,
      'artist': artist,
      'venue_name': venueName,
      'tier_name': tierName,
      'price_idr': priceIdr,
      'buyer_name': buyerName,
      'buyer_nik': buyerNik,
      'order_date': orderDate,
      'event_date': eventDate,
      'state': state,
    };
  }
}
