/*
 * ! IMPORTANT: Detailed view of individual car listings
 * 
 * * Key Features:
 * * - Complete car information display
 * * - Image gallery
 * * - Specifications
 * * - Contact seller options
 * * - Price information
  * * - Bid functionality for buyers
 */

import 'package:buyer_centric_app_v2/screens/car%20details/utils/buyer_details_section.dart';
import 'package:buyer_centric_app_v2/screens/car%20details/utils/detail_section.dart';
import 'package:buyer_centric_app_v2/screens/car%20details/utils/feature_section.dart';
import 'package:buyer_centric_app_v2/services/auth_service.dart';
import 'package:buyer_centric_app_v2/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/widgets/custom_app_bar.dart';
import 'package:buyer_centric_app_v2/widgets/custom_drawer.dart';
import 'package:provider/provider.dart';
import 'package:buyer_centric_app_v2/models/car_details_model.dart';
import 'package:buyer_centric_app_v2/models/car_post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//* Car Details Screen POV of Buyer and Seller
//* The buyer can see the details of the car and the bids placed on the car
class CarDetailsScreen extends StatefulWidget {
  final String image;
  final String carName;
  final int lowRange;
  final int highRange;
  final String description;
  final int index;
  final String userId;

  const CarDetailsScreen({
    super.key,
    required this.image,
    required this.carName,
    required this.lowRange,
    required this.highRange,
    required this.description,
    required this.index,
    required this.userId,
  });

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  final TextEditingController _bidController = TextEditingController();
  bool _isLoading = false;
  List<Bid> _bids = [];

  @override
  void initState() {
    super.initState();
    _loadBids();
  }

  Future<void> _loadBids() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.index.toString())
          .get();

      if (doc.exists) {
        final offers = doc.data()?['offers'] as List<dynamic>? ?? [];
        setState(() {
          _bids = offers
              .map((offer) => Bid(
                    sellerId: offer['sellerId'],
                    carId: widget.index.toString(),
                    amount: (offer['amount'] as num).toDouble(),
                    timestamp: DateTime.parse(offer['timestamp']),
                  ))
              .toList();
        });
      }
    } catch (e) {
      CustomSnackbar.showError(context, 'Error loading bids: $e');
    }
  }

  Future<void> _showBidDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.black,
        title: Text(
          'Place Bid',
          style: TextStyle(
            color: AppColor.white,
            fontFamily: GoogleFonts.poppins().fontFamily,
          ),
        ),
        content: TextField(
          controller: _bidController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColor.white),
          decoration: InputDecoration(
            hintText: 'Enter bid amount',
            hintStyle: TextStyle(color: AppColor.white.withOpacity(0.5)),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColor.white),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColor.green),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColor.white,
                fontFamily: GoogleFonts.poppins().fontFamily,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (_bidController.text.isEmpty) {
                CustomSnackbar.showError(context, 'Please enter a bid amount');
                return;
              }

              final bidAmount = double.tryParse(_bidController.text);
              if (bidAmount == null) {
                CustomSnackbar.showError(
                    context, 'Please enter a valid amount');
                return;
              }

              if (bidAmount < widget.lowRange || bidAmount > widget.highRange) {
                CustomSnackbar.showError(
                  context,
                  'Bid must be between PKR ${widget.lowRange} and PKR ${widget.highRange}',
                );
                return;
              }

              setState(() => _isLoading = true);
              try {
                final user = Provider.of<AuthService>(context, listen: false)
                    .currentUser;
                if (user == null) {
                  throw Exception('User must be logged in to place a bid');
                }

                // Create the offer object
                final offer = {
                  'sellerId': user.uid,
                  'amount': bidAmount,
                  'timestamp': DateTime.now().toIso8601String(),
                };

                // Update the post document with the new offer
                await FirebaseFirestore.instance
                    .collection('posts')
                    .doc(widget.index.toString())
                    .update({
                  'offers': FieldValue.arrayUnion([offer])
                });

                _bidController.clear();
                Navigator.pop(context);
                CustomSnackbar.showSuccess(context, 'Bid placed successfully!');
                _loadBids(); // You might want to update this method to load offers instead
              } catch (e) {
                CustomSnackbar.showError(context, 'Error placing bid: $e');
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: Text(
              'Submit',
              style: TextStyle(
                color: AppColor.green,
                fontFamily: GoogleFonts.poppins().fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
    final isBuyer =
        currentUser?.uid != widget.userId; // Determine if the user is a buyer

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
    return Hero(
      tag: 'car-image-${widget.carName}-${widget.index}-${widget.userId}',
      child: Image.network(
        widget.image,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildCarAndBidDetails(BuildContext context) {
    final currentUser =
        Provider.of<AuthService>(context, listen: false).currentUser;
    final isPostOwner = currentUser?.uid == widget.userId;

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
          _buildBidRow(
            'Current Bid',
            isPostOwner ? 'Your Post' : 'Place Bid',
            onPlaceBid: isPostOwner ? null : _showBidDialog,
          ),
          const Divider(color: AppColor.grey, thickness: 1.3),
          if (_bids.isEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
              child: Text(
                isPostOwner
                    ? 'Waiting for bids...'
                    // : 'Be the First to place bid', //!error
                    : '''Error: type "Context' is not a subtype of type "BuildContext' in type cast''',
                style: TextStyle(
                  color: AppColor.white.withOpacity(0.7),
                  fontSize: 16,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              ),
            )
          else
            ..._bids.map((bid) => Column(
                  children: [
                    _buildBidderAndBid('Bidder ${_bids.indexOf(bid) + 1}',
                        bid.amount.toStringAsFixed(0)),
                    const Divider(color: AppColor.grey, thickness: 1.3),
                  ],
                )),
        ],
      ),
    );
  }

  Widget _buildBidRow(String leftText, String rightText,
      {VoidCallback? onPlaceBid}) {
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
          if (onPlaceBid !=
              null) // Only show as clickable if onPlaceBid is provided
            GestureDetector(
              onTap: onPlaceBid,
              child: Text(
                rightText,
                style: const TextStyle(
                  color: AppColor.purple,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            Text(
              // Non-clickable text for post owner
              rightText,
              style: TextStyle(
                color: AppColor.grey.withOpacity(0.7),
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBidderAndBid(String bidderName, String bidAmount) {
    // Get current user from AuthService
    final currentUser =
        Provider.of<AuthService>(context, listen: false).currentUser;

    // Check if current user is the post creator
    final isPostCreator = currentUser?.uid == widget.userId;

    return Padding(
      padding: EdgeInsets.only(left: 15.0, right: isPostCreator ? 0 : 15),
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
              // Show icons only if the current user is the post creator
              if (isPostCreator) ...[
                const SizedBox(width: 10),
                IconButton.filled(
                  onPressed: () {
                    // Add chat functionality
                  },
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
                  onPressed: () {
                    // Add info functionality
                  },
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

  //Todo: Implement
  // // * Builds the main image carousel
  // Widget _buildImageCarousel() {
  //   // ... implementation
  // }

  // // * Builds car specifications section
  // Widget _buildSpecifications() {
  //   // ... implementation
  // }

  // // * Builds seller information section
  // Widget _buildSellerInfo() {
  //   // ... implementation
  // }

  // // ! Critical: Handles contacting the seller
  // void _contactSeller() {
  //   // ... implementation
  // }
}
