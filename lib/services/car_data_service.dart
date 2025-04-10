import 'dart:convert';
import 'package:flutter/services.dart';

class Car {
  final int id;
  final String make;
  final String model;
  final int year;
  final String color;
  final String transmission;
  final String fuelType;
  final String engine;
  final String bodyType;
  final List<String> features;
  final List<String> imageUrls;

  Car({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.transmission,
    required this.fuelType,
    required this.engine,
    required this.bodyType,
    required this.features,
    required this.imageUrls,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'],
      make: json['make'],
      model: json['model'],
      year: json['year'],
      color: json['color'],
      transmission: json['transmission'],
      fuelType: json['fuel_type'],
      engine: json['engine'],
      bodyType: json['body_type'],
      features: List<String>.from(json['features']),
      imageUrls: List<String>.from(json['image_urls']),
    );
  }
}

class CarDataService {
  List<Car> _cars = [];

  Future<void> loadCars() async {
    final String jsonData = await rootBundle.loadString('lib/data/carData.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonData);
    final List<dynamic> carsJson = jsonMap['cars'];
    
    _cars = carsJson.map((carJson) => Car.fromJson(carJson)).toList();
  }

  List<Car> get cars => _cars;

  List<String> getUniqueMakes() {
    return _cars.map((car) => car.make).toSet().toList()..sort();
  }

  List<String> getModelsForMake(String make) {
    return _cars
        .where((car) => car.make == make)
        .map((car) => car.model)
        .toSet()
        .toList()
        ..sort();
  }

  List<int> getYearsForMakeAndModel(String make, String model) {
    return _cars
        .where((car) => car.make == make && car.model == model)
        .map((car) => car.year)
        .toSet()
        .toList()
        ..sort();
  }

  Car? findCar(String make, String model, int year) {
    try {
      return _cars.firstWhere(
        (car) => 
          car.make == make && 
          car.model == model && 
          car.year == year
      );
    } catch (e) {
      return null;
    }
  }
} 