import 'package:buyer_centric_app_v2/models/car_post_model.dart';
import 'package:buyer_centric_app_v2/providers/post_provider.dart';
import 'package:buyer_centric_app_v2/screens/car%20details/utils/buyer_details_section.dart';
import 'package:buyer_centric_app_v2/screens/car%20details/utils/detail_section.dart';
import 'package:buyer_centric_app_v2/screens/car%20details/utils/feature_section.dart';
import 'package:buyer_centric_app_v2/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/widgets/custom_app_bar.dart';
import 'package:buyer_centric_app_v2/widgets/custom_drawer.dart';
import 'package:provider/provider.dart';
import 'package:buyer_centric_app_v2/models/car_details_model.dart';

//* Car Details Screen POV of Buyer and Seller
//* The buyer can see the details of the car and the bids placed on the car
class CarDetailsScreen extends StatefulWidget {
  final String image;
  final String carName;
  final int lowRange;
  final int highRange;
  final String description;
  final int index;

  const CarDetailsScreen({
    super.key,
    required this.image,
    required this.carName,
    required this.lowRange,
    required this.highRange,
    required this.description,
    required this.index,
  });

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  final TextEditingController _bidController = TextEditingController();
  bool _isLoading = false;

  Future<CarDetails> _getSellerCarDetails(String sellerId) async {
    // Implement the logic to fetch seller's car details from Firebase
    // This is a placeholder - you'll need to implement the actual Firebase fetch
    throw UnimplementedError('Implement Firebase fetch logic');
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;
    // Since we don't have carPost, we'll need to determine buyer status differently
    // You might want to pass this as a parameter or get it from a provider
    final isBuyer = false; // Default to false or implement your logic here

    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildBackButton(context),
              _buildCarImage(),
              _buildCarAndBidDetails(context),

              //* Sections
              const DetailSection(), //* Details Section
              FeatureSection(), //* Features Section
              const BuyerDetailsSection(), //* Buyer Details Section
              if (isBuyer) _buildBidderInfo(widget.index.toString()),
              // if (!isBuyer) _buildBidSection(),
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
          widget.image,
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
                  widget.carName,
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
                    'PKR ${widget.lowRange} - ${widget.highRange}',
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

  // Widget _buildBidSection() {
  //   return Padding(
  //     padding: const EdgeInsets.all(16.0),
  //     child: Column(
  //       children: [
  //         TextField(
  //           controller: _bidController,
  //           keyboardType: TextInputType.number,
  //           decoration: const InputDecoration(
  //             labelText: 'Your Bid Amount',
  //             border: OutlineInputBorder(),
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         if (_isLoading)
  //           const CircularProgressIndicator()
  //         else
  //           ElevatedButton(
  //             onPressed: _placeBid,
  //             child: const Text('Place Bid'),
  //           ),
  //       ],
  //     ),
  //   );
  // }

  // Future<void> _placeBid() async {
  //   if (_bidController.text.isEmpty) return;

  //   setState(() => _isLoading = true);
  //   try {
  //     final user = Provider.of<AuthService>(context, listen: false).currentUser;
  //     if (user == null) {
  //       throw Exception('User must be logged in to place a bid');
  //     }

  //     final bid = Bid(
  //       sellerId: user.uid,
  //       carId: widget.index.toString(), // Using index as carId
  //       amount: double.parse(_bidController.text),
  //       timestamp: DateTime.now(),
  //     );

  //     await Provider.of<PostProvider>(context, listen: false)
  //         .placeBid(widget.index.toString(), bid);

  //     _bidController.clear();
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Bid placed successfully!')),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error placing bid: $e')),
  //     );
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  Widget _buildBidderInfo(String carId) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Seller Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColor.white,
                  )),
          const SizedBox(height: 8),
          FutureBuilder(
              future: _getSellerCarDetails(carId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final carDetails = snapshot.data;
                  return Column(
                    children: [
                      Image.network(carDetails!.imageUrl),
                      Text(
                        carDetails.description,
                        style: TextStyle(
                          color: AppColor.white,
                          fontSize: 16,
                          fontFamily: GoogleFonts.poppins().fontFamily,
                        ),
                      ),
                    ],
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColor.white,
                  ),
                );
              })
        ],
      ),
    );
  }
}
