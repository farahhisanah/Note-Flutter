import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paged_vertical_calendar/paged_vertical_calendar.dart';
import 'package:note_flutter/database/firestore.dart'; // Import FirestoreDatabase

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<DateTime, List<String>> eventsMap = {};
  late FirestoreDatabase _firestoreDatabase;

  @override
  void initState() {
    super.initState();
    _firestoreDatabase = FirestoreDatabase();
    _fetchEvents();
  }

  void _fetchEvents() async {
    try {
      Map<DateTime, List<String>> events = await _firestoreDatabase.fetchEvents();
      setState(() {
        eventsMap = events;
      });
    } catch (error) {
      print('Error fetching events: $error');
    }
  }

  void _addEvent(BuildContext context, DateTime date) {
    TextEditingController eventController = TextEditingController();
    String? existingEvent = eventsMap[date]?.isNotEmpty == true ? eventsMap[date]!.first : null;
    eventController.text = existingEvent ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(existingEvent != null ? "Edit Event" : "Add Event"),
          content: TextField(
            controller: eventController,
            decoration: InputDecoration(hintText: "Enter event"),
          ),
          actions: <Widget>[
            if (existingEvent != null)
              TextButton(
                child: Text("Delete"),
                onPressed: () => _deleteEvent(context, date, existingEvent),
              ),
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(existingEvent != null ? "Save" : "Add"),
              onPressed: () => _saveEvent(context, date, existingEvent, eventController.text),
            ),
          ],
        );
      },
    );
  }

  void _saveEvent(BuildContext context, DateTime date, String? existingEvent, String newEvent) async {
    if (newEvent.trim().isEmpty) {
      print('Event cannot be empty');
      return;
    }

    try {
      if (existingEvent != null) {
        await _firestoreDatabase.updateEventInCalendar(date, existingEvent, newEvent);
        setState(() {
          eventsMap[date] = [newEvent];
        });
      } else {
        await _firestoreDatabase.addEventToCalendar(date, newEvent);
        setState(() {
          eventsMap[date] ??= [];
          eventsMap[date]!.add(newEvent);
        });
      }
      Navigator.of(context).pop();
    } catch (error) {
      print('Error saving event: $error');
    }
  }

  void _deleteEvent(BuildContext context, DateTime date, String event) async {
    try {
      await _firestoreDatabase.deleteEventInCalendar(date, event);
      setState(() {
        eventsMap[date]!.remove(event);
      });
      Navigator.of(context).pop();
    } catch (error) {
      print('Error deleting event: $error');
    }
  }

  void _fetchNewEvents(int year, int month) async {
    Random random = Random();
    final newItems = List<DateTime>.generate(random.nextInt(40), (i) {
      return DateTime(year, month, random.nextInt(27) + 1);
    });
    setState(() {
      for (var date in newItems) {
        eventsMap[date] ??= [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
      ),
      body: PagedVerticalCalendar(
        addAutomaticKeepAlives: true,
        onMonthLoaded: _fetchNewEvents,
        dayBuilder: (context, date) {
          final eventsThisDay = eventsMap[date] ?? [];
          return GestureDetector(
            onTap: () => _addEvent(context, date),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(DateFormat('d').format(date)),
                Wrap(
                  children: [
                    ...eventsThisDay.map((event) {
                      return Padding(
                        padding: const EdgeInsets.all(1),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 5,
                              backgroundColor: Colors.red,
                            ),
                            SizedBox(height: 2),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          );
        },
        onDayPressed: (day) {
          final eventsThisDay = eventsMap[day] ?? [];
          print('Events on $day: $eventsThisDay');
        },
      ),
    );
  }
}
