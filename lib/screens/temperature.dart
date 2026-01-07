import 'package:fikraa/screens/data_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fikraa/screens/home_screen.dart';
import 'package:fikraa/screens/app_colors.dart';

class TemperaturePage extends StatefulWidget {
  const TemperaturePage({Key? key}) : super(key: key);

  @override
  _TemperaturePageState createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {
  double heating = 12;
  bool isFan1On = false;
  bool isFan2On = false;
  late DatabaseReference _fanRef;
  late DatabaseReference _temperatureRef;
  double currentTemperature = 24.0;
  
  List<FlSpot> temperatureData = [
    FlSpot(0, 22),
    FlSpot(1, 24),
    FlSpot(2, 23),
    FlSpot(3, 25),
    FlSpot(4, 24),
  ];

  @override
  void initState() {
    super.initState();
    _fanRef = FirebaseDatabase.instance.ref('fans');
    _temperatureRef = FirebaseDatabase.instance.ref('temperature/current');

    // Listen to changes in fan states
    _fanRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          isFan1On = data['fan1']?['isOn'] ?? false;
          isFan2On = data['fan2']?['isOn'] ?? false;
        });
      }
    });

    // Listen to temperature changes
    _temperatureRef.onValue.listen((event) {
      final temperatureValue = event.snapshot.value;
      double temperature;
      if (temperatureValue is double) {
        temperature = temperatureValue;
      } else if (temperatureValue is int) {
        temperature = temperatureValue.toDouble();
      } else {
        try {
          temperature = double.parse(temperatureValue.toString());
        } catch (e) {
          print('Error parsing temperature: $e');
          return;
        }
      }
      
      setState(() {
        currentTemperature = temperature;
        _updateTemperatureData(temperature);
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
            icon: const Icon(Icons.menu, color: Colors.indigo), // Icon for the menu
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
                      builder: (context) => DataScreen() // Provide actual notifications list
                    ),
                  );
                  // Action to display data
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
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 18, left: 24, right: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(height: 32),
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 180,
                            height: 180,
                            child: CircularProgressIndicator(
                              value: currentTemperature / 100, // Adjust based on max temperature
                              strokeWidth: 14,
                              color: Colors.indigo,
                              backgroundColor: Colors.indigo.shade100,
                            ),
                          ),
                          Text(
                            '${currentTemperature.toStringAsFixed(1)}\u00B0',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        'TEMPERATURE',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _roundedButton(title: 'AT SERVICE', isActive: true),
                        _roundedButton(title: 'OFF-DUTY'),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildTemperatureChart(),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FanControl(
                          room: 'Living Room',
                          isOn: isFan1On,
                          onToggle: () {
                            setState(() {
                              isFan1On = !isFan1On;
                              _fanRef.child('fan1').update({'isOn': isFan1On});
                            });
                          },
                        ),
                        FanControl(
                          room: 'BedRoom',
                          isOn: isFan2On,
                          onToggle: () {
                            setState(() {
                              isFan2On = !isFan2On;
                              _fanRef.child('fan2').update({'isOn': isFan2On});
                            });
                          },
                        ),
                      ],
                    ),
                    
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemperatureChart() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: const Text(
              'Real-time Temperature',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: temperatureData,
                    isCurved: true,
                    color: Colors.indigo,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                titlesData: FlTitlesData(show: true),
                borderData: FlBorderData(show: true),
                gridData: FlGridData(show: true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundedButton({
    required String title,
    bool isActive = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 32,
      ),
      decoration: BoxDecoration(
        color: isActive ? Colors.indigo : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.indigo),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
class FanControl extends StatelessWidget {
  final String room;
  final bool isOn;
  final VoidCallback onToggle;

  const FanControl({
    required this.room,
    required this.isOn,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: isOn ? Colors.indigo : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                'images/fan-2.png',
                color: isOn ? Colors.yellow : Colors.grey,
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 1),
              Text(
                room,
                style: TextStyle(
                  color: isOn ? Colors.white : Colors.black87,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 1),
              Switch(
                value: isOn,
                onChanged: (value) => onToggle(),
                activeColor: Colors.yellow,
              ),
              Text(
                isOn ? 'On' : 'Off',
                style: TextStyle(
                  color: isOn ? Colors.white : Colors.black87,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

