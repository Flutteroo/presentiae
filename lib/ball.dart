import 'dart:math';
import 'package:flutter/material.dart';

class Ball extends StatefulWidget {
  @override
  _BallState createState() => _BallState();
}

class _BallState extends State<Ball> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _tween;

  double posX = 0.0, posY = 0.0;
  double dirX = 0.0, dirY = 0.0;
  double speed = 7.0;
  bool initialized = false;
  double angle = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    );

    _tween = Tween<double>(begin: speed, end: -speed)
        .chain(CurveTween(curve: Curves.decelerate))
        .animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      posX = MediaQuery.of(context).size.width / 2;
      posY = MediaQuery.of(context).size.height / 2;
      angle = Random().nextDouble() * 2 * pi;
      dirX = cos(angle);
      dirY = sin(angle);
      initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _tween,
      builder: (context, child) {
        posX += dirX * _tween.value;
        posY += dirY * _tween.value;

        if (posX <= 0 || posX >= MediaQuery.of(context).size.width) {
          angle = pi - angle;
          posX = posX <= 0 ? 0 : MediaQuery.of(context).size.width;
          _controller.forward(from: 0.0);
        }

        if (posY <= 0 || posY >= MediaQuery.of(context).size.height) {
          angle = 2 * pi - angle;
          posY = posY <= 0 ? 0 : MediaQuery.of(context).size.height;
          speed += speed;

          _controller.forward(from: 0.0);
        }
        dirX = cos(angle);
        dirY = sin(angle);

        return CustomPaint(
          painter: MovingDotPainter(Offset(posX, posY), _tween.value),
          child: Container(),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class MovingDotPainter extends CustomPainter {
  final Offset pos;
  final double speed;

  MovingDotPainter(this.pos, this.speed);

  @override
  void paint(Canvas canvas, Size size) {
    // double middlePointX = size.width / 2;
    // double bottomPointY = size.height;
    var paint = Paint()
      ..color = Colors.yellow.withOpacity(0.8)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.0;
    canvas.drawCircle(pos, 5, paint);
    // paint.color = speed > 0 ? Colors.green : Colors.red;
    // canvas.drawRect(
    //     Rect.fromCenter(
    //         center: Offset(middlePointX, bottomPointY),
    //         width: (speed * speed * speed).abs(),
    //         height: 2),
    //     paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
