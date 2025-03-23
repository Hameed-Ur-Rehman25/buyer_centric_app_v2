/*
 * ! IMPORTANT: Custom filter container widget for car parts selection
 * 
 * * This widget provides:
 * * - Make selection
 * * - Model selection (dependent on make)
 * * - Part type selection
 * * - Image source selection
 * 
 * @see CarPartsScreen
 */

import 'package:flutter/material.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'autocomplete_field.dart';
import 'custom_dropdown.dart';

class FilterContainer extends StatelessWidget {
  // ? Required properties for filter functionality
  final String? selectedMake;
  final String? selectedModel;
  final String? selectedPartType;
  final String? selectedImageOption;
  final List<String> carMakes;
  final Map<String, List<String>> makeToModels;
  final List<String> partTypes;
  final List<String> imageOptions;
  final Function(String) onMakeSelected;
  final Function(String) onModelSelected;
  final Function(String) onPartTypeSelected;
  final Function(String?) onImageOptionSelected;
  final VoidCallback onContinue;
  final bool isSearching;

  // * Constructor with required parameters
  const FilterContainer({
    super.key,
    required this.selectedMake,
    required this.selectedModel,
    required this.selectedPartType,
    required this.selectedImageOption,
    required this.carMakes,
    required this.makeToModels,
    required this.partTypes,
    required this.imageOptions,
    required this.onMakeSelected,
    required this.onModelSelected,
    required this.onPartTypeSelected,
    required this.onImageOptionSelected,
    required this.onContinue,
    required this.isSearching,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Consider adding animation for container appearance
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AutocompleteField(
            label: "Make",
            hint: "Select car make",
            items: carMakes,
            onSelected: onMakeSelected,
            showError: false,
          ),
          const SizedBox(height: 16),
          AutocompleteField(
            label: "Model",
            hint:
                selectedMake == null ? "Select make first" : "Select car model",
            items: makeToModels[selectedMake] ?? [],
            onSelected: onModelSelected,
            showError: false,
            enabled: selectedMake != null,
            disabledColor: Colors.white,
            showDisabledBorder: true,
          ),
          const SizedBox(height: 16),
          AutocompleteField(
            label: "Part Type",
            hint: "Select part type",
            items: partTypes,
            onSelected: onPartTypeSelected,
            showError: false,
          ),
          const SizedBox(height: 16),
          CustomDropdown(
            label: 'Image Source',
            items: imageOptions,
            value: selectedImageOption,
            onChanged: onImageOptionSelected,
          ),
          const SizedBox(height: 16),
          _buildNote(context),
          const SizedBox(height: 16),
          _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildNote(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.buttonGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColor.buttonGreen.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColor.buttonGreen.withOpacity(0.7),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Note: If the part type is not found in the database, select the part type as "Others" and choose "Upload New Image" as the image source.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // * Builds the continue button with loading state
  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isSearching ? null : onContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.buttonGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isSearching
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Continue',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
