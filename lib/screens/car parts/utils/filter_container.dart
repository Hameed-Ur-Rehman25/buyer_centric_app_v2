/*
 * ! IMPORTANT: Custom filter container widget for car parts selection
 * 
 * * This widget provides:
 * * - Item type filter (car parts, cars, or all)
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
  final ButtonStyle continueButtonStyle;
  // Item type filter properties
  final String selectedItemType;
  final Function(String) onItemTypeSelected;

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
    required this.continueButtonStyle,
    this.selectedItemType = 'all',
    required this.onItemTypeSelected,
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
          // Item type selection
          _buildItemTypeFilter(context),
          const SizedBox(height: 16),
          // Divider for visual separation
          Divider(color: Colors.white.withOpacity(0.2), thickness: 1),
          const SizedBox(height: 16),
          
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

  // Item type filter widget
  Widget _buildItemTypeFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Show Items',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildRadioOption('all', 'All Items'),
            const SizedBox(width: 16),
            _buildRadioOption('car', 'Cars Only'),
            const SizedBox(width: 16),
            _buildRadioOption('car_part', 'Parts Only'),
          ],
        ),
      ],
    );
  }

  // Individual radio option
  Widget _buildRadioOption(String value, String label) {
    return Expanded(
      child: InkWell(
        onTap: () => onItemTypeSelected(value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: selectedItemType == value
                ? AppColor.buttonGreen.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selectedItemType == value
                  ? AppColor.buttonGreen
                  : Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selectedItemType == value
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selectedItemType == value
                    ? AppColor.buttonGreen
                    : Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
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
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColor.white,
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
        style: continueButtonStyle,
        child: isSearching
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              )
            : const Text(
                'Continue',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
