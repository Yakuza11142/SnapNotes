import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import 'capture_and_ocr_service.dart';

CaptureAndOcrService createCaptureAndOcrService() => _IoCaptureAndOcrService();

class _IoCaptureAndOcrService implements CaptureAndOcrService {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<String?> captureAndExtractText({
    ImageSource source = ImageSource.camera,
  }) async {
    final XFile? photo = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (photo == null) {
      return null;
    }

    final InputImage inputImage = InputImage.fromFilePath(photo.path);
    final RecognizedText recognizedText =
        await _textRecognizer.processImage(inputImage);
    return recognizedText.text.trim();
  }

  @override
  Future<void> dispose() async {
    await _textRecognizer.close();
  }
}
