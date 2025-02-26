import 'package:flutter/material.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';

class FeatureSection extends StatelessWidget {
  final List<Map<String, dynamic>> features = [
    {'icon': Icons.ac_unit, 'text': 'Air Conditioning'},
    {'icon': Icons.wifi, 'text': 'WiFi'},
    {'icon': Icons.bluetooth, 'text': 'Bluetooth'},
    {'icon': Icons.local_parking, 'text': 'Parking Sensors'},
    {'icon': Icons.directions_car, 'text': 'Cruise Control'},
    {'icon': Icons.music_note, 'text': 'Music System'},
    {'icon': Icons.security, 'text': 'Anti-theft System'},
    {'icon': Icons.airline_seat_recline_extra, 'text': 'Reclining Seats'},
    {'icon': Icons.gps_fixed, 'text': 'GPS Navigation'},
    {'icon': Icons.camera_alt, 'text': 'Rear Camera'},
    {'icon': Icons.healing, 'text': 'First Aid Kit'},
    {'icon': Icons.directions_car, 'text': 'Cruise Control'},
    {'icon': Icons.music_note, 'text': 'Music System'},
    {'icon': Icons.child_care, 'text': 'Child Seat'},
  ];

  FeatureSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.black,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(),
          const SizedBox(
            height: 10,
          ),
          ..._buildFeatureRows(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Features',
      style: TextStyle(
        color: AppColor.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  List<Widget> _buildFeatureRows() {
    List<Widget> rows = [];
    for (int i = 0; i < features.length; i += 2) {
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(features[i]['icon'],
                      color: AppColor.white.withOpacity(0.6)),
                  const SizedBox(width: 8),
                  Text(features[i]['text'],
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
            if (i + 1 < features.length)
              Expanded(
                child: Row(
                  children: [
                    Icon(features[i + 1]['icon'],
                        color: AppColor.white.withOpacity(0.6)),
                    const SizedBox(width: 8),
                    Text(features[i + 1]['text'],
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
          ],
        ),
      );
    }
    return rows;
  }
}
