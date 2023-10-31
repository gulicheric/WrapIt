import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:table_calendar/table_calendar.dart';

class TableBasicsExampleOther extends StatefulWidget {
  final String uid;

  const TableBasicsExampleOther({super.key, required this.uid});

  @override
  _TableBasicsExampleOtherState createState() =>
      _TableBasicsExampleOtherState();
}

class _TableBasicsExampleOtherState extends State<TableBasicsExampleOther> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime now = DateTime.now();
  DateTime _focusedDay = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
  DateTime? _selectedDay;
  Map<DateTime, String> _posts = {};

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  void fetchPosts() async {
    var collection = FirebaseFirestore.instance.collection('Posts');
    var snapshot = await collection.get();
    var posts = snapshot.docs.map((doc) => doc.data()).toList();
    _posts.clear();
    final user = widget.uid;

    for (var post in posts) {
      // Check if the post is by the current user.
      if (post['postedBy'] == user) {
        var createdAt = DateTime.parse(post['createdAt']);

        // Create a new DateTime object with only the year, month, and day.
        var createdAtDateOnly =
            DateTime(createdAt.year, createdAt.month, createdAt.day);

        var url = post['url'];

        // Map the date to the URL.
        _posts[createdAtDateOnly] = url;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // print(_posts);
    // print("I'm in calendar");

    // if (_posts[_focusedDay] != null) {
    //   print("focused day is not null");
    //   print(_focusedDay);
    //   print(_posts[_focusedDay]);
    // } else {
    //   print("sorry its null");
    //   print(_focusedDay);
    // }
    return TableCalendar(
      currentDay: _focusedDay,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
      },
      daysOfWeekVisible: false,
      daysOfWeekHeight: 20,
      rowHeight: 70,
      weekendDays: [DateTime.saturday],
      calendarStyle: CalendarStyle(
        isTodayHighlighted: false,
        cellMargin: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
        selectedDecoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          shape: BoxShape.rectangle,
        ),
        todayDecoration:
            _posts[_focusedDay] != null && _posts[_focusedDay]!.isNotEmpty
                ? BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(_posts[_focusedDay]!),
                      fit: BoxFit.cover,
                    ),
                    shape: BoxShape.rectangle,
                  )
                : const BoxDecoration(),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, date, events) {
          if (_posts.keys.any((day) => isSameDay(day, date))) {
            if (kDebugMode) {
              // print("Im in calendar");
              // print("day: " + date.toString());
              // print(_posts[DateTime.parse(date.toString().split("Z")[0])]);
            }

            return Container(
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Stack(
                  children: [
                    InstaImageViewer(
                        child: Image(
                      height: 100,
                      image: NetworkImage(
                        _posts[DateTime.parse(date.toString().split("Z")[0])] ??
                            "",
                        scale: 2.5,
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null)
                          return child; // Return the image if it's loaded
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            height: 100,
                            color: Colors.white,
                          ),
                        );
                      },
                      // fit: BoxFit
                      //     .fill, // Uncomment this if you want the image to fill the container
                    )),
                    Positioned(
                      // Position the text widget at the center of the Stack.
                      left: 0,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Text(date.day.toString()),
                      ),
                    ),
                  ],
                ));
          } else {
            return Center(
              child: Text(date.day.toString()),
            );
          }
        },
      ),
      firstDay: kFirstDay,
      lastDay: kLastDay,
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      onDaySelected: (selectedDay, focusedDay) {
        if (_posts.keys.contains(selectedDay)) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        }
      },
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
    );
  }
}

/// Example event class.
class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}

/// Example events.
///
/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_kEventSource);

final _kEventSource = Map.fromIterable(List.generate(50, (index) => index),
    key: (item) => DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5),
    value: (item) => List.generate(
        item % 4 + 1, (index) => Event('Event $item | ${index + 1}')))
  ..addAll({
    kToday: [
      const Event('Today\'s Event 1'),
      const Event('Today\'s Event 2'),
    ],
  });

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 12, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 1, kToday.day);
