import 'package:flutter/material.dart';

class LedIndicator extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final int ledCount;
  final double width;
  final double height;
  final Axis orientation;
  final List<Color> colors;
  final List<double> colorThresholds; // Normalized thresholds for color changes

  const LedIndicator({
    Key? key,
    required this.value,
    this.ledCount = 20,
    this.width = 40,
    this.height = 200,
    this.orientation = Axis.vertical,
    this.colors = const [
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.red,
    ],
    this.colorThresholds = const [0.4, 0.7, 0.9], // 40%, 70%, 90%
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: LedIndicatorPainter(
        value: value,
        ledCount: ledCount,
        orientation: orientation,
        colors: colors,
        colorThresholds: colorThresholds,
      ),
      child: Container(
        width: width,
        height: height,
        // decoration: BoxDecoration(
        //   borderRadius: BorderRadius.circular(5),
        //   color: Colors.black.withOpacity(0.3),
        // ),
      ),
    );
  }
}

class LedIndicatorPainter extends CustomPainter {
  final double value;
  final int ledCount;
  final Axis orientation;
  final List<Color> colors;
  final List<double> colorThresholds;
  final double ledSpacing;
  final Color offColor;

  LedIndicatorPainter({
    required this.value,
    required this.ledCount,
    required this.orientation,
    required this.colors,
    required this.colorThresholds,
    this.ledSpacing = 3,
    this.offColor = const Color(0xFF333333),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final int litLeds = (value * ledCount).ceil();
    final double ledSize = orientation == Axis.vertical
        ? (size.height - (ledCount - 1) * ledSpacing) / ledCount
        : (size.width - (ledCount - 1) * ledSpacing) / ledCount;

    for (int i = 0; i < ledCount; i++) {
      final bool isLit = i < litLeds;
      final Color color = isLit ? _getColorForLed(i / ledCount) : offColor;

      Rect ledRect;
      if (orientation == Axis.vertical) {
        final double top = size.height - (i + 1) * (ledSize + ledSpacing);
        ledRect = Rect.fromLTWH(
          (size.width - ledSize) / 2,
          top,
          ledSize,
          ledSize,
        );
      } else {
        final double left = i * (ledSize + ledSpacing);
        ledRect = Rect.fromLTWH(
          left,
          (size.height - ledSize) / 2,
          ledSize,
          ledSize,
        );
      }

      final Paint paint = Paint()..color = color;
      canvas.drawRect(ledRect, paint);
    }
  }

  Color _getColorForLed(double normalizedPosition) {
    if (colors.isEmpty) return Colors.white;

    for (int i = 0; i < colorThresholds.length; i++) {
      if (normalizedPosition <= colorThresholds[i]) {
        return colors[i];
      }
    }

    return colors.last;
  }

  @override
  bool shouldRepaint(covariant LedIndicatorPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.ledCount != ledCount ||
        oldDelegate.orientation != orientation ||
        oldDelegate.colors != colors ||
        oldDelegate.colorThresholds != colorThresholds;
  }
}
