import 'package:flutter/material.dart';
import 'package:present/digital_clock.dart';
import 'package:flutter/services.dart';

import 'ball.dart';

enum Status { offline, online, away, busy, open }

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Presentia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const Presentia(),
    );
  }
}

class Presentia extends StatefulWidget {
  const Presentia({super.key});

  @override
  State<Presentia> createState() => _PresentiaState();
}

class _PresentiaState extends State<Presentia> {
  Status _state = Status.offline;

  void _toggleStatus() {
    setState(() {
      _state = Status.values[(_state.index + 1) % Status.values.length];
    });
  }

  Color colorForStatus() {
    switch (_state) {
      case Status.offline:
        return Colors.grey;
      case Status.online:
        return Colors.green;
      case Status.busy:
        return Colors.red;
      case Status.away:
        return Colors.purple;
      case Status.open:
        return Colors.blue;
      default:
        return Colors.transparent;
    }
  }

  String labelForStatus() {
    switch (_state) {
      case Status.offline:
        return "404 // Nowhere to be found;";
      case Status.online:
        return "200 // Onsite doing my things;";
      case Status.busy:
        return "403 // Busy at the moment... Try again later!";
      case Status.away:
        return "302 // Not here, but I'll be back soon.";
      case Status.open:
        return "204 // Ready and Willing to Geek out! ;)";
      default:
        return "503 // Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Stack(children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DigitalClock(label: 'Tokyo', timeZone: 'Asia/Tokyo'),
                    DigitalClock(label: 'Lisbon', timeZone: 'Europe/Lisbon'),
                    DigitalClock(
                        label: 'San Diego', timeZone: 'America/Los_Angeles'),
                  ],
                ),
                Text(
                  'Manu Tozzato',
                  style: TextStyle(
                    fontFamily: 'BungeeOutline',
                    fontSize: 75,
                    color: colorForStatus(),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    'self-diagnosed computer genïus®',
                    style: TextStyle(
                      fontFamily: 'BungeeHairline',
                      fontSize: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
                AnimatedContainer(
                    duration: const Duration(milliseconds: 2048),
                    curve: Curves.easeInOutCubic,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: colorForStatus(),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 12, height: 42),
                        Text(
                          labelForStatus(),
                          style: const TextStyle(
                            fontFamily: 'ShareTechMono',
                            fontSize: 25,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ),
        Ball()
      ]),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.grey[700],
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: _toggleStatus,
        tooltip: 'Toggle Status',
        child: const Icon(Icons.change_circle_outlined),
      ),
    );
  }
}
