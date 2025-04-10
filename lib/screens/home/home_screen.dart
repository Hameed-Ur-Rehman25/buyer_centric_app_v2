import 'package:buyer_centric_app_v2/routes/app_routes.dart';
import 'package:buyer_centric_app_v2/screens/buy%20car/buy_car_screen.dart';
import 'package:buyer_centric_app_v2/screens/car%20parts/car_parts_screen.dart';
import 'package:buyer_centric_app_v2/screens/profile/profile_screen.dart';
import 'package:buyer_centric_app_v2/screens/upload/upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/utils/bottom_nav_bar.dart';
import 'package:buyer_centric_app_v2/utils/car_search_card.dart';
import 'package:buyer_centric_app_v2/widgets/custom_app_bar.dart';
import 'package:buyer_centric_app_v2/widgets/post_card.dart';
import 'package:buyer_centric_app_v2/widgets/custom_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buyer_centric_app_v2/utils/image_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum SortOption {
  newest,
  oldest,
  priceLowToHigh,
  priceHighToLow,
}

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final int _postsPerPage = 10;
  int _lastVisiblePostIndex = 0;
  bool _isLoadingMore = false;
  bool _hasMorePosts = true;
  List<DocumentSnapshot> _allPosts = [];
  ScrollController _scrollController = ScrollController();
  DocumentSnapshot? _lastDocument;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late int _selectedIndex;

  // Sort and filter states
  SortOption _currentSortOption = SortOption.newest;
  RangeValues _priceRange = const RangeValues(0, 100000000);
  String? _selectedMake;
  int? _selectedYear;
  final List<String> _carMakes = [
    'Toyota',
    'Honda',
    'Ford',
    'BMW',
    'Mercedes',
    'Audi',
    'Tesla'
  ];
  final List<int> _yearOptions =
      List.generate(30, (index) => DateTime.now().year - index);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.forward();
      }
    });

    // Initialize scroll controller for CustomScrollView
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    // Load initial posts when screen is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_allPosts.isEmpty) {
        _loadInitialPosts();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sort Posts',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.black54),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Sort Options
                  Text(
                    'Sort By',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: GoogleFonts.montserrat().fontFamily,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sort option buttons
                  _buildSortOption(SortOption.newest, 'Newest First',
                      Icons.calendar_today, setState),
                  const SizedBox(height: 12),
                  _buildSortOption(SortOption.oldest, 'Oldest First',
                      Icons.history, setState),
                  const SizedBox(height: 12),
                  _buildSortOption(SortOption.priceLowToHigh,
                      'Price: Low to High', Icons.arrow_upward, setState),
                  const SizedBox(height: 12),
                  _buildSortOption(SortOption.priceHighToLow,
                      'Price: High to Low', Icons.arrow_downward, setState),

                  const SizedBox(height: 32),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _applySortOption();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Apply Sort',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortOption(
      SortOption option, String title, IconData icon, StateSetter setState) {
    bool isSelected = _currentSortOption == option;

    return InkWell(
      onTap: () {
        setState(() {
          _currentSortOption = option;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.black : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColor.black : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black54,
              size: 22,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
                fontFamily: GoogleFonts.montserrat().fontFamily,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _applySortOption() {
    setState(() {
      // Reset post list when sort option changes
      _allPosts = [];
      _lastDocument = null;
      _hasMorePosts = true;
    });

    // Reload posts with new sort option
    _loadInitialPosts();
  }

  /// Shows a dialog with filter options for posts
  /// Includes price range slider, car make dropdown, and year dropdown
  void _showFilterOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Filter Options',
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price Range Filter
                    const Text('Price Range:'),
                    RangeSlider(
                      values: _priceRange,
                      min: 0,
                      max: 100000000,
                      divisions: 20,
                      labels: RangeLabels(
                        '\$${_priceRange.start.round()}',
                        '\$${_priceRange.end.round()}',
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          _priceRange = values;
                        });
                      },
                      activeColor: AppColor.black,
                    ),
                    const SizedBox(height: 20),

                    // Car Make Filter
                    const Text('Make:'),
                    DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Select Make'),
                      value: _selectedMake,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedMake = newValue;
                        });
                      },
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Makes'),
                        ),
                        ..._carMakes
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Year Filter
                    const Text('Year:'),
                    DropdownButton<int>(
                      isExpanded: true,
                      hint: const Text('Select Year'),
                      value: _selectedYear,
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedYear = newValue;
                        });
                      },
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('All Years'),
                        ),
                        ..._yearOptions.map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                // Reset Button - Clears all filter selections
                TextButton(
                  onPressed: () {
                    setState(() {
                      _priceRange = const RangeValues(0, 100000000);
                      _selectedMake = null;
                      _selectedYear = null;
                    });
                  },
                  child:
                      const Text('Reset', style: TextStyle(color: Colors.red)),
                ),
                // Cancel Button - Closes dialog without applying filters
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.grey)),
                ),
                // Apply Button - Applies selected filters and closes dialog
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _applyFilters();
                  },
                  child: const Text('Apply',
                      style: TextStyle(color: AppColor.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Applies the selected filters to the posts list
  /// Resets the current posts and reloads with the new filter criteria
  void _applyFilters() {
    setState(() {
      _allPosts = []; // Clear current posts
      _lastDocument = null; // Reset pagination
      _hasMorePosts = true; // Reset pagination flag
    });

    // Load new posts with the applied filters
    _loadInitialPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: _selectedIndex == 0 || _selectedIndex == 1
          ? const CustomAppBar()
          : null,
      drawer: _selectedIndex == 0 || _selectedIndex == 1
          ? const CustomDrawer()
          : null,
      body: _buildBody(),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const BuyCarScreen();
      case 2:
        return const UploadScreen();
      case 3:
        return const CarPartsScreen();
      case 4:
        return const ProfileScreen();
      default:
        return Center(
          child: Text(
            "Page ${_selectedIndex + 1} coming soon!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.montserrat().fontFamily,
            ),
          ),
        );
    }
  }

  Widget _buildHomeContent() {
    // Load initial posts if needed
    if (_allPosts.isEmpty && !_isLoadingMore) {
      _loadInitialPosts();
    }

    return SafeArea(
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Animated image header
          SliverToBoxAdapter(
            child: _buildAnimatedImage(),
          ),

          // Feature title and sell card
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildFeatureTitle(),
                const SizedBox(height: 10),
                // _buildWantToSellCard(),
                // const SizedBox(height: 20),
              ],
            ),
          ),

          // Loading indicator for initial load
          if (_isLoadingMore && _allPosts.isEmpty)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          // No posts message
          else if (_allPosts.isEmpty && !_isLoadingMore)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'No posts available',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            )
          // Posts list
          else
            _buildSliverPostsList(),
        ],
      ),
    );
  }

  // Convert the posts list to a sliver list
  Widget _buildSliverPostsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Show loading indicator at the end when loading more posts
          if (index == _allPosts.length) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.0),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Loading more posts...',
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

          final doc = _allPosts[index];
          final data = doc.data() as Map<String, dynamic>;
          final String category = data['category'] ?? 'car';

          // Get images with proper fallbacks based on category
          String imageUrl = '';
          List<String> imageUrls = [];

          // For car parts, use mainImageUrl as the primary source
          if (category == 'car_part') {
            // First try to get mainImageUrl
            imageUrl = data['mainImageUrl'] ?? '';

            // If mainImageUrl is empty, try imageUrl
            if (imageUrl.isEmpty) {
              imageUrl = data['imageUrl'] ?? '';
            }

            // Get all image URLs for the carousel
            if (data['imageUrls'] != null && data['imageUrls'] is List) {
              imageUrls = List<String>.from((data['imageUrls'] as List)
                  .map((url) => url?.toString() ?? '')
                  .where((url) => url.isNotEmpty));
            }
          } else {
            // For regular car posts, use imageUrl
            imageUrl = data['imageUrl'] ?? '';

            // Get imageUrls if available
            if (data['imageUrls'] != null && data['imageUrls'] is List) {
              imageUrls = List<String>.from((data['imageUrls'] as List)
                  .map((url) => url?.toString() ?? '')
                  .where((url) => url.isNotEmpty));
            }
          }

          // If no valid image URL found, use fallback image
          if (imageUrl.isEmpty) {
            imageUrl = category == 'car_part'
                ? 'assets/images/car_part_placeholder.png'
                : 'assets/images/car1.png';
          }

          return Padding(
            padding:
                const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
            child: PostCard(
              index: doc.id,
              animationIndex: index, // Use the list index for animation timing
              carName: "${data['make'] ?? ''} ${data['model'] ?? ''}",
              lowRange: (data['minPrice'] as num?)?.toInt() ?? 0,
              highRange: (data['maxPrice'] as num?)?.toInt() ?? 0,
              image: imageUrl,
              description: data['description']?.isNotEmpty == true
                  ? data['description']
                  : 'No description',
              userId: data['userId'] ?? '',
              imageUrls: imageUrls,
              category: data['category'] ?? 'car',
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.carDetails,
                arguments: {
                  ...data,
                  'index': doc.id,
                  'carName': "${data['make'] ?? ''} ${data['model'] ?? ''}",
                  'lowRange': (data['minPrice'] as num?)?.toInt() ?? 0,
                  'highRange': (data['maxPrice'] as num?)?.toInt() ?? 0,
                  'image': imageUrl,
                  'description': data['description'] ?? '',
                  'userId': data['userId'] ?? '',
                  'imageUrls': imageUrls,
                },
              ),
            ),
          );
        },
        childCount: _allPosts.length + (_hasMorePosts ? 1 : 0),
      ),
    );
  }

  Widget _buildAnimatedImage() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ImageUtils.loadAssetImage(
          imagePath: 'assets/images/home_screen_image.png',
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildFeatureTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'All Features',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.montserrat().fontFamily,
              color: Colors.black,
            ),
          ),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _showSortOptions,
                icon: SvgPicture.asset(
                  'assets/svg/sort-vertical-svgrepo-com.svg',
                  height: 20,
                  color: Colors.black,
                ),
                label:
                    const Text('Sort', style: TextStyle(color: Colors.black)),
                iconAlignment: IconAlignment.end,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
              const SizedBox(width: 10),
              //! This button is commented out for now
              // ElevatedButton.icon(
              //   onPressed: _showFilterOptions,
              //   icon:
              //       const Icon(Icons.filter_alt_outlined, color: Colors.black),
              //   label:
              //       const Text('Filter', style: TextStyle(color: Colors.black)),
              //   iconAlignment: IconAlignment.end,
              //   style: ElevatedButton.styleFrom(
              //     foregroundColor: Colors.black,
              //     backgroundColor: Colors.white,
              //     elevation: 4,
              //     shadowColor: Colors.black.withOpacity(0.5),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(5),
              //     ),
              //     padding: const EdgeInsets.symmetric(horizontal: 8),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWantToSellCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        height: 90,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: const BoxDecoration(
          color: AppColor.black,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Want to sell your car?',
                  style: TextStyle(
                    color: AppColor.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.inter().fontFamily,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: AppColor.white,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Hurry up.....',
                      style: TextStyle(
                        color: AppColor.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.inter().fontFamily,
                      ),
                    ),
                  ],
                )
              ],
            ),
            const Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        "Sell Now",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Load initial posts
  Future<void> _loadInitialPosts() async {
    if (_allPosts.isNotEmpty) return;

    print('DEBUG: Starting to load initial posts');
    setState(() {
      _isLoadingMore = true;
      _hasMorePosts = true;
      _lastDocument = null;
    });

    try {
      // Create query for initial posts
      Query query = _buildQuery().limit(_postsPerPage);
      print('DEBUG: Final query: ${query.toString()}');

      // Execute query
      print('DEBUG: Executing Firestore query...');
      final querySnapshot = await query.get();
      final docs = querySnapshot.docs;
      print('DEBUG: Retrieved ${docs.length} documents from Firestore');

      if (docs.isEmpty) {
        print('DEBUG: No documents found in Firestore');
        setState(() {
          _hasMorePosts = false;
          _isLoadingMore = false;
        });
        return;
      }

      // For initial load, show all posts without price filtering
      setState(() {
        _allPosts = docs;
        if (docs.isNotEmpty) {
          _lastDocument = docs.last;
        }

        if (docs.length < _postsPerPage) {
          _hasMorePosts = false;
        }

        _isLoadingMore = false;
      });

      print('DEBUG: Loaded ${docs.length} initial posts');
    } catch (e, stackTrace) {
      print('Error loading initial posts: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Widget _buildBuySellSection() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 10),
      child: Row(
        children: [
          Text(
            'Buy / Sell',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.montserrat().fontFamily,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              //Todo: Navigate to Buy/Sell screen
            },
            icon: const Icon(Icons.arrow_forward_ios),
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  /// Builds a Firestore query based on the current filter and sort options
  /// Returns a query that can be used to fetch posts
  Query _buildQuery() {
    Query query = FirebaseFirestore.instance.collection('posts');
    print('DEBUG: Initial query created for collection: posts');

    // Apply make filter if selected
    if (_selectedMake != null) {
      query = query.where('make', isEqualTo: _selectedMake);
      print('DEBUG: Applied make filter: $_selectedMake');
    }

    // Apply year filter if selected
    if (_selectedYear != null) {
      query = query.where('year', isEqualTo: _selectedYear);
      print('DEBUG: Applied year filter: $_selectedYear');
    }

    // Apply sorting based on selected sort option
    switch (_currentSortOption) {
      case SortOption.newest:
        query = query.orderBy('timestamp', descending: true);
        print('DEBUG: Applied sort: newest first');
        break;
      case SortOption.oldest:
        query = query.orderBy('timestamp', descending: false);
        print('DEBUG: Applied sort: oldest first');
        break;
      case SortOption.priceLowToHigh:
        query = query.orderBy('minPrice', descending: false);
        print('DEBUG: Applied sort: price low to high');
        break;
      case SortOption.priceHighToLow:
        query = query.orderBy('maxPrice', descending: true);
        print('DEBUG: Applied sort: price high to low');
        break;
    }

    return query;
  }

  // Scroll listener to detect when user reaches bottom
  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = maxScroll - 500; // Load more when 500px from bottom

    if (currentScroll > threshold && !_isLoadingMore && _hasMorePosts) {
      _loadMorePosts();
    }
  }

  // Load more posts
  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || !_hasMorePosts || _lastDocument == null) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      // Create query for next batch of posts
      Query query = _buildQuery();

      // Start after the last document
      query = query.startAfterDocument(_lastDocument!);

      // Limit to posts per page
      query = query.limit(_postsPerPage);

      // Execute query
      final querySnapshot = await query.get();
      final docs = querySnapshot.docs;

      if (docs.isEmpty) {
        setState(() {
          _hasMorePosts = false;
          _isLoadingMore = false;
        });
        print('DEBUG: No more posts to load');
        return;
      }

      // Filter docs based on price range
      final List<DocumentSnapshot> filteredDocs = docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final minPrice = (data['minPrice'] as num?)?.toDouble() ?? 0;
        final maxPrice = (data['maxPrice'] as num?)?.toDouble() ?? 0;

        // Check if the document's price range overlaps with the selected price range
        return minPrice <= _priceRange.end && maxPrice >= _priceRange.start;
      }).toList();

      setState(() {
        if (filteredDocs.isNotEmpty) {
          _allPosts.addAll(filteredDocs);
        }

        // Update the last document reference for pagination
        if (docs.isNotEmpty) {
          _lastDocument = docs.last;
        }

        // If we got fewer documents than requested, there are no more posts
        if (docs.length < _postsPerPage) {
          _hasMorePosts = false;
        }

        _isLoadingMore = false;
      });

      // Log for debugging
      print(
          'DEBUG: Loaded ${filteredDocs.length} more posts. Total: ${_allPosts.length}');
    } catch (e) {
      print('Error loading more posts: $e');
      setState(() {
        _isLoadingMore = false;
      });
    }
  }
}
