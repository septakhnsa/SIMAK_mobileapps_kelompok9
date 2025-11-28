import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../api/api_service.dart';
import 'camera_interface.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:camera/camera.dart';


class AbsenSubmitPage extends StatefulWidget {
  final int idKrsDetail;
  final int pertemuan;
  final String namaMatkul;

  const AbsenSubmitPage({
    super.key,
    required this.idKrsDetail,
    required this.pertemuan,
    required this.namaMatkul,
  });

  @override
  State<AbsenSubmitPage> createState() => _AbsenSubmitPageState();
}

class _AbsenSubmitPageState extends State<AbsenSubmitPage> {
  dynamic cam; // bisa WebCamera atau MobileCamera
  Uint8List? imageBytes;
  Position? position;

  bool isCameraReady = false;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeCameraAfterRender();
    });
  }

  Future<void> _initializeCameraAfterRender() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      if (kIsWeb) {
        cam = WebCamera();
        await cam.initialize();
      } else {
        cam = MobileCamera();
        await cam.initialize();
      }//

      setState(() => isCameraReady = true);
    } catch (e) {
      debugPrint("Error init camera: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal akses kamera: $e")),
      );
    }
  }

  @override
  void dispose() {
    cam?.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    try {
      final data = await cam.capture();
      setState(() => imageBytes = data);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal mengambil foto")));
    }
  }

  Future<void> _getLocation() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lokasi tidak aktif")));
      return;
    }

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Izin lokasi ditolak")));
      return;
    }

    final pos = await Geolocator.getCurrentPosition();
    setState(() => position = pos);
  }

  Future<void> _submitAbsen() async {
    if (imageBytes == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Foto belum diambil")));
      return;
    }
    if (position == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lokasi belum diambil")));
      return;
    }

    setState(() => isSubmitting = true);

    try {
      Dio dio = Dio();

      final form = FormData.fromMap({
        "id_krs_detail": widget.idKrsDetail,
        "pertemuan": widget.pertemuan,
        "latitude": position!.latitude,
        "longitude": position!.longitude,
        "foto": MultipartFile.fromBytes(
          imageBytes!,
          filename: "absen_${DateTime.now().millisecondsSinceEpoch}.png",
        ),
      });

      final res = await dio.post(
        "${ApiService.baseUrl}absensi/submit",
        data: form,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.data["message"] ?? "Absen berhasil")),
      );

      Navigator.pop(context);
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal submit absen")));
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  Widget _buildCameraPreview() {
    if (kIsWeb) {
      // ✅ Untuk Web: pakai webcam browser
      return Container(
        height: 240,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const HtmlElementView(viewType: 'webcam-view'),
      );
    } else if (cam != null &&
        cam.controller != null &&
        cam.controller.value.isInitialized) {
      // ✅ Untuk Mobile: pakai kamera native
      return AspectRatio(
        aspectRatio: cam.controller.value.aspectRatio,
        child: CameraPreview(cam.controller),
      );
    } else {
      return Container(
        height: 240,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          "Kamera belum aktif",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7EE),
      appBar: AppBar(
        title: Text(
          "Absen - ${widget.namaMatkul} (P.${widget.pertemuan})",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4C7F9A),
        centerTitle: true,
        elevation: 3,
        shadowColor: Colors.black26,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Kamera:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4C7F9A),
              ),
            ),
            const SizedBox(height: 8),

            // ==== LIVE CAMERA (AUTO PLATFORM) ====
            _buildCameraPreview(),

            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: isCameraReady ? _capturePhoto : null,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Ambil Foto"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4C7F9A),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            if (imageBytes != null) ...[
              const SizedBox(height: 20),
              const Text(
                "Hasil Foto:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4C7F9A),
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(imageBytes!, height: 200),
              ),
            ],

            const Divider(height: 40, thickness: 1),
            const Text(
              "Lokasi:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4C7F9A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              position == null
                  ? "Belum diambil"
                  : "Lat: ${position!.latitude}, Lng: ${position!.longitude}",
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _getLocation,
              icon: const Icon(Icons.my_location),
              label: const Text("Ambil Lokasi Sekarang"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isSubmitting ? null : _submitAbsen,
                icon: const Icon(Icons.check_circle_outline),
                label: isSubmitting
                    ? const Text("Mengirim...", style: TextStyle(color: Colors.white))
                    : const Text("Submit Absen"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C7F9A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
