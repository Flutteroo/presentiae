```dart
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mlb_companion_app/shared/text_styled.dart';

import 'shared/colors.dart';
import 'shared/constants.dart';
import 'shared/shared_prefs.dart';
import 'services/analytics.dart';

class AudioNotificationSettingScreen extends StatefulWidget {
  AudioNotificationSettingScreen({Key? key, this.customButton})
      : super(key: key);

  final Widget? customButton;
  TextStyle get _style {
    return TextStyled.getFontStyle(
      color: colorDefaultText,
      fontSize: AppSettings.strBaseText,
    );
  }

  @override
  _AudioNotificationSettingScreenState createState() =>
      _AudioNotificationSettingScreenState();
}

class _AudioNotificationSettingScreenState
    extends State<AudioNotificationSettingScreen> {
  _AudioNotificationSettingScreenState();

  final player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  double _currentVolume = SharedPrefs().notificationVolume;

  @override
  void initState() {
    super.initState();
    _trackScreen();
  }

  void _playSound() async {
    player.setSource(AssetSource('cash.wav'));
    player.setVolume(_currentVolume / 100);
    await player.stop();
    await player.resume();
  }

  void _setVolume(double volume) {
    SharedPrefs().notificationVolume = volume;
    setState(() {
      _currentVolume = volume;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
                foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                elevation: 0,
                title: Text(AppStrings.labelAudioNotificationSettings,
                    style: widget._style)),
            backgroundColor: colorDefaultBackgroundGeneric,
            body: _body()));
  }

  Widget _body() {
    return SafeArea(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: CustomPaint(
              painter: LedGaugePainter(volume: _currentVolume),
              child: Container(
                height: 224,
                width: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.black.withOpacity(0.3)),
              )),
        ),
        Text(_currentVolume.round().toString(),
            style: widget._style.copyWith(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold)),
        widget.customButton != null
            ? Align(alignment: Alignment.center, child: widget.customButton)
            : TextButton(
                style: Theme.of(context).textButtonTheme.style?.copyWith(
                    side: MaterialStateProperty.all(
                        BorderSide(color: colorDefaultTextSecondary)),
                    backgroundColor:
                        MaterialStateProperty.all(Colors.transparent)),
                onPressed: _playSound,
                child: Text(AppStrings.labelVolumeTest,
                    style: widget._style.copyWith(
                        color: colorDefaultTextSecondary,
                        fontWeight: FontWeight.bold))),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
                child: Text(AppStrings.labelVolumeMin,
                    style: widget._style.copyWith(color: colorDefaultText)),
                onPressed: () => _setVolume(0)),
            Slider(
              activeColor: colorDefaultText,
              inactiveColor: colorDefaultBackgroundSecondaryGeneric,
              value: _currentVolume,
              min: 0,
              max: 100,
              divisions: 100,
              label: null,
              onChanged: (double value) => _setVolume(value),
            ),
            TextButton(
                child: Text(AppStrings.labelVolumeMax,
                    style: widget._style.copyWith(color: colorDefaultText)),
                onPressed: () => _setVolume(100)),
          ],
        ),
      ],
    ));
  }

  Future<void> _trackScreen() async {
    Analytics().trackScreen(
        screenName: 'Audio Notification Setting Screen',
        screenClassOverride: 'AudioNotificationSettingScreen');
  }
}

class LedGaugePainter extends CustomPainter {
  final double volume;
  final int ledCount = 20;
  final double ledHeight = 8;
  final double ledWidth = 30;
  final double ledSpacing = 3;

  LedGaugePainter({required this.volume});

  @override
  void paint(Canvas canvas, Size size) {
    int litLeds = (volume / 5).ceil();
    for (int i = 0; i < ledCount; i++) {
      Color color;
      if (i < 8) {
        color = (i < litLeds)
            ? Colors.green
            : colorDefaultBackgroundSecondaryGeneric;
      } else if (i < 14) {
        color = (i < litLeds)
            ? Colors.yellow
            : colorDefaultBackgroundSecondaryGeneric;
      } else if (i < 18) {
        color = (i < litLeds)
            ? Colors.orange
            : colorDefaultBackgroundSecondaryGeneric;
      } else {
        color =
            (i < litLeds) ? Colors.red : colorDefaultBackgroundSecondaryGeneric;
      }

      double top = size.height - (i + 1) * (ledHeight + ledSpacing);
      Rect ledRect =
          Rect.fromLTWH((size.width - ledWidth) / 2, top, ledWidth, ledHeight);
      Paint paint = Paint()..color = color;
      canvas.drawRect(ledRect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant LedGaugePainter oldDelegate) {
    return oldDelegate.volume != volume;
  }
}
```