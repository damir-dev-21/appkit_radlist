import 'package:appkit/common/util/date_utils.dart';

/// Something that has a timestamp.
abstract class Timestamped {
  DateTime? get timestamp;

  /// Groups given [items] into [groupedItems] by same-day [timestamp].
  static void groupItemsByDate<T extends Timestamped>(
    List<T>? items,
    List<TimestampedGroup<T>> groupedItems,
  ) {
    groupedItems.clear();
    if (items == null || items.isEmpty) {
      return;
    }

    final headerIndices = <int>[];

    DateTime? timestamp;
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      if (timestamp == null) {
        timestamp = item.timestamp;
        if (timestamp != null) {
          headerIndices.add(i);
        }
      } else {
        final currentTimestamp = item.timestamp;
        if (currentTimestamp != null && !DateUtils.isOnSameDay(timestamp, currentTimestamp)) {
          timestamp = item.timestamp;
          headerIndices.add(i);
        }
      }
    }

    for (int i = 0; i < headerIndices.length; i++) {
      final headerIndex = headerIndices[i];
      final firstItem = items[headerIndex];
      final timestamp = firstItem.timestamp;
      if (timestamp != null) {
        if (i < headerIndices.length - 1) {
          groupedItems.add(TimestampedGroup(
            timestamp: timestamp,
            items: items.sublist(headerIndex, headerIndices[i + 1]),
            indexOffset: headerIndex,
          ));
        } else {
          groupedItems.add(TimestampedGroup(
            timestamp: timestamp,
            items: items.sublist(headerIndex),
            indexOffset: headerIndex,
          ));
        }
      }
    }
  }
}

class TimestampedGroup<T extends Timestamped> {
  final DateTime timestamp;
  final List<T> items;
  final int indexOffset;

  TimestampedGroup({
    required this.timestamp,
    required this.items,
    required this.indexOffset,
  });
}
