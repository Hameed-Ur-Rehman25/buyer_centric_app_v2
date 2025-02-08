import 'package:buyer_centric_app_v2/screens/car_details_screen.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PostCard extends StatefulWidget {
  final String carName;
  final int lowRange;
  final int highRange;
  final String image;
  final int index; // Added for staggered animation

  const PostCard({
    super.key,
    required this.carName,
    required this.lowRange,
    required this.highRange,
    required this.image,
    required this.index,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3), // Slide from below
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    // Staggered animation delay
    Future.delayed(Duration(milliseconds: widget.index * 200), () {
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Card(
          margin:
              EdgeInsets.symmetric(horizontal: size.width * 0.07, vertical: 10),
          color: AppColor.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColor.black,
                      borderRadius: const BorderRadius.only(
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
                    child: SvgPicture.asset(
                      'assets/svg/info_icon.svg',
                      height: 29,
                    ),
                  ),
                ],
              ),

              //* Car Image with Hero Animation
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          CarDetailsScreen(image: widget.image),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                    ),
                  );
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => CarDetailsScreen(
                  //       image: widget.image,
                  //     ),
                  //   ),
                  // );
                },
                child: Hero(
                  tag: 'car-image-${widget.index}', // Unique tag for each car
                  child: Image.asset(
                    widget.image,
                    width: 250,
                  ),
                ),
              ),

              //* Car Name & Price
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColor.black,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: widget.carName,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            TextSpan(
                              text: '\nRange',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text:
                                  '   PKR ${widget.lowRange} - ${widget.highRange}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColor.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          MaterialButton(
                            onPressed: () {},
                            color: AppColor.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Place Bid',
                              style: TextStyle(
                                color: AppColor.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          MaterialButton(
                            onPressed: () {},
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
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
