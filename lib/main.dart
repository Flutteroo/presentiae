import 'package:flutter/material.dart';
import 'package:present/digital_clock.dart';
import 'package:flutter/services.dart';

import 'ball.dart';
import 'led_indicator.dart';

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
  double _distance = 0.0;
  double _speed = 0.0;
  double _lastImpactForce = 0.0;
  double _dynamicBounciness = 0.0;
  double _maxObservedSpeed = 50.0; // Start with a reasonable minimum
  double _smoothedSpeed = 0.0;
  final GlobalKey<BallState> _ballKey = GlobalKey<BallState>();

  void _toggleStatus() {
    setState(() {
      _state = Status.values[(_state.index + 1) % Status.values.length];
      _ballKey.currentState?.kick();
    });
  }

  void _resetMaxSpeed() {
    setState(() {
      _maxObservedSpeed = 50.0; // Reset to default minimum
    });
    _ballKey.currentState?.resetMaxSpeed();
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
    final displayDistance = _distance % 100000;
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Stack(children: [
        // Distance counter at the top
        Positioned(
          top: 20,
          left: 16,
          right: 16,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  LedIndicator(
                    value: (_smoothedSpeed / _maxObservedSpeed)
                        .clamp(0.0, 1.0), // Use adaptive scaling
                    width: 357,
                    height: 12,
                    ledCount: 42,
                    orientation: Axis.horizontal,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${displayDistance.toStringAsFixed(2).padLeft(8, '0')} MT',
                        // '${(displayDistance ~/ 1).toString().padLeft(5, '0')}.${(displayDistance % 1 * 1000).toInt().toString().padLeft(3, '0')} MT',
                        style: const TextStyle(
                          fontFamily: 'ShareTechMono',
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 28),
                      Text(
                        '${_speed.toStringAsFixed(2)} MT/s',
                        style: const TextStyle(
                          fontFamily: 'ShareTechMono',
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 28),
                      Text(
                        '${_lastImpactForce.toStringAsFixed(2)} F',
                        style: const TextStyle(
                          fontFamily: 'ShareTechMono',
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 28),
                      Text(
                        '${_dynamicBounciness.toStringAsFixed(2)} B',
                        style: const TextStyle(
                          fontFamily: 'ShareTechMono',
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

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
        Ball(
          key: _ballKey,
          onUpdate: (distance, speed, lastImpactForce, dynamicBounciness,
              rawPixelSpeed) {
            if (mounted) {
              setState(() {
                _distance = distance;
                _speed = speed;
                _lastImpactForce = lastImpactForce;
                _dynamicBounciness = dynamicBounciness;

                // Update max observed speed (adaptive scaling)
                if (rawPixelSpeed > _maxObservedSpeed) {
                  _maxObservedSpeed = rawPixelSpeed;
                }

                // Smooth the speed reading to prevent jitter
                const double smoothingFactor = 0.1; // Lower = smoother
                _smoothedSpeed = _smoothedSpeed * (1 - smoothingFactor) +
                    rawPixelSpeed * smoothingFactor;
              });
            }
          },
        )
      ]),
      floatingActionButton: GestureDetector(
        onLongPress: _resetMaxSpeed,
        child: FloatingActionButton(
          foregroundColor: Colors.grey[700],
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: _toggleStatus,
          tooltip: 'Toggle Status (Long press to reset LED calibration)',
          child: const Icon(Icons.change_circle_outlined),
        ),
      ),
    );
  }
}
