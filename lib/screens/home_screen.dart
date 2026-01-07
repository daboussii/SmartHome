import 'package:fikraa/screens/user_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:fikraa/screens/energy.dart';
import 'package:fikraa/screens/entertainment.dart';
import 'package:fikraa/screens/temperature.dart';
import 'package:fikraa/screens/water.dart';
import 'package:fikraa/widgets/weather_card.dart'; 
import 'package:fikraa/screens/data_screen.dart';
import 'package:fikraa/screens/entertainment.dart'; // Ensure this is correct

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade50,
        title: const Text('Hi Mariem'),
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
                case 'user':
                Navigator.push(
           context,
           MaterialPageRoute(
          builder: (context) => UserManagementScreen(userEmail: 'example@example.com'),
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
                  value: 'user',
                  child: Row(
                    children: [
                      const Icon(Icons.person_add, color: Colors.indigo),
                      const SizedBox(width: 8),
                      const Text('User Management'),
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
                      child: WeatherCard(),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Smart Home',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    const Text(
                      'SERVICES',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _cardMenu(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EnergyPage(),
                              ),
                            );
                          },
                          icon: 'images/energy.png',
                          title: 'LIGHT',
                        ),
                        _cardMenu(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TemperaturePage(),
                              ),
                            );
                          },
                          icon: 'images/temperature.png',
                          title: 'CLIMATE',
                          color: Colors.indigoAccent,
                          fontColor: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _cardMenu(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WaterPage(),
                              ),
                            );
                          },
                          icon: 'images/water.png',
                          title: 'Water',
                        ),
                        _cardMenu(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GasControlPage(),
                              ),
                            );
                          },
                          icon: 'images/security.png',
                          title: 'Gas',
                          width: 130, // Adjust the size here
                          height: 50, // Adjust the size here
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardMenu({
    required String title,
    required String icon,
    VoidCallback? onTap,
    Color color = Colors.white,
    Color fontColor = Colors.grey,
    double width = 80, // Default width
    double height = 50, // Default height
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 36),
        width: 156,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Image.asset(
              icon,
              width: width,
              height: height,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, color: fontColor),
            ),
          ],
        ),
      ),
    );
  }
}
