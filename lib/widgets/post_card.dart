import 'package:buyer_centric_app_v2/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/widgets/car_selection_bottom_sheet.dart';
import 'package:buyer_centric_app_v2/widgets/car_part_selection_bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:buyer_centric_app_v2/utils/image_utils.dart';
import 'dart:math';

// PostCard widget to display car details
class PostCard extends StatefulWidget {
  final String carName;
  final int lowRange;
  final int highRange;
  final String image;
  final String description;
  final String index;
  final int animationIndex;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isSeller;
  final bool isBuyer;
  final String? userId;
  final List<String>? imageUrls;
  final String? category;

  const PostCard({
    super.key,
    required this.carName,
    required this.lowRange,
    required this.highRange,
    required this.image,
    required this.description,
    required this.index,
    this.animationIndex = 0,
    this.onTap,
    this.onDelete,
    this.isSeller = false,
    this.isBuyer = false,
    this.userId,
    this.imageUrls,
    this.category,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    Future.delayed(Duration(milliseconds: widget.animationIndex * 200), () {
      if (mounted) {
        _controller.forward();
      }
    });
    
    // Add listener to update current page
    _pageController.addListener(() {
      if (_pageController.page != null && mounted) {
        final page = _pageController.page!.round();
        if (_currentPage != page) {
          setState(() {
            _currentPage = page;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: () => _navigateToCarDetails(context),
          child: Card(
            margin: EdgeInsets.symmetric(
                horizontal: size.width * 0.07, vertical: 10),
            color: AppColor.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            child: Column(
              children: [
                _buildHeader(context),
                _buildCarImage(context),
                _buildCarDetails(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 20),
          decoration: const BoxDecoration(
            color: AppColor.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          child: const Text(
            'FEATURED',
            style: TextStyle(
              color: AppColor.white,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: InkWell(
            onTap: () => _navigateToCarDetails(context),
            child: SvgPicture.asset(
              'assets/svg/info_icon.svg',
              height: 29,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarImage(BuildContext context) {
    // Get all available images using the getImagesList method
    final List<String> images = getImagesList();
    
    if (images.isEmpty) {
      return _buildImageErrorWidget();
    }
    
    if (images.length <= 1) {
      // Single image implementation
      return InkWell(
        onTap: () => _navigateToCarDetails(context),
        child: Hero(
          tag: 'car-image-${widget.carName}-${widget.index}',
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
            child: _loadCarImage(images[0]),
          ),
        ),
      );
    } else {
      // Multi-image carousel implementation
      return InkWell(
        onTap: () => _navigateToCarDetails(context),
        child: Stack(
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Hero(
                      tag: 'car-image-${widget.carName}-${widget.index}-$index',
                      child: _loadCarImage(images[index]),
                    );
                  },
                ),
              ),
            ),
            
            // Image counter indicator
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.photo_library,
                      color: AppColor.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_currentPage + 1}/${images.length}',
                      style: const TextStyle(
                        color: AppColor.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Navigation buttons for the carousel
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left arrow
                  if (_currentPage > 0)
                    GestureDetector(
                      onTap: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 40),
                    
                  // Right arrow
                  if (_currentPage < images.length - 1)
                    GestureDetector(
                      onTap: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 40),
                ],
              ),
            ),
            
            // Dot indicators
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? AppColor.buttonGreen
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _loadCarImage(String imageUrl) {
    // Check if it's a network image or local asset
    if (ImageUtils.isValidImageUrl(imageUrl)) {
      // Network image
      return Container(
        width: double.infinity,
        height: 180,
        child: ImageUtils.loadNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          errorWidget: _buildImageErrorWidget(),
          loadingWidget: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColor.buttonGreen,
                ),
                const SizedBox(height: 12),
                Text(
                  'Loading image...',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Handle as asset image
      String fixedPath = imageUrl;
      // Ensure path starts with 'assets/'
      if (!fixedPath.startsWith('assets/')) {
        fixedPath = 'assets/$fixedPath';
      }
      
      // Handle the file:// prefix if present
      if (fixedPath.startsWith('file:///assets/')) {
        fixedPath = fixedPath.replaceAll('file:///', '');
      }
      
      return Container(
        width: double.infinity,
        height: 180,
        child: ImageUtils.loadAssetImage(
          imagePath: fixedPath,
          fit: BoxFit.cover,
          errorWidget: _buildImageErrorWidget(),
        ),
      );
    }
  }
  
  Widget _buildImageErrorWidget() {
    // Determine whether this is a car part post by checking if the carName contains a recognizable car part term
    bool isCarPart = false;
    final lowerCarName = widget.carName.toLowerCase();
    
    // Check for common part words in the name
    const List<String> partKeywords = [
      'engine', 'brake', 'transmission', 'wheel', 'tire', 
      'battery', 'bumper', 'hood', 'door', 'mirror', 
      'light', 'suspension', 'part', 'interior', 'exterior'
    ];
    
    for (final keyword in partKeywords) {
      if (lowerCarName.contains(keyword)) {
        isCarPart = true;
        break;
      }
    }
    
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isCarPart ? Icons.build_outlined : Icons.directions_car_outlined,
            size: 50,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            isCarPart ? 'Car part image not available' : 'Car image not available',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarDetails(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColor.black,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCarNameAndRange(context),
            const SizedBox(height: 8),
            _buildActionButtons(),
            _buildDescription(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCarNameAndRange(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: widget.carName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColor.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                TextSpan(
                  text: '\nRange',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600, color: AppColor.white),
                ),
                TextSpan(
                  text: '   PKR ${widget.lowRange} - ${widget.highRange}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColor.green,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
        if (widget.onDelete != null)
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: widget.onDelete,
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isPostOwner = currentUser?.uid == widget.userId;

    return Row(
      children: [
        MaterialButton(
          onPressed: isPostOwner
              ? null
              : () {
                  _showCarSelectionBottomSheet(context);
                },
          color: AppColor.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(
              color: AppColor.white,
              width: 2,
            ),
          ),
          child: Text(
            isPostOwner ? 'Your Post' : 'Place Bid',
            style: TextStyle(
              color: isPostOwner ? AppColor.white : AppColor.black,
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
        ),
        const SizedBox(width: 10),
        MaterialButton(
          onPressed: () => _navigateToCarDetails(context),
          color: AppColor.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'View Bids',
            style: TextStyle(
              color: AppColor.black,
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Description  ',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColor.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          TextSpan(
            text: '(Buyer comments)\n',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColor.white.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
          ),
          TextSpan(
            text: widget.description.length > 90
                ? '${widget.description.substring(0, 90)}... '
                : widget.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColor.white,
                  fontWeight: FontWeight.w400,
                ),
          ),
          if (widget.description.length > 100)
            TextSpan(
              text: 'see more',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColor.white,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
            ),
        ],
      ),
    );
  }

  void _navigateToCarDetails(BuildContext context) {
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      _navigateToInfo();
    }
  }

  void _navigateToInfo() {
    print('DEBUG - Navigating to car details with imageUrls: ${widget.imageUrls?.length ?? 0} images');
    Navigator.pushNamed(context, AppRoutes.carDetails, arguments: {
      'image': widget.image,
      'carName': widget.carName,
      'lowRange': widget.lowRange,
      'highRange': widget.highRange,
      'description': widget.description,
      'index': widget.index,
      'userId': widget.userId ?? '',
      'category': widget.category ?? 'car',
      'imageUrls': widget.imageUrls != null && widget.imageUrls!.isNotEmpty
          ? List<String>.from(widget.imageUrls!
              .map((url) => url)
              .where((url) => url.isNotEmpty == true))
          : null,
    });
  }

  void _navigateToChat() {
    Navigator.pushNamed(
      context,
      AppRoutes.chat,
      arguments: {
        'postId': widget.index,
        'carName': widget.carName,
      },
    );
  }

  Widget _buildBidOptions() {
    return Row(children: [
      if (widget.isSeller) ...[
        ElevatedButton.icon(
            onPressed: () => _showCarSelectionBottomSheet(context),
            icon: const Icon(Icons.attach_money),
            label: const Text('Place Bid')),
      ],
      if (widget.isBuyer) ...[
        IconButton(
            onPressed: () => _navigateToInfo(), icon: const Icon(Icons.info)),
        IconButton(
            onPressed: () => _navigateToChat(), icon: const Icon(Icons.chat)),
      ]
    ]);
  }

  void _showCarSelectionBottomSheet(BuildContext context) {
    // Check if post is car part or car to show appropriate bottom sheet
    final String postCategory = widget.category ?? 'car';
    
    if (postCategory == 'car_part') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => CarPartSelectionBottomSheet(
          onPartSelected: (selectedPartId, selectedPartName) {
            Navigator.pop(context);
            _showBidAmountDialog(context, selectedPartId, selectedPartName, isCarPart: true);
          },
        ),
      );
    } else {
      // Default to car selection
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => CarSelectionBottomSheet(
          onCarSelected: (selectedCarId, selectedCarName) {
            Navigator.pop(context);
            _showBidAmountDialog(context, selectedCarId, selectedCarName);
          },
        ),
      );
    }
  }

  void _showBidAmountDialog(
      BuildContext context, String itemId, String itemName, {bool isCarPart = false}) {
    TextEditingController bidAmountController = TextEditingController();
    bool isSubmitting = false;

    // Fetch the item's price from inventory based on item type
    FirebaseFirestore.instance
        .collection(isCarPart ? 'inventoryCarParts' : 'inventoryCars')
        .doc(itemId)
        .get()
        .then((doc) {
      if (doc.exists) {
        final price = doc.data()?['price'] as double?;
        if (price != null) {
          bidAmountController.text = price.toString();
        }
      }
    });

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: AppColor.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Place Bid for $itemName',
            style: TextStyle(
              color: AppColor.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: bidAmountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColor.white),
                  decoration: InputDecoration(
                    hintText: 'Enter bid amount',
                    hintStyle:
                        TextStyle(color: AppColor.white.withOpacity(0.5)),
                    prefixText: 'PKR ',
                    prefixStyle: const TextStyle(color: AppColor.green),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColor.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColor.green),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColor.black.withOpacity(0.1),
                  ),
                ),
                if (isSubmitting) ...[
                  const SizedBox(height: 16),
                  const Center(
                    child: CircularProgressIndicator(
                      color: AppColor.green,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColor.white,
                  fontSize: 16,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              ),
            ),
            TextButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final bidAmount =
                          double.tryParse(bidAmountController.text);
                      if (bidAmount != null && bidAmount > 0) {
                        setState(() {
                          isSubmitting = true;
                        });

                        try {
                          await _placeBid(itemId, bidAmount);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Bid placed successfully for $itemName',
                                  style: TextStyle(
                                    color: AppColor.white,
                                    fontFamily:
                                        GoogleFonts.poppins().fontFamily,
                                  ),
                                ),
                                backgroundColor: AppColor.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          setState(() {
                            isSubmitting = false;
                          });
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to place bid: ${e.toString()}',
                                  style: TextStyle(
                                    color: AppColor.white,
                                    fontFamily:
                                        GoogleFonts.poppins().fontFamily,
                                  ),
                                ),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please enter a valid amount',
                              style: TextStyle(
                                color: AppColor.white,
                                fontFamily: GoogleFonts.poppins().fontFamily,
                              ),
                            ),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    },
              child: Text(
                'Submit',
                style: TextStyle(
                  color: AppColor.green,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _placeBid(String itemId, double amount) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;

    final String? userId = auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Determine item type by checking collection
    final bool isCarPart = await firestore
        .collection('inventoryCarParts')
        .doc(itemId)
        .get()
        .then((doc) => doc.exists);

    // Create bid data
    final Map<String, dynamic> bidData = {
      'sellerId': userId,
      'itemId': itemId,
      'itemType': isCarPart ? 'car_part' : 'car',
      'amount': amount,
      'timestamp': FieldValue.serverTimestamp(),
      'postId': widget.index,
      'buyerId': widget.userId,
      'carName': widget.carName,
      'status': 'pending',
    };

    try {
      // Add bid to the 'bids' collection
      final bidRef = await firestore.collection('bids').add(bidData);
      print('Bid added with ID: ${bidRef.id}');

      // Use the correct document ID
      String postId = widget.index;
      print('Updating post with ID: $postId');

      // Update the post document to include only the bid reference in offers array
      await firestore.collection('posts').doc(postId).update({
        'offers': FieldValue.arrayUnion([bidRef.id])
      });
      print('Offer added to post: $postId');
    } catch (e) {
      print('Error placing bid: $e');
    }
  }

  // Method to get a filtered list of all available images
  List<String> getImagesList() {
    List<String> images = [];
    
    print('PostCard: Getting images for ${widget.carName}');
    
    // First try to get images from imageUrls array (if available)
    if (widget.imageUrls != null && widget.imageUrls!.isNotEmpty) {
      print('PostCard: Found ${widget.imageUrls!.length} images in imageUrls');
      // Add all valid URLs from imageUrls
      for (String url in widget.imageUrls!) {
        if (url.isNotEmpty == true && ImageUtils.isValidImageUrl(url)) {
          print('PostCard: Adding valid image URL: ${url.substring(0, min(50, url.length))}...');
          images.add(url);
        } else {
          print('PostCard: Skipping invalid image URL: ${url.isEmpty ? "empty" : url.substring(0, min(50, url.length))}...');
        }
      }
    } else {
      print('PostCard: No imageUrls available');
    }
    
    // If no valid images in imageUrls, add the main image as fallback
    if (images.isEmpty && widget.image.isNotEmpty == true) {
      print('PostCard: Using main image as fallback');
      images.add(widget.image);
    }
    
    print('PostCard: Total valid images: ${images.length}');
    
    // If still no images, return an empty list (will show placeholder)
    return images;
  }
}

