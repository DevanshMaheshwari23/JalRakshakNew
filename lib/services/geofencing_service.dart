import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/flutter_flow/flutter_flow_util.dart';

/// Site coordinates with cache metadata
class SiteCoordinates {
  final LatLng location;
  final double radius;
  final DateTime cachedAt;
  final String siteName;

  SiteCoordinates({
    required this.location,
    required this.radius,
    required this.cachedAt,
    required this.siteName,
  });

  bool get isExpired =>
      DateTime.now().difference(cachedAt) > const Duration(minutes: 30);
}

/// Geofence validation result
class GeofenceResult {
  final bool isValid;
  final double distance;
  final String message;
  final GeofenceStatus status;
  final LatLng? userLocation;
  final LatLng? siteLocation;

  GeofenceResult({
    required this.isValid,
    required this.distance,
    required this.message,
    required this.status,
    this.userLocation,
    this.siteLocation,
  });

  @override
  String toString() {
    return 'GeofenceResult(isValid: $isValid, distance: ${distance.toStringAsFixed(2)}m, status: $status, message: $message)';
  }
}

/// Geofence status enumeration
enum GeofenceStatus {
  inside,
  outside,
  locationError,
  permissionDenied,
  serviceDisabled,
  siteNotFound,
  cacheError,
}

/// Geofencing Service for CWC Water Level Monitoring System
///
/// This service handles location validation and geofencing for monitoring sites.
/// It ensures field personnel are within the required 50m radius of monitoring sites
/// before allowing water level readings to be submitted.
class GeofencingService {
  static final GeofencingService _instance = GeofencingService._internal();
  factory GeofencingService() => _instance;
  GeofencingService._internal();

  // Cache for site coordinates to avoid repeated Firestore reads
  final Map<String, SiteCoordinates> _siteCache = {};
  static const double _defaultGeofenceRadius = 50.0; // meters

  /// Validate if user location is within geofence radius of a site
  ///
  /// [siteLat] - Site latitude
  /// [siteLng] - Site longitude
  /// [radius] - Geofence radius in meters (default: 50m)
  ///
  /// Returns true if user is within the geofence, false otherwise
  Future<bool> validateUserLocation(
    double siteLat,
    double siteLng, {
    double radius = _defaultGeofenceRadius,
  }) async {
    try {
      final result = await _checkGeofenceWithLocation(
        siteLat,
        siteLng,
        radius: radius,
      );
      return result.isValid;
    } catch (e) {
      _logError('validateUserLocation', e);
      return false;
    }
  }

  /// Check geofence status for a specific site
  ///
  /// [siteId] - Monitoring site ID
  /// [radius] - Custom radius override (optional)
  ///
  /// Returns GeofenceResult with detailed status information
  Future<GeofenceResult> checkGeofenceStatus(
    String siteId, {
    double? radius,
  }) async {
    try {
      // Get site coordinates (from cache or Firestore)
      final siteCoords = await _getSiteCoordinates(siteId);
      if (siteCoords == null) {
        return GeofenceResult(
          isValid: false,
          distance: 0.0,
          message: 'Site not found: $siteId',
          status: GeofenceStatus.siteNotFound,
        );
      }

      // Use custom radius if provided, otherwise use site's default radius
      final effectiveRadius = radius ?? siteCoords.radius;

      // Check geofence with current user location
      return await _checkGeofenceWithLocation(
        siteCoords.location.latitude,
        siteCoords.location.longitude,
        radius: effectiveRadius,
        siteName: siteCoords.siteName,
      );
    } catch (e) {
      _logError('checkGeofenceStatus', e);
      return GeofenceResult(
        isValid: false,
        distance: 0.0,
        message: 'Error checking geofence: ${e.toString()}',
        status: GeofenceStatus.cacheError,
      );
    }
  }

  /// Get site coordinates from cache or Firestore
  Future<SiteCoordinates?> _getSiteCoordinates(String siteId) async {
    try {
      // Check cache first
      final cached = _siteCache[siteId];
      if (cached != null && !cached.isExpired) {
        _logInfo('Using cached coordinates for site: $siteId');
        return cached;
      }

      // Fetch from Firestore
      _logInfo('Fetching site coordinates from Firestore: $siteId');
      final doc = await FirebaseFirestore.instance
          .collection('monitoring_sites')
          .doc(siteId)
          .get();

      if (!doc.exists) {
        _logError('_getSiteCoordinates', 'Site not found: $siteId');
        return null;
      }

      final data = doc.data()!;
      final location = data['location'] as GeoPoint?;
      if (location == null) {
        _logError('_getSiteCoordinates', 'Site location not found: $siteId');
        return null;
      }

      final siteCoords = SiteCoordinates(
        location: LatLng(location.latitude, location.longitude),
        radius: (data['geofence_radius'] as double?) ?? _defaultGeofenceRadius,
        cachedAt: DateTime.now(),
        siteName: (data['site_name'] as String?) ?? 'Unknown Site',
      );

      // Cache the coordinates
      _siteCache[siteId] = siteCoords;
      _logInfo('Cached coordinates for site: $siteId');

      return siteCoords;
    } catch (e) {
      _logError('_getSiteCoordinates', e);
      return null;
    }
  }

  /// Check geofence with current user location
  Future<GeofenceResult> _checkGeofenceWithLocation(
    double siteLat,
    double siteLng, {
    required double radius,
    String? siteName,
  }) async {
    try {
      // Get current user location using existing pattern
      final userLocation = await getCurrentUserLocation(
        defaultLocation: const LatLng(0.0, 0.0),
        cached: false, // Always get fresh location for geofencing
      );

      // Check if location is valid
      if (userLocation.latitude == 0.0 && userLocation.longitude == 0.0) {
        return GeofenceResult(
          isValid: false,
          distance: 0.0,
          message: 'Unable to get current location',
          status: GeofenceStatus.locationError,
          userLocation: userLocation,
          siteLocation: LatLng(siteLat, siteLng),
        );
      }

      // Calculate distance using Geolocator
      final distance = Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        siteLat,
        siteLng,
      );

      final isValid = distance <= radius;
      final status = isValid ? GeofenceStatus.inside : GeofenceStatus.outside;

      final message = isValid
          ? 'You are within the monitoring site area (${distance.toStringAsFixed(1)}m from site)'
          : 'You are outside the monitoring site area. Distance: ${distance.toStringAsFixed(1)}m (Required: ≤${radius.toStringAsFixed(0)}m)';

      _logInfo(
          'Geofence check: ${isValid ? "INSIDE" : "OUTSIDE"} - Distance: ${distance.toStringAsFixed(1)}m, Radius: ${radius.toStringAsFixed(0)}m');

      return GeofenceResult(
        isValid: isValid,
        distance: distance,
        message: message,
        status: status,
        userLocation: userLocation,
        siteLocation: LatLng(siteLat, siteLng),
      );
    } catch (e) {
      _logError('_checkGeofenceWithLocation', e);

      // Handle specific location permission errors
      if (e.toString().contains('permission')) {
        return GeofenceResult(
          isValid: false,
          distance: 0.0,
          message: 'Location permission denied. Please enable location access.',
          status: GeofenceStatus.permissionDenied,
        );
      } else if (e.toString().contains('disabled')) {
        return GeofenceResult(
          isValid: false,
          distance: 0.0,
          message: 'Location services are disabled. Please enable GPS.',
          status: GeofenceStatus.serviceDisabled,
        );
      }

      return GeofenceResult(
        isValid: false,
        distance: 0.0,
        message: 'Location error: ${e.toString()}',
        status: GeofenceStatus.locationError,
      );
    }
  }

  /// Clear site cache (useful for testing or when site data changes)
  void clearCache() {
    _siteCache.clear();
    _logInfo('Site cache cleared');
  }

  /// Get cached site count (for debugging)
  int get cachedSiteCount => _siteCache.length;

  /// Check if a site is cached
  bool isSiteCached(String siteId) {
    final cached = _siteCache[siteId];
    return cached != null && !cached.isExpired;
  }

  /// Logging methods
  void _logInfo(String message) {
    print('[GeofencingService] INFO: $message');
  }

  void _logError(String method, dynamic error) {
    print('[GeofencingService] ERROR in $method: $error');
  }
}

/// Extension methods for GeofenceStatus
extension GeofenceStatusExtension on GeofenceStatus {
  String get displayName {
    switch (this) {
      case GeofenceStatus.inside:
        return 'Inside Geofence';
      case GeofenceStatus.outside:
        return 'Outside Geofence';
      case GeofenceStatus.locationError:
        return 'Location Error';
      case GeofenceStatus.permissionDenied:
        return 'Permission Denied';
      case GeofenceStatus.serviceDisabled:
        return 'Location Disabled';
      case GeofenceStatus.siteNotFound:
        return 'Site Not Found';
      case GeofenceStatus.cacheError:
        return 'Cache Error';
    }
  }

  bool get isError {
    return this != GeofenceStatus.inside && this != GeofenceStatus.outside;
  }
}
