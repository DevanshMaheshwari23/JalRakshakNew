import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

/// OCR Service for CWC Water Level Monitoring System
/// 
/// This service handles OCR processing of water level gauge images
/// to automatically extract water level readings with confidence scores.
class OCRService {
  static final OCRService _instance = OCRService._internal();
  factory OCRService() => _instance;
  OCRService._internal();

  late TextRecognizer _textRecognizer;
  bool _isInitialized = false;

  /// OCR processing result
  class OCRResult {
    final String extractedText;
    final double confidence;
    final double? waterLevel;
    final List<TextElement> textElements;
    final bool isWaterLevelDetected;

    OCRResult({
      required this.extractedText,
      required this.confidence,
      this.waterLevel,
      required this.textElements,
      required this.isWaterLevelDetected,
    });

    @override
    String toString() {
      return 'OCRResult(text: $extractedText, confidence: ${confidence.toStringAsFixed(2)}, waterLevel: $waterLevel, detected: $isWaterLevelDetected)';
    }
  }

  /// Initialize the OCR service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _textRecognizer = TextRecognizer();
      _isInitialized = true;
      _logInfo('OCR Service initialized successfully');
    } catch (e) {
      _logError('initialize', e);
      rethrow;
    }
  }

  /// Process image and extract water level reading
  /// 
  /// [imageBytes] - Image data as Uint8List
  /// [imagePath] - Optional file path for debugging
  /// 
  /// Returns OCRResult with extracted text and confidence score
  Future<OCRResult> processImage(
    Uint8List imageBytes, {
    String? imagePath,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      _logInfo('Processing image for OCR...');
      
      // Create input image from bytes
      final inputImage = InputImage.fromBytes(
        bytes: imageBytes,
        metadata: InputImageMetadata(
          size: Size(1920, 1080), // Default size, will be corrected by ML Kit
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.bgra8888,
          bytesPerRow: 4 * 1920,
        ),
      );

      // Perform text recognition
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Extract text and confidence
      final extractedText = recognizedText.text;
      final confidence = _calculateConfidence(recognizedText);
      
      // Look for water level patterns
      final waterLevel = _extractWaterLevel(extractedText);
      final isWaterLevelDetected = waterLevel != null;
      
      _logInfo('OCR completed - Text: $extractedText, Confidence: ${confidence.toStringAsFixed(2)}');
      
      return OCRResult(
        extractedText: extractedText,
        confidence: confidence,
        waterLevel: waterLevel,
        textElements: recognizedText.blocks
            .expand((block) => block.lines)
            .expand((line) => line.elements)
            .toList(),
        isWaterLevelDetected: isWaterLevelDetected,
      );
    } catch (e) {
      _logError('processImage', e);
      return OCRResult(
        extractedText: '',
        confidence: 0.0,
        textElements: [],
        isWaterLevelDetected: false,
      );
    }
  }

  /// Process image from file path
  Future<OCRResult> processImageFromFile(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Image file does not exist: $imagePath');
      }
      
      final imageBytes = await file.readAsBytes();
      return await processImage(imageBytes, imagePath: imagePath);
    } catch (e) {
      _logError('processImageFromFile', e);
      return OCRResult(
        extractedText: '',
        confidence: 0.0,
        textElements: [],
        isWaterLevelDetected: false,
      );
    }
  }

  /// Calculate overall confidence score from recognized text
  double _calculateConfidence(RecognizedText recognizedText) {
    if (recognizedText.blocks.isEmpty) return 0.0;
    
    double totalConfidence = 0.0;
    int elementCount = 0;
    
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        for (final element in line.elements) {
          totalConfidence += element.confidence;
          elementCount++;
        }
      }
    }
    
    return elementCount > 0 ? totalConfidence / elementCount : 0.0;
  }

  /// Extract water level reading from text using pattern matching
  double? _extractWaterLevel(String text) {
    // Clean the text
    final cleanText = text.replaceAll(RegExp(r'[^\d.,\s]'), ' ').trim();
    
    // Look for common water level patterns
    final patterns = [
      // Pattern: "Water Level: 12.5m"
      RegExp(r'water\s*level\s*:?\s*(\d+\.?\d*)\s*m', caseSensitive: false),
      // Pattern: "Level: 12.5"
      RegExp(r'level\s*:?\s*(\d+\.?\d*)', caseSensitive: false),
      // Pattern: "12.5m"
      RegExp(r'(\d+\.?\d*)\s*m'),
      // Pattern: "12.5"
      RegExp(r'(\d+\.?\d*)'),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(cleanText);
      if (match != null) {
        final value = double.tryParse(match.group(1) ?? '');
        if (value != null && value >= 0 && value <= 1000) { // Reasonable water level range
          _logInfo('Water level detected: $value from pattern: ${pattern.pattern}');
          return value;
        }
      }
    }
    
    _logInfo('No water level pattern found in text: $cleanText');
    return null;
  }

  /// Preprocess image for better OCR results
  Future<Uint8List> preprocessImage(Uint8List imageBytes) async {
    try {
      // Decode image
      final image = img.decodeImage(imageBytes);
      if (image == null) return imageBytes;
      
      // Convert to grayscale for better OCR
      final grayImage = img.grayscale(image);
      
      // Enhance contrast
      final enhancedImage = img.contrast(grayImage, contrast: 1.5);
      
      // Encode back to bytes
      return Uint8List.fromList(img.encodeJpg(enhancedImage));
    } catch (e) {
      _logError('preprocessImage', e);
      return imageBytes; // Return original if preprocessing fails
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    if (_isInitialized) {
      await _textRecognizer.close();
      _isInitialized = false;
      _logInfo('OCR Service disposed');
    }
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Logging methods
  void _logInfo(String message) {
    print('[OCRService] INFO: $message');
  }

  void _logError(String method, dynamic error) {
    print('[OCRService] ERROR in $method: $error');
  }
}
