import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BuyerDetailsSection extends StatelessWidget {
  const BuyerDetailsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.black,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(),
          const SizedBox(height: 30),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.white,
              ),
              padding: const EdgeInsets.all(10.0),
              child: SvgPicture.asset(
                'assets/svg/chat_icon.svg',
                height: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        const Text(
          'Buyer Details',
          style: TextStyle(
            color: AppColor.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: () {
            //TODO: Implement view all button
          },
          child: const Text(
            'View buyer profile',
            style: TextStyle(
              color: AppColor.purple,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }
}
