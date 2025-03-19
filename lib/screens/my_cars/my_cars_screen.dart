import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:buyer_centric_app_v2/services/auth_service.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/widgets/custom_app_bar.dart';
import 'package:buyer_centric_app_v2/utils/bottom_nav_bar.dart';

class MyCarsScreen extends StatefulWidget {
  const MyCarsScreen({super.key});

  @override
  State<MyCarsScreen> createState() => _MyCarsScreenState();
}

class _MyCarsScreenState extends State<MyCarsScreen> {
  bool _isSelectingCar = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context, listen: false).currentUser;

    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: const CustomAppBar(showSearchBar: false),
      body: _isSelectingCar 
          ? _buildAvailableCarsToSelect() 
          : _buildUserCarsList(user!.uid),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTabSelected: (index) {},
      ),
      floatingActionButton: !_isSelectingCar
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isSelectingCar = true;
                });
              },
              backgroundColor: AppColor.black,
              child: const Icon(Icons.add, color: AppColor.white),
            )
          : null,
    );
  }

  Widget _buildUserCarsList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('selected_cars')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No cars selected yet',
                  style: TextStyle(
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isSelectingCar = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.black,
                    foregroundColor: AppColor.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Select Your First Car'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final car = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: car['carImageUrl'] != null
                      ? Image.network(
                          car['carImageUrl'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          child: const Icon(Icons.directions_car),
                        ),
                ),
                title: Text(
                  car['carModel'] ?? 'Unknown Model',
                  style: TextStyle(
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  'Price Range: \$${car['minPrice']} - \$${car['maxPrice']}',
                  style: TextStyle(
                    fontFamily: GoogleFonts.inter().fontFamily,
                    color: Colors.grey[600],
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .collection('selected_cars')
                        .doc(snapshot.data!.docs[index].id)
                        .delete();
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAvailableCarsToSelect() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          color: AppColor.white,
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSelectingCar = false;
                  });
                },
                icon: const Icon(Icons.arrow_back_ios),
              ),
              const SizedBox(width: 8),
              Text(
                'Select a Car',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final car = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColor.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: car['carImageUrl'] != null
                            ? Image.network(
                                car['carImageUrl'],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[200],
                                child: const Icon(Icons.directions_car),
                              ),
                      ),
                      title: Text(
                        car['carModel'] ?? 'Unknown Model',
                        style: TextStyle(
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'Price Range: \$${car['minPrice']} - \$${car['maxPrice']}',
                        style: TextStyle(
                          fontFamily: GoogleFonts.inter().fontFamily,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: OutlinedButton(
                        onPressed: () async {
                          final user = Provider.of<AuthService>(context, listen: false).currentUser;
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user!.uid)
                              .collection('selected_cars')
                              .add({
                                'carId': snapshot.data!.docs[index].id,
                                'carModel': car['carModel'],
                                'carImageUrl': car['carImageUrl'],
                                'minPrice': car['minPrice'],
                                'maxPrice': car['maxPrice'],
                                'selectedAt': DateTime.now(),
                              });

                          setState(() {
                            _isSelectingCar = false;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColor.black,
                          side: const BorderSide(color: AppColor.black),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Select'),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
} 