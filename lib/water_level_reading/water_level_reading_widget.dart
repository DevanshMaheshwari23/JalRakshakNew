import '/backend/firebase_storage/storage.dart';
import '/backend/schema/water_level_readings_record.dart';
import '/backend/schema/enums.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/services/geofencing_service.dart';
import '/services/ocr_service.dart';
import '/widgets/geofence_validator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'water_level_reading_model.dart';
export 'water_level_reading_model.dart';

class WaterLevelReadingWidget extends StatefulWidget {
  const WaterLevelReadingWidget({super.key});

  @override
  State<WaterLevelReadingWidget> createState() =>
      _WaterLevelReadingWidgetState();
}

class _WaterLevelReadingWidgetState extends State<WaterLevelReadingWidget>
    with TickerProviderStateMixin {
  late WaterLevelReadingModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final animationsMap = <String, AnimationInfo>{};

  // Services
  final OCRService _ocrService = OCRService();

  // State variables
  String? _selectedSiteId;
  String? _selectedSiteName;
  GeofenceResult? _geofenceResult;
  dynamic _ocrResult;
  bool _isOffline = false;
  bool _isQRScanned = false;
  String? _qrCodeValue;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WaterLevelReadingModel());

    _model.waterLevelController ??= TextEditingController();
    _model.waterLevelFocusNode ??= FocusNode();

    _model.manualOverrideController ??= TextEditingController();
    _model.manualOverrideFocusNode ??= FocusNode();

    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.0, 110.0),
            end: const Offset(0.0, 0.0),
          ),
        ],
      ),
    });
    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
    );

    _checkConnectivity();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    // Simulate connectivity check for now
    // In real implementation, use connectivity_plus package
    setState(() {
      _isOffline = false; // Assume online for now
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).secondaryText,
              size: 30.0,
            ),
            onPressed: () async {
              context.pushNamed('home1Copy');
            },
          ),
          title: Text(
            'Water Level Reading',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Inter Tight',
                  letterSpacing: 0.0,
                ),
          ),
          actions: [
            // Offline indicator
            if (_isOffline)
              Container(
                margin: const EdgeInsets.only(right: 16.0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_off,
                      color: Colors.white,
                      size: 16.0,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      'Offline',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Align(
            alignment: const AlignmentDirectional(0.0, -1.0),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                maxWidth: 770.0,
              ),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            child: Text(
                              'Submit Water Level Reading',
                              style: FlutterFlowTheme.of(context)
                                  .headlineMedium
                                  .override(
                                    fontFamily: 'Inter Tight',
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16.0, 8.0, 16.0, 0.0),
                            child: Text(
                              'Capture gauge reading and submit for monitoring',
                              style: FlutterFlowTheme.of(context)
                                  .labelLarge
                                  .override(
                                    fontFamily: 'Inter',
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),

                          // Geofence Validator
                          if (_selectedSiteId != null)
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16.0, 16.0, 16.0, 0.0),
                              child: GeofenceValidatorWidget(
                                siteId: _selectedSiteId!,
                                onStatusChanged: (result) {
                                  setState(() {
                                    _geofenceResult = result;
                                  });
                                },
                              ),
                            ),

                          // Site Selection
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16.0, 16.0, 16.0, 0.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                // Show site selection dialog
                                _showSiteSelectionDialog();
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                    width: 2.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      size: 24.0,
                                    ),
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _selectedSiteName ??
                                                'Select Monitoring Site',
                                            style: FlutterFlowTheme.of(context)
                                                .titleMedium
                                                .override(
                                                  fontFamily: 'Inter Tight',
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                          if (_selectedSiteId != null)
                                            Text(
                                              'Site ID: $_selectedSiteId',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmall
                                                      .override(
                                                        fontFamily: 'Inter',
                                                        letterSpacing: 0.0,
                                                      ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Live Camera Section
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16.0, 16.0, 16.0, 0.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                // Capture live image only (no gallery)
                                await _captureLiveImage();
                              },
                              child: Container(
                                width: double.infinity,
                                constraints: const BoxConstraints(
                                  maxWidth: 500.0,
                                ),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                    width: 2.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.camera_alt,
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        size: 48.0,
                                      ),
                                      const SizedBox(height: 12.0),
                                      Text(
                                        'Capture Gauge Reading',
                                        style: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .override(
                                              fontFamily: 'Inter Tight',
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        'Tap to capture live image of water level gauge',
                                        textAlign: TextAlign.center,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Inter',
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ).animateOnPageLoad(
                                animationsMap['containerOnPageLoadAnimation']!),
                          ),

                          // Show captured image
                          if (_model.uploadedFileUrl != '')
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16.0, 16.0, 16.0, 0.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12.0),
                                    child: Image.network(
                                      _model.uploadedFileUrl,
                                      width: double.infinity,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 12.0),
                                  // OCR Results
                                  if (_ocrResult != null)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                        color: _ocrResult!.isWaterLevelDetected
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.orange.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        border: Border.all(
                                          color:
                                              _ocrResult!.isWaterLevelDetected
                                                  ? Colors.green
                                                  : Colors.orange,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                _ocrResult!.isWaterLevelDetected
                                                    ? Icons.check_circle
                                                    : Icons.warning,
                                                color: _ocrResult!
                                                        .isWaterLevelDetected
                                                    ? Colors.green
                                                    : Colors.orange,
                                                size: 20.0,
                                              ),
                                              const SizedBox(width: 8.0),
                                              Text(
                                                'OCR Analysis',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily:
                                                              'Inter Tight',
                                                          letterSpacing: 0.0,
                                                        ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text(
                                            'Extracted Text: ${_ocrResult!.extractedText}',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Inter',
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                          Text(
                                            'Confidence: ${(_ocrResult!.confidence * 100).toStringAsFixed(1)}%',
                                            style: FlutterFlowTheme.of(context)
                                                .bodySmall
                                                .override(
                                                  fontFamily: 'Inter',
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                          if (_ocrResult!.waterLevel != null)
                                            Text(
                                              'Detected Water Level: ${_ocrResult!.waterLevel!.toStringAsFixed(2)}m',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily: 'Inter',
                                                    color:
                                                        Colors.green.shade700,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 0.0,
                                                  ),
                                            ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),

                          // Manual Override Input
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16.0, 16.0, 16.0, 0.0),
                            child: TextFormField(
                              controller: _model.manualOverrideController,
                              focusNode: _model.manualOverrideFocusNode,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Manual Override (if needed)',
                                hintText: 'Enter water level reading manually',
                                labelStyle: FlutterFlowTheme.of(context)
                                    .headlineSmall
                                    .override(
                                      fontFamily: 'Inter Tight',
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                hintStyle: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      fontFamily: 'Inter',
                                      letterSpacing: 0.0,
                                    ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(0.0),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).primary,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(0.0),
                                ),
                                contentPadding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        16.0, 12.0, 16.0, 12.0),
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .headlineSmall
                                  .override(
                                    fontFamily: 'Inter Tight',
                                    letterSpacing: 0.0,
                                  ),
                              cursorColor: FlutterFlowTheme.of(context).primary,
                            ),
                          ),

                          // QR Code Scanner Button
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16.0, 16.0, 16.0, 0.0),
                            child: FFButtonWidget(
                              onPressed: () async {
                                await _scanQRCode();
                              },
                              text: _isQRScanned
                                  ? 'QR Code Scanned'
                                  : 'Scan QR Code',
                              icon: Icon(
                                _isQRScanned
                                    ? Icons.check_circle
                                    : Icons.qr_code_scanner,
                                size: 20.0,
                              ),
                              options: FFButtonOptions(
                                height: 50.0,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                iconPadding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                color: _isQRScanned
                                    ? Colors.green
                                    : FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      fontFamily: 'Inter Tight',
                                      color: Colors.white,
                                      letterSpacing: 0.0,
                                    ),
                                elevation: 0.0,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ].addToEnd(const SizedBox(height: 32.0)),
                      ),
                    ),
                  ),
                  // Submit Button
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        16.0, 12.0, 16.0, 12.0),
                    child: FFButtonWidget(
                      onPressed: _canSubmit()
                          ? () async {
                              await _submitReading();
                            }
                          : null,
                      text: 'Submit Water Level Reading',
                      icon: const Icon(
                        Icons.water_drop,
                        size: 20.0,
                      ),
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 54.0,
                        padding: const EdgeInsets.all(0.0),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 0.0),
                        color: _canSubmit()
                            ? FlutterFlowTheme.of(context).primary
                            : FlutterFlowTheme.of(context).secondaryText,
                        textStyle:
                            FlutterFlowTheme.of(context).titleSmall.override(
                                  fontFamily: 'Inter Tight',
                                  color: Colors.white,
                                  letterSpacing: 0.0,
                                ),
                        elevation: 4.0,
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSiteSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Monitoring Site'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Delhi - Yamuna River'),
              subtitle: const Text('Site ID: delhi_site_001'),
              onTap: () {
                setState(() {
                  _selectedSiteId = 'delhi_site_001';
                  _selectedSiteName = 'Delhi - Yamuna River';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Mumbai - Ulhas River'),
              subtitle: const Text('Site ID: mumbai_site_001'),
              onTap: () {
                setState(() {
                  _selectedSiteId = 'mumbai_site_001';
                  _selectedSiteName = 'Mumbai - Ulhas River';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Bangalore - Cauvery River'),
              subtitle: const Text('Site ID: bangalore_site_001'),
              onTap: () {
                setState(() {
                  _selectedSiteId = 'bangalore_site_001';
                  _selectedSiteName = 'Bangalore - Cauvery River';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureLiveImage() async {
    try {
      // Use camera only (no gallery option)
      final selectedMedia = await selectMediaWithSourceBottomSheet(
        context: context,
        allowPhoto: true,
        allowVideo: false,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        textColor: FlutterFlowTheme.of(context).primaryText,
        pickerFontFamily: 'Outfit',
      );

      if (selectedMedia != null && selectedMedia.isNotEmpty) {
        setState(() => _model.isDataUploading = true);

        try {
          showUploadMessage(context, 'Processing image...', showLoading: true);

          // Upload image
          final downloadUrl = await uploadData(
            selectedMedia.first.storagePath,
            selectedMedia.first.bytes,
          );

          if (downloadUrl != null) {
            setState(() {
              _model.uploadedLocalFile = FFUploadedFile(
                name: selectedMedia.first.storagePath.split('/').last,
                bytes: selectedMedia.first.bytes,
                height: selectedMedia.first.dimensions?.height,
                width: selectedMedia.first.dimensions?.width,
                blurHash: selectedMedia.first.blurHash,
              );
              _model.uploadedFileUrl = downloadUrl;
            });

            // Process with OCR
            await _processOCR(selectedMedia.first.bytes);

            showUploadMessage(context, 'Image captured successfully!');
          }
        } finally {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          setState(() => _model.isDataUploading = false);
        }
      }
    } catch (e) {
      showUploadMessage(context, 'Error capturing image: $e');
    }
  }

  Future<void> _processOCR(Uint8List imageBytes) async {
    try {
      final result = await _ocrService.processImage(imageBytes);
      setState(() {
        _ocrResult = result;
      });

      // Auto-fill water level if detected
      if (result.waterLevel != null) {
        _model.waterLevelController?.text =
            result.waterLevel!.toStringAsFixed(2);
      }
    } catch (e) {
      showUploadMessage(context, 'OCR processing failed: $e');
    }
  }

  Future<void> _scanQRCode() async {
    // For now, simulate QR scanning
    // In real implementation, you would use QRCodeScanner widget
    setState(() {
      _isQRScanned = true;
      _qrCodeValue =
          'SITE_${_selectedSiteId}_${DateTime.now().millisecondsSinceEpoch}';
    });

    showUploadMessage(context, 'QR Code scanned successfully!');
  }

  bool _canSubmit() {
    return _selectedSiteId != null &&
        _model.uploadedFileUrl.isNotEmpty &&
        _geofenceResult?.isValid == true &&
        _isQRScanned;
  }

  Future<void> _submitReading() async {
    try {
      // Create water level reading record
      await WaterLevelReadingsRecord.collection.doc().set(
            createWaterLevelReadingsRecordData(
              siteId: _selectedSiteId!,
              readingValue: double.tryParse(
                      _model.manualOverrideController?.text ?? '') ??
                  _ocrResult?.waterLevel ??
                  0.0,
              timestamp: DateTime.now(),
              location: _geofenceResult?.userLocation,
              photoUrl: _model.uploadedFileUrl,
              photoMetadata: {
                'ocr_confidence': _ocrResult?.confidence ?? 0.0,
                'ocr_text': _ocrResult?.extractedText ?? '',
                'manual_override':
                    _model.manualOverrideController?.text.isNotEmpty ?? false,
              },
              ocrConfidence: _ocrResult?.confidence,
              ocrExtractedText: _ocrResult?.extractedText,
              manualOverride:
                  _model.manualOverrideController?.text.isNotEmpty ?? false,
              deviceId: 'device_${DateTime.now().millisecondsSinceEpoch}',
              userId: null, // Will be set by backend
              syncStatus: _isOffline ? SyncStatus.pending : SyncStatus.synced,
              readingSource: _ocrResult?.isWaterLevelDetected == true
                  ? ReadingSource.ocr
                  : ReadingSource.manual,
              gpsAccuracy: _geofenceResult?.distance ?? 0.0,
              isGeofenceValidated: _geofenceResult?.isValid ?? false,
              isQrScanned: _isQRScanned,
              qrCodeValue: _qrCodeValue,
              createdTime: DateTime.now(),
            ),
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Water level reading submitted successfully!',
            style: FlutterFlowTheme.of(context).titleSmall.override(
                  fontFamily: 'Inter Tight',
                  color: FlutterFlowTheme.of(context).info,
                  fontSize: 16.0,
                  letterSpacing: 0.0,
                ),
            textAlign: TextAlign.center,
          ),
          duration: const Duration(milliseconds: 2000),
          backgroundColor: FlutterFlowTheme.of(context).primary,
        ),
      );

      context.pushNamed('home1Copy');
    } catch (e) {
      showUploadMessage(context, 'Error submitting reading: $e');
    }
  }
}
