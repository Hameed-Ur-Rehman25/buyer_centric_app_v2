import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'part_list_item.dart';

class AvailablePartsList extends StatelessWidget {
  final Stream<QuerySnapshot> query;
  final Function(Map<String, dynamic>) onTapPart;

  const AvailablePartsList({
    Key? key,
    required this.query,
    required this.onTapPart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: query,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Something went wrong: ${snapshot.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No parts available',
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final part = doc.data() as Map<String, dynamic>;
            return PartListItem(
              part: part,
              onTap: () => onTapPart(part),
            );
          },
        );
      },
    );
  }
}
