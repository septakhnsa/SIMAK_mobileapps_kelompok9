import 'package:camera/camera.dart';
import 'dart:typed_data';

// Interface ICamera
abstract class ICamera {
  Future<void> initialize();
  Future<Uint8List> capture();
  void dispose();
}

// MobileCamera implement ICamera
class MobileCamera implements ICamera {
  CameraController? controller;
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    final cameras = await availableCameras();
    final frontCam = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    controller = CameraController(frontCam, ResolutionPreset.medium);
    await controller!.initialize();
    _isInitialized = true;
    print("✅ Kamera berhasil diinisialisasi (Mobile)");
  }

  @override
  Future<Uint8List> capture() async {
    if (!_isInitialized || controller == null) {
      throw Exception("Kamera belum siap");
    }
    final image = await controller!.takePicture();
    return await image.readAsBytes();
  }

  @override
  void dispose() {
    controller?.dispose();
    controller = null;
    _isInitialized = false;
  }
}
