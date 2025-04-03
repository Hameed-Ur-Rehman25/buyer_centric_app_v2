import 'package:flutter/material.dart';
import '../models/car_data.dart';
import '../custom_dropdown.dart';

class CarPartFilterWidget extends StatelessWidget {
  final CarPartFilter filter;
  final Function(CarPartFilter) onFilterChanged;
  final VoidCallback onContinue;
  final bool isLoading;

  const CarPartFilterWidget({
    super.key,
    required this.filter,
    required this.onFilterChanged,
    required this.onContinue,
    this.isLoading = false,
  });

  void _updateFilter({
    String? make,
    String? model,
    String? partType,
    String? imageOption,
  }) {
    onFilterChanged(filter.copyWith(
      make: make,
      model: model,
      partType: partType,
      imageOption: imageOption,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomDropdown(
            label: 'Make',
            value: filter.make,
            items: CarData.carMakes,
            onChanged: (value) => _updateFilter(make: value),
          ),
          const SizedBox(height: 16),
          CustomDropdown(
            label: 'Model',
            value: filter.model,
            items: filter.make != null
                ? CarData.makeToModels[filter.make] ?? []
                : [],
            onChanged: (value) => _updateFilter(model: value),
            enabled: filter.make != null,
          ),
          const SizedBox(height: 16),
          CustomDropdown(
            label: 'Part Type',
            value: filter.partType,
            items: CarData.partTypes,
            onChanged: (value) => _updateFilter(partType: value),
          ),
          const SizedBox(height: 16),
          CustomDropdown(
            label: 'Image Source',
            value: filter.imageOption,
            items: CarData.imageOptions,
            onChanged: (value) => _updateFilter(imageOption: value),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: filter.isComplete && !isLoading ? onContinue : null,
            child: isLoading
                ? const CircularProgressIndicator()
                : const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
