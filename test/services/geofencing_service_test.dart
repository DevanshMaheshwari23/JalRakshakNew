import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:jal_rakshak/services/geofencing_service.dart';
import 'package:jal_rakshak/flutter_flow/flutter_flow_util.dart';

// Generate mocks for testing
@GenerateMocks(
    [FirebaseFirestore, CollectionReference, DocumentSnapshot, QuerySnapshot])
import 'geofencing_service_test.mocks.dart';

void main() {
  group('GeofencingService Tests', () {
    late GeofencingService geofencingService;
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference mockCollection;
    late MockDocumentSnapshot mockDocument;

    setUp(() {
      geofencingService = GeofencingService();
      mockFirestore = MockFirebaseFirestore();
      mockCollection = MockCollectionReference();
      mockDocument = MockDocumentSnapshot();
    });

    tearDown(() {
      geofencingService.clearCache();
    });

    group('validateUserLocation', () {
      test('should return true when user is within 50m radius', () async {
        // Test coordinates: Delhi (28.6139, 77.2090) and nearby point
        const siteLat = 28.6139;
        const siteLng = 77.2090;

        // Mock getCurrentUserLocation to return a nearby location (within 50m)
        // This would be approximately 28.6140, 77.2091 (about 15m away)
        const userLat = 28.6140;
        const userLng = 77.2091;

        // Mock the location service
        when(Geolocator.distanceBetween(userLat, userLng, siteLat, siteLng))
            .thenReturn(15.0); // 15 meters - within 50m radius

        // Note: In real implementation, we'd need to mock getCurrentUserLocation
        // For this test, we'll test the distance calculation logic directly

        final result =
            await geofencingService.validateUserLocation(siteLat, siteLng);
        expect(result, isTrue);
      });

      test('should return false when user is outside 50m radius', () async {
        const siteLat = 28.6139;
        const siteLng = 77.2090;

        // Mock distance calculation to return 75m (outside 50m radius)
        when(Geolocator.distanceBetween(any, any, siteLat, siteLng))
            .thenReturn(75.0);

        final result =
            await geofencingService.validateUserLocation(siteLat, siteLng);
        expect(result, isFalse);
      });

      test('should handle custom radius', () async {
        const siteLat = 28.6139;
        const siteLng = 77.2090;
        const customRadius = 100.0; // 100m radius

        // Mock distance calculation to return 80m (within 100m but outside 50m)
        when(Geolocator.distanceBetween(any, any, siteLat, siteLng))
            .thenReturn(80.0);

        final result = await geofencingService
            .validateUserLocation(siteLat, siteLng, radius: customRadius);
        expect(result, isTrue);
      });
    });

    group('checkGeofenceStatus', () {
      test('should return valid result for cached site', () async {
        const siteId = 'test_site_001';
        const siteLat = 28.6139;
        const siteLng = 77.2090;

        // Mock Firestore response
        when(mockFirestore.collection('monitoring_sites'))
            .thenReturn(mockCollection);
        when(mockCollection.doc(siteId)).thenReturn(mockDocument);
        when(mockDocument.exists).thenReturn(true);
        when(mockDocument.data()).thenReturn({
          'location': GeoPoint(siteLat, siteLng),
          'geofence_radius': 50.0,
          'site_name': 'Test Monitoring Site',
        });

        // Mock distance calculation
        when(Geolocator.distanceBetween(any, any, siteLat, siteLng))
            .thenReturn(25.0); // 25m - within radius

        final result = await geofencingService.checkGeofenceStatus(siteId);

        expect(result.isValid, isTrue);
        expect(result.distance, equals(25.0));
        expect(result.status, equals(GeofencingService.GeofenceStatus.inside));
        expect(result.message, contains('within the monitoring site area'));
      });

      test('should return error for non-existent site', () async {
        const siteId = 'non_existent_site';

        when(mockFirestore.collection('monitoring_sites'))
            .thenReturn(mockCollection);
        when(mockCollection.doc(siteId)).thenReturn(mockDocument);
        when(mockDocument.exists).thenReturn(false);

        final result = await geofencingService.checkGeofenceStatus(siteId);

        expect(result.isValid, isFalse);
        expect(result.status,
            equals(GeofencingService.GeofenceStatus.siteNotFound));
        expect(result.message, contains('Site not found'));
      });

      test('should use cached coordinates when available', () async {
        const siteId = 'cached_site_001';
        const siteLat = 28.6139;
        const siteLng = 77.2090;

        // First call - cache the site
        when(mockFirestore.collection('monitoring_sites'))
            .thenReturn(mockCollection);
        when(mockCollection.doc(siteId)).thenReturn(mockDocument);
        when(mockDocument.exists).thenReturn(true);
        when(mockDocument.data()).thenReturn({
          'location': GeoPoint(siteLat, siteLng),
          'geofence_radius': 50.0,
          'site_name': 'Cached Test Site',
        });

        // Mock distance calculation
        when(Geolocator.distanceBetween(any, any, siteLat, siteLng))
            .thenReturn(30.0);

        // First call to cache the site
        await geofencingService.checkGeofenceStatus(siteId);

        // Second call should use cache
        final result = await geofencingService.checkGeofenceStatus(siteId);

        expect(result.isValid, isTrue);
        expect(geofencingService.isSiteCached(siteId), isTrue);
      });
    });

    group('Cache Management', () {
      test('should clear cache', () {
        geofencingService.clearCache();
        expect(geofencingService.cachedSiteCount, equals(0));
      });

      test('should track cached site count', () async {
        const siteId = 'test_site_001';

        when(mockFirestore.collection('monitoring_sites'))
            .thenReturn(mockCollection);
        when(mockCollection.doc(siteId)).thenReturn(mockDocument);
        when(mockDocument.exists).thenReturn(true);
        when(mockDocument.data()).thenReturn({
          'location': GeoPoint(28.6139, 77.2090),
          'geofence_radius': 50.0,
          'site_name': 'Test Site',
        });

        await geofencingService.checkGeofenceStatus(siteId);

        expect(geofencingService.cachedSiteCount, equals(1));
      });
    });

    group('Error Handling', () {
      test('should handle location permission denied', () async {
        const siteLat = 28.6139;
        const siteLng = 77.2090;

        // Mock location error
        when(Geolocator.distanceBetween(any, any, any, any))
            .thenThrow(Exception('Location permission denied'));

        final result =
            await geofencingService.validateUserLocation(siteLat, siteLng);
        expect(result, isFalse);
      });

      test('should handle location services disabled', () async {
        const siteLat = 28.6139;
        const siteLng = 77.2090;

        // Mock location service disabled error
        when(Geolocator.distanceBetween(any, any, any, any))
            .thenThrow(Exception('Location services are disabled'));

        final result =
            await geofencingService.validateUserLocation(siteLat, siteLng);
        expect(result, isFalse);
      });
    });
  });

  group('GeofenceResult Tests', () {
    test('should create valid result with correct properties', () {
      final result = GeofencingService.GeofenceResult(
        isValid: true,
        distance: 25.5,
        message: 'Test message',
        status: GeofencingService.GeofenceStatus.inside,
        userLocation: const LatLng(28.6140, 77.2091),
        siteLocation: const LatLng(28.6139, 77.2090),
      );

      expect(result.isValid, isTrue);
      expect(result.distance, equals(25.5));
      expect(result.status, equals(GeofencingService.GeofenceStatus.inside));
      expect(result.userLocation, isNotNull);
      expect(result.siteLocation, isNotNull);
    });

    test('should format toString correctly', () {
      final result = GeofencingService.GeofenceResult(
        isValid: true,
        distance: 25.5,
        message: 'Test message',
        status: GeofencingService.GeofenceStatus.inside,
      );

      final string = result.toString();
      expect(string, contains('true'));
      expect(string, contains('25.50'));
      expect(string, contains('inside'));
    });
  });

  group('GeofenceStatus Extension Tests', () {
    test('should return correct display names', () {
      expect(GeofencingService.GeofenceStatus.inside.displayName,
          equals('Inside Geofence'));
      expect(GeofencingService.GeofenceStatus.outside.displayName,
          equals('Outside Geofence'));
      expect(GeofencingService.GeofenceStatus.permissionDenied.displayName,
          equals('Permission Denied'));
    });

    test('should identify error statuses correctly', () {
      expect(GeofencingService.GeofenceStatus.inside.isError, isFalse);
      expect(GeofencingService.GeofenceStatus.outside.isError, isFalse);
      expect(GeofencingService.GeofenceStatus.locationError.isError, isTrue);
      expect(GeofencingService.GeofenceStatus.permissionDenied.isError, isTrue);
    });
  });
}

/// Test coordinates for real-world testing
class TestCoordinates {
  // Delhi coordinates for testing
  static const LatLng delhi = LatLng(28.6139, 77.2090);

  // Point 15m away from Delhi (within 50m radius)
  static const LatLng delhiNearby = LatLng(28.6140, 77.2091);

  // Point 100m away from Delhi (outside 50m radius)
  static const LatLng delhiFar = LatLng(28.6145, 77.2095);

  // Mumbai coordinates for testing
  static const LatLng mumbai = LatLng(19.0760, 72.8777);

  // Test site coordinates
  static const Map<String, LatLng> testSites = {
    'delhi_site_001': delhi,
    'mumbai_site_001': mumbai,
  };
}
