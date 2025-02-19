import 'package:flutter/material.dart';
import 'dart:async';

class CarSearchCard extends StatefulWidget {
  const CarSearchCard({super.key});

  @override
  _CarSearchCardState createState() => _CarSearchCardState();
}

class _CarSearchCardState extends State<CarSearchCard> {
  String? selectedMake;
  String? selectedModel;
  String? selectedVariant;
  String? selectedYear;

  bool showMakeError = false;
  bool showModelError = false;
  bool showVariantError = false;
  bool showYearError = false;

  final List<String> makes = ['Toyota', 'Honda', 'Ford', 'BMW'];
  final List<String> models = ['Model A', 'Model B', 'Model C'];
  final List<String> variants = ['Variant 1', 'Variant 2', 'Variant 3'];
  final List<String> years = ['2022', '2023', '2024'];

  void validateAndSearch() {
    setState(() {
      showMakeError = selectedMake == null || selectedMake!.isEmpty;
      showModelError = selectedModel == null || selectedModel!.isEmpty;
      showVariantError = selectedVariant == null || selectedVariant!.isEmpty;
      showYearError = selectedYear == null || selectedYear!.isEmpty;
    });

    if (showMakeError || showModelError || showVariantError || showYearError) {
      Timer(const Duration(seconds: 1), () {
        setState(() {
          showMakeError = false;
          showModelError = false;
          showVariantError = false;
          showYearError = false;
        });
      });
    } else {
      print(
          "Searching for: $selectedMake $selectedModel $selectedVariant $selectedYear");
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
          _buildAutocompleteField("Make", "Select car make", makes, (value) {
            setState(() {
              selectedMake = value;
              showMakeError = false;
            });
          }, showMakeError),
          const SizedBox(height: 10),
          _buildAutocompleteField("Model", "Select car model", models, (value) {
            setState(() {
              selectedModel = value;
              showModelError = false;
            });
          }, showModelError),
          const SizedBox(height: 10),
          _buildAutocompleteField("Variant", "Select car variant", variants,
              (value) {
            setState(() {
              selectedVariant = value;
              showVariantError = false;
            });
          }, showVariantError),
          const SizedBox(height: 10),
          _buildAutocompleteField("Year", "Select car year", years, (value) {
            setState(() {
              selectedYear = value;
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
