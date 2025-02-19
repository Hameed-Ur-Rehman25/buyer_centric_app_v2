import 'package:flutter/material.dart';

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

  final List<String> makes = ['Toyota', 'Honda', 'Ford', 'BMW'];
  final List<String> models = ['Model A', 'Model B', 'Model C'];
  final List<String> variants = ['Variant 1', 'Variant 2', 'Variant 3'];
  final List<String> years = ['2022', '2023', '2024'];

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
          _buildAutocompleteField("Make", makes, (value) {
            setState(() => selectedMake = value);
          }),
          const SizedBox(height: 10),
          _buildAutocompleteField("Model", models, (value) {
            setState(() => selectedModel = value);
          }),
          const SizedBox(height: 10),
          _buildAutocompleteField("Variant", variants, (value) {
            setState(() => selectedVariant = value);
          }),
          const SizedBox(height: 10),
          _buildAutocompleteField("Year", years, (value) {
            setState(() => selectedYear = value);
          }),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              print(
                  "Searching for: $selectedMake $selectedModel $selectedVariant $selectedYear");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              textStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: const Text("Search"),
          ),
        ],
      ),
    );
  }

  Widget _buildAutocompleteField(
      String label, List<String> items, ValueChanged<String> onSelected) {
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
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
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
                decoration: const InputDecoration(border: InputBorder.none),
                style: const TextStyle(color: Colors.black),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
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
                      children: options.map((option) {
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
