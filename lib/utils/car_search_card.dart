import 'dart:async';
import 'package:buyer_centric_app_v2/screens/buy%20car/create_car_post_screen.dart';
import 'package:buyer_centric_app_v2/services/car_data_service.dart';
import 'package:flutter/material.dart';
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

  // Add this variable to track loading state
  bool _isSearching = false;
  bool _isLoading = true;

  // Car data service
  final CarDataService _carDataService = CarDataService();
  
  // Lists for dropdowns
  List<String> _carMakes = [];
  List<String> _carModels = [];
  List<String> _carYears = [];
  List<String> _variants = ['Base', 'Sport', 'Luxury']; // Default variants

  @override
  void initState() {
    super.initState();
    _loadCarData();
  }

  Future<void> _loadCarData() async {
    setState(() {
      _isLoading = true;
    });
    
    await _carDataService.loadCars();
    
    setState(() {
      _carMakes = _carDataService.getUniqueMakes();
      _isLoading = false;
    });
  }

  void _updateModels(String make) {
    setState(() {
      selectedMake = make;
      selectedModel = null;
      selectedYear = null;
      _carModels = _carDataService.getModelsForMake(make);
      showMakeError = false;
    });
  }

  void _updateYears(String model) {
    setState(() {
      selectedModel = model;
      selectedYear = null;
      if (selectedMake != null) {
        final years = _carDataService.getYearsForMakeAndModel(selectedMake!, model);
        _carYears = years.map((year) => year.toString()).toList();
      }
      showModelError = false;
    });
  }

  void validateAndSearch() async {
    setState(() {
      showMakeError = selectedMake == null || selectedMake!.isEmpty;
      showModelError = selectedModel == null || selectedModel!.isEmpty;
      showYearError = selectedYear == null || selectedYear!.isNaN;
      showVariantError = false;
      _isSearching = true;
    });

    if (showMakeError || showModelError || showYearError) {
      Timer(const Duration(seconds: 1), () {
        setState(() {
          showMakeError = false;
          showModelError = false;
          showYearError = false;
          _isSearching = false;
        });
      });
    } else {
      try {
        final car = _carDataService.findCar(
          selectedMake!, 
          selectedModel!, 
          selectedYear!
        );

        if (car != null) {
          CustomSnackbar.showSuccess(context, 'Car details found');
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, scrollController) => Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: CreateCarPostScreen(
                  make: car.make,
                  model: car.model,
                  year: car.year.toString(),
                  imageUrl: car.imageUrls.isNotEmpty ? car.imageUrls.first : '',
                  color: car.color,
                  transmission: car.transmission,
                  fuelType: car.fuelType,
                  engine: car.engine,
                  bodyType: car.bodyType,
                  features: car.features,
                  imageUrls: car.imageUrls,
                ),
              ),
            ),
          );
        } else {
          CustomSnackbar.showError(context, 'No car details found');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSearching = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
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
            _updateModels(value);
          }, showMakeError),
          const SizedBox(height: 10),
          _buildAutocompleteField("Model", "Select car model", _carModels,
              (value) {
            _updateYears(value);
          }, showModelError),
          const SizedBox(height: 10),
          _buildAutocompleteField(
              "Variant (Optional)", "Select car variant", _variants, (value) {
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
            onPressed: _isSearching ? null : validateAndSearch,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: _isSearching ? Colors.grey : Colors.white,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: _isSearching
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Searching...",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : const Text(
                    "Search",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
