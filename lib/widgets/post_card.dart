import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PostCard extends StatelessWidget {
  final String carName;
  final int lowRange;
  final int highRange;
  final String image;

  const PostCard({
    super.key,
    required this.carName,
    required this.lowRange,
    required this.highRange,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.07, vertical: 10),
      color: AppColor.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 4,
      child: Column(
        children: [
          Row(
            children: [
              //feature
              Container(
                padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColor.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: Text(
                  'FEATURED',
                  style: TextStyle(
                    color: AppColor.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
              Spacer(),
              //info icon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: SvgPicture.asset(
                  'assets/svg/info_icon.svg',
                  height: 29,
                ),
              ),
            ],
          ),

          //* image
          Image.asset(
            image,
            // height: 100,
            width: 250,
            // fit: BoxFit.cover,
          ),

          //* car name
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColor.black,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: carName,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        TextSpan(
                          text: '\nRange',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        TextSpan(
                          text: '   PKR ${lowRange}k - $highRange',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColor.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),

                  //* Buttons

                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        MaterialButton(
                          onPressed: () {},
                          color: AppColor.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
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
                          child: Text(
                            'View Bids',
                            style: TextStyle(
                              color: AppColor.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
