import 'package:image_picker/image_picker.dart';

import 'capture_and_ocr_service.dart';

CaptureAndOcrService createCaptureAndOcrService() => _WebCaptureAndOcrService();

class _WebCaptureAndOcrService implements CaptureAndOcrService {
  @override
  Future<String?> captureAndExtractText({
    ImageSource source = ImageSource.camera,
  }) async {
    throw UnsupportedError(
      'Image OCR is available on the Android/iOS mobile app; paste or type text on Web.',
    );
  }

  @override
  Future<void> dispose() async {}
}
