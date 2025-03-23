import 'package:flutter/material.dart';

class CarData {
  static const List<String> carMakes = [
    'Toyota',
    'Honda',
    'Ford',
    'Chevrolet',
    'Nissan'
  ];

  static const Map<String, List<String>> makeToModels = {
    'Toyota': ['Camry', 'Corolla', 'Prius'],
    'Honda': ['Civic', 'Accord', 'Fit'],
    'Ford': ['Focus', 'Mustang', 'Explorer'],
    'Chevrolet': ['Malibu', 'Impala', 'Cruze'],
    'Nissan': ['Altima', 'Sentra', 'Maxima']
  };

  static const List<String> partTypes = [
    'Engine',
    'Transmission',
    'Brakes',
    'Suspension',
    'Electrical',
    'Body Parts',
    'Interior',
    'Exterior',
    'Other'
  ];

  static const List<String> imageOptions = [
    'Retrieve from Database',
    'Upload New Image'
  ];
}

class CarPartFilter {
  final String? make;
  final String? model;
  final String? partType;
  final String? imageOption;

  const CarPartFilter({
    this.make,
    this.model,
    this.partType,
    this.imageOption,
  });

  bool get isComplete => 
    make != null && model != null && partType != null && imageOption != null;

  CarPartFilter copyWith({
    String? make,
    String? model,
    String? partType,
    String? imageOption,
  }) {
    return CarPartFilter(
      make: make ?? this.make,
      model: model ?? this.model,
      partType: partType ?? this.partType,
      imageOption: imageOption ?? this.imageOption,
    );
  }
} 