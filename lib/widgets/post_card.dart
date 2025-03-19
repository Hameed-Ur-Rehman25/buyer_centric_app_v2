import 'package:buyer_centric_app_v2/routes/app_routes.dart';
import 'package:buyer_centric_app_v2/screens/car%20details/car_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';

// PostCard widget to display car details
class PostCard extends StatefulWidget {
  final Car car;
  final VoidCallback onTap;

  const PostCard({
    Key? key,
    required this.car,
    required this.onTap,
  }) : super(key: key);

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
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

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
        child: GestureDetector(
          onTap: widget.onTap,
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
    return InkWell(
      onTap: () => _navigateToCarDetails(context),
      child: Hero(
        tag: 'car-image-${widget.index}',
        child: Image.asset(
          widget.car.image,
          width: 250,
        ),
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
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${widget.car.make} ${widget.car.model} ${widget.car.year}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColor.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          TextSpan(
            text: '\nRange',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.w600, color: AppColor.white),
          ),
          TextSpan(
            text: '   PKR ${widget.car.lowRange} - ${widget.car.highRange}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColor.green,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        MaterialButton(
          onPressed: () {
            //TODO: Implement place bid functionality
            Navigator.pushNamed(context, AppRoutes.sellCar);
          },
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
        _buildBidButton(context),
      ],
    );
  }

  Widget _buildBidButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CarDetailsScreen(
              image: widget.car.image,
              carName:
                  '${widget.car.make} ${widget.car.model} ${widget.car.year}',
              lowRange: widget.car.lowRange,
              highRange: widget.car.highRange,
              description: widget.car.description,
              index: widget.index,
            ),
          ),
        );
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      ),
      child: const Row(
        children: [
          Text(
            "View Bid",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10),
          Icon(Icons.arrow_forward, color: Colors.white),
        ],
      ),
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
            text: widget.car.description.length > 90
                ? '${widget.car.description.substring(0, 90)}... '
                : widget.car.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColor.white,
                  fontWeight: FontWeight.w400,
                ),
          ),
          if (widget.car.description.length > 100)
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
    Navigator.pushNamed(
      context,
      AppRoutes.carDetails,
      arguments: {
        'image': widget.car.image,
        'carName': '${widget.car.make} ${widget.car.model} ${widget.car.year}',
        'lowRange': widget.car.lowRange,
        'highRange': widget.car.highRange,
        'description': widget.car.description,
        'index': widget.index,
      },
    );
  }

  Widget _buildBidOptions() {
    return Row(children: [
      if (widget.isSeller) ...[
        ElevatedButton.icon(
            onPressed: () => _showPlaceBidDialog(context),
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

  void _showPlaceBidDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Place Bid'),
        content: const TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: 'Enter bid amount'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement bid placement logic
              Navigator.pop(context);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _navigateToChat() {
    Navigator.pushNamed(context, AppRoutes.chat, arguments: {
      'postId': widget.index,
      'carName': '${widget.car.make} ${widget.car.model} ${widget.car.year}',
    });
  }

  void _navigateToInfo() {
    Navigator.pushNamed(context, AppRoutes.carDetails, arguments: {
      'image': widget.car.image,
      'carName': '${widget.car.make} ${widget.car.model} ${widget.car.year}',
      'lowRange': widget.car.lowRange,
      'highRange': widget.car.highRange,
      'description': widget.car.description,
      'index': widget.index,
    });
  }
}
