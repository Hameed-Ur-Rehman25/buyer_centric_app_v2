import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DetailSection extends StatelessWidget {
  const DetailSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.black,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(),
          const SizedBox(height: 20),
          _buildIconRow(),
          const Divider(color: AppColor.grey, thickness: 1.3),
          ..._buildDetailRows(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Details',
      style: TextStyle(
        color: AppColor.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildIconRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _iconWithTitle(icon: Icons.calendar_today, title: '2024'),
        _iconWithTitle(icon: Icons.speed, title: '280'),
        _iconWithTitle(icon: Icons.local_gas_station_rounded, title: 'Petrol'),
        _iconWithTitle(
            title: 'Automatic', svgPath: 'assets/svg/engine_transmission.svg'),
      ],
    );
  }

  List<Widget> _buildDetailRows() {
    final details = [
      {'label': 'Engine', 'value': '2200cc'},
      {'label': 'Body Type', 'value': 'SUV'},
      {'label': 'Body Color', 'value': 'White'},
      {'label': 'Assembly', 'value': 'Local'},
    ];

    return details
        .expand((detail) => [
              _rowOfText1andText2(detail['label']!, detail['value']!),
              const Divider(color: AppColor.grey, thickness: 1.3),
            ])
        .toList();
  }

  Row _rowOfText1andText2(final String text1, final String text2) {
    final bool flag = text1.contains(
        'Body Type'); // check body type is SUV or not if yes text color set to purple

    return Row(
      children: [
        const SizedBox(width: 10),
        Text(text1,
            style: const TextStyle(color: AppColor.white, fontSize: 15)),
        const Spacer(),
        Text(text2,
            style: TextStyle(
                color: flag ? AppColor.purple : AppColor.white, fontSize: 15)),
        const SizedBox(width: 10),
      ],
    );
  }

  Column _iconWithTitle(
      {IconData? icon, required String title, String? svgPath}) {
    return Column(
      children: [
        if (icon != null)
          Icon(icon, color: AppColor.grey)
        else if (svgPath != null)
          SvgPicture.asset(
            svgPath,
            width: 26,
            height: 26,
            colorFilter: const ColorFilter.mode(AppColor.grey, BlendMode.srcIn),
          ),
        const SizedBox(height: 5),
        Text(title, style: const TextStyle(color: AppColor.purple)),
      ],
    );
  }
}
