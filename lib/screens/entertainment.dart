import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:fikraa/screens/home_screen.dart';// Ajuster le chemin
import 'package:fikraa/screens/data_screen.dart';
import 'package:fikraa/screens/app_colors.dart';


class GasControlPage extends StatefulWidget {
  const GasControlPage({Key? key}) : super(key: key);

  @override
  _GasControlPageState createState() => _GasControlPageState();
}

class _GasControlPageState extends State<GasControlPage> {
  bool isGasControlOn = false;
  double currentGasLevel = 5.0;
  String notificationMessage = '';

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  late StreamSubscription _gasLevelSubscription;
  late StreamSubscription _gasControlSubscription;

  @override
  void initState() {
    super.initState();
    _listenForGasLevelAndControlState();
  }

  @override
  void dispose() {
    _gasLevelSubscription.cancel();
    _gasControlSubscription.cancel();
    super.dispose();
  }

  void _listenForGasLevelAndControlState() {
    _gasLevelSubscription = _database.child('gas/level').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && mounted) {
        setState(() {
          currentGasLevel = (data as num).toDouble();
          _checkGasLevels();
        });
      }
    });

    _gasControlSubscription = _database.child('gasControl/isOn').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && mounted) {
        setState(() {
          isGasControlOn = data as bool;
        });
      }
    });
  }

  void _checkGasLevels() {
    if (currentGasLevel > 9) {
      if (currentGasLevel >= 10 && currentGasLevel <= 70) {
        notificationMessage = 'Symptômes légers possibles : maux de tête légers';
      } else if (currentGasLevel > 70 && currentGasLevel <= 150) {
        notificationMessage = 'Danger : maux de tête sévères et nausées possibles';
      } else if (currentGasLevel > 150) {
        notificationMessage = 'Urgence : Risque de perte de conscience';
      }
      setState(() {
        isGasControlOn = true;
      });
    } else {
      setState(() {
        notificationMessage = '';
      });
    }
  }

  Future<void> _updateGasControlState(bool isOn) async {
    await _database.child('gasControl').set({'isOn': isOn});
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
                              value: currentGasLevel / 400,
                              strokeWidth: 14,
                              color: Colors.indigo,
                              backgroundColor: Colors.indigo.shade100,
                            ),
                          ),
                          Text(
                            '${currentGasLevel.toStringAsFixed(1)} ppm',
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
                        'GAS LEVEL',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                          fontSize: 25,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    if (notificationMessage.isNotEmpty)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(top: 20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade300, width: 2),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.gas_meter,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Notifications',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        notificationMessage = '';
                                      });
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Gas Detection Alert: $notificationMessage',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
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
