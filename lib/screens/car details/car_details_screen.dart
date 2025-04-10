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

import 'package:buyer_centric_app_v2/screens/car%20details/model/custom_bid_model.dart';
import 'package:buyer_centric_app_v2/screens/car%20details/utils/detail_section.dart';
import 'package:buyer_centric_app_v2/screens/car%20details/utils/feature_section.dart';
import 'package:buyer_centric_app_v2/services/auth_service.dart';
import 'package:buyer_centric_app_v2/utils/snackbar.dart';
import 'package:buyer_centric_app_v2/widgets/car_part_selection_bottom_sheet.dart';
import 'package:buyer_centric_app_v2/widgets/car_selection_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/widgets/custom_app_bar.dart';
import 'package:buyer_centric_app_v2/widgets/custom_drawer.dart';
import 'package:provider/provider.dart';
import 'package:buyer_centric_app_v2/models/car_details_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';

//* Car Details Screen POV of Buyer and Seller
//* The buyer can see the details of the car and the bids placed on the car
class CarDetailsScreen extends StatefulWidget {
  final String image;
  final String carName;
  final int lowRange;
  final int highRange;
  final String description;
  final String index;
  final String userId;
  final List<String>? imageUrls;
  final String? category;

  const CarDetailsScreen({
    super.key,
    required this.image,
    required this.carName,
    required this.lowRange,
    required this.highRange,
    required this.description,
    required this.index,
    required this.userId,
    this.imageUrls,
    this.category,
  });

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  final TextEditingController _bidController = TextEditingController();
  bool _isLoading = false;
  List<CustomBid> _bids = [];

  // Store the image URLs
  List<String> _imageUrls = [];

  // Cache of user IDs to usernames for faster lookups
  final Map<String, String> _usernameCache = {};

  @override
  void initState() {
    super.initState();

    // Initialize _imageUrls from widget if available
    if (widget.imageUrls != null && widget.imageUrls!.isNotEmpty) {
      _imageUrls =
          List<String>.from(widget.imageUrls!.where((url) => url.isNotEmpty));
      print(
          'DEBUG - Initialized _imageUrls from widget with ${_imageUrls.length} images');
    }

    // Load bids
    _loadBids();
  }

  // Save username to Firestore for future reference
  Future<void> _saveUsernameToDB(String userId, String username) async {
    try {
      await FirebaseFirestore.instance.collection('usernames').doc(userId).set({
        'username': username,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving username: $e');
    }
  }

  Future<String> _fetchSellerName(String sellerId) async {
    // Check cache first for fast lookups
    if (_usernameCache.containsKey(sellerId)) {
      return _usernameCache[sellerId]!;
    }

    if (sellerId.isEmpty) {
      return "Unknown User";
    }

    try {
      // Try to get from username cache in Firestore first
      try {
        final usernameDoc = await FirebaseFirestore.instance
            .collection('usernames')
            .doc(sellerId)
            .get();

        if (usernameDoc.exists && usernameDoc.data() != null) {
          final cachedUsername = usernameDoc.data()!['username'] as String?;
          if (cachedUsername != null && cachedUsername.isNotEmpty) {
            // Cache it locally too
            _usernameCache[sellerId] = cachedUsername;
            return cachedUsername;
          }
        }
      } catch (e) {
        print('Error fetching cached username: $e');
      }

      // First check Firebase Auth directly for the user
      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        if (authService.currentUser?.uid == sellerId) {
          // If this is the current user, we already have their data
          final username = authService.currentUser?.username ??
              authService.currentUser?.email ??
              "User ${sellerId.substring(0, 5)}";
          // Cache the username
          _usernameCache[sellerId] = username;
          _saveUsernameToDB(sellerId, username);
          return username;
        }
      } catch (e) {
        print('Error accessing current user: $e');
      }

      // Try to get from Firestore users collection
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(sellerId)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          final userData = userDoc.data()!;

          // Try various field names for username
          String? username;

          // Try username field
          username = userData['username'] as String?;
          if (username != null && username.isNotEmpty) {
            _usernameCache[sellerId] = username;
            _saveUsernameToDB(sellerId, username);
            return username;
          }

          // Try displayName field
          final displayName = userData['displayName'] as String?;
          if (displayName != null && displayName.isNotEmpty) {
            _usernameCache[sellerId] = displayName;
            _saveUsernameToDB(sellerId, displayName);
            return displayName;
          }

          // Try name field
          final name = userData['name'] as String?;
          if (name != null && name.isNotEmpty) {
            _usernameCache[sellerId] = name;
            _saveUsernameToDB(sellerId, name);
            return name;
          }

          // Try email field
          final email = userData['email'] as String?;
          if (email != null && email.isNotEmpty) {
            final emailUsername =
                email.split('@')[0]; // Use part before @ from email
            _usernameCache[sellerId] = emailUsername;
            _saveUsernameToDB(sellerId, emailUsername);
            return emailUsername;
          }
        }
      } catch (e) {
        print('Error fetching user from Firestore: $e');
      }

      // Continue with other methods to find the username...
      String foundUsername = "";

      // Try Realtime Database users
      if (foundUsername.isEmpty) {
        try {
          final databaseRef =
              FirebaseDatabase.instance.ref().child('users').child(sellerId);
          final snapshot = await databaseRef.get();

          if (snapshot.exists) {
            final data = snapshot.value as Map<dynamic, dynamic>?;
            if (data != null) {
              final username = data['username'];
              if (username != null &&
                  username is String &&
                  username.isNotEmpty) {
                foundUsername = username;
              }
            }
          }
        } catch (e) {
          print('Error fetching from Realtime Database: $e');
        }
      }

      // Try querying authentication users
      if (foundUsername.isEmpty) {
        try {
          final authDoc = await FirebaseFirestore.instance
              .collection('authUsers')
              .where('uid', isEqualTo: sellerId)
              .limit(1)
              .get();

          if (authDoc.docs.isNotEmpty) {
            final authData = authDoc.docs.first.data();
            final username = authData['username'] as String?;
            if (username != null && username.isNotEmpty) {
              foundUsername = username;
            } else {
              final email = authData['email'] as String?;
              if (email != null && email.isNotEmpty) {
                foundUsername =
                    email.split('@')[0]; // Use part before @ from email
              }
            }
          }
        } catch (e) {
          print('Error querying auth users: $e');
        }
      }

      // Last resort - try to get the seller's inventory cars
      if (foundUsername.isEmpty) {
        try {
          final carDocs = await FirebaseFirestore.instance
              .collection('inventoryCars')
              .where('userId', isEqualTo: sellerId)
              .limit(1)
              .get();

          if (carDocs.docs.isNotEmpty) {
            final carData = carDocs.docs.first.data();
            final sellerName = carData['sellerName'] as String?;
            if (sellerName != null && sellerName.isNotEmpty) {
              foundUsername = sellerName;
            }
          }
        } catch (e) {
          print('Error fetching seller cars: $e');
        }
      }

      // If we found a username in any of the above methods, cache and return it
      if (foundUsername.isNotEmpty) {
        _usernameCache[sellerId] = foundUsername;
        _saveUsernameToDB(sellerId, foundUsername);
        return foundUsername;
      }

      // If we still don't have a name, use a more user-friendly fallback
      final fallbackName =
          "User ${sellerId.substring(0, min(5, sellerId.length))}...";
      _usernameCache[sellerId] = fallbackName;
      return fallbackName;
    } catch (e) {
      print('Error in fetchSellerName: $e');
      return "User";
    }
  }

  Future<void> _loadBids() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // First, get the post document to retrieve bid references
      final postDoc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.index)
          .get();

      if (postDoc.exists) {
        final List<dynamic> offerRefs =
            postDoc.data()?['offers'] as List<dynamic>? ?? [];

        if (offerRefs.isEmpty) {
          setState(() {
            _bids = [];
            _isLoading = false;
          });
          return;
        }

        // Fetch all bid documents from the bids collection
        List<CustomBid> fetchedBids = [];
        for (final bidRef in offerRefs) {
          try {
            final bidDoc = await FirebaseFirestore.instance
                .collection('bids')
                .doc(bidRef)
                .get();

            if (bidDoc.exists) {
              final data = bidDoc.data()!;

              // Get seller ID
              final sellerId = data['sellerId'] as String? ?? '';

              // Get the specific carId from the bid data
              // First try to get itemId (preferred) then fall back to legacy carId field if needed
              final carId =
                  data['itemId'] as String? ?? data['carId'] as String?;

              // Log the carId value for debugging
              print('DEBUG - Bid carId/itemId from Firestore: $carId');

              // Create the bid with a placeholder name first to allow UI to render
              final newBid = CustomBid(
                sellerId: sellerId,
                carId: carId ??
                    '', // Use empty string instead of widget.index if null
                amount: (data['amount'] as num).toDouble(),
                timestamp: data['timestamp'] is Timestamp
                    ? (data['timestamp'] as Timestamp).toDate()
                    : DateTime.now(),
                sellerName: _usernameCache[sellerId] ??
                    "Loading...", // Use cached name if available
              );

              fetchedBids.add(newBid);

              // Fetch the actual seller name in the background if not cached
              if (!_usernameCache.containsKey(sellerId)) {
                _fetchSellerName(sellerId).then((sellerName) {
                  // Update the bid with the actual seller name once available
                  setState(() {
                    final index =
                        _bids.indexWhere((b) => b.sellerId == sellerId);
                    if (index != -1) {
                      _bids[index] = CustomBid(
                        sellerId: _bids[index].sellerId,
                        carId: _bids[index].carId,
                        amount: _bids[index].amount,
                        timestamp: _bids[index].timestamp,
                        sellerName: sellerName,
                      );
                    }
                  });
                });
              }
            }
          } catch (e) {
            print('Error fetching bid $bidRef: $e');
          }
        }

        // Sort bids by amount in descending order (highest first)
        fetchedBids.sort((a, b) => b.amount.compareTo(a.amount));

        // Debug information about loaded bids
        print('DEBUG - Loaded ${fetchedBids.length} bids:');
        for (int i = 0; i < fetchedBids.length; i++) {
          final bid = fetchedBids[i];
          print(
              'DEBUG - Bid #${i + 1}: sellerId=${bid.sellerId}, carId=${bid.carId}, amount=${bid.amount}');
        }

        setState(() {
          _bids = fetchedBids;
          _isLoading = false;
        });

        // Now fetch all seller names that weren't in the cache to update the UI
        for (final bid in fetchedBids) {
          if (bid.sellerName == "Loading...") {
            final sellerName = await _fetchSellerName(bid.sellerId);
            if (mounted) {
              setState(() {
                final index = _bids.indexOf(bid);
                if (index != -1) {
                  _bids[index] = CustomBid(
                    sellerId: bid.sellerId,
                    carId: bid.carId,
                    amount: bid.amount,
                    timestamp: bid.timestamp,
                    sellerName: sellerName,
                  );
                }
              });
            }
          }
        }
      } else {
        setState(() {
          _bids = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      CustomSnackbar.showError(context, 'Error loading bids: $e');
    }
  }

  Future<void> _showBidDialog() async {
    // Check if category is car_part
    String postCategory = widget.category ?? 'car';

    if (postCategory == 'car_part') {
      // Show car part selection bottom sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => CarPartSelectionBottomSheet(
          onPartSelected: (selectedPartId, selectedPartName) {
            Navigator.pop(context);
            _showBidAmountDialogInternal(selectedPartId, selectedPartName,
                isCarPart: true);
          },
        ),
      );
    } else {
      // Show car selection bottom sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => CarSelectionBottomSheet(
          onCarSelected: (selectedCarId, selectedCarName) {
            Navigator.pop(context);
            _showBidAmountDialogInternal(selectedCarId, selectedCarName);
          },
        ),
      );
    }
  }

  Future<void> _showBidAmountDialogInternal(String itemId, String itemName,
      {bool isCarPart = false}) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Place Bid'),
          content: TextField(
            controller: _bidController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter bid amount',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_bidController.text.isEmpty) {
                  CustomSnackbar.showError(
                      context, 'Please enter a bid amount');
                  return;
                }

                final bidAmount = double.tryParse(_bidController.text);
                if (bidAmount == null) {
                  CustomSnackbar.showError(
                      context, 'Please enter a valid amount');
                  return;
                }

                if (bidAmount < widget.lowRange ||
                    bidAmount > widget.highRange) {
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

                  // Create the bid document in the bids collection
                  final firestore = FirebaseFirestore.instance;

                  // First, verify that the inventory item actually exists
                  final inventoryCollection =
                      isCarPart ? 'carParts' : 'inventoryCars';
                  final inventoryDoc = await firestore
                      .collection(inventoryCollection)
                      .doc(itemId)
                      .get();

                  if (!inventoryDoc.exists) {
                    throw Exception(
                        'Selected item no longer exists in inventory');
                  }

                  // Create bid data with consistent ID references
                  final Map<String, dynamic> bidData = {
                    'sellerId': user.uid,
                    'itemId': itemId,
                    'carId':
                        itemId, // Ensure carId matches itemId for compatibility
                    'itemType': isCarPart ? 'car_part' : 'car',
                    'amount': bidAmount,
                    'timestamp': FieldValue.serverTimestamp(),
                    'postId': widget.index,
                    'buyerId': widget.userId,
                    'carName': itemName,
                    'status': 'pending',
                    'inventoryRef': inventoryDoc
                        .reference, // Store direct reference to inventory item
                  };

                  // Log the bid data for debugging
                  print('DEBUG - Creating bid with data:');
                  print('itemId: $itemId');
                  print('carId: $itemId');
                  print('inventoryRef: ${inventoryDoc.reference.path}');

                  // Add bid to 'bids' collection
                  final bidRef =
                      await firestore.collection('bids').add(bidData);

                  // Update the post document to reference the bid
                  await firestore.collection('posts').doc(widget.index).update({
                    'offers': FieldValue.arrayUnion([bidRef.id])
                  });

                  _bidController.clear();
                  Navigator.pop(context);
                  CustomSnackbar.showSuccess(
                      context, 'Bid placed successfully!');
                  _loadBids(); // Reload bids to show the new bid
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
        );
      },
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
    final isSeller =
        currentUser?.uid == widget.userId; // Determine if the user is a seller
    // The post owner is the seller, not the buyer

    // Get the category
    final String postCategory = widget.category ?? 'car';
    final bool isCarPart = postCategory == 'car_part';

    // Debug: Log arguments to check imageUrls
    final args = ModalRoute.of(context)?.settings.arguments;
    print(
        'DEBUG - CarDetailsScreen received arguments type: ${args.runtimeType}');

    // Extract imageUrls from arguments if available
    List<String>? routeImageUrls;

    if (args is Map) {
      final map = args;
      print('DEBUG - Arguments keys: ${map.keys.toList()}');

      if (map.containsKey('imageUrls')) {
        final imageUrls = map['imageUrls'];
        print('DEBUG - imageUrls type: ${imageUrls.runtimeType}');

        if (imageUrls is List) {
          // Safer conversion using String.from and filtering out empty values
          routeImageUrls = List<String>.from(imageUrls
              .map((url) => url?.toString() ?? '')
              .where((url) => url.isNotEmpty == true));
          print(
              'DEBUG - Extracted ${routeImageUrls.length} imageUrls from Map arguments');
        }
      }
    } else if (args != null) {
      // If args is a CarPost or other object, try to access imageUrls
      try {
        final dynamic imageUrls = (args as dynamic).imageUrls;
        if (imageUrls is List) {
          // Safer conversion using String.from and filtering out empty values
          routeImageUrls = List<String>.from(imageUrls
              .map((url) => url?.toString() ?? '')
              .where((url) => url.isNotEmpty == true));
          print(
              'DEBUG - Extracted ${routeImageUrls.length} imageUrls from object arguments');
        }
      } catch (e) {
        print('DEBUG - Failed to extract imageUrls from arguments: $e');
      }
    }

    // Store the extracted imageUrls in state for access in other methods
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && routeImageUrls != null && routeImageUrls.isNotEmpty) {
        // If we have image URLs and they're different from current state, update
        setState(() {
          // Store the imageUrls in a class field if needed
          _imageUrls = routeImageUrls!;
          print('DEBUG - Updated _imageUrls with ${_imageUrls.length} items');
        });
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColor.appBarColor,
        elevation: 0,
        title: Text(
          'Details',
          style: TextStyle(
            color: AppColor.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.poppins().fontFamily,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColor.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      drawer: const CustomDrawer(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildCarImage(),
              _buildCarAndBidDetails(context),

              //* Sections - Only show Details and Features sections for car posts, not car parts
              if (!isCarPart) ...[
                const DetailSection(), //* Details Section
                FeatureSection(), //* Features Section
              ],

              // Display buyer description section
              _buildBuyerDescriptionSection(context, isSeller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarImage() {
    // Get all available images - first from class field, then widget props
    List<String> imageList = [];

    // Use the _imageUrls field if it has values
    if (_imageUrls.isNotEmpty) {
      imageList = List.from(_imageUrls);
      print('DEBUG - Using ${imageList.length} images from _imageUrls field');
    }
    // If _imageUrls is empty, use the main image as fallback
    else if (widget.image.isNotEmpty) {
      imageList.add(widget.image);
      print('DEBUG - Using main image as fallback: ${widget.image}');
    }

    // If there are no images at all, show placeholder
    if (imageList.isEmpty) {
      print('DEBUG - No images available, showing placeholder');
      return _buildImageErrorPlaceholder();
    }

    // Log found images
    print('DEBUG - Total images for carousel: ${imageList.length}');
    for (int i = 0; i < imageList.length; i++) {
      print(
          'DEBUG - Image $i: ${imageList[i].substring(0, min(50, imageList[i].length))}...');
    }

    // Create page controller for the carousel
    final PageController pageController = PageController();

    return SizedBox(
      height: 250,
      width: double.infinity,
      child: Stack(
        children: [
          // Image carousel
          PageView.builder(
            controller: pageController,
            itemCount: imageList.length,
            itemBuilder: (context, index) {
              return Hero(
                tag: 'car-image-${widget.carName}-${widget.index}-$index',
                child: _loadCarImage(imageList[index]),
              );
            },
          ),

          // Image counter indicator (only show if multiple images)
          if (imageList.length > 1)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColor.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    // Ensure we have a listener that calls setState when page changes
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (pageController.hasClients) {
                        pageController.addListener(() {
                          setState(() {});
                        });
                      }
                    });

                    final currentPage = pageController.hasClients
                        ? (pageController.page?.round() ?? 0) + 1
                        : 1;

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.photo_library,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$currentPage/${imageList.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

          // Navigation arrows (only if multiple images)
          if (imageList.length > 1)
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left arrow
                  StatefulBuilder(
                    builder: (context, setState) {
                      // Ensure we have a listener that calls setState when page changes
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (pageController.hasClients) {
                          pageController.addListener(() {
                            setState(() {});
                          });
                        }
                      });

                      final currentPage = pageController.hasClients
                          ? pageController.page?.round() ?? 0
                          : 0;

                      return currentPage > 0
                          ? GestureDetector(
                              onTap: () {
                                pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColor.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            )
                          : const SizedBox(width: 40);
                    },
                  ),

                  // Right arrow
                  StatefulBuilder(
                    builder: (context, setState) {
                      // Ensure we have a listener that calls setState when page changes
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (pageController.hasClients) {
                          pageController.addListener(() {
                            setState(() {});
                          });
                        }
                      });

                      final currentPage = pageController.hasClients
                          ? pageController.page?.round() ?? 0
                          : 0;

                      return currentPage < imageList.length - 1
                          ? GestureDetector(
                              onTap: () {
                                pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColor.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            )
                          : const SizedBox(width: 40);
                    },
                  ),
                ],
              ),
            ),

          // Dots indicator (only if multiple images)
          if (imageList.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: StatefulBuilder(
                builder: (context, setState) {
                  // Ensure we have a listener that calls setState when page changes
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (pageController.hasClients) {
                      pageController.addListener(() {
                        setState(() {});
                      });
                    }
                  });

                  final currentPage = pageController.hasClients
                      ? pageController.page?.round() ?? 0
                      : 0;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      imageList.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentPage == index
                              ? AppColor.green
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _loadCarImage(String imageUrl) {
    print(
        'DEBUG - Loading image URL: ${imageUrl.substring(0, min(50, imageUrl.length))}...');
    return Image.network(
      imageUrl,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('DEBUG - Error loading image: $error');
        return _buildImageErrorPlaceholder();
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          print('DEBUG - Image loaded successfully');
          return child;
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: AppColor.green,
              ),
              const SizedBox(height: 12),
              Text(
                'Loading image...',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (loadingProgress.expectedTotalBytes != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    '${((loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!) * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: AppColor.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageErrorPlaceholder() {
    return Container(
      width: double.infinity,
      height: 250,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Image not available',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {}); // Trigger rebuild to retry loading
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle: const TextStyle(fontSize: 14),
            ),
          ),
        ],
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
            'Current Bidders',
            isPostOwner ? 'Your Post' : 'Placed Bids',
            onPlaceBid: isPostOwner ? null : _showBidDialog,
          ),
          const Divider(color: AppColor.grey, thickness: 1.3),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(color: AppColor.green),
              ),
            )
          else if (_bids.isEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
              child: Text(
                isPostOwner
                    ? 'Waiting for bids...'
                    : 'Be the First to place bid',
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
                    _buildBidderAndBid(bid),
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
              // onTap: onPlaceBid,//! it was only for testing
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

  Widget _buildBidderAndBid(CustomBid bid) {
    // Get current user from AuthService
    final currentUser =
        Provider.of<AuthService>(context, listen: false).currentUser;

    // Check if current user is the post creator
    final isPostCreator = currentUser?.uid == widget.userId;

    // Debug prints for bid object
    print('DEBUG - Bid details:');
    print('Bid seller ID: ${bid.sellerId}');
    print('Bid seller name: ${bid.sellerName}');
    print('Bid car ID: "${bid.carId}"');
    print('Bid amount: ${bid.amount}');

    return Padding(
      padding: EdgeInsets.only(left: 15.0, right: isPostCreator ? 0 : 15),
      child: Row(
        children: [
          Expanded(
            child: Text(
              bid.sellerName,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColor.white,
                fontSize: 18,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            children: [
              Text(
                'PKR ${bid.amount.toStringAsFixed(0)}',
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
                    // Navigate to chat with the bidder
                    Navigator.pushNamed(
                      context,
                      '/chat',
                      arguments: {
                        'postId': widget.index,
                        'carName': widget.carName,
                        'recipientId': bid.sellerId,
                        'recipientName': bid.sellerName,
                      },
                    );
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
                    // Show seller info with car details from the bid
                    if (bid.carId.isEmpty) {
                      // Show a warning snackbar if carId is empty
                      CustomSnackbar.showError(
                        context,
                        'Car information not available for this bid',
                      );
                    } else {
                      print(
                          'DEBUG - Info button clicked for bid with carId: ${bid.carId}');
                      _showSellerInfoDialog(
                          bid.sellerId, bid.sellerName, bid.carId);
                    }
                  },
                  padding: const EdgeInsets.all(0),
                  style: IconButton.styleFrom(
                    backgroundColor: bid.carId.isEmpty
                        ? Colors.grey.withOpacity(0.5)
                        : AppColor.white,
                    disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                  ),
                  tooltip: bid.carId.isEmpty
                      ? 'Car information not available'
                      : 'View car information',
                  icon: SvgPicture.asset(
                    'assets/svg/info_icon.svg',
                    height: 25,
                    color: bid.carId.isEmpty ? Colors.grey[400] : null,
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showSellerInfoDialog(
      String sellerId, String sellerName, String carId) async {
    // Determine if the carId is empty
    if (carId.isEmpty) {
      CustomSnackbar.showError(
          context, 'No car information available for this bid');
      return;
    }

    print('DEBUG - Showing seller info dialog for carId: $carId');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColor.green.withOpacity(0.2), Colors.transparent],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Seller Information',
            style: TextStyle(
              color: AppColor.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
          ),
        ),
        content: FutureBuilder(
          future: Future.wait([
            // Get seller profile
            FirebaseFirestore.instance.collection('users').doc(sellerId).get(),

            // Get seller's other cars
            FirebaseFirestore.instance
                .collection('inventoryCars')
                .where('userId', isEqualTo: sellerId)
                .limit(3)
                .get(),

            // Try different ways to get the specific bid car data
            _getCarDocument(carId),
          ]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(color: AppColor.green),
                ),
              );
            }

            if (snapshot.hasError) {
              print(
                  'DEBUG - Error in _showSellerInfoDialog: ${snapshot.error}');
              return Text(
                'Error loading seller information: ${snapshot.error}',
                style: TextStyle(
                  color: AppColor.white,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              );
            }

            final userData = snapshot.data?[0].data();
            final userCars = snapshot.data?[1].docs ?? [];
            final bidCarData = snapshot.data?[2]?.data();

            // Debug prints for car data
            print('DEBUG - Car ID: $carId');
            print('DEBUG - Bid car data exists: ${bidCarData != null}');

            if (bidCarData != null) {
              print('DEBUG - Bid car data keys: ${bidCarData.keys.toList()}');
            } else {
              print('WARNING: bidCarData is null - car document may not exist');
            }

            return SizedBox(
              width: double.maxFinite,
              height: 400, // Increased height for more content
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seller profile
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColor.grey.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              sellerName.isNotEmpty
                                  ? sellerName[0].toUpperCase()
                                  : 'S',
                              style: const TextStyle(
                                color: AppColor.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sellerName,
                                style: const TextStyle(
                                  color: AppColor.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (userData != null && userData['email'] != null)
                                Text(
                                  userData['email'],
                                  style: TextStyle(
                                    color: AppColor.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Seller stats
                    if (userData != null)
                      _buildSellerStat(
                          'Member since',
                          userData['createdAt'] is Timestamp
                              ? _formatDate(
                                  (userData['createdAt'] as Timestamp).toDate())
                              : 'Unknown'),

                    _buildSellerStat('Cars for sale', '${userCars.length}'),

                    // Bid car information section
                    if (bidCarData != null) ...[
                      const SizedBox(height: 16),
                      const Divider(color: AppColor.grey, thickness: 1),
                      const SizedBox(height: 16),
                      _buildSectionHeader('Car offered in this bid:'),
                      const SizedBox(height: 12),

                      // Car image carousel
                      SizedBox(
                        height: 250, // Increased height for better viewing
                        child: Builder(
                          builder: (context) {
                            // Collect all valid images for the carousel
                            final List<String> carouselImages = [];

                            // Add the main image URL if it exists
                            if (bidCarData.containsKey('mainImageUrl') &&
                                bidCarData['mainImageUrl'] != null &&
                                bidCarData['mainImageUrl']
                                    .toString()
                                    .isNotEmpty) {
                              carouselImages.add(bidCarData['mainImageUrl']);
                            }

                            // Add images from imageUrls array if they exist
                            if (bidCarData.containsKey('imageUrls') &&
                                bidCarData['imageUrls'] is List) {
                              for (var url in bidCarData['imageUrls']) {
                                if (url is String &&
                                    url.isNotEmpty &&
                                    !carouselImages.contains(url)) {
                                  carouselImages.add(url);
                                }
                              }
                            }

                            // If no images available, show a placeholder
                            if (carouselImages.isEmpty) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.directions_car,
                                        color: Colors.white70,
                                        size: 60,
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'No car images available',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            // Create a page controller for the image carousel
                            final PageController pageController =
                                PageController();

                            // Return the image carousel
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.black,
                              ),
                              child: Stack(
                                children: [
                                  // Image carousel
                                  PageView.builder(
                                    controller: pageController,
                                    itemCount: carouselImages.length,
                                    itemBuilder: (context, index) {
                                      final String imageUrl =
                                          carouselImages[index];
                                      return Center(
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit
                                              .contain, // Ensure image fits without cropping
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.broken_image_rounded,
                                                  color: Colors.white70,
                                                  size: 50,
                                                ),
                                                SizedBox(height: 10),
                                                Text(
                                                  'Image not available',
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }

                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                                color: AppColor.green,
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),

                                  // Image counter in top right
                                  if (carouselImages.length > 1)
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.7),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: StatefulBuilder(
                                          builder: (context, setState) {
                                            pageController.addListener(() {
                                              setState(() {});
                                            });

                                            final currentPage =
                                                pageController.hasClients
                                                    ? (pageController.page
                                                                ?.round() ??
                                                            0) +
                                                        1
                                                    : 1;

                                            return Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.photo_library,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '$currentPage/${carouselImages.length}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ),

                                  // Pagination dots at the bottom
                                  if (carouselImages.length > 1)
                                    Positioned(
                                      bottom: 12,
                                      left: 0,
                                      right: 0,
                                      child: StatefulBuilder(
                                        builder: (context, setState) {
                                          pageController.addListener(() {
                                            setState(() {});
                                          });

                                          final currentPage = pageController
                                                  .hasClients
                                              ? pageController.page?.round() ??
                                                  0
                                              : 0;

                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: List.generate(
                                              carouselImages.length,
                                              (index) => Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 3),
                                                height: 8,
                                                width: 8,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: currentPage == index
                                                      ? AppColor.green
                                                      : Colors.white
                                                          .withOpacity(0.8),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Car details
                      _buildSellerStat(
                          'Model', bidCarData['model'] ?? 'Unknown'),
                      _buildSellerStat('Make', bidCarData['make'] ?? 'Unknown'),
                      if (bidCarData['year'] != null)
                        _buildSellerStat('Year', bidCarData['year'].toString()),
                      if (bidCarData['price'] != null)
                        _buildSellerStat('Listed Price',
                            'PKR ${bidCarData['price'].toString()}'),
                      if (bidCarData['mileage'] != null)
                        _buildSellerStat(
                            'Mileage', '${bidCarData['mileage']} km'),
                      if (bidCarData['condition'] != null)
                        _buildSellerStat('Condition', bidCarData['condition']),
                      if (bidCarData['description'] != null &&
                          bidCarData['description'].toString().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Description:',
                          style: TextStyle(
                            color: AppColor.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bidCarData['description'],
                          style: TextStyle(
                            color: AppColor.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],

                    const SizedBox(height: 16),
                    const Divider(color: AppColor.grey, thickness: 1),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildStyledButton('Close', () => Navigator.pop(context)),
                const SizedBox(width: 8),
                _buildStyledButton('Chat with Seller', () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    '/chat',
                    arguments: {
                      'postId': widget.index,
                      'carName': widget.carName,
                      'recipientId': sellerId,
                      'recipientName': sellerName,
                    },
                  );
                }, isPrimary: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: AppColor.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColor.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.green.withOpacity(0.7), Colors.transparent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: AppColor.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
      ),
    );
  }

  Widget _buildStyledButton(String text, VoidCallback onPressed,
      {bool isPrimary = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPrimary
              ? [AppColor.green, AppColor.green.withOpacity(0.7)]
              : [Colors.grey.withOpacity(0.3), Colors.grey.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              text,
              style: TextStyle(
                color:
                    isPrimary ? Colors.white : AppColor.white.withOpacity(0.9),
                fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
                fontSize: isPrimary ? 14 : 13,
                fontFamily: GoogleFonts.poppins().fontFamily,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // New method to build the buyer description section
  Widget _buildBuyerDescriptionSection(BuildContext context, bool isSeller) {
    return Container(
      color: AppColor.black,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Buyer Description',
                style: TextStyle(
                  color: AppColor.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (!isSeller)
                InkWell(
                  onTap: () async {
                    // Fetch the buyer's username
                    final buyerName = await _fetchSellerName(widget.userId);

                    // Navigate to chat with the buyer
                    Navigator.pushNamed(
                      context,
                      '/chat',
                      arguments: {
                        'postId': widget.index,
                        'carName': widget.carName,
                        'recipientId': widget.userId,
                        'recipientName': buyerName,
                      },
                    );
                  },
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
          const SizedBox(height: 10),
          Text(
            widget.description.trim().isEmpty
                ? "No description"
                : widget.description,
            style: const TextStyle(
              color: AppColor.white,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Helper method to get car document using different approaches
  Future<DocumentSnapshot?> _getCarDocument(String carId) async {
    try {
      print('DEBUG - Attempting to get car document for ID: $carId');

      // Try to get the document directly from inventoryCars collection first
      try {
        final directDoc = await FirebaseFirestore.instance
            .collection('inventoryCars')
            .doc(carId)
            .get();

        if (directDoc.exists) {
          print('DEBUG - Found car document in inventoryCars collection');
          return directDoc;
        }
      } catch (e) {
        print('DEBUG - Error getting car from inventoryCars: $e');
      }

      // If not found, try car parts collection (in case it's a part)
      try {
        final partDoc = await FirebaseFirestore.instance
            .collection('carParts')
            .doc(carId)
            .get();

        if (partDoc.exists) {
          print('DEBUG - Found car document in carParts collection');
          return partDoc;
        }
      } catch (e) {
        print('DEBUG - Error getting car from carParts: $e');
      }

      // If still not found, try to lookup from bids collection to find reference
      try {
        final bidsQuery = await FirebaseFirestore.instance
            .collection('bids')
            .where('itemId', isEqualTo: carId)
            .limit(1)
            .get();

        if (bidsQuery.docs.isNotEmpty) {
          final bidData = bidsQuery.docs.first.data();

          // Check if bid has inventoryRef field
          if (bidData.containsKey('inventoryRef')) {
            print('DEBUG - Found inventory reference in bid');

            // Convert reference to DocumentReference
            final inventoryRef = bidData['inventoryRef'] as DocumentReference;
            final docSnapshot = await inventoryRef.get();

            if (docSnapshot.exists) {
              print('DEBUG - Successfully retrieved document from reference');
              return docSnapshot;
            }
          }
        }
      } catch (e) {
        print('DEBUG - Error getting car from bids reference: $e');
      }

      // As a last resort, search for the car by looking up any car with this ID
      try {
        final results = await FirebaseFirestore.instance
            .collectionGroup('inventoryCars')
            .where(FieldPath.documentId, isEqualTo: carId)
            .get();

        if (results.docs.isNotEmpty) {
          print('DEBUG - Found car document through collection group query');
          return results.docs.first;
        }
      } catch (e) {
        print('DEBUG - Error in collection group query: $e');
      }

      // If all approaches failed, return null
      print('DEBUG - Could not find car document with ID: $carId');
      return null;
    } catch (e) {
      print('DEBUG - Error in _getCarDocument: $e');
      return null;
    }
  }
}
