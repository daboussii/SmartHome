import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fikraa/screens/home_screen.dart';
import 'package:fikraa/screens/app_colors.dart';
import 'package:fikraa/screens/data_screen.dart';
import 'dart:async';

class WaterPage extends StatefulWidget {
  const WaterPage({Key? key}) : super(key: key);

  @override
  _WaterPageState createState() => _WaterPageState();
}

class _WaterPageState extends State<WaterPage> {
  bool isPumpOn = false;
  double currentHumidity = 55.0;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  late StreamSubscription _pumpSubscription;
  late StreamSubscription _humiditySubscription;

  @override
  void initState() {
    super.initState();
    _listenForHumidityAndPumpState();
  }

  @override
  void dispose() {
    _pumpSubscription.cancel();
    _humiditySubscription.cancel();
    super.dispose();
  }

  void _listenForHumidityAndPumpState() {
    _pumpSubscription = _database.child('pump/isOn').onValue.listen((event) {
      final data = event.snapshot.value;
      if (mounted) {
        setState(() {
          isPumpOn = data as bool;
        });
      }
    });

    _humiditySubscription = _database.child('humidity/sol').onValue.listen((event) {
      final data = event.snapshot.value;
      if (mounted) {
        setState(() {
          currentHumidity = (data as num).toDouble();
        });
      }
    });
  }

  Future<void> _updatePumpState(bool isOn) async {
    await _database.child('pump').set({'isOn': isOn});
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
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                  break;
                case 'data':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DataScreen()),
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
                    const SizedBox(height: 50),
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 180,
                            height: 180,
                            child: CircularProgressIndicator(
                              value: currentHumidity / 100,
                              strokeWidth: 14,
                              color: Colors.indigo,
                              backgroundColor: Colors.indigo.shade100,
                            ),
                          ),
                          Text(
                            '${currentHumidity.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Center(
                      child: Text(
                        'SOIL MOISTURE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                          fontSize: 25,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Center(
                      child: PumpControl(
                        isOn: isPumpOn,
                        onToggle: () {
                          setState(() {
                            isPumpOn = !isPumpOn;
                          });
                          _updatePumpState(isPumpOn);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PumpControl extends StatefulWidget {
  final bool isOn;
  final VoidCallback onToggle;

  const PumpControl({
    required this.isOn,
    required this.onToggle,
  });

  @override
  _PumpControlState createState() => _PumpControlState();
}

class _PumpControlState extends State<PumpControl> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant PumpControl oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isOn) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: widget.onToggle,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: widget.isOn ? Colors.indigo : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.water_drop,
                  size: 100.0,
                  color: widget.isOn ? Colors.white : Colors.indigo,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Garden Pump',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 10),
                Switch(
                  value: widget.isOn,
                  onChanged: (value) {
                    widget.onToggle();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
