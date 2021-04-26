import 'package:flutter/widgets.dart';

import '../event.dart';
import '../time/overlay.dart';
import '../utils.dart';
import 'date_events.dart';
import 'overlays.dart';

typedef DateContentBackgroundTapCallback = void Function(DateTime dateTime);

class DateContent<E extends Event> extends StatelessWidget {
  DateContent({
    Key? key,
    required this.date,
    required Iterable<E> events,
    required this.eventBuilder,
    this.overlays = const [],
    this.onBackgroundTap,
    this.dateEventsStyle = const DateEventsStyle(),
  })  : assert(date.isValidTimetableDate),
        assert(
          events.every((e) => e.interval.intersects(date.fullDayInterval)),
          'All events must intersect the given date',
        ),
        assert(
          events.toSet().length == events.length,
          'Events may not contain duplicates',
        ),
        events = events.sortedByOnTopStartLength(),
        super(key: key);

  final DateTime date;

  final List<E> events;
  final EventBuilder<E> eventBuilder;

  final List<TimeOverlay> overlays;

  final DateContentBackgroundTapCallback? onBackgroundTap;
  final DateEventsStyle dateEventsStyle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapUp: onBackgroundTap != null
              ? (details) => _onBackgroundTap(height, details.localPosition.dy)
              : null,
          child: Stack(
            children: [
              _buildOverlaysForPosition(DecorationPosition.background),
              DateEvents<E>(
                date: date,
                events: events,
                eventBuilder: eventBuilder,
                style: dateEventsStyle,
              ),
              _buildOverlaysForPosition(DecorationPosition.foreground),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverlaysForPosition(DecorationPosition position) {
    return Positioned.fill(
      child: TimeOverlays(
        overlays: overlays.where((it) => it.position == position).toList(),
      ),
    );
  }

  void _onBackgroundTap(double height, double yOffset) =>
      onBackgroundTap!(date + (yOffset / height).days);
}