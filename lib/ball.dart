import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:present/physics_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Ball extends StatefulWidget {
  final Function(double distance, double speed, double lastImpactForce,
      double dynamicBounciness, double rawPixelSpeed)? onUpdate;

  const Ball({Key? key, this.onUpdate}) : super(key: key);

  @override
  BallState createState() => BallState();
}

class BallState extends State<Ball> {
  // Physics properties
  late PhysicsConfig _config;
  double posX = 0.0, posY = 0.0;
  double velX = 0.0, velY = 0.0;
  double prevPosX = 0.0, prevPosY = 0.0;

  // Configuration
  final double radius = 5.0;

  // State
  bool _initialized = false;
  double _totalDistancePixels = 0.0;
  double _speedMetersPerSecond = 0.0;
  double _lastImpactForce = 0.0;
  double _dynamicBounciness = 0.0;
  double _smoothedSpeed = 0.0;
  double _maxObservedSpeed = 50.0; // Start with reasonable minimum
  Timer? _timer;

  // Persistence
  SharedPreferences? _prefs;

  // A simple scaling factor to make the counter increase slowly.
  // This is not a physically accurate measurement.
  final double _distanceScaleFactor = 5000.0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadConfig();
    _loadDistance();

    // Start the physics loop
    _timer = Timer.periodic(const Duration(milliseconds: 16), _update);
  }

  Future<void> _loadConfig() async {
    final String? configString = null; //_prefs?.getString('physics_config');
    if (configString != null) {
      _config = PhysicsConfig.fromJson(jsonDecode(configString));
    } else {
      _config = PhysicsConfig.defaultConfig();
      await _saveConfig(); // Save the default config if none exists
    }
  }

  Future<void> _saveConfig() async {
    // await _prefs?.setString('physics_config', jsonEncode(_config.toJson()));
  }

  void _loadDistance() {
    setState(() {
      _totalDistancePixels = _prefs?.getDouble('ball_distance_pixels') ?? 0.0;
    });
    widget.onUpdate?.call(
      _totalDistancePixels / _distanceScaleFactor,
      _speedMetersPerSecond,
      _lastImpactForce,
      _dynamicBounciness,
      0.0, // rawPixelSpeed - not available during load
    );
  }

  Future<void> _saveDistance() async {
    // await _prefs?.setDouble('ball_distance_pixels', _totalDistancePixels);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final size = MediaQuery.of(context).size;
      posX = size.width / 2;
      posY = size.height / 2;

      // Give it an initial random velocity
      final random = Random();
      final angle = random.nextDouble() * 2 * pi;
      velX = cos(angle) * 5;
      velY = sin(angle) * 5;

      prevPosX = posX;
      prevPosY = posY;
      _initialized = true;
    }
  }

  void kick() {
    final random = Random();
    final angle = random.nextDouble() * 2 * pi;
    final force = random.nextDouble() * 10 + 5; // Random force between 5 and 15
    velX += cos(angle) * force;
    velY += sin(angle) * force;
  }

  void resetMaxSpeed() {
    _maxObservedSpeed = 50.0; // Reset to default minimum
  }

  // Apply random angle variation to bounce for more realistic physics
  void _applyRandomBounceVariation() {
    final random = Random();
    final angleVariation = (random.nextDouble() - 0.5) *
        2 *
        (_config.bounceAngleVariation *
            pi /
            180.0); // Configurable ± degrees in radians

    // Calculate current velocity angle and magnitude
    final currentAngle = atan2(velY, velX);
    final currentSpeed = sqrt(velX * velX + velY * velY);

    // Apply angle variation
    final newAngle = currentAngle + angleVariation;

    // Update velocity components with new angle but same speed
    velX = cos(newAngle) * currentSpeed;
    velY = sin(newAngle) * currentSpeed;
  }

  void _update(Timer timer) {
    if (!_initialized || !mounted) return;

    // Kick the ball if it's barely moving
    if (velX.abs() < 0.1 && velY.abs() < 0.1) {
      kick();
    }

    setState(() {
      // Store previous position for distance calculation
      prevPosX = posX;
      prevPosY = posY;

      // Apply friction
      velX *= _config.friction;
      velY *= _config.friction;

      // Update position
      posX += velX;
      posY += velY;

      // Calculate current speed for bounciness calculation
      final currentSpeed = sqrt(velX * velX + velY * velY);
      _dynamicBounciness =
          _config.wallBounciness - (currentSpeed * _config.bouncinessFalloff);
      if (_dynamicBounciness < 0) _dynamicBounciness = 0;

      // Wall collision detection
      final size = MediaQuery.of(context).size;
      if (posX - radius < 0) {
        posX = radius;
        _lastImpactForce = velX.abs();
        velX = -velX * _dynamicBounciness;
        _applyRandomBounceVariation();
      } else if (posX + radius > size.width) {
        posX = size.width - radius;
        _lastImpactForce = velX.abs();
        velX = -velX * _dynamicBounciness;
        _applyRandomBounceVariation();
      }

      if (posY - radius < 0) {
        posY = radius;
        _lastImpactForce = velY.abs();
        velY = -velY * _dynamicBounciness;
        _applyRandomBounceVariation();
      } else if (posY + radius > size.height) {
        posY = size.height - radius;
        _lastImpactForce = velY.abs();
        velY = -velY * _dynamicBounciness;
        _applyRandomBounceVariation();
      }

      // Calculate and update distance
      final double dx = posX - prevPosX;
      final double dy = posY - prevPosY;
      final double distanceThisFrame = sqrt(dx * dx + dy * dy);
      _totalDistancePixels += distanceThisFrame;

      // Calculate speed
      final double pixelsPerSecond = distanceThisFrame / (16 / 1000.0);
      _speedMetersPerSecond = pixelsPerSecond / _distanceScaleFactor;

      // Update max observed speed and smooth the speed reading
      if (pixelsPerSecond > _maxObservedSpeed) {
        _maxObservedSpeed = pixelsPerSecond;
      }
      const double smoothingFactor = 0.1; // Lower = smoother
      _smoothedSpeed = _smoothedSpeed * (1 - smoothingFactor) +
          pixelsPerSecond * smoothingFactor;

      widget.onUpdate?.call(
        _totalDistancePixels / _distanceScaleFactor,
        _speedMetersPerSecond,
        _lastImpactForce,
        _dynamicBounciness,
        pixelsPerSecond,
      );

      // Periodically save the distance
      if (_totalDistancePixels % 100 < distanceThisFrame) {
        _saveDistance();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _saveDistance(); // Ensure distance is saved on exit
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MovingDotPainter(
          Offset(posX, posY), radius, _smoothedSpeed, _maxObservedSpeed),
      child: Container(),
    );
  }
}

class MovingDotPainter extends CustomPainter {
  final Offset pos;
  final double radius;
  final double currentSpeed;
  final double maxSpeed;

  MovingDotPainter(this.pos, this.radius, this.currentSpeed, this.maxSpeed);

  Color _getSpeedColor() {
    if (maxSpeed <= 0) return Colors.yellow.withOpacity(0.8);

    final normalizedSpeed = (currentSpeed / maxSpeed).clamp(0.0, 1.0);

    // Same color thresholds as LED indicator
    if (normalizedSpeed <= 0.4) {
      return Colors.green.withOpacity(0.8);
    } else if (normalizedSpeed <= 0.7) {
      return Colors.yellow.withOpacity(0.8);
    } else if (normalizedSpeed <= 0.9) {
      return Colors.orange.withOpacity(0.8);
    } else {
      return Colors.red.withOpacity(0.8);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = _getSpeedColor()
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
