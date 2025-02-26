import 'package:buyer_centric_app_v2/screens/buy_car_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/utils/bottom_nav_bar.dart';
import 'package:buyer_centric_app_v2/utils/car_search_card.dart';
import 'package:buyer_centric_app_v2/widgets/custom_app_bar.dart';
import 'package:buyer_centric_app_v2/widgets/post_card.dart';
import 'package:buyer_centric_app_v2/widgets/custom_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
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
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildAnimatedImage(),
          const SizedBox(height: 10),
          _buildFeatureTitle(),
          _buildPostCards(),
          _buildBuySellSection(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: CarSearchCard(),
          ),
          const SizedBox(height: 20),
          _buildWantToSellCard(),
          const SizedBox(height: 20),
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
                    fontSize: 20,
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

  Widget _buildAnimatedImage() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Image.asset(
          'assets/images/home_screen_image.png',
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
                onPressed: () {},
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
              ElevatedButton.icon(
                onPressed: () {},
                icon:
                    const Icon(Icons.filter_alt_outlined, color: Colors.black),
                label:
                    const Text('Filter', style: TextStyle(color: Colors.black)),
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostCards() {
    return const Column(
      children: [
        PostCard(
          index: 0,
          carName: 'BMW 5 Series',
          lowRange: 2000000,
          highRange: 2300000,
          image: 'assets/images/car2.png',
          description:
              'Car should be in mint condition and should be the exact same model as specified above. asdg asd gas dg asd ga dg ad ga',
        ),
        PostCard(
          index: 1,
          carName: 'Audi A6',
          lowRange: 2500000,
          highRange: 2700000,
          image: 'assets/images/car1.png',
          description:
              'Car should be in mint condition and should be the exact same model as specified above.',
        ),
      ],
    );
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
}
