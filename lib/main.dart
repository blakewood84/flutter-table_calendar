// ignore_for_file: public_member_api_docs, sort_constructors_first, unused_field
import 'dart:collection';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'dart:developer' as devtools;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

int getHashCode(DateTime key) {
  return key.day * 100000 + key.month * 10000 + key.year;
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

final _newEventSource = <DateTime, List<Event>>{
  DateTime.utc(2022, 11, 01): [
    Event(title: 'Event on Nov1'),
  ],
  DateTime.utc(2022, 11, 02): [Event(title: 'Event on Nov 2'), Event(title: 'Another Event on Nov 2')],
  DateTime.utc(2022, 11, 16): [
    Event(title: 'Event on Nov 16'),
    Event(title: 'Another one'),
    Event(title: 'Yet another one'),
  ],
  DateTime.utc(2022, 11, 22): [Event(title: 'Boom')]
};

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final kEvents = LinkedHashMap<DateTime, List<Event>>(
    equals: isSameDay,
    hashCode: getHashCode,
  )..addAll(_newEventSource);

  List<Event>? _selectedDateRangeEvents;

  // Tapped Day
  DateTime? _selectedDay = DateTime.now();
  // Day calendar page is focused on
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;

  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  List<Event> _getEventsForDay(DateTime day) {
    return kEvents[day] ?? [];
  }

  void _getEventsForRange(DateTime start, DateTime end) {
    final eventsList = <Event>[];
    for (final entry in kEvents.entries) {
      if (!entry.key.isBefore(start) && !entry.key.isAfter(end)) {
        for (final item in entry.value) {
          eventsList.add(item);
        }
      }
    }
    setState(() {
      _selectedDateRangeEvents = eventsList;
    });
  }

  List<Event> _selectedEvents = [];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                  _selectedDay = selectedDay;
                  _selectedEvents = _getEventsForDay(selectedDay);
                  _rangeSelectionMode = RangeSelectionMode.toggledOff;
                  _rangeStart = null;
                  _rangeEnd = null;
                  _selectedDateRangeEvents = null;
                });
              },
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              // Changes the focus day of the calendar
              onPageChanged: (focusedDay) {
                _focusedDay = _focusedDay;
              },
              // Loops through each day of the days showing on calendar
              // Returns a list of events for that day
              eventLoader: (day) {
                return _getEventsForDay(day);
              },
              calendarBuilders: CalendarBuilders(
                dowBuilder: (context, day) {
                  if (day.weekday == DateTime.sunday) {
                    final text = DateFormat.E().format(day);

                    return Center(
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                    );
                  }

                  return null;
                },
              ),
              rangeSelectionMode: _rangeSelectionMode,
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              onRangeSelected: (start, end, focusedDay) {
                setState(() {
                  _selectedDay = null;
                  _focusedDay = focusedDay;
                  _rangeStart = start;
                  _rangeEnd = end;
                  _rangeSelectionMode = RangeSelectionMode.toggledOn;
                });
                // If date range is present, find all in that date range
                if (_rangeStart != null && _rangeEnd != null) {
                  _getEventsForRange(_rangeStart!, _rangeEnd!);
                }
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _selectedDateRangeEvents != null ? _selectedDateRangeEvents!.length : _selectedEvents.length,
                itemBuilder: (context, index) {
                  final event = _selectedDateRangeEvents![index];
                  return Container(
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.red,
                      ),
                    ),
                    width: double.infinity,
                    child: Text(event.title),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Event {
  final String title;

  Event({required this.title});
}
