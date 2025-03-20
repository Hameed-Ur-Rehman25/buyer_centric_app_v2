import 'package:buyer_centric_app_v2/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';

// PostCard widget to display car details
class PostCard extends StatefulWidget {
  final String carName;
  final int lowRange;
  final int highRange;
  final String image;
  final String description;
  final int index;
  final VoidCallback onTap;
  final bool isSeller;
  final bool isBuyer;
  final String? userId;

  const PostCard({
    super.key,
    required this.carName,
    required this.lowRange,
    required this.highRange,
    required this.image,
    required this.description,
    required this.index,
    required this.onTap,
    this.isSeller = false,
    this.isBuyer = false,
    this.userId,
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
    return InkWell(
      onTap: () => _navigateToCarDetails(context),
      child: Hero(
        tag: 'car-image-${widget.carName}-${widget.index}',
        child: Image.network(
          widget.image,
          width: 250,
          height: 150,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: 250,
              height: 150,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 250,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image_rounded,
                    size: 50,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Image not available',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          },
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
            text: widget.carName,
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
            text: '   PKR ${widget.lowRange} - ${widget.highRange}',
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
    Navigator.pushNamed(
      context,
      AppRoutes.carDetails,
      arguments: {
        'image': widget.image,
        'carName': widget.carName,
        'lowRange': widget.lowRange,
        'highRange': widget.highRange,
        'description': widget.description,
        'index': widget.index,
        'userId': widget.userId ?? '',
      },
    );
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

  void _navigateToInfo() {
    Navigator.pushNamed(context, AppRoutes.carDetails, arguments: {
      'image': widget.image,
      'carName': widget.carName,
      'lowRange': widget.lowRange,
      'highRange': widget.highRange,
      'description': widget.description,
      'index': widget.index,
    });
  }
}
