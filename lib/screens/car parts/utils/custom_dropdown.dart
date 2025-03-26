import 'package:flutter/material.dart';

/*
 * ! IMPORTANT: Custom dropdown widget for image source selection
 * 
 * * Features:
 * * - Custom styling
 * * - Error state handling
 * * - Disabled state support
 * 
 * @see FilterContainer
 */

class CustomDropdown extends StatelessWidget {
  // ? Required properties for dropdown functionality
  final String label;

  final List<String> items;
  final String? value;
  final void Function(String?) onChanged;
  final bool enabled;

  // * Constructor with required parameters
  const CustomDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList(),
              onChanged: enabled ? onChanged : null,
              isExpanded: true,
              hint: Text(
                'Select $label',
                style: TextStyle(color: Colors.grey[600]),
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
