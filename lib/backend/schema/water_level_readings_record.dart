import 'dart:async';

import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums.dart';

import '/flutter_flow/flutter_flow_util.dart';

/// Water Level Reading Record for CWC Monitoring System
///
/// This record represents a single water level reading taken at a monitoring site.
/// It includes all metadata, validation, and tamper detection information.
class WaterLevelReadingsRecord extends FirestoreRecord {
  WaterLevelReadingsRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "site_id" field - Required, indexed for queries
  String? _siteId;
  String get siteId => _siteId ?? '';
  bool hasSiteId() => _siteId != null;

  // "reading_value" field - Required water level measurement
  double? _readingValue;
  double get readingValue => _readingValue ?? 0.0;
  bool hasReadingValue() => _readingValue != null;

  // "timestamp" field - Required, indexed for time-based queries
  DateTime? _timestamp;
  DateTime? get timestamp => _timestamp;
  bool hasTimestamp() => _timestamp != null;

  // "location" field - Required GPS coordinates
  LatLng? _location;
  LatLng? get location => _location;
  bool hasLocation() => _location != null;

  // "photo_url" field - Required Firebase Storage URL
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "photo_metadata" field - EXIF and processing metadata
  Map<String, dynamic>? _photoMetadata;
  Map<String, dynamic> get photoMetadata => _photoMetadata ?? const {};
  bool hasPhotoMetadata() => _photoMetadata != null;

  // "ocr_confidence" field - OCR confidence score (0.0-1.0)
  double? _ocrConfidence;
  double? get ocrConfidence => _ocrConfidence;
  bool hasOcrConfidence() => _ocrConfidence != null;

  // "ocr_extracted_text" field - Raw OCR output
  String? _ocrExtractedText;
  String get ocrExtractedText => _ocrExtractedText ?? '';
  bool hasOcrExtractedText() => _ocrExtractedText != null;

  // "manual_override" field - Whether reading was manually corrected
  bool? _manualOverride;
  bool get manualOverride => _manualOverride ?? false;
  bool hasManualOverride() => _manualOverride != null;

  // "device_id" field - Required device identifier
  String? _deviceId;
  String get deviceId => _deviceId ?? '';
  bool hasDeviceId() => _deviceId != null;

  // "user_id" field - Required reference to users collection
  DocumentReference? _userId;
  DocumentReference? get userId => _userId;
  bool hasUserId() => _userId != null;

  // "sync_status" field - Required sync status enum
  String? _syncStatus;
  SyncStatus get syncStatus =>
      SyncStatusExtension.fromString(_syncStatus ?? 'pending');
  bool hasSyncStatus() => _syncStatus != null;

  // "reading_source" field - Required source enum
  String? _readingSource;
  ReadingSource get readingSource =>
      ReadingSourceExtension.fromString(_readingSource ?? 'manual');
  bool hasReadingSource() => _readingSource != null;

  // "tamper_flags" field - List of tamper detection flags
  List<String>? _tamperFlags;
  List<TamperFlag> get tamperFlags =>
      _tamperFlags?.map((f) => TamperFlagExtension.fromString(f)).toList() ??
      [TamperFlag.none];
  bool hasTamperFlags() => _tamperFlags != null;

  // "gps_accuracy" field - Required GPS accuracy in meters
  double? _gpsAccuracy;
  double get gpsAccuracy => _gpsAccuracy ?? 0.0;
  bool hasGpsAccuracy() => _gpsAccuracy != null;

  // "is_geofence_validated" field - Required geofence validation status
  bool? _isGeofenceValidated;
  bool get isGeofenceValidated => _isGeofenceValidated ?? false;
  bool hasIsGeofenceValidated() => _isGeofenceValidated != null;

  // "is_qr_scanned" field - QR code validation status
  bool? _isQrScanned;
  bool get isQrScanned => _isQrScanned ?? false;
  bool hasIsQrScanned() => _isQrScanned != null;

  // "qr_code_value" field - Scanned QR code data
  String? _qrCodeValue;
  String get qrCodeValue => _qrCodeValue ?? '';
  bool hasQrCodeValue() => _qrCodeValue != null;

  // "created_time" field - Auto-generated timestamp
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  void _initializeFields() {
    _siteId = snapshotData['site_id'] as String?;
    _readingValue = castToType<double>(snapshotData['reading_value']);
    _timestamp = snapshotData['timestamp'] as DateTime?;
    _location = snapshotData['location'] as LatLng?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _photoMetadata = snapshotData['photo_metadata'] as Map<String, dynamic>?;
    _ocrConfidence = castToType<double>(snapshotData['ocr_confidence']);
    _ocrExtractedText = snapshotData['ocr_extracted_text'] as String?;
    _manualOverride = snapshotData['manual_override'] as bool?;
    _deviceId = snapshotData['device_id'] as String?;
    _userId = snapshotData['user_id'] as DocumentReference?;
    _syncStatus = snapshotData['sync_status'] as String?;
    _readingSource = snapshotData['reading_source'] as String?;
    _tamperFlags = getDataList<String>(snapshotData['tamper_flags']);
    _gpsAccuracy = castToType<double>(snapshotData['gps_accuracy']);
    _isGeofenceValidated = snapshotData['is_geofence_validated'] as bool?;
    _isQrScanned = snapshotData['is_qr_scanned'] as bool?;
    _qrCodeValue = snapshotData['qr_code_value'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
  }

  /// Firestore collection reference for water level readings
  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('water_level_readings');

  /// Stream a single document
  static Stream<WaterLevelReadingsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => WaterLevelReadingsRecord.fromSnapshot(s));

  /// Get a single document once
  static Future<WaterLevelReadingsRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => WaterLevelReadingsRecord.fromSnapshot(s));

  /// Create record from Firestore snapshot
  static WaterLevelReadingsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      WaterLevelReadingsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  /// Create record from data and reference
  static WaterLevelReadingsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      WaterLevelReadingsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'WaterLevelReadingsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is WaterLevelReadingsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

/// Create data map for WaterLevelReadingsRecord
Map<String, dynamic> createWaterLevelReadingsRecordData({
  String? siteId,
  double? readingValue,
  DateTime? timestamp,
  LatLng? location,
  String? photoUrl,
  Map<String, dynamic>? photoMetadata,
  double? ocrConfidence,
  String? ocrExtractedText,
  bool? manualOverride,
  String? deviceId,
  DocumentReference? userId,
  SyncStatus? syncStatus,
  ReadingSource? readingSource,
  List<TamperFlag>? tamperFlags,
  double? gpsAccuracy,
  bool? isGeofenceValidated,
  bool? isQrScanned,
  String? qrCodeValue,
  DateTime? createdTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'site_id': siteId,
      'reading_value': readingValue,
      'timestamp': timestamp,
      'location': location,
      'photo_url': photoUrl,
      'photo_metadata': photoMetadata,
      'ocr_confidence': ocrConfidence,
      'ocr_extracted_text': ocrExtractedText,
      'manual_override': manualOverride,
      'device_id': deviceId,
      'user_id': userId,
      'sync_status': syncStatus?.value,
      'reading_source': readingSource?.value,
      'tamper_flags': tamperFlags?.map((f) => f.value).toList(),
      'gps_accuracy': gpsAccuracy,
      'is_geofence_validated': isGeofenceValidated,
      'is_qr_scanned': isQrScanned,
      'qr_code_value': qrCodeValue,
      'created_time': createdTime,
    }.withoutNulls,
  );

  return firestoreData;
}

/// Document equality implementation for WaterLevelReadingsRecord
class WaterLevelReadingsRecordDocumentEquality
    implements Equality<WaterLevelReadingsRecord> {
  const WaterLevelReadingsRecordDocumentEquality();

  @override
  bool equals(WaterLevelReadingsRecord? e1, WaterLevelReadingsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.siteId == e2?.siteId &&
        e1?.readingValue == e2?.readingValue &&
        e1?.timestamp == e2?.timestamp &&
        e1?.location == e2?.location &&
        e1?.photoUrl == e2?.photoUrl &&
        mapEquals(e1?.photoMetadata, e2?.photoMetadata) &&
        e1?.ocrConfidence == e2?.ocrConfidence &&
        e1?.ocrExtractedText == e2?.ocrExtractedText &&
        e1?.manualOverride == e2?.manualOverride &&
        e1?.deviceId == e2?.deviceId &&
        e1?.userId == e2?.userId &&
        e1?.syncStatus == e2?.syncStatus &&
        e1?.readingSource == e2?.readingSource &&
        listEquality.equals(e1?.tamperFlags, e2?.tamperFlags) &&
        e1?.gpsAccuracy == e2?.gpsAccuracy &&
        e1?.isGeofenceValidated == e2?.isGeofenceValidated &&
        e1?.isQrScanned == e2?.isQrScanned &&
        e1?.qrCodeValue == e2?.qrCodeValue &&
        e1?.createdTime == e2?.createdTime;
  }

  @override
  int hash(WaterLevelReadingsRecord? e) => const ListEquality().hash([
        e?.siteId,
        e?.readingValue,
        e?.timestamp,
        e?.location,
        e?.photoUrl,
        e?.photoMetadata,
        e?.ocrConfidence,
        e?.ocrExtractedText,
        e?.manualOverride,
        e?.deviceId,
        e?.userId,
        e?.syncStatus,
        e?.readingSource,
        e?.tamperFlags,
        e?.gpsAccuracy,
        e?.isGeofenceValidated,
        e?.isQrScanned,
        e?.qrCodeValue,
        e?.createdTime
      ]);

  @override
  bool isValidKey(Object? o) => o is WaterLevelReadingsRecord;
}
