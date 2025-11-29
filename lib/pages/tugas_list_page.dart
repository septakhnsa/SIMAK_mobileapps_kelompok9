// tugas_list_page.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'tugas_detail_page.dart';

class TugasListPage extends StatelessWidget {
  const TugasListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> daftarTugas = [
      {"matkul": "Mobile Programming", "judul": "Layout Login", "deadline": "12 Jan 2025"},
      {"matkul": "Data Mining", "judul": "Preprocessing Dataset", "deadline": "18 Jan 2025"},
      {"matkul": "Sistem Basis Data", "judul": "Trigger & Function", "deadline": "20 Jan 2025"},
      {"matkul": "Kecerdasan Buatan", "judul": "Implementasi Algoritma", "deadline": "22 Jan 2025"},
      {"matkul": "Pemrograman Web", "judul": "Membuat CRUD", "deadline": "25 Jan 2025"},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4C7F9A),
        centerTitle: true,
        title: const Text(
          "Daftar Tugas",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFFDF7EE),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: daftarTugas.length,
        itemBuilder: (context, index) {
          final tugas = daftarTugas[index];
          return _TugasCard(
              context, tugas["matkul"]!, tugas["judul"]!, tugas["deadline"]!);
        },
      ),
    );
  }

  Widget _TugasCard(BuildContext context, String matkul, String judul, String deadline) {
    return StatefulBuilder(builder: (context, setStateHover) {
      bool isHovered = false;
      return MouseRegion(
        onEnter: (_) => setStateHover(() => isHovered = true),
        onExit: (_) => setStateHover(() => isHovered = false),
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => Dialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        judul,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4C7F9A)),
                      ),
                      const SizedBox(height: 16),
                      Text("Mata Kuliah: $matkul"),
                      Text("Deadline: $deadline"),
                      const SizedBox(height: 24),
                      const Text(
                        "Pilih aksi:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Tombol Lihat Detail
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4C7F9A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              elevation: 6,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TugasDetailPage(
                                      matkul: matkul,
                                      judul: judul,
                                      deadline: deadline),
                                ),
                              );
                            },
                            child: const Text(
                              "Lihat Detail",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Tombol Upload Tugas langsung pilih file
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4C7F9A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              elevation: 6,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                            onPressed: () async {
                              Navigator.pop(context); // tutup dialog
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles();

                              if (result != null) {
                                final file = result.files.first;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "File ${file.name} berhasil di-upload (dummy)",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: const Color(0xFF4C7F9A),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Tidak ada file dipilih",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Color(0xFF4C7F9A),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              "Upload Tugas",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isHovered ? 0.15 : 0.06),
                  blurRadius: isHovered ? 8 : 4,
                  offset: const Offset(0, 4),
                ),
              ],
              border: isHovered
                  ? Border.all(color: const Color(0xFF4C7F9A), width: 1)
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4C7F9A).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Icon(Icons.assignment_outlined, color: Color(0xFF4C7F9A)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(judul,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(matkul,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 16, color: Color(0xFF4C7F9A)),
                    Text(deadline,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF4C7F9A))),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
