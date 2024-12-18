import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ProfileRunCalendar extends StatefulWidget {
  final Map<DateTime, List<String>> runDates; // Events by date

  const ProfileRunCalendar({super.key, required this.runDates});

  @override
  State<ProfileRunCalendar> createState() => _ProfileRunCalendarState();
}

//TODO 1
// 달력을 누르면 그 날의 기록이 나오도록 구현

class _ProfileRunCalendarState extends State<ProfileRunCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime(2000),
          lastDay: DateTime(2100),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          eventLoader: (day) {
            // Match `day` to keys in `runDates`, ignoring time
            return widget.runDates.entries
                .where((entry) => isSameDay(entry.key, day))
                .expand((entry) => entry.value)
                .toList();
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.redAccent,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.blueAccent,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
          ),
        ),
        const SizedBox(height: 16),
        _buildEventList(),
      ],
    );
  }

  Widget _buildEventList() {
    final events = widget.runDates.entries
        .where((entry) => isSameDay(entry.key, _selectedDay))
        .expand((entry) => entry.value)
        .toList();

    if (events.isEmpty) {
      return const Text("No runs on this day.");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(events[index]),
          leading: const Icon(
            Icons.run_circle,
            color: Colors.green,
          ),
        );
      },
    );
  }
}
