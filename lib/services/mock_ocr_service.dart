// DEMO VERSION - Replace with real ML Kit OCR for production

import 'dart:math';

/// Mock OCR Service for simulating water level extraction
///
/// This service simulates OCR processing for demonstration purposes.
/// In production, replace this with actual ML Kit OCR implementation.
class MockOCRService {
  static final MockOCRService _instance = MockOCRService._internal();
  factory MockOCRService() => _instance;
  MockOCRService._internal();

  final Random _random = Random();

  /// Simulates OCR extraction of water level from an image
  ///
  /// [imagePath] - Path to the image file to process
  /// Returns a Map containing the extracted water level data
  Future<Map<String, dynamic>> extractWaterLevel(String imagePath) async {
    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Generate random realistic water level reading (5.0 to 15.0 meters)
    final double reading = 5.0 + (_random.nextDouble() * 10.0);

    // Generate high confidence score (0.85 to 0.99)
    final double confidence = 0.85 + (_random.nextDouble() * 0.14);

    // Format the reading as a string
    final String extractedText = "${reading.toStringAsFixed(2)} m";

    // Simulate processing time
    const int processingTime = 1800;

    return {
      'reading': reading,
      'confidence': confidence,
      'extractedText': extractedText,
      'processingTime': processingTime,
    };
  }
}
