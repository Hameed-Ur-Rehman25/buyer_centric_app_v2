import 'package:buyer_centric_app_v2/screens/profile/utils/profile_app_bar.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ProfileAppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text('Hameed'),

          //* List view builder for the profile details
          ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Item $index'),
                subtitle: Text('Subtitle $index'),
              );
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
