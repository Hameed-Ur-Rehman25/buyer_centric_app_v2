import 'dart:async';
import 'package:buyer_centric_app_v2/utils/all_cars.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buyer_centric_app_v2/utils/snackbar.dart';

class CarSearchCard extends StatefulWidget {
  const CarSearchCard({super.key});

  @override
  _CarSearchCardState createState() => _CarSearchCardState();
}

class _CarSearchCardState extends State<CarSearchCard> {
  String? selectedMake;
  String? selectedModel;
  String? selectedVariant;
  int? selectedYear;

  bool showMakeError = false;
  bool showModelError = false;
  bool showVariantError = false;
  bool showYearError = false;

  // List of car makes to populate the dropdown
  final List<String> _carMakes = [
    'Toyota',
    'Honda',
    'Ford',
    'Chevrolet',
    'Nissan'
  ];

  // List of car models, initially empty
  List<String> _carModels = [];

  // List of car years from 1990 to the current year
  final List<String> _carYears = List.generate(
      DateTime.now().year - 1990 + 2, (index) => (1990 + index).toString());

  // List of car variants, initially empty
  List<String> variants = [];

  // Map of car makes to their respective models
  final Map<String, List<String>> _makeToModels = {
    'Toyota': ['Camry', 'Corolla', 'Prius'],
    'Honda': ['Civic', 'Accord', 'Fit'],
    'Ford': ['Focus', 'Mustang', 'Explorer'],
    'Chevrolet': ['Malibu', 'Impala', 'Cruze'],
    'Nissan': ['Altima', 'Sentra', 'Maxima']
  };

  // Map of car models to their respective variants
  final Map<String, List<String>> _modelToVariants = {
    'Camry': ['Base', 'Sport', 'Luxury'],
    'Corolla': ['Base', 'Sport', 'Luxury'],
    'Prius': ['Base', 'Sport', 'Luxury'],
    'Civic': ['Base', 'Oriel', 'Luxury'],
    'Accord': ['Base', 'Sport', 'Luxury'],
    'Fit': ['Base', 'Sport', 'Luxury'],
    'Focus': ['Base', 'Sport', 'Luxury'],
    'Mustang': ['Base', 'Sport', 'Luxury'],
    'Explorer': ['Base', 'Sport', 'Luxury'],
    'Malibu': ['Base', 'Sport', 'Luxury'],
    'Impala': ['Base', 'Sport', 'Luxury'],
    'Cruze': ['Base', 'Sport', 'Luxury'],
    'Altima': ['Base', 'Sport', 'Luxury'],
    'Sentra': ['Base', 'Sport', 'Luxury'],
    'Maxima': ['Base', 'Sport', 'Luxury']
  };

  void validateAndSearch() async {
    setState(() {
      showMakeError = selectedMake == null || selectedMake!.isEmpty;
      showModelError = selectedModel == null || selectedModel!.isEmpty;
      showYearError = selectedYear == null || selectedYear!.isNaN;
    });

    if (showMakeError || showModelError || showYearError) {
      Timer(const Duration(seconds: 1), () {
        setState(() {
          showMakeError = false;
          showModelError = false;
          showYearError = false;
        });
      });
    } else {
      // Fetch car details from Firebase
      final carDetails = await fetchCarDetails(
          selectedMake!, selectedModel!, selectedVariant, selectedYear!);
      if (carDetails != null) {
        CustomSnackbar.showSuccess(context, 'Car details found');
        //TODO: Navigate to car details screen
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => CarDetailsScreenPost(carDetails: carDetails),
        //   ),
        // );
      } else {
        CustomSnackbar.showError(context, 'No car details found');
      }
    }
  }

  Future<Map<String, dynamic>?> fetchCarDetails(
      String make, String model, String? variant, int year) async {
    print('Fetching car details for: $make, $model, $variant, $year');

    // Convert values to lowercase to match case with database
    make = make.toLowerCase();
    model = model.toLowerCase();
    variant = variant?.toLowerCase();

    var query = FirebaseFirestore.instance
        .collection('cars')
        .where('make', isEqualTo: make)
        .where('model', isEqualTo: model)
        .where('year', isEqualTo: year);

    if (variant != null && variant.isNotEmpty) {
      query = query.where('variant', isEqualTo: variant);
    }

    final querySnapshot = await query.get();

    if (querySnapshot.docs.isNotEmpty) {
      print('Car details found: ${querySnapshot.docs.first.data()}');
      return querySnapshot.docs.first.data();
    } else {
      print(
          'No car details found. Query params: make=$make, model=$model, variant=$variant, year=$year');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAutocompleteField("Make", "Select car make", _carMakes,
              (value) {
            setState(() {
              selectedMake = value;
              showMakeError = false;
              _carModels = _makeToModels[value] ?? [];
            });
          }, showMakeError),
          const SizedBox(height: 10),
          _buildAutocompleteField("Model", "Select car model", _carModels,
              (value) {
            setState(() {
              selectedModel = value;
              showModelError = false;
            });
          }, showModelError),
          const SizedBox(height: 10),
          _buildAutocompleteField(
              "Variant (Optional)", "Select car variant", variants, (value) {
            setState(() {
              selectedVariant = value;
              showVariantError = false;
            });
          }, showVariantError),
          const SizedBox(height: 10),
          _buildAutocompleteField("Year", "Select car year", _carYears,
              (value) {
            setState(() {
              selectedYear = int.tryParse(value);
              showYearError = false;
            });
          }, showYearError),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: validateAndSearch,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: const Text(
              "Search",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          //Outline button navigate to allcarscreen
          OutlinedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const AllCarsScreen();
              }));
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: const Text(
              "All Cars",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutocompleteField(String label, String hint, List<String> items,
      ValueChanged<String> onSelected, bool showError) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: showError ? Colors.red : Colors.transparent, width: 2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              return items.where((item) => item
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase()));
            },
            onSelected: onSelected,
            fieldViewBuilder:
                (context, controller, focusNode, onFieldSubmitted) {
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                ),
                style: const TextStyle(color: Colors.black),
                onTap: () {
                  if (controller.text.isEmpty) {
                    setState(() {});
                  }
                },
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      showError = false;
                    });
                  }
                },
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              final List<String> displayOptions =
                  options.isEmpty ? items : options.toList();
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  color: Colors.white,
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 250,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      children: displayOptions.map((option) {
                        return ListTile(
                          title: Text(option,
                              style: const TextStyle(color: Colors.black)),
                          onTap: () => onSelected(option),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
