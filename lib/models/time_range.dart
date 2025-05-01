// lib/models/time_range.dart
import 'package:flutter/material.dart';

class TimeRange {
  TimeOfDay start;
  TimeOfDay end;
  
  TimeRange(this.start, this.end);
  
  // Add copyWith method if needed
  TimeRange copyWith({
    TimeOfDay? start,
    TimeOfDay? end,
  }) {
    return TimeRange(
      start ?? this.start,
      end ?? this.end,
    );
  }
}