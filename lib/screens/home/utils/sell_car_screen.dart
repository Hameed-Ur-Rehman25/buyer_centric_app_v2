import 'package:buyer_centric_app_v2/utils/bottom_nav_bar.dart';
import 'package:buyer_centric_app_v2/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//* when the user clicks on the place bid this screen will be shown to the user
//* the user can place a bid on the car
class SellCarScreen extends StatelessWidget {
  const SellCarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        showSearchBar: false,
      ),

      body: Column(
        children: [
          Row(
            children: [
              //bac button
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios),
              ),
              //title bidding
              const Text(
                'Bidding',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          //upload text
          const Text(
            'Upload Images',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          //outline container with choose file and drage and drop text and with the outline bbutton upload
          Container(
            height: 200,
            width: 300,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Choose a file or drag & drop it here',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    // fontFamily: GoogleFonts.montserrat().fontFamily,
                  ),
                ),
                OutlinedButton(
                  onPressed: null, //TODO: Implement file picker
                  child: const Text('Browse file'),
                  style: OutlinedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      //TODO: Nav Bar not working properly
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTabSelected: (index) {},
      ),
    );
  }
}
