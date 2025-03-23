/*
 * ! IMPORTANT: Custom autocomplete field for car parts selection
 * 
 * * Features:
 * * - Dropdown suggestions
 * * - Error state handling
 * * - Disabled state support
 * * - Custom styling
 * 
 * @see FilterContainer
 */

import 'package:flutter/material.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';

class AutocompleteField extends StatelessWidget {
  // ? Required properties for autocomplete functionality
  final String label;
  final String hint;
  final List<String> items;
  final ValueChanged<String> onSelected;
  final bool showError;
  final bool enabled;
  final Color? disabledColor;
  final bool showDisabledBorder;

  // * Constructor with required parameters
  const AutocompleteField({
    Key? key,
    required this.label,
    required this.hint,
    required this.items,
    required this.onSelected,
    required this.showError,
    this.enabled = true,
    this.disabledColor,
    this.showDisabledBorder = false,
  }) : super(key: key);

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
        const SizedBox(height: 5),
        if (enabled) _buildAutocomplete(context) else _buildDisabledField(context),
      ],
    );
  }

  // * Builds the main autocomplete input field
  Widget _buildAutocomplete(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: showError ? Colors.red : Colors.transparent,
          width: 2,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: RawAutocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          return items.where((item) =>
              item.toLowerCase().contains(textEditingValue.text.toLowerCase()));
        },
        onSelected: onSelected,
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          return TextFormField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade600),
            ),
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          final displayOptions = options.isEmpty ? items : options.toList();
          return _buildOptionsOverlay(context, displayOptions, onSelected);
        },
      ),
    );
  }

  // * Builds the options overlay for suggestions
  Widget _buildOptionsOverlay(
    BuildContext context,
    List<String> displayOptions,
    AutocompleteOnSelected<String> onSelected,
  ) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        color: Colors.white,
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.3,
          ),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: displayOptions.length,
            itemBuilder: (context, index) {
              final option = displayOptions[index];
              return ListTile(
                title: Text(
                  option,
                  style: const TextStyle(color: Colors.black),
                ),
                onTap: () {
                  onSelected(option);
                  FocusScope.of(context).unfocus();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // * Builds disabled state view
  Widget _buildDisabledField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: disabledColor ?? Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        border: showDisabledBorder
            ? Border.all(
                color: AppColor.buttonGreen.withOpacity(0.3),
                width: 1,
              )
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Row(
        children: [
          Expanded(
            child: Text(
              hint,
              style: TextStyle(
                color: disabledColor == Colors.white 
                    ? Colors.grey.shade600 
                    : Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ),
          Icon(
            Icons.arrow_drop_down,
            color: disabledColor == Colors.white 
                ? Colors.grey.shade600 
                : Colors.white.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}
