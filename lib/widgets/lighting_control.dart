import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fikraa/screens/app_colors.dart';

class LightingControl extends StatefulWidget {
  final String roomName;

  LightingControl({required this.roomName});

  @override
  _LightingControlState createState() => _LightingControlState();
}

class _LightingControlState extends State<LightingControl> {
  bool isSwitched = false;
  late DatabaseReference _lightRef;

  @override
  void initState() {
    super.initState();
    // Initialize Firebase database reference
    _lightRef = FirebaseDatabase.instance.ref('lights/${widget.roomName}');
    _lightRef.onValue.listen((event) {
      final bool status = event.snapshot.value as bool? ?? false;
      setState(() {
        isSwitched = status;
      });
    });
  }

  void _toggleSwitch(bool value) {
    setState(() {
      isSwitched = value;
      // Update the state in Firebase
      _lightRef.set(isSwitched);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSwitched ? Colors.indigo : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.lightbulb, color: isSwitched ? Colors.white : AppColors.accent, size: 30),
              Icon(Icons.star, color: isSwitched ? Colors.white : AppColors.white, size: 20),
            ],
          ),
          SizedBox(height: 8),
          Text(
            widget.roomName,
            style: TextStyle(
              color: isSwitched ? Colors.white : Color.fromARGB(255, 16, 12, 12),
              fontSize: 18,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isSwitched ? 'On' : 'Off',
                style: TextStyle(
                  color: isSwitched ? Colors.white : Colors.black87,
                  fontSize: 18,
                ),
              ),
              Switch(
                value: isSwitched,
                onChanged: _toggleSwitch,
                activeColor: AppColors.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
