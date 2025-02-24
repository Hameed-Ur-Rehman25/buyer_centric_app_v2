import 'package:buyer_centric_app_v2/utils/car_search_card.dart';
import 'package:flutter/material.dart';

class BuyCarScreen extends StatelessWidget {
  const BuyCarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        //* Unfocus the text field when tapped outside
        FocusScope.of(context).unfocus();
      },
      child: const SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: CarSearchCard(),
            ),
          ],
        ),
      ),
    );
  }
}
