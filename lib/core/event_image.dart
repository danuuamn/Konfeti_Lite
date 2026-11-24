import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/event_controller.dart';
import '../models/event_model.dart';

class EventImage extends StatelessWidget {
  final EventModel event;
  final double height;
  final double iconSize;

  const EventImage({
    super.key,
    required this.event,
    required this.height,
    this.iconSize = 48,
  });

  @override
  Widget build(BuildContext context) {
    final eventCtrl = Get.find<EventController>();

    return Obx(() {
      final url = eventCtrl.artistImages[event.artist];

      Widget placeholder() => Container(
            height: height,
            width: double.infinity,
            color: const Color(0xFF1E1A34),
            child: Center(
              child: Icon(Icons.music_note_rounded, size: iconSize, color: const Color(0xFF64748B)),
            ),
          );

      if (url == null) return placeholder();

      return Image.network(
        url,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => placeholder(),
      );
    });
  }
}
