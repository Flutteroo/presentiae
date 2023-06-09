import 'dart:async';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_10y.dart' as tzData;
import 'package:flutter/material.dart';

class DigitalClock extends StatefulWidget {
  String timeZone;
  String label;
  DigitalClock({Key? key, required this.timeZone, required this.label})
      : super(key: key);

  @override
  DigitalClockState createState() => DigitalClockState();
}

class DigitalClockState extends State<DigitalClock> {
  bool _blink = true;
  late tz.Location location;
  String _datetime = '';

  @override
  void initState() {
    super.initState();
    tzData.initializeTimeZones();
    location = tz.getLocation(widget.timeZone);
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
  }

  void _getTime() {
    final now = tz.TZDateTime.now(location);
    final datetime = DateFormat('E, dd HH:mm', 'en_US').format(now);
    setState(() {
      _datetime = datetime;
      _blink = !_blink;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateTime = _datetime.split(':');
    if (dateTime.length < 2) {
      return const SizedBox.shrink();
    }

    final separator = _blink ? ':' : ' ';
    return Text(
      '${widget.label} ${dateTime[0]}$separator${dateTime[1]}',
      style: TextStyle(
        fontFamily: 'ShareTechMono',
        fontSize: 15.0,
        color: Colors.green.withOpacity(0.8),
      ),
    );
  }
}
