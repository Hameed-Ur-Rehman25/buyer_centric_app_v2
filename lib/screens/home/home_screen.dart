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

enum PostType {
  all,
  car,
  carPart,
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
  PostType _selectedPostType = PostType.all; // Default to show all posts
  RangeValues _priceRange = const RangeValues(0, 1000000);
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
                  _buildSortOption(SortOption.newest, 'Newest First', Icons.calendar_today, setState),
                  const SizedBox(height: 12),
                  _buildSortOption(SortOption.oldest, 'Oldest First', Icons.history, setState),
                  const SizedBox(height: 12),
                  _buildSortOption(SortOption.priceLowToHigh, 'Price: Low to High', Icons.arrow_upward, setState),
                  const SizedBox(height: 12),
                  _buildSortOption(SortOption.priceHighToLow, 'Price: High to Low', Icons.arrow_downward, setState),
                  
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

  Widget _buildSortOption(SortOption option, String title, IconData icon, StateSetter setState) {
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

  void _showFilterOptions() {
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
                        'Filter Posts',
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
                  
                  // Current Filter Status - Show what's currently active
                  if (_selectedPostType != PostType.all)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                  children: [
                          Icon(
                            _selectedPostType == PostType.car
                                ? Icons.directions_car_outlined
                                : Icons.build_outlined,
                            size: 16,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Currently showing: ${_selectedPostType == PostType.car ? 'Cars Only' : 'Parts Only'}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_selectedPostType != PostType.all)
                    const SizedBox(height: 20),
                  
                  // Post Type Selector
                  Text(
                    'Post Type',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: GoogleFonts.montserrat().fontFamily,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Post Type Options
                  Row(
                    children: [
                      _buildPostTypeOption(PostType.all, 'All Posts', setState),
                      const SizedBox(width: 12),
                      _buildPostTypeOption(PostType.car, 'Cars Only', setState),
                      const SizedBox(width: 12),
                      _buildPostTypeOption(PostType.carPart, 'Parts Only', setState),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        
                        // Show a loading indicator
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Applying filter: ${_selectedPostType == PostType.all ? 'All Posts' : _selectedPostType == PostType.car ? 'Cars Only' : 'Parts Only'}',
                    ),
                  ],
                ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        
                        // Apply the filter
                        _applyFilters();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Apply Filter',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Reset Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                          _selectedPostType = PostType.all;
                    });
                  },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black54,
                        side: const BorderSide(color: Colors.black38),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Reset Filter',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
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

  // Build post type selection option
  Widget _buildPostTypeOption(PostType type, String label, StateSetter setState) {
    bool isSelected = _selectedPostType == type;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPostType = type;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColor.black : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColor.black : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                type == PostType.all
                    ? Icons.category_outlined
                    : type == PostType.car
                        ? Icons.directions_car_outlined
                        : Icons.build_outlined,
                color: isSelected ? Colors.white : Colors.black54,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyFilters() {
    setState(() {
      _allPosts = [];
      _lastDocument = null;
      _hasMorePosts = true;
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
          // No posts message with retry button
          else if (_allPosts.isEmpty && !_isLoadingMore)
            SliverFillRemaining(
              child: _buildEmptyPostsView(),
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
              // Sort Button
              GestureDetector(
                onTap: _showSortOptions,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                  'assets/svg/sort-vertical-svgrepo-com.svg',
                        height: 18,
                  color: Colors.black,
                ),
                      const SizedBox(width: 8),
                      Text(
                        'Sort',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Filter Button
              GestureDetector(
                onTap: _showFilterOptions,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.filter_alt_outlined,
                        size: 18,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Filter',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ),
                      ),
                      
                      // Show indicator dot if filter is active
                      if (_selectedPostType != PostType.all)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
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
    setState(() {
      _isLoadingMore = true;
      _hasMorePosts = true;
      _lastDocument = null;
      _allPosts = [];
    });

    try {
      // Analyze the structure if debugging is needed
      await _analyzePostsStructure();
      
      // Create query for initial posts
      Query query = _buildQuery().limit(_postsPerPage);
      print('Executing query: $query');

      // Execute query
      final querySnapshot = await query.get();
      final docs = querySnapshot.docs;

      print('Query returned ${docs.length} documents');

      if (docs.isEmpty) {
        setState(() {
          _hasMorePosts = false;
          _isLoadingMore = false;
        });
        return;
      }

      setState(() {
        _allPosts = docs;
        if (docs.isNotEmpty) {
          _lastDocument = docs.last;
        }
        _isLoadingMore = false;
      });
    } catch (e) {
      print('Error loading initial posts: $e');
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

  // Load more posts when scrolling
  Future<void> _loadMorePosts() async {
    if (!_hasMorePosts || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      // Create query for more posts, starting after last document
      Query query = _buildQuery().startAfterDocument(_lastDocument!).limit(_postsPerPage);

      // Execute query
      final querySnapshot = await query.get();
      final docs = querySnapshot.docs;

      if (docs.isEmpty) {
        setState(() {
          _hasMorePosts = false;
          _isLoadingMore = false;
        });
        return;
      }

      setState(() {
        _allPosts.addAll(docs);
        _lastDocument = docs.last;
        _isLoadingMore = false;
      });
    } catch (e) {
      print('Error loading more posts: $e');
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  // Build query based on current sort and filter options
  Query _buildQuery() {
    Query query = FirebaseFirestore.instance.collection('posts');

    // Apply post type filter
    if (_selectedPostType != PostType.all) {
      // Check both 'category' and possible alternative fields
      String categoryValue = _selectedPostType == PostType.car ? 'car' : 'car_part';
      
      // Debug - log the filter being applied
      print('Filtering posts by category: $categoryValue');
      
      // Try alternative field names that might be used
      if (_selectedPostType == PostType.car) {
        // To find cars, check if the type field equals 'car'
        // OR if the record doesn't have a car_part field or type field
        try {
          // First approach: try using a direct equality check on 'type' or 'category'
          query = query.where('category', isEqualTo: categoryValue);
        } catch (e) {
          print('Error using category field: $e');
          
          // If that fails, try looking for posts with a 'type' field
          try {
            query = query.where('type', isEqualTo: 'car');
          } catch (e) {
            print('Error using type field: $e');
            
            // As a last resort, try to filter by other fields that might indicate it's a car
            try {
              query = query.where('isCar', isEqualTo: true);
            } catch (e) {
              print('Error using isCar field: $e');
              // Give up on filtering and just sort the results
            }
          }
        }
      } else {
        // For car parts, try various possible field names
        try {
          query = query.where('category', isEqualTo: categoryValue);
        } catch (e) {
          print('Error using category field for parts: $e');
          
          try {
            query = query.where('type', isEqualTo: 'car_part');
          } catch (e) {
            print('Error using type field for parts: $e');
            
            try {
              query = query.where('isCarPart', isEqualTo: true);
            } catch (e) {
              print('Error using isCarPart field: $e');
            }
          }
        }
      }
    }

    // Apply sort option - make sure we have a default fallback for createdAt
    try {
    switch (_currentSortOption) {
      case SortOption.newest:
          query = query.orderBy('createdAt', descending: true);
        break;
      case SortOption.oldest:
          query = query.orderBy('createdAt', descending: false);
        break;
      case SortOption.priceLowToHigh:
        query = query.orderBy('minPrice', descending: false);
        break;
      case SortOption.priceHighToLow:
          query = query.orderBy('minPrice', descending: true);
        break;
      }
    } catch (e) {
      // If sort field doesn't exist, fallback to a reliable field
      print('Error applying sort: $e');
      query = query.orderBy('createdAt', descending: true);
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

  // Show a retry button when no posts are found
  Widget _buildEmptyPostsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No posts found with the selected filter',
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
    setState(() {
                _selectedPostType = PostType.all;
              });
              _applyFilters();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Show All Posts'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Create a snapshot of the current filter state for diagnostics
  String _getFilterDebugInfo() {
    return 'Filter: ${_selectedPostType.toString()}, Sort: ${_currentSortOption.toString()}';
  }

  // Debug helper to analyze the actual structure of posts in Firestore
  Future<void> _analyzePostsStructure() async {
    try {
      // Get a small sample of all posts
      final querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .limit(20)
          .get();
      
      final docs = querySnapshot.docs;

      if (docs.isEmpty) {
        print('DEBUG: No posts found in the collection');
        return;
      }

      print('DEBUG: Analyzing ${docs.length} posts for field structure');
      
      // Analyze fields used for categorization
      int hasCategory = 0;
      int hasType = 0;
      int hasIsCar = 0;
      int hasIsCarPart = 0;
      
      // Analyze available category values
      Set<String> categoryValues = {};
      Set<String> typeValues = {};
      
      for (final doc in docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Check which fields exist
        if (data.containsKey('category')) {
          hasCategory++;
          if (data['category'] != null) {
            categoryValues.add(data['category'].toString());
          }
        }
        
        if (data.containsKey('type')) {
          hasType++;
          if (data['type'] != null) {
            typeValues.add(data['type'].toString());
          }
        }
        
        if (data.containsKey('isCar')) {
          hasIsCar++;
        }
        
        if (data.containsKey('isCarPart')) {
          hasIsCarPart++;
        }
        
        // Log the first few documents entirely for debugging
        if (docs.indexOf(doc) < 3) {
          print('DEBUG: Document ${doc.id} data:');
          data.forEach((key, value) {
            print('  $key: $value');
          });
        }
      }
      
      // Log summary
      print('DEBUG: Field usage summary:');
      print('  - category field: $hasCategory/${docs.length} documents');
      print('  - type field: $hasType/${docs.length} documents');
      print('  - isCar field: $hasIsCar/${docs.length} documents');
      print('  - isCarPart field: $hasIsCarPart/${docs.length} documents');
      
      print('DEBUG: Category values found: $categoryValues');
      print('DEBUG: Type values found: $typeValues');
      
    } catch (e) {
      print('DEBUG: Error analyzing posts structure: $e');
    }
  }
}
