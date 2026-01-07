import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fikraa/screens/home_screen.dart';
import 'package:fikraa/screens/notifications_screen.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:fikraa/screens/weather_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DataScreen(),
    );
  }
}

class DataScreen extends StatefulWidget {
  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  double homeTemperature = 0.0;
  double gasLevel = 0.0;
  double energyUsage = 0.0;
  double humidity = 0.0;
  late DatabaseReference _temperatureRef;
  late DatabaseReference _energyRef;
  late DatabaseReference _humidityRef;
 late DatabaseReference _gasLevelRef;

  List<FlSpot> temperatureData = [];

  @override
  void initState() {
    super.initState();

    _energyRef = FirebaseDatabase.instance.ref('energy/energyUsage');
    _humidityRef = FirebaseDatabase.instance.ref('humidity/sol');
    _temperatureRef = FirebaseDatabase.instance.ref('temperature/current');
    _gasLevelRef = FirebaseDatabase.instance.ref('gas/level');

    _energyRef.onValue.listen((event) {
      final double usage = (event.snapshot.value as num?)?.toDouble() ?? 0.0;
      setState(() {
        energyUsage = usage;
      });
    });

    _temperatureRef.onValue.listen((event) {
      final double temperature = (event.snapshot.value as num?)?.toDouble() ?? 0.0;
      setState(() {
        homeTemperature = temperature;
      });
    });
 _gasLevelRef.onValue.listen((event) {
      final double level = (event.snapshot.value as num?)?.toDouble() ?? 0.0;
      setState(() {
        gasLevel = level;
      });
    });
  
  

    _humidityRef.onValue.listen((event) {
      final double humidityValue =
          (event.snapshot.value as num?)?.toDouble() ?? 0.0;
      setState(() {
        humidity = humidityValue;
      });
    });
    

  }


  void _updateTemperatureData(double newTemperature) {
    setState(() {
      temperatureData.add(FlSpot(temperatureData.length.toDouble(), newTemperature));
      if (temperatureData.length > 10) {
        temperatureData.removeAt(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade50,
        
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.indigo,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.indigo),
            onSelected: (value) {
              switch (value) {
                case 'home':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ),
                  );
                  break;
                case 'data':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DataScreen(),
                    ),
                  );
                  break;
              
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'home',
                  child: Row(
                    children: [
                      const Icon(Icons.home, color: Colors.indigo),
                      const SizedBox(width: 8),
                      const Text('Home'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'data',
                  child: Row(
                    children: [
                      const Icon(Icons.data_usage, color: Colors.indigo),
                      const SizedBox(width: 8),
                      const Text('Data'),
                    ],
                  ),
                ),
            
              ];
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 70),
            const Text(
              'Sensor Data',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 26, 6, 116),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 15.0,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildGauge('Gas Level', gasLevel),
                  _buildGauge('Home Temp', homeTemperature),
                  _buildGauge('Soil Moisture', humidity),
                  _buildGauge('Energy', energyUsage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGauge(String title, double value) {
    return Container(
      width: 150,
      height: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: CustomPaint(
                  painter: GaugePainter(value),
                  size: const Size(150, 150),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double value;

  GaugePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    paint.color = Colors.black;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);

    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 10;
    canvas.drawCircle(center, radius, paint);

    final Paint needlePaint = Paint()
      ..color = const Color.fromARGB(255, 54, 31, 155)
      ..style = PaintingStyle.fill;

    double needleAngle = -pi / 2 + (2 * pi * (value / 100));
    double needleLength = radius * 0.9;

    final double baseWidth = 10;
    final Path needlePath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(
        center.dx + baseWidth * cos(needleAngle - pi / 12),
        center.dy + baseWidth * sin(needleAngle - pi / 12),
      )
      ..lineTo(
        center.dx + needleLength * cos(needleAngle),
        center.dy + needleLength * sin(needleAngle),
      )
      ..lineTo(
        center.dx + baseWidth * cos(needleAngle + pi / 12),
        center.dy + baseWidth * sin(needleAngle + pi / 12),
      )
      ..close();

    canvas.drawPath(needlePath, needlePaint);

    paint.color = const Color.fromARGB(255, 15, 6, 124);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(center, 5, paint);

    paint.color = Colors.white;
    paint.strokeWidth = 2;
    final TextPainter textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    final double labelRadius = radius * 0.85;
    for (int i = 0; i <= 10; i++) {
      double markAngle = -pi / 2 + (2 * pi * (i / 10));
      double markX1 = center.dx + radius * 0.9 * cos(markAngle);
      double markY1 = center.dy + radius * 0.9 * sin(markAngle);
      double markX2 = center.dx + radius * 0.95 * cos(markAngle);
      double markY2 = center.dy + radius * 0.95 * sin(markAngle);
      paint.strokeWidth = 2;
      paint.color = Colors.white;
      canvas.drawLine(Offset(markX1, markY1), Offset(markX2, markY2), paint);

      textPainter.text = TextSpan(
        text: '${(i * 10).toInt()}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          center.dx + (radius * 0.75) * cos(markAngle) - (textPainter.width / 2),
          center.dy + (radius * 0.75) * sin(markAngle) - (textPainter.height / 2),
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}



