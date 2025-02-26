import 'package:buyer_centric_app_v2/screens/car%20details/utils/buyer_details_section.dart';
import 'package:buyer_centric_app_v2/screens/car%20details/utils/detail_section.dart';
import 'package:buyer_centric_app_v2/screens/car%20details/utils/feature_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/widgets/custom_app_bar.dart';
import 'package:buyer_centric_app_v2/widgets/custom_drawer.dart';

//* Car Details Screen POV of Buyer and Seller
//* The buyer can see the details of the car and the bids placed on the car
class CarDetailsScreen extends StatelessWidget {
  final String image;
  const CarDetailsScreen({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBackButton(context),
              _buildCarImage(),
              _buildCarAndBidDetails(context),

              //* Sections
              const DetailSection(), //* Details Section
              FeatureSection(), //* Features Section
              const BuyerDetailsSection(), //* Buyer Details Section
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios, color: AppColor.black),
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
    );
  }

  Widget _buildCarImage() {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      decoration: const BoxDecoration(color: Colors.white),
      child: Hero(
        tag: 'car-image',
        child: Image.asset(
          image,
          width: 250,
        ),
      ),
    );
  }

  Widget _buildCarAndBidDetails(BuildContext context) {
    return Container(
      color: AppColor.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BMW 5 Series',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColor.white,
                      ),
                ),
                Text(
                  'Range',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColor.white,
                      ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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
          const Divider(color: AppColor.grey, thickness: 1.3),
          _buildBidRow('Current Bid', 'Place Bid'),
          const Divider(color: AppColor.grey, thickness: 1.3),
          _buildBidderAndBid('Bidder 1', '2100000'),
          const Divider(color: AppColor.grey, thickness: 1.3),
          _buildBidderAndBid('Bidder 2', '2150000'),
          const Divider(color: AppColor.grey, thickness: 1.3),
          _buildBidderAndBid('Bidder 3', '2200000'),
          const Divider(color: AppColor.grey, thickness: 1.3),
        ],
      ),
    );
  }

  Widget _buildBidRow(String leftText, String rightText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
      child: Row(
        children: [
          Text(
            leftText,
            style: const TextStyle(
              color: AppColor.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            rightText,
            style: const TextStyle(
              color: AppColor.purple,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  //* Bidder and Bid
  Widget _buildBidderAndBid(String bidderName, String bidAmount) {
    //* Chat Button and  info button shown on buyer screen only
    final bool isBuyer = true;
    return Padding(
      padding: EdgeInsets.only(left: 15.0, right: isBuyer ? 0 : 15),
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
          Row(
            children: [
              Text(
                'PKR $bidAmount',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColor.green,
                  fontSize: 18,
                ),
              ),
              if (isBuyer) ...[
                const SizedBox(width: 10),
                IconButton.filled(
                  onPressed: () {},
                  padding: const EdgeInsets.all(0),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColor.white,
                  ),
                  icon: SvgPicture.asset(
                    'assets/svg/chat_icon.svg',
                    height: 20,
                  ),
                ),
                IconButton.filled(
                  onPressed: () {},
                  padding: const EdgeInsets.all(0),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColor.white,
                  ),
                  icon: SvgPicture.asset(
                    'assets/svg/info_icon.svg',
                    height: 25,
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
