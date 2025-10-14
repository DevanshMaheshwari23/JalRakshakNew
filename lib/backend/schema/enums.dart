// Enums for CWC Water Level Monitoring System
//
// This file contains all the enumeration types used across the water monitoring
// system for type safety and consistency.

/// Sync status for offline data management
enum SyncStatus {
  pending,
  syncing,
  synced,
  failed,
}

/// Source of water level reading
enum ReadingSource {
  manual,
  ocr,
  auto,
}

/// User roles in the system
enum UserRole {
  fieldPersonnel,
  supervisor,
  analyst,
  admin,
}

/// Tamper detection flags
enum TamperFlag {
  none,
  locationSpoofing,
  photoManipulation,
  timeAnomaly,
  rapidSubmission,
}

/// Validation status for readings
enum ValidationStatus {
  pending,
  approved,
  rejected,
}

/// Network requirement for sync operations
enum NetworkRequirement {
  any,
  wifi,
  none,
}

/// Extension methods for enum serialization
extension SyncStatusExtension on SyncStatus {
  String get value {
    switch (this) {
      case SyncStatus.pending:
        return 'pending';
      case SyncStatus.syncing:
        return 'syncing';
      case SyncStatus.synced:
        return 'synced';
      case SyncStatus.failed:
        return 'failed';
    }
  }

  static SyncStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return SyncStatus.pending;
      case 'syncing':
        return SyncStatus.syncing;
      case 'synced':
        return SyncStatus.synced;
      case 'failed':
        return SyncStatus.failed;
      default:
        return SyncStatus.pending;
    }
  }
}

extension ReadingSourceExtension on ReadingSource {
  String get value {
    switch (this) {
      case ReadingSource.manual:
        return 'manual';
      case ReadingSource.ocr:
        return 'ocr';
      case ReadingSource.auto:
        return 'auto';
    }
  }

  static ReadingSource fromString(String value) {
    switch (value) {
      case 'manual':
        return ReadingSource.manual;
      case 'ocr':
        return ReadingSource.ocr;
      case 'auto':
        return ReadingSource.auto;
      default:
        return ReadingSource.manual;
    }
  }
}

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.fieldPersonnel:
        return 'fieldPersonnel';
      case UserRole.supervisor:
        return 'supervisor';
      case UserRole.analyst:
        return 'analyst';
      case UserRole.admin:
        return 'admin';
    }
  }

  static UserRole fromString(String value) {
    switch (value) {
      case 'fieldPersonnel':
        return UserRole.fieldPersonnel;
      case 'supervisor':
        return UserRole.supervisor;
      case 'analyst':
        return UserRole.analyst;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.fieldPersonnel;
    }
  }
}

extension TamperFlagExtension on TamperFlag {
  String get value {
    switch (this) {
      case TamperFlag.none:
        return 'none';
      case TamperFlag.locationSpoofing:
        return 'locationSpoofing';
      case TamperFlag.photoManipulation:
        return 'photoManipulation';
      case TamperFlag.timeAnomaly:
        return 'timeAnomaly';
      case TamperFlag.rapidSubmission:
        return 'rapidSubmission';
    }
  }

  static TamperFlag fromString(String value) {
    switch (value) {
      case 'none':
        return TamperFlag.none;
      case 'locationSpoofing':
        return TamperFlag.locationSpoofing;
      case 'photoManipulation':
        return TamperFlag.photoManipulation;
      case 'timeAnomaly':
        return TamperFlag.timeAnomaly;
      case 'rapidSubmission':
        return TamperFlag.rapidSubmission;
      default:
        return TamperFlag.none;
    }
  }
}

extension ValidationStatusExtension on ValidationStatus {
  String get value {
    switch (this) {
      case ValidationStatus.pending:
        return 'pending';
      case ValidationStatus.approved:
        return 'approved';
      case ValidationStatus.rejected:
        return 'rejected';
    }
  }

  static ValidationStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return ValidationStatus.pending;
      case 'approved':
        return ValidationStatus.approved;
      case 'rejected':
        return ValidationStatus.rejected;
      default:
        return ValidationStatus.pending;
    }
  }
}

extension NetworkRequirementExtension on NetworkRequirement {
  String get value {
    switch (this) {
      case NetworkRequirement.any:
        return 'any';
      case NetworkRequirement.wifi:
        return 'wifi';
      case NetworkRequirement.none:
        return 'none';
    }
  }

  static NetworkRequirement fromString(String value) {
    switch (value) {
      case 'any':
        return NetworkRequirement.any;
      case 'wifi':
        return NetworkRequirement.wifi;
      case 'none':
        return NetworkRequirement.none;
      default:
        return NetworkRequirement.any;
    }
  }
}
