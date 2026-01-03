// lib/features/medicines/data/models/medicine_model.dart
import 'dart:developer';
import 'package:flutter/material.dart';

class MedicineModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String category;
  final bool requiresPrescription;
  final String imageUrl;
  final int stock;
  final String manufacturer;
  final String dosage;
  
  MedicineModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.requiresPrescription,
    required this.imageUrl ,
    required this.stock,
    this.manufacturer = '',
    this.dosage = '',
  });
  
  factory MedicineModel.fromMap(Map<String, dynamic> map) {
    log('📄 Creating MedicineModel from map');
    log('📄 Map data: $map');
    
    try {
      final model = MedicineModel(
        id: map['id']?.toInt() ?? 0,
        name: map['name']?.toString() ?? 'Unknown',
        description: map['description']?.toString() ?? '',
        price: (map['price'] is double) 
            ? map['price'] as double 
            : (map['price'] is int) 
                ? (map['price'] as int).toDouble()
                : double.tryParse(map['price']?.toString() ?? '0') ?? 0.0,
        category: map['category']?.toString() ?? 'General',
        requiresPrescription: (map['requires_prescription'] ?? 0) == 1,
        imageUrl: map['image_url']?.toString() ?? 'assets/medicines/paracetamol.jpg',
        stock: map['stock']?.toInt() ?? 0,
        manufacturer: map['manufacturer']?.toString() ?? '',
        dosage: map['dosage']?.toString() ?? '',
      );
      
      log('✅ MedicineModel created: ${model.name} (ID: ${model.id})');
      return model;
    } catch (e) {
      log('❌ Error creating MedicineModel: $e');
      log('❌ Map that caused error: $map');
      rethrow;
    }
  }
  
  Map<String, dynamic> toMap() {
    log('📝 Converting MedicineModel to map: $name');
    
    final map = <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'image_url': imageUrl,
      'requires_prescription': requiresPrescription ? 1 : 0,
      'stock': stock,
    };
    
   // map['image_url'] = imageUrl; // Add ! to assert not null
      if (manufacturer.isNotEmpty) {
      map['manufacturer'] = manufacturer;
    }
    if (dosage.isNotEmpty) {
      map['dosage'] = dosage;
    }
    
    log('✅ MedicineModel converted to map');
    return map;
  }
  
  MedicineModel copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? category,
    bool? requiresPrescription,
    String? imageUrl,
    int? stock,
    String? manufacturer,
    String? dosage,
  }) {
    log('📋 Creating copy of MedicineModel: $name');
    
    return MedicineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      requiresPrescription: requiresPrescription ?? this.requiresPrescription,
      imageUrl: imageUrl ?? this.imageUrl,
      stock: stock ?? this.stock,
      manufacturer: manufacturer ?? this.manufacturer,
      dosage: dosage ?? this.dosage,
    );
  }
  
  @override
  String toString() {
    return 'MedicineModel(id: $id, name: $name, price: $price F, category: $category, stock: $stock)';
  }
  
  // Helper methods
  String get formattedPrice {
    return '${price.toStringAsFixed(0)}F';
  }
  
  bool get isInStock {
    return stock > 0;
  }
  
  String get prescriptionStatus {
    return requiresPrescription ? 'Prescription Required' : 'Available OTC';
  }
  
  String get stockStatus {
    if (stock > 20) return 'In Stock';
    if (stock > 0) return 'Low Stock';
    return 'Out of Stock';
  }
  
  Color get stockColor {
    if (stock > 20) return Colors.green;
    if (stock > 0) return Colors.orange;
    return Colors.red;
  }
}