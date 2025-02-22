import 'package:buyer_centric_app_v2/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/widgets/custom_app_bar.dart';

class CarDetailsScreen extends StatelessWidget {
  final String image;
  const CarDetailsScreen({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
      body: InkWell(
        onTap: () {
          //* Unfocus the text field when tapped outside
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //* Back button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: AppColor.black,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Car Details',
                      style: TextStyle(
                        color: AppColor.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              //* Image
              Container(
                width: double.infinity,
                height: 200,
                padding: const EdgeInsets.symmetric(horizontal: 25),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Hero(
                  tag: 'car-image',
                  child: Image.asset(
                    image,
                    // height: 100,
                    width: 250,
                    // fit: BoxFit.cover,
                  ),
                ),
              ),

              //* Details
              Container(
                color: AppColor.black,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15.0,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BMW 5 Series',
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(
                                  color: AppColor.white,
                                  // fontWeight: FontWeight.w900,
                                ),
                          ),
                          Text('Range',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: AppColor.white,
                                    // fontWeight: FontWeight.w600,
                                  )),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColor.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'PKR 2000000 - 2300000',
                              style: TextStyle(
                                color: AppColor.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                fontFamily: GoogleFonts.poppins().fontFamily,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      color: AppColor.grey,
                      thickness: 1.3,
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
                      child: Row(
                        children: [
                          Text(
                            'Current Bid',
                            style: TextStyle(
                              color: AppColor.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          Text(
                            'Place Bid',
                            style: TextStyle(
                              color: AppColor.purple,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      color: AppColor.grey,
                      thickness: 1.3,
                    ),
                    _biddersAndBid('Bidder 1', '2100000'),
                    const Divider(
                      color: AppColor.grey,
                      thickness: 1.3,
                    ),
                    _biddersAndBid('Bidder 2', '2150000'),
                    const Divider(
                      color: AppColor.grey,
                      thickness: 1.3,
                    ),
                    _biddersAndBid('Bidder 3', '2200000'),
                    const Divider(
                      color: AppColor.grey,
                      thickness: 1.3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding _biddersAndBid(String bidderName, String bidAmount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        children: [
          Text(
            bidderName,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColor.white,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          Text(
            'PKR $bidAmount',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColor.green,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
