// lib/content/availability/widgets/add_hours_modal.dart
import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:tabourak/models/time_range.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class AddHoursModal extends StatefulWidget {
  const AddHoursModal({Key? key}) : super(key: key);

  @override
  State<AddHoursModal> createState() => _AddHoursModalState();
}

class _AddHoursModalState extends State<AddHoursModal> {
  final Map<DateTime, List<TimeRange>> _dateTimeRanges = {};
  DateTime? _copySourceDate;
  List<DateTime> _copyTargetDates = [];

  void _addTimeRange(DateTime date) {
    setState(() {
      _dateTimeRanges[date] ??= [];
      final lastSlot = _dateTimeRanges[date]!.isEmpty 
          ? null 
          : _dateTimeRanges[date]!.last;
      
      final newStart = lastSlot?.end ?? TimeOfDay(hour: 9, minute: 0);
      final newEnd = TimeOfDay(
        hour: (newStart.hour + 1) % 24,
        minute: newStart.minute,
      );

      _dateTimeRanges[date]!.add(TimeRange(newStart, newEnd));
    });
  }

  void _removeTimeRange(DateTime date, int index) {
    setState(() {
      _dateTimeRanges[date]?.removeAt(index);
      if (_dateTimeRanges[date]?.isEmpty ?? true) {
        _dateTimeRanges.remove(date);
      }
    });
  }

  bool _hasTimeOverlap(List<TimeRange> ranges, TimeRange newRange) {
    for (final existingRange in ranges) {
      if (existingRange == newRange) continue;
      
      final existingStart = existingRange.start;
      final existingEnd = existingRange.end;
      final newStart = newRange.start;
      final newEnd = newRange.end;

      if (_isStartSameAsEnd(existingRange) || _isStartSameAsEnd(newRange)) {
        continue;
      }

      if ((newStart.hour < existingEnd.hour || 
          (newStart.hour == existingEnd.hour && newStart.minute < existingEnd.minute)) &&
          (newEnd.hour > existingStart.hour || 
          (newEnd.hour == existingStart.hour && newEnd.minute > existingStart.minute))) {
        return true;
      }
    }
    return false;
  }

  bool _isStartAfterEnd(TimeRange range) {
    return range.end.hour < range.start.hour || 
          (range.end.hour == range.start.hour && range.end.minute < range.start.minute);
  }

  bool _isStartSameAsEnd(TimeRange range) {
    return range.start.hour == range.end.hour && 
           range.start.minute == range.end.minute;
  }

Future<void> _selectDates(BuildContext context) async {
  final List<DateTime>? picked = await showDialog<List<DateTime>>(
    context: context,
    builder: (context) {
      List<DateTime> selectedDates = [];
      int selectedCount = 0;
      final existingDates = _dateTimeRanges.keys.toList();
      
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Select Dates'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 300,
                    child: SfDateRangePicker(
                      selectionMode: DateRangePickerSelectionMode.multiple,
                      initialSelectedDates: existingDates,
                      minDate: DateTime(1900),
                      maxDate: DateTime(2100),
                      monthViewSettings: const DateRangePickerMonthViewSettings(
                        showTrailingAndLeadingDates: true,
                        firstDayOfWeek: 6,
                        // Removed cellPadding as it's not a valid parameter
                      ),
                      selectionColor: AppColors.primaryColor,
                      selectionShape: DateRangePickerSelectionShape.circle,
                      selectionTextStyle: const TextStyle(
                        color: Colors.white,
                        height: 1.0, // Changed from 1.2 to fix vertical alignment
                        fontSize: 14, // Added for better text sizing
                      ),
                      todayHighlightColor: AppColors.primaryColor,
                      onSelectionChanged: (args) {
                        if (args.value is List<DateTime>) {
                          selectedDates = (args.value as List<DateTime>)
                              .where((date) => !existingDates.any((d) => DateUtils.isSameDay(d, date)))
                              .toList();
                          selectedCount = selectedDates.length;
                          setState(() {});
                        }
                      },
                      // Updated cellBuilder with correct property
                      cellBuilder: (BuildContext context, DateRangePickerCellDetails details) {
                        final isSelected = existingDates.any((d) => DateUtils.isSameDay(d, details.date)) || 
                                         selectedDates.any((d) => DateUtils.isSameDay(d, details.date));
                        final isToday = DateUtils.isSameDay(details.date, DateTime.now());
                        final isCurrentMonth = details.date.month == DateTime.now().month;
                        
                        return Container(
                          alignment: Alignment.center,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (isSelected)
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              if (isToday && !isSelected)
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.primaryColor,
                                      width: 1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              Text(
                                details.date.day.toString(),
                                style: TextStyle(
                                  color: isSelected ? Colors.white : 
                                        isToday ? AppColors.primaryColor : 
                                        !isCurrentMonth ? Colors.grey : Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Tip',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'You can pick more than one date.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                ),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, selectedDates);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text('Add ${selectedCount > 0 ? selectedCount : ''} Date${selectedCount != 1 ? 's' : ''}'), 
              ),
            ],
          );
        },
      );
    },
  );

  if (picked != null && picked.isNotEmpty) {
    setState(() {
      for (final date in picked) {
        if (!_dateTimeRanges.containsKey(date)) {
          _dateTimeRanges[date] = [
            TimeRange(
              TimeOfDay(hour: 9, minute: 0),
              TimeOfDay(hour: 17, minute: 0),
            )
          ];
        }
      }
    });
  }
}
  void _removeAllDates() {
    setState(() {
      _dateTimeRanges.clear();
    });
  }

  void _removeDate(DateTime date) {
    setState(() {
      _dateTimeRanges.remove(date);
    });
  }

  void _showCopyOptions(DateTime date) {
    setState(() {
      _copySourceDate = date;
      _copyTargetDates = _dateTimeRanges.keys
          .where((d) => !DateUtils.isSameDay(d, date))
          .toList();
    });

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Copy Time Slots'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Copy to',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Theme(
                      data: Theme.of(context).copyWith(
                        unselectedWidgetColor: AppColors.primaryColor,
                      ),
                      child: CheckboxListTile(
                        title: const Text('All Dates'),
                        value: _copyTargetDates.length == _dateTimeRanges.length - 1,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _copyTargetDates = _dateTimeRanges.keys
                                  .where((d) => !DateUtils.isSameDay(d, date))
                                  .toList();
                            } else {
                              _copyTargetDates = [];
                            }
                          });
                        },
                        activeColor: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Or select specific dates:',
                      style: TextStyle(fontSize: 12),
                    ),
                    const Divider(),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: _dateTimeRanges.length,
                        itemBuilder: (context, index) {
                          final targetDate = _dateTimeRanges.keys.elementAt(index);
                          if (DateUtils.isSameDay(targetDate, date)) return const SizedBox();
                          
                          return Theme(
                            data: Theme.of(context).copyWith(
                              unselectedWidgetColor: AppColors.primaryColor,
                            ),
                            child: CheckboxListTile(
                              title: Text(DateFormat('EEE, MMM d, y').format(targetDate)),
                              value: _copyTargetDates.any((d) => DateUtils.isSameDay(d, targetDate)),
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _copyTargetDates.add(targetDate);
                                  } else {
                                    _copyTargetDates.removeWhere((d) => DateUtils.isSameDay(d, targetDate));
                                  }
                                });
                              },
                              activeColor: AppColors.primaryColor,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                  ),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_copySourceDate != null && _dateTimeRanges.containsKey(_copySourceDate)) {
                      setState(() {
                        for (final targetDate in _copyTargetDates) {
                          _dateTimeRanges[targetDate] = _dateTimeRanges[_copySourceDate]!
                              .map((tr) => TimeRange(tr.start, tr.end))
                              .toList();
                        }
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedDates = _dateTimeRanges.keys.toList()..sort();
    
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Edit Date-Specific Hours',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Add Dates button and Remove All
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _selectDates(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.textColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                              side: BorderSide(
                                color: AppColors.mediumColor,
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          icon: Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: AppColors.primaryColor,
                          ),
                          label: const Text('Add Dates'),
                        ),
                        if (sortedDates.isNotEmpty)
                          TextButton.icon(
                            onPressed: _removeAllDates,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            icon: Icon(
                              Icons.delete_outline, 
                              size: 16,
                              color: Colors.red,
                            ),
                            label: const Text('Remove All Dates'),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Empty state or date list
                    if (sortedDates.isEmpty)
                      DottedBorder(
                        color: Colors.grey.shade400,
                        strokeWidth: 1,
                        dashPattern: const [5, 5],
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(4),
                        padding: const EdgeInsets.all(24),
                        child: Container(
                          child: Column(
                            children: [
                              Text(
                                "There's nothing here yet.",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add some dates to start configuring your available hours.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColorSecond,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: sortedDates.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: Colors.grey.shade300,
                          ),
                          itemBuilder: (context, index) {
                            final date = sortedDates[index];
                            final timeRanges = _dateTimeRanges[date]!;
                            return _DateHoursItem(
                              date: date,
                              timeRanges: timeRanges,
                              onAddTime: () => _addTimeRange(date),
                              onRemoveTime: (index) => _removeTimeRange(date, index),
                              onRemoveDate: () => _removeDate(date),
                              onCopyDate: () => _showCopyOptions(date),
                              hasOverlap: (range) => _hasTimeOverlap(timeRanges, range),
                              isStartAfterEnd: _isStartAfterEnd,
                              isStartSameAsEnd: _isStartSameAsEnd,
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text('Save Changes'),
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

class _DateHoursItem extends StatelessWidget {
  final DateTime date;
  final List<TimeRange> timeRanges;
  final VoidCallback onAddTime;
  final Function(int) onRemoveTime;
  final VoidCallback onRemoveDate;
  final VoidCallback onCopyDate;
  final Function(TimeRange) hasOverlap;
  final Function(TimeRange) isStartAfterEnd;
  final Function(TimeRange) isStartSameAsEnd;

  const _DateHoursItem({
    required this.date,
    required this.timeRanges,
    required this.onAddTime,
    required this.onRemoveTime,
    required this.onRemoveDate,
    required this.onCopyDate,
    required this.hasOverlap,
    required this.isStartAfterEnd,
    required this.isStartSameAsEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Date header with actions
          Row(
            children: [
              Container(
                width: 80,
                padding: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('EEE').format(date).toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColorSecond,
                      ),
                    ),
                    Text(
                      DateFormat('MM/dd').format(date),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  DateFormat('EEE, MMM d, y').format(date),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: AppColors.textColorSecond,
                ),
                onSelected: (value) {
                  if (value == 'copy') {
                    onCopyDate();
                  } else if (value == 'delete') {
                    onRemoveDate();
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'copy',
                    child: Row(
                      children: [
                        Icon(Icons.copy, color: AppColors.primaryColor),
                        const SizedBox(width: 8),
                        const Text('Copy'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        const SizedBox(width: 8),
                        const Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Time ranges
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: timeRanges.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final range = timeRanges[index];
              final hasOverlapping = hasOverlap(range);
              final isStartAfter = isStartAfterEnd(range);
              final isStartSame = isStartSameAsEnd(range);
              final isInvalid = hasOverlapping || isStartAfter || isStartSame;
              
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: isInvalid ? Colors.red : Colors.grey.shade300,
                    width: isInvalid ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectTime(context, true, range),
                            child: _TimeBox(
                              time: range.start,
                              isInvalid: isInvalid,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '-',
                            style: TextStyle(color: AppColors.textColorSecond),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectTime(context, false, range),
                            child: _TimeBox(
                              time: range.end,
                              isInvalid: isInvalid,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: isInvalid ? Colors.red : AppColors.textColor,
                          ),
                          onPressed: () => onRemoveTime(index),
                        ),
                      ],
                    ),
                    if (isInvalid)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          isStartAfter 
                              ? "Start can't be after end" 
                              : isStartSame
                                ? "Start time can't be same as end time"
                                : "Time ranges can't overlap",
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),

          // Add Time button
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onAddTime,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
              icon: Icon(
                Icons.add, 
                size: 16,
                color: AppColors.primaryColor,
              ),
              label: const Text('Add Time'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStart, TimeRange range) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? range.start : range.end,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null && context.mounted) {
      (context as Element).markNeedsBuild();
      
      if (isStart) {
        range.start = picked;
      } else {
        range.end = picked;
      }
    }
  }
}

class _TimeBox extends StatelessWidget {
  final TimeOfDay time;
  final bool isInvalid;

  const _TimeBox({
    required this.time,
    required this.isInvalid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          color: isInvalid ? Colors.red : Colors.grey,
          width: isInvalid ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(5),
        color: isInvalid ? Colors.red.withOpacity(0.1) : null,
      ),
      child: Center(
        child: Text(
          time.format(context),
          style: TextStyle(
            color: isInvalid ? Colors.red : AppColors.textColor,
          ),
        ),
      ),
    );
  }
}
// // lib/content/availability/widgets/add_hours_modal.dart
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'package:intl/intl.dart';
// import 'package:tabourak/models/time_range.dart';
// import 'package:dotted_border/dotted_border.dart';
// import 'package:syncfusion_flutter_datepicker/datepicker.dart';

// class AddHoursModal extends StatefulWidget {
//   const AddHoursModal({Key? key}) : super(key: key);

//   @override
//   State<AddHoursModal> createState() => _AddHoursModalState();
// }

// class _AddHoursModalState extends State<AddHoursModal> {
//   final Map<DateTime, List<TimeRange>> _dateTimeRanges = {};
//   DateTime? _copySourceDate;
//   List<DateTime> _copyTargetDates = [];

//   void _addTimeRange(DateTime date) {
//     setState(() {
//       _dateTimeRanges[date] ??= [];
//       final lastSlot = _dateTimeRanges[date]!.isEmpty 
//           ? null 
//           : _dateTimeRanges[date]!.last;
      
//       final newStart = lastSlot?.end ?? TimeOfDay(hour: 9, minute: 0);
//       final newEnd = TimeOfDay(
//         hour: (newStart.hour + 1) % 24,
//         minute: newStart.minute,
//       );

//       _dateTimeRanges[date]!.add(TimeRange(newStart, newEnd));
//     });
//   }

//   void _removeTimeRange(DateTime date, int index) {
//     setState(() {
//       _dateTimeRanges[date]?.removeAt(index);
//       if (_dateTimeRanges[date]?.isEmpty ?? true) {
//         _dateTimeRanges.remove(date);
//       }
//     });
//   }

//   bool _hasTimeOverlap(List<TimeRange> ranges, TimeRange newRange) {
//     for (final existingRange in ranges) {
//       if (existingRange == newRange) continue;
      
//       final existingStart = existingRange.start;
//       final existingEnd = existingRange.end;
//       final newStart = newRange.start;
//       final newEnd = newRange.end;

//       if (_isStartSameAsEnd(existingRange) || _isStartSameAsEnd(newRange)) {
//         continue;
//       }

//       if ((newStart.hour < existingEnd.hour || 
//           (newStart.hour == existingEnd.hour && newStart.minute < existingEnd.minute)) &&
//           (newEnd.hour > existingStart.hour || 
//           (newEnd.hour == existingStart.hour && newEnd.minute > existingStart.minute))) {
//         return true;
//       }
//     }
//     return false;
//   }

//   bool _isStartAfterEnd(TimeRange range) {
//     return range.end.hour < range.start.hour || 
//           (range.end.hour == range.start.hour && range.end.minute < range.start.minute);
//   }

//   bool _isStartSameAsEnd(TimeRange range) {
//     return range.start.hour == range.end.hour && 
//            range.start.minute == range.end.minute;
//   }


// Future<void> _selectDates(BuildContext context) async {
//   final List<DateTime>? picked = await showDialog<List<DateTime>>(
//     context: context,
//     builder: (context) {
//       List<DateTime> selectedDates = [];
//       int selectedCount = 0;
//       final existingDates = _dateTimeRanges.keys.toList();
      
//       return StatefulBuilder(
//         builder: (context, setState) {
//           return AlertDialog(
//             title: const Text('Select Dates'),
//             content: SizedBox(
//               width: double.maxFinite,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   SizedBox(
//                     height: 300,
//                     child: SfDateRangePicker(
//                       selectionMode: DateRangePickerSelectionMode.multiple,
//                       initialSelectedDates: existingDates,
//                       minDate: DateTime(1900),
//                       maxDate: DateTime(2100),
//                       monthViewSettings: const DateRangePickerMonthViewSettings(
//                         showTrailingAndLeadingDates: true,
//                         firstDayOfWeek: 6,
//                       ),
//                       selectionColor: AppColors.primaryColor,
//                       selectionShape: DateRangePickerSelectionShape.circle,
//                       selectionTextStyle: const TextStyle(color: Colors.white),
//                       todayHighlightColor: AppColors.primaryColor,
//                       onSelectionChanged: (args) {
//                         if (args.value is List<DateTime>) {
//                           // Filter out already selected dates
//                           selectedDates = (args.value as List<DateTime>)
//                               .where((date) => !existingDates.any((d) => DateUtils.isSameDay(d, date)))
//                               .toList();
//                           selectedCount = selectedDates.length;
//                           setState(() {});
//                         }
//                       },
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[100],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.purple,
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: const Text(
//                             'Tip',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         const Text(
//                           'You can pick more than one date.',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 style: TextButton.styleFrom(
//                   foregroundColor: AppColors.primaryColor,
//                 ),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context, selectedDates);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primaryColor,
//                   foregroundColor: Colors.white,
//                 ),
//                 child: Text('Add ${selectedCount > 0 ? selectedCount : ''} Date${selectedCount != 1 ? 's' : ''}'), 
//               ),
//             ],
//           );
//         },
//       );
//     },
//   );

//   if (picked != null && picked.isNotEmpty) {
//     setState(() {
//       for (final date in picked) {
//         if (!_dateTimeRanges.containsKey(date)) {
//           _dateTimeRanges[date] = [
//             TimeRange(
//               TimeOfDay(hour: 9, minute: 0),
//               TimeOfDay(hour: 17, minute: 0),
//             )
//           ];
//         }
//       }
//     });
//   }
// }
//   void _removeAllDates() {
//     setState(() {
//       _dateTimeRanges.clear();
//     });
//   }

//   void _removeDate(DateTime date) {
//     setState(() {
//       _dateTimeRanges.remove(date);
//     });
//   }

//   void _showCopyOptions(DateTime date) {
//     setState(() {
//       _copySourceDate = date;
//       _copyTargetDates = _dateTimeRanges.keys
//           .where((d) => !DateUtils.isSameDay(d, date))
//           .toList();
//     });

//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: const Text('Copy Time Slots'),
//               content: SizedBox(
//                 width: double.maxFinite,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Copy to',
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     CheckboxListTile(
//                       title: const Text('All Dates'),
//                       value: _copyTargetDates.length == _dateTimeRanges.length - 1,
//                       onChanged: (value) {
//                         setState(() {
//                           if (value == true) {
//                             _copyTargetDates = _dateTimeRanges.keys
//                                 .where((d) => !DateUtils.isSameDay(d, date))
//                                 .toList();
//                           } else {
//                             _copyTargetDates = [];
//                           }
//                         });
//                       },
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       'Or select specific dates:',
//                       style: TextStyle(fontSize: 12),
//                     ),
//                     const Divider(),
//                     SizedBox(
//                       height: 200,
//                       child: ListView.builder(
//                         itemCount: _dateTimeRanges.length,
//                         itemBuilder: (context, index) {
//                           final targetDate = _dateTimeRanges.keys.elementAt(index);
//                           if (DateUtils.isSameDay(targetDate, date)) return const SizedBox();
                          
//                           return CheckboxListTile(
//                             title: Text(DateFormat('EEE, MMM d, y').format(targetDate)),
//                             value: _copyTargetDates.any((d) => DateUtils.isSameDay(d, targetDate)),
//                             onChanged: (value) {
//                               setState(() {
//                                 if (value == true) {
//                                   _copyTargetDates.add(targetDate);
//                                 } else {
//                                   _copyTargetDates.removeWhere((d) => DateUtils.isSameDay(d, targetDate));
//                                 }
//                               });
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Cancel'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (_copySourceDate != null && _dateTimeRanges.containsKey(_copySourceDate)) {
//                       setState(() {
//                         for (final targetDate in _copyTargetDates) {
//                           _dateTimeRanges[targetDate] = _dateTimeRanges[_copySourceDate]!
//                               .map((tr) => TimeRange(tr.start, tr.end))
//                               .toList();
//                         }
//                       });
//                       Navigator.pop(context);
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primaryColor,
//                   ),
//                   child: const Text('Apply'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final sortedDates = _dateTimeRanges.keys.toList()..sort();
    
//     return Dialog(
//       insetPadding: const EdgeInsets.all(16),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: ConstrainedBox(
//         constraints: const BoxConstraints(maxWidth: 600),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 border: Border(
//                   bottom: BorderSide(
//                     color: Colors.grey.shade300,
//                     width: 1,
//                   ),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.edit_outlined,
//                     color: AppColors.primaryColor,
//                     size: 24,
//                   ),
//                   const SizedBox(width: 8),
//                   const Text(
//                     'Edit Date-Specific Hours',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => Navigator.of(context).pop(),
//                   ),
//                 ],
//               ),
//             ),

//             // Body
//             Flexible(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     // Add Dates button and Remove All
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         ElevatedButton.icon(
//                           onPressed: () => _selectDates(context),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.white,
//                             foregroundColor: AppColors.textColor,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(4),
//                               side: BorderSide(
//                                 color: AppColors.mediumColor,
//                                 width: 1,
//                               ),
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 8,
//                             ),
//                           ),
//                           icon: Icon(
//                             Icons.calendar_today,
//                             size: 16,
//                             color: AppColors.primaryColor,
//                           ),
//                           label: const Text('Add Dates'),
//                         ),
//                         if (sortedDates.isNotEmpty)
//                           TextButton.icon(
//                             onPressed: _removeAllDates,
//                             style: TextButton.styleFrom(
//                               foregroundColor: Colors.red,
//                             ),
//                             icon: const Icon(Icons.delete_outline, size: 16),
//                             label: const Text('Remove All Dates'),
//                           ),
//                       ],
//                     ),

//                     const SizedBox(height: 16),

//                     // Empty state or date list
//                     if (sortedDates.isEmpty)
//                       DottedBorder(
//                         color: Colors.grey.shade400,
//                         strokeWidth: 1,
//                         dashPattern: const [5, 5],
//                         borderType: BorderType.RRect,
//                         radius: const Radius.circular(4),
//                         padding: const EdgeInsets.all(24),
//                         child: Container(
//                           child: Column(
//                             children: [
//                               Text(
//                                 "There's nothing here yet.",
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: AppColors.textColor,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 'Add some dates to start configuring your available hours.',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: AppColors.textColorSecond,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ],
//                           ),
//                         ),
//                       )
//                     else
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(4),
//                           border: Border.all(
//                             color: Colors.grey.shade300,
//                           ),
//                         ),
//                         child: ListView.separated(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: sortedDates.length,
//                           separatorBuilder: (context, index) => Divider(
//                             height: 1,
//                             color: Colors.grey.shade300,
//                           ),
//                           itemBuilder: (context, index) {
//                             final date = sortedDates[index];
//                             final timeRanges = _dateTimeRanges[date]!;
//                             return _DateHoursItem(
//                               date: date,
//                               timeRanges: timeRanges,
//                               onAddTime: () => _addTimeRange(date),
//                               onRemoveTime: (index) => _removeTimeRange(date, index),
//                               onRemoveDate: () => _removeDate(date),
//                               onCopyDate: () => _showCopyOptions(date),
//                               hasOverlap: (range) => _hasTimeOverlap(timeRanges, range),
//                               isStartAfterEnd: _isStartAfterEnd,
//                               isStartSameAsEnd: _isStartSameAsEnd,
//                             );
//                           },
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),

//             // Footer
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 border: Border(
//                   top: BorderSide(
//                     color: Colors.grey.shade300,
//                     width: 1,
//                   ),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   const Spacer(),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primaryColor,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 12,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                     ),
//                     child: const Text('Save Changes'),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _DateHoursItem extends StatelessWidget {
//   final DateTime date;
//   final List<TimeRange> timeRanges;
//   final VoidCallback onAddTime;
//   final Function(int) onRemoveTime;
//   final VoidCallback onRemoveDate;
//   final VoidCallback onCopyDate;
//   final Function(TimeRange) hasOverlap;
//   final Function(TimeRange) isStartAfterEnd;
//   final Function(TimeRange) isStartSameAsEnd;

//   const _DateHoursItem({
//     required this.date,
//     required this.timeRanges,
//     required this.onAddTime,
//     required this.onRemoveTime,
//     required this.onRemoveDate,
//     required this.onCopyDate,
//     required this.hasOverlap,
//     required this.isStartAfterEnd,
//     required this.isStartSameAsEnd,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Date header with actions
//           Row(
//             children: [
//               Container(
//                 width: 80,
//                 padding: const EdgeInsets.only(right: 16),
//                 decoration: BoxDecoration(
//                   border: Border(
//                     right: BorderSide(
//                       color: Colors.grey.shade300,
//                       width: 1,
//                     ),
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     Text(
//                       DateFormat('EEE').format(date).toUpperCase(),
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.textColorSecond,
//                       ),
//                     ),
//                     Text(
//                       DateFormat('MM/dd').format(date),
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Text(
//                   DateFormat('EEE, MMM d, y').format(date),
//                   style: const TextStyle(fontSize: 16),
//                 ),
//               ),
//               PopupMenuButton<String>(
//                 icon: Icon(
//                   Icons.more_vert,
//                   color: AppColors.textColorSecond,
//                 ),
//                 onSelected: (value) {
//                   if (value == 'copy') {
//                     onCopyDate();
//                   } else if (value == 'delete') {
//                     onRemoveDate();
//                   }
//                 },
//                 itemBuilder: (BuildContext context) => [
//                   PopupMenuItem<String>(
//                     value: 'copy',
//                     child: Row(
//                       children: [
//                         Icon(Icons.copy, color: AppColors.primaryColor),
//                         const SizedBox(width: 8),
//                         const Text('Copy'),
//                       ],
//                     ),
//                   ),
//                   PopupMenuItem<String>(
//                     value: 'delete',
//                     child: Row(
//                       children: [
//                         Icon(Icons.delete, color: Colors.red),
//                         const SizedBox(width: 8),
//                         const Text('Delete'),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),

//           // Time ranges
//           ListView.separated(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: timeRanges.length,
//             separatorBuilder: (context, index) => const SizedBox(height: 16),
//             itemBuilder: (context, index) {
//               final range = timeRanges[index];
//               final hasOverlapping = hasOverlap(range);
//               final isStartAfter = isStartAfterEnd(range);
//               final isStartSame = isStartSameAsEnd(range);
//               final isInvalid = hasOverlapping || isStartAfter || isStartSame;
              
//               return Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   border: Border.all(
//                     color: isInvalid ? Colors.red : Colors.grey.shade300,
//                     width: isInvalid ? 2 : 1,
//                   ),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 padding: const EdgeInsets.all(10),
//                 child: Column(
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () => _selectTime(context, true, range),
//                             child: _TimeBox(
//                               time: range.start,
//                               isInvalid: isInvalid,
//                             ),
//                           ),
//                         ),
//                         const Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 8),
//                           child: Text(
//                             '-',
//                             style: TextStyle(color: AppColors.textColorSecond),
//                           ),
//                         ),
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () => _selectTime(context, false, range),
//                             child: _TimeBox(
//                               time: range.end,
//                               isInvalid: isInvalid,
//                             ),
//                           ),
//                         ),
//                         IconButton(
//                           icon: Icon(
//                             Icons.close,
//                             color: isInvalid ? Colors.red : AppColors.textColor,
//                           ),
//                           onPressed: () => onRemoveTime(index),
//                         ),
//                       ],
//                     ),
//                     if (isInvalid)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8.0),
//                         child: Text(
//                           isStartAfter 
//                               ? "Start can't be after end" 
//                               : isStartSame
//                                 ? "Start time can't be same as end time"
//                                 : "Time ranges can't overlap",
//                           style: const TextStyle(
//                             color: Colors.red,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 8),

//           // Add Time button
//           Align(
//             alignment: Alignment.centerLeft,
//             child: TextButton.icon(
//               onPressed: onAddTime,
//               style: TextButton.styleFrom(
//                 foregroundColor: AppColors.primaryColor,
//               ),
//               icon: const Icon(Icons.add, size: 16),
//               label: const Text('Add Time'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _selectTime(BuildContext context, bool isStart, TimeRange range) async {
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: isStart ? range.start : range.end,
//       builder: (context, child) {
//         return MediaQuery(
//           data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null && context.mounted) {
//       (context as Element).markNeedsBuild();
      
//       if (isStart) {
//         range.start = picked;
//       } else {
//         range.end = picked;
//       }
//     }
//   }
// }

// class _TimeBox extends StatelessWidget {
//   final TimeOfDay time;
//   final bool isInvalid;

//   const _TimeBox({
//     required this.time,
//     required this.isInvalid,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         border: Border.all(
//           color: isInvalid ? Colors.red : Colors.grey,
//           width: isInvalid ? 2 : 1,
//         ),
//         borderRadius: BorderRadius.circular(5),
//         color: isInvalid ? Colors.red.withOpacity(0.1) : null,
//       ),
//       child: Center(
//         child: Text(
//           time.format(context),
//           style: TextStyle(
//             color: isInvalid ? Colors.red : AppColors.textColor,
//           ),
//         ),
//       ),
//     );
//   }
// }



// // lib/content/availability/widgets/add_hours_modal.dart
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'package:intl/intl.dart';
// import 'package:tabourak/models/time_range.dart';
// import 'package:dotted_border/dotted_border.dart';
// import 'package:syncfusion_flutter_datepicker/datepicker.dart';

// class AddHoursModal extends StatefulWidget {
//   const AddHoursModal({Key? key}) : super(key: key);

//   @override
//   State<AddHoursModal> createState() => _AddHoursModalState();
// }

// class _AddHoursModalState extends State<AddHoursModal> {
//   final List<DateTime> _selectedDates = [];
//   final List<TimeRange> _timeRanges = [
//     TimeRange(
//       TimeOfDay(hour: 9, minute: 0),
//       TimeOfDay(hour: 17, minute: 0),
//     )
//   ];
//   DateTime? _copySourceDate;
//   List<DateTime> _copyTargetDates = [];

//   void _addTimeRange() {
//     setState(() {
//       _timeRanges.add(
//         TimeRange(
//           TimeOfDay(hour: 9, minute: 0),
//           TimeOfDay(hour: 17, minute: 0),
//         ),
//       );
//     });
//   }

//   void _removeTimeRange(int index) {
//     setState(() {
//       _timeRanges.removeAt(index);
//     });
//   }

// Future<void> _selectDates(BuildContext context) async {
//   final List<DateTime>? picked = await showDialog<List<DateTime>>(
//     context: context,
//     builder: (context) {
//       List<DateTime> selectedDates = List.from(_selectedDates);
      
//       return AlertDialog(
//         title: const Text('Select Dates'),
//         content: SizedBox(
//           width: double.maxFinite,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               SizedBox(
//                 height: 300,
//                 child: SfDateRangePicker(
//                   selectionMode: DateRangePickerSelectionMode.multiple,
//                   initialSelectedDates: _selectedDates,
//                   minDate: DateTime(1900),
//                   maxDate: DateTime(2100),
//                   monthViewSettings: const DateRangePickerMonthViewSettings(
//                     showTrailingAndLeadingDates: true,
//                   ),
//                   onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
//                     if (args.value is List<DateTime>) {
//                       selectedDates = args.value;
//                     }
//                   },
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.purple,
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: const Text(
//                         'Tip',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     const Text(
//                       'You can pick more than one date.',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context, selectedDates);
//             },
//             child: const Text('Add Dates'),
//           ),
//         ],
//       );
//     },
//   );

//   if (picked != null && picked.isNotEmpty) {
//     setState(() {
//       _selectedDates.addAll(picked);
//       // Remove duplicates
//       _selectedDates.sort();
//       _selectedDates.retainWhere((date) => !_selectedDates.any((d) => 
//         d != date && DateUtils.isSameDay(d, date)));
//     });
//   }
// }

//   void _removeAllDates() {
//     setState(() {
//       _selectedDates.clear();
//     });
//   }

//   void _removeDate(DateTime date) {
//     setState(() {
//       _selectedDates.removeWhere((d) => DateUtils.isSameDay(d, date));
//     });
//   }

//   void _showCopyOptions(DateTime date) {
//     setState(() {
//       _copySourceDate = date;
//       _copyTargetDates = _selectedDates.where((d) => !DateUtils.isSameDay(d, date)).toList();
//     });

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Copy Time Slots'),
//         content: SizedBox(
//           width: double.maxFinite,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Copy to',
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               CheckboxListTile(
//                 title: const Text('All Dates'),
//                 value: _copyTargetDates.length == _selectedDates.length - 1,
//                 onChanged: (value) {
//                   setState(() {
//                     if (value == true) {
//                       _copyTargetDates = _selectedDates.where((d) => !DateUtils.isSameDay(d, date)).toList();
//                     } else {
//                       _copyTargetDates = [];
//                     }
//                   });
//                 },
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'Or select specific dates:',
//                 style: TextStyle(fontSize: 12),
//               ),
//               const Divider(),
//               SizedBox(
//                 height: 200,
//                 child: ListView.builder(
//                   itemCount: _selectedDates.length,
//                   itemBuilder: (context, index) {
//                     final targetDate = _selectedDates[index];
//                     if (DateUtils.isSameDay(targetDate, date)) return const SizedBox();
                    
//                     return CheckboxListTile(
//                       title: Text(DateFormat('EEE, MMM d, y').format(targetDate)),
//                       value: _copyTargetDates.any((d) => DateUtils.isSameDay(d, targetDate)),
//                       onChanged: (value) {
//                         setState(() {
//                           if (value == true) {
//                             _copyTargetDates.add(targetDate);
//                           } else {
//                             _copyTargetDates.removeWhere((d) => DateUtils.isSameDay(d, targetDate));
//                           }
//                         });
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               // Here you would implement the actual copy logic
//               // For now, we'll just close the dialog
//               Navigator.pop(context);
//             },
//             child: const Text('Apply'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       insetPadding: const EdgeInsets.all(16),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: ConstrainedBox(
//         constraints: const BoxConstraints(maxWidth: 600),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 border: Border(
//                   bottom: BorderSide(
//                     color: Colors.grey.shade300,
//                     width: 1,
//                   ),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.edit_outlined,
//                     color: AppColors.primaryColor,
//                     size: 24,
//                   ),
//                   const SizedBox(width: 8),
//                   const Text(
//                     'Edit Date-Specific Hours',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => Navigator.of(context).pop(),
//                   ),
//                 ],
//               ),
//             ),

//             // Body
//             Flexible(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     // Add Dates button and Remove All
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         ElevatedButton.icon(
//                           onPressed: () => _selectDates(context),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.white,
//                             foregroundColor: AppColors.textColor,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(4),
//                               side: BorderSide(
//                                 color: AppColors.mediumColor,
//                                 width: 1,
//                               ),
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 8,
//                             ),
//                           ),
//                           icon: Icon(
//                             Icons.calendar_today,
//                             size: 16,
//                             color: AppColors.primaryColor,
//                           ),
//                           label: const Text('Add Dates'),
//                         ),
//                         if (_selectedDates.isNotEmpty)
//                           TextButton.icon(
//                             onPressed: _removeAllDates,
//                             style: TextButton.styleFrom(
//                               foregroundColor: Colors.red,
//                             ),
//                             icon: const Icon(Icons.delete_outline, size: 16),
//                             label: const Text('Remove All Dates'),
//                           ),
//                       ],
//                     ),

//                     const SizedBox(height: 16),

//                     // Empty state or date list
//                     if (_selectedDates.isEmpty)
//                       DottedBorder(
//                         color: Colors.grey.shade300,
//                         strokeWidth: 1,
//                         dashPattern: const [5, 5],
//                         borderType: BorderType.RRect,
//                         radius: const Radius.circular(4),
//                         padding: const EdgeInsets.all(24),
//                         child: Container(
//                           color: AppColors.lightcolor,
//                           child: Column(
//                             children: [
//                               Text(
//                                 "There's nothing here yet.",
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: AppColors.textColor,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 'Add some dates to start configuring your available hours.',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: AppColors.textColorSecond,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ],
//                           ),
//                         ),
//                       )
//                     else
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(4),
//                           border: Border.all(
//                             color: Colors.grey.shade300,
//                           ),
//                         ),
//                         child: ListView.separated(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: _selectedDates.length,
//                           separatorBuilder: (context, index) => Divider(
//                             height: 1,
//                             color: Colors.grey.shade300,
//                           ),
//                           itemBuilder: (context, index) {
//                             final date = _selectedDates[index];
//                             return _DateHoursItem(
//                               date: date,
//                               timeRanges: _timeRanges,
//                               onAddTime: _addTimeRange,
//                               onRemoveTime: _removeTimeRange,
//                               onRemoveDate: () => _removeDate(date),
//                               onCopyDate: () => _showCopyOptions(date),
//                             );
//                           },
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),

//             // Footer
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 border: Border(
//                   top: BorderSide(
//                     color: Colors.grey.shade300,
//                     width: 1,
//                   ),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   const Spacer(),
//                   ElevatedButton(
//                     onPressed: () {
//                       // Save logic here
//                       Navigator.of(context).pop();
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primaryColor,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 12,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                     ),
//                     child: const Text('Save Changes'),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _DateHoursItem extends StatelessWidget {
//   final DateTime date;
//   final List<TimeRange> timeRanges;
//   final VoidCallback onAddTime;
//   final Function(int) onRemoveTime;
//   final VoidCallback onRemoveDate;
//   final VoidCallback onCopyDate;

//   const _DateHoursItem({
//     required this.date,
//     required this.timeRanges,
//     required this.onAddTime,
//     required this.onRemoveTime,
//     required this.onRemoveDate,
//     required this.onCopyDate,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Date header with actions
//           Row(
//             children: [
//               // Desktop view - abbreviated day and date
//               Container(
//                 width: 80,
//                 padding: const EdgeInsets.only(right: 16),
//                 decoration: BoxDecoration(
//                   border: Border(
//                     right: BorderSide(
//                       color: Colors.grey.shade300,
//                       width: 1,
//                     ),
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     Text(
//                       DateFormat('EEE').format(date).toUpperCase(),
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.textColorSecond,
//                       ),
//                     ),
//                     Text(
//                       DateFormat('MM/dd').format(date),
//                       style: const TextStyle(
//                         fontSize: 16,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 16),
//               // Mobile view - full date
//               Expanded(
//                 child: Text(
//                   DateFormat('EEE, MMM d, y').format(date),
//                   style: const TextStyle(
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//               IconButton(
//                 icon: Icon(
//                   Icons.copy,
//                   color: AppColors.primaryColor,
//                   size: 20,
//                 ),
//                 onPressed: onCopyDate,
//                 tooltip: 'Copy time slots to other dates',
//               ),
//               IconButton(
//                 icon: Icon(
//                   Icons.delete_outline,
//                   color: Colors.red,
//                   size: 20,
//                 ),
//                 onPressed: onRemoveDate,
//                 tooltip: 'Remove date',
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),

//           // Time ranges
//           ListView.separated(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: timeRanges.length,
//             separatorBuilder: (context, index) => const SizedBox(height: 16),
//             itemBuilder: (context, index) {
//               final range = timeRanges[index];
//               return Row(
//                 children: [
//                   Expanded(
//                     child: _TimeRangeInput(
//                       startTime: range.start,
//                       endTime: range.end,
//                       onStartChanged: (TimeOfDay newTime) {
//                         // Handle start time change
//                       },
//                       onEndChanged: (TimeOfDay newTime) {
//                         // Handle end time change
//                       },
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(
//                       Icons.close,
//                       color: AppColors.textColorSecond,
//                     ),
//                     onPressed: () => onRemoveTime(index),
//                   ),
//                 ],
//               );
//             },
//           ),
//           const SizedBox(height: 8),

//           // Add Time button
//           Align(
//             alignment: Alignment.centerLeft,
//             child: TextButton.icon(
//               onPressed: onAddTime,
//               style: TextButton.styleFrom(
//                 foregroundColor: AppColors.primaryColor,
//               ),
//               icon: const Icon(Icons.add, size: 16),
//               label: const Text('Add Time'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _TimeRangeInput extends StatelessWidget {
//   final TimeOfDay startTime;
//   final TimeOfDay endTime;
//   final ValueChanged<TimeOfDay> onStartChanged;
//   final ValueChanged<TimeOfDay> onEndChanged;

//   const _TimeRangeInput({
//     required this.startTime,
//     required this.endTime,
//     required this.onStartChanged,
//     required this.onEndChanged,
//   });

//   Future<void> _selectTime(
//     BuildContext context, 
//     TimeOfDay initialTime,
//     ValueChanged<TimeOfDay> onTimeSelected,
//   ) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: initialTime,
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: AppColors.primaryColor,
//               onPrimary: Colors.white,
//               surface: Colors.white,
//               onSurface: AppColors.textColor,
//             ),
//             dialogBackgroundColor: Colors.white,
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null) {
//       onTimeSelected(picked);
//     }
//   }

//   String _formatTime(TimeOfDay time) {
//     final now = DateTime.now();
//     final dt = DateTime(
//       now.year, now.month, now.day, time.hour, time.minute);
//     return DateFormat.jm().format(dt);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: InkWell(
//             onTap: () => _selectTime(context, startTime, onStartChanged),
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey.shade300),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Text(_formatTime(startTime)),
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8),
//           child: Text(
//             '-',
//             style: TextStyle(color: AppColors.textColorSecond),
//           ),
//         ),
//         Expanded(
//           child: InkWell(
//             onTap: () => _selectTime(context, endTime, onEndChanged),
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey.shade300),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Text(_formatTime(endTime)),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // lib/content/availability/widgets/add_hours_modal.dart
// import 'package:flutter/material.dart';
// import 'package:tabourak/colors/app_colors.dart';
// import 'package:intl/intl.dart';
// import 'package:tabourak/models/time_range.dart';
// import 'package:dotted_border/dotted_border.dart';

// class AddHoursModal extends StatefulWidget {
//   const AddHoursModal({Key? key}) : super(key: key);

//   @override
//   State<AddHoursModal> createState() => _AddHoursModalState();
// }

// class _AddHoursModalState extends State<AddHoursModal> {
//   final List<DateTime> _selectedDates = [];
//   final List<TimeRange> _timeRanges = [
//     TimeRange(
//       TimeOfDay(hour: 9, minute: 0),
//       TimeOfDay(hour: 17, minute: 0),
//     )
//   ];

//   void _addTimeRange() {
//     setState(() {
//       _timeRanges.add(
//         TimeRange(
//           TimeOfDay(hour: 9, minute: 0),
//           TimeOfDay(hour: 17, minute: 0),
//         ),
//       );
//     });
//   }

//   void _removeTimeRange(int index) {
//     setState(() {
//       _timeRanges.removeAt(index);
//     });
//   }

//   Future<void> _selectDates(BuildContext context) async {
//     final DateTimeRange? picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime.now(),
//       lastDate: DateTime(DateTime.now().year + 1),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: AppColors.primaryColor,
//               onPrimary: Colors.white,
//               surface: Colors.white,
//               onSurface: AppColors.textColor,
//             ),
//             dialogBackgroundColor: Colors.white,
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null) {
//       setState(() {
//         _selectedDates.clear();
//         DateTime current = picked.start;
//         while (current.isBefore(picked.end) || current == picked.end) {
//           _selectedDates.add(current);
//           current = current.add(const Duration(days: 1));
//         }
//       });
//     }
//   }

//   void _removeAllDates() {
//     setState(() {
//       _selectedDates.clear();
//     });
//   }

//   void _removeDate(DateTime date) {
//     setState(() {
//       _selectedDates.removeWhere((d) => DateUtils.isSameDay(d, date));
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       insetPadding: const EdgeInsets.all(16),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: ConstrainedBox(
//         constraints: const BoxConstraints(maxWidth: 600),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 border: Border(
//                   bottom: BorderSide(
//                     color: Colors.grey.shade300,
//                     width: 1,
//                   ),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.edit_outlined,
//                     color: AppColors.primaryColor,
//                     size: 24,
//                   ),
//                   const SizedBox(width: 8),
//                   const Text(
//                     'Edit Date-Specific Hours',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => Navigator.of(context).pop(),
//                   ),
//                 ],
//               ),
//             ),

//             // Body
//             Flexible(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     // Add Dates button and Remove All
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         ElevatedButton.icon(
//                           onPressed: () => _selectDates(context),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.white,
//                             foregroundColor: AppColors.textColor,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(4),
//                               side: BorderSide(
//                                 color: AppColors.mediumColor,
//                                 width: 1,
//                               ),
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 8,
//                             ),
//                           ),
//                           icon: Icon(
//                             Icons.calendar_today,
//                             size: 16,
//                             color: AppColors.primaryColor,
//                           ),
//                           label: const Text('Add Dates'),
//                         ),
//                         if (_selectedDates.isNotEmpty)
//                           TextButton.icon(
//                             onPressed: _removeAllDates,
//                             style: TextButton.styleFrom(
//                               foregroundColor: Colors.red,
//                             ),
//                             icon: const Icon(Icons.delete_outline, size: 16),
//                             label: const Text('Remove All Dates'),
//                           ),
//                       ],
//                     ),

//                     const SizedBox(height: 16),

//                     // Empty state or date list
//                     if (_selectedDates.isEmpty)
//                       DottedBorder(
//                         color: Colors.grey.shade300,
//                         strokeWidth: 1,
//                         dashPattern: const [5, 5],
//                         borderType: BorderType.RRect,
//                         radius: const Radius.circular(4),
//                         padding: const EdgeInsets.all(24),
//                         child: Container(
//                           color: AppColors.lightcolor,
//                           child: Column(
//                             children: [
//                               Text(
//                                 "There's nothing here yet.",
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: AppColors.textColor,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 'Add some dates to start configuring your available hours.',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: AppColors.textColorSecond,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ],
//                           ),
//                         ),
//                       )
//                     else
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(4),
//                           border: Border.all(
//                             color: Colors.grey.shade300,
//                           ),
//                         ),
//                         child: ListView.separated(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: _selectedDates.length,
//                           separatorBuilder: (context, index) => Divider(
//                             height: 1,
//                             color: Colors.grey.shade300,
//                           ),
//                           itemBuilder: (context, index) {
//                             final date = _selectedDates[index];
//                             return _DateHoursItem(
//                               date: date,
//                               timeRanges: _timeRanges,
//                               onAddTime: _addTimeRange,
//                               onRemoveTime: _removeTimeRange,
//                               onRemoveDate: () => _removeDate(date),
//                             );
//                           },
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),

//             // Footer
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 border: Border(
//                   top: BorderSide(
//                     color: Colors.grey.shade300,
//                     width: 1,
//                   ),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   const Spacer(),
//                   ElevatedButton(
//                     onPressed: () {
//                       // Save logic here
//                       Navigator.of(context).pop();
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primaryColor,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 12,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                     ),
//                     child: const Text('Save Changes'),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _DateHoursItem extends StatelessWidget {
//   final DateTime date;
//   final List<TimeRange> timeRanges;
//   final VoidCallback onAddTime;
//   final Function(int) onRemoveTime;
//   final VoidCallback onRemoveDate;

//   const _DateHoursItem({
//     required this.date,
//     required this.timeRanges,
//     required this.onAddTime,
//     required this.onRemoveTime,
//     required this.onRemoveDate,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Date header
//           Row(
//             children: [
//               // Desktop view - abbreviated day and date
//               Container(
//                 width: 80,
//                 padding: const EdgeInsets.only(right: 16),
//                 decoration: BoxDecoration(
//                   border: Border(
//                     right: BorderSide(
//                       color: Colors.grey.shade300,
//                       width: 1,
//                     ),
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     Text(
//                       DateFormat('EEE').format(date).toUpperCase(),
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.textColorSecond,
//                       ),
//                     ),
//                     Text(
//                       DateFormat('MM/dd').format(date),
//                       style: const TextStyle(
//                         fontSize: 16,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 16),
//               // Mobile view - full date
//               Expanded(
//                 child: Text(
//                   DateFormat('EEE, MMM d, y').format(date),
//                   style: const TextStyle(
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),

//           // Time ranges
//           ListView.separated(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: timeRanges.length,
//             separatorBuilder: (context, index) => const SizedBox(height: 16),
//             itemBuilder: (context, index) {
//               final range = timeRanges[index];
//               return Row(
//                 children: [
//                   Expanded(
//                     child: _TimeRangeInput(
//                       startTime: range.start,
//                       endTime: range.end,
//                       onStartChanged: (TimeOfDay newTime) {
//                         // Handle start time change
//                       },
//                       onEndChanged: (TimeOfDay newTime) {
//                         // Handle end time change
//                       },
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(
//                       Icons.close,
//                       color: AppColors.textColorSecond,
//                     ),
//                     onPressed: () => onRemoveTime(index),
//                   ),
//                 ],
//               );
//             },
//           ),
//           const SizedBox(height: 8),

//           // Add Time button
//           Align(
//             alignment: Alignment.centerLeft,
//             child: TextButton.icon(
//               onPressed: onAddTime,
//               style: TextButton.styleFrom(
//                 foregroundColor: AppColors.primaryColor,
//               ),
//               icon: const Icon(Icons.add, size: 16),
//               label: const Text('Add Time'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _TimeRangeInput extends StatelessWidget {
//   final TimeOfDay startTime;
//   final TimeOfDay endTime;
//   final ValueChanged<TimeOfDay> onStartChanged;
//   final ValueChanged<TimeOfDay> onEndChanged;

//   const _TimeRangeInput({
//     required this.startTime,
//     required this.endTime,
//     required this.onStartChanged,
//     required this.onEndChanged,
//   });

//   Future<void> _selectTime(
//     BuildContext context, 
//     TimeOfDay initialTime,
//     ValueChanged<TimeOfDay> onTimeSelected,
//   ) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: initialTime,
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: AppColors.primaryColor,
//               onPrimary: Colors.white,
//               surface: Colors.white,
//               onSurface: AppColors.textColor,
//             ),
//             dialogBackgroundColor: Colors.white,
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null) {
//       onTimeSelected(picked);
//     }
//   }

//   String _formatTime(TimeOfDay time) {
//     final now = DateTime.now();
//     final dt = DateTime(
//       now.year, now.month, now.day, time.hour, time.minute);
//     return DateFormat.jm().format(dt);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: InkWell(
//             onTap: () => _selectTime(context, startTime, onStartChanged),
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey.shade300),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Text(_formatTime(startTime)),
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8),
//           child: Text(
//             '-',
//             style: TextStyle(color: AppColors.textColorSecond),
//           ),
//         ),
//         Expanded(
//           child: InkWell(
//             onTap: () => _selectTime(context, endTime, onEndChanged),
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey.shade300),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Text(_formatTime(endTime)),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }