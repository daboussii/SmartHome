import 'package:fikraa/screens/data_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fikraa/screens/app_colors.dart';
import 'package:fikraa/widgets/lighting_control.dart'; 
import 'package:fikraa/screens/home_screen.dart';// Ajuster le chemin

class EnergyPage extends StatefulWidget {
  const EnergyPage({Key? key}) : super(key: key);

  @override
  _EnergyPageState createState() => _EnergyPageState();
}

class _EnergyPageState extends State<EnergyPage> {
  double energyUsage = 0.0;
  late DatabaseReference _energyRef;

  @override
  void initState() {
    super.initState();
    // Initialisation de la référence Firebase pour energyUsage
    _energyRef = FirebaseDatabase.instance.ref('energy/energyUsage');
    
    // Écoute des changements dans la valeur energyUsage dans Firebase
    _energyRef.onValue.listen((event) {
      final double usage = (event.snapshot.value as num?)?.toDouble() ?? 0.0;
      setState(() {
        energyUsage = usage;
      });
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
                      builder: (context) => DataScreen(),
                    ),
                  );
                  // Action pour afficher les données
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
                              value: energyUsage / 100, // Update based on Firebase value
                              strokeWidth: 14,
                              color: Colors.indigo,
                              backgroundColor: Colors.indigo.shade100,
                            ),
                          ),
                          Text(
                            '${energyUsage.toStringAsFixed(1)}%', // Display the energy usage percentage
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        'ENERGY USAGE',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _roundedButton(title: 'LIGHTING', isActive: true),
                        _roundedButton(title: 'DARKNESS'),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // First row of LightingControl widgets
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(8),
                            child: LightingControl(roomName: 'BedRoom'),
                          ),
                        ),
                        SizedBox(width: 13),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(8),
                            child: LightingControl(roomName: 'Kitchen'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Second row of smaller LightingControl widgets
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            constraints: BoxConstraints(
                              maxHeight: 180, // Adjusted to fit new size
                            ),
                            padding: EdgeInsets.all(8),
                            child: LightingControl(roomName: 'Living Room'),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            constraints: BoxConstraints(
                              maxHeight: 180, // Adjusted to fit new size
                            ),
                            padding: EdgeInsets.all(8),
                            child: LightingControl(roomName: 'Bathroom'),
                          ),
                        ),
                      ],
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
        color: isActive ? Colors.indigo : const Color.fromARGB(0, 202, 16, 16),
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


