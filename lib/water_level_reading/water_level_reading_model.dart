import '/flutter_flow/flutter_flow_util.dart';
import 'water_level_reading_widget.dart' show WaterLevelReadingWidget;
import 'package:flutter/material.dart';

class WaterLevelReadingModel extends FlutterFlowModel<WaterLevelReadingWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for water level TextField widget.
  FocusNode? waterLevelFocusNode;
  TextEditingController? waterLevelController;
  String? Function(BuildContext, String?)? waterLevelControllerValidator;

  // State field(s) for manual override TextField widget.
  FocusNode? manualOverrideFocusNode;
  TextEditingController? manualOverrideController;
  String? Function(BuildContext, String?)? manualOverrideControllerValidator;

  // Image upload state
  bool isDataUploading = false;
  FFUploadedFile uploadedLocalFile =
      FFUploadedFile(bytes: Uint8List.fromList([]));
  String uploadedFileUrl = '';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    waterLevelFocusNode?.dispose();
    waterLevelController?.dispose();

    manualOverrideFocusNode?.dispose();
    manualOverrideController?.dispose();
  }
}
