import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../api/api_service.dart';
import '../pages/matakuliah_page.dart';
import '../pages/profile_pages.dart';
import '../pages/input_krs_page.dart';
import '../pages/feedback_pages.dart';
import '../pages/notifikasi_page.dart';
import '../pages/surat_kotak_masuk_page.dart';
import '../pages/tugas_list_page.dart'; 
import 'tugas_detail_page.dart';

class DashboardPages extends StatefulWidget {
  const DashboardPages({super.key});

  @override
  State<DashboardPages> createState() => _DashboardPagesState();
}

class _DashboardPagesState extends State<DashboardPages> {
  Map<String, dynamic>? user;
  int _selectedIndexNavbar = 1;
  String _hoveredCard = "";
  int _jadwalIndex = 0;

  final List<Map<String, dynamic>> menuItems = [
    {"icon": Icons.article_outlined, "label": "e-sertifikat"},
    {"icon": Icons.menu_book_outlined, "label": "Nilai"},
    {"icon": Icons.newspaper_outlined, "label": "News"},
    {"icon": Icons.assignment_outlined, "label": "KRS"},
    {"icon": Icons.insert_drive_file_outlined, "label": "Transkrip"},
    {"icon": Icons.menu_book_outlined, "label": "Mata Kuliah"},
    {"icon": Icons.account_balance_wallet_outlined, "label": "Keuangan"},
    {"icon": Icons.school_outlined, "label": "KHS"},
    {"icon": Icons.chat_bubble_outline, "label": "Umpan Balik"},
    {"icon": Icons.replay_circle_filled_outlined, "label": "Remidi"},
    {"icon": Icons.fact_check_outlined, "label": "Ujian"},
    {"icon": Icons.check_circle_outline, "label": "Absensi"},
  ];

  final List<Map<String, dynamic>> jadwalDummy = [
    {
      "tanggal": "Senin, 1 Sept 2025",
      "matkul": [
        {"nama": "Mobile Programming", "jam": "08.00 - 10.30"},
        {"nama": "Data Mining", "jam": "13.00 - 15.00"},
      ]
    },
    {
      "tanggal": "Selasa, 2 Sept 2025",
      "matkul": [
        {"nama": "Sistem Basis Data", "jam": "09.00 - 11.00"},
        {"nama": "Kecerdasan Buatan", "jam": "14.00 - 16.00"},
      ]
    },
    {
      "tanggal": "Rabu, 3 Sept 2025",
      "matkul": [
        {"nama": "Pemrograman Web", "jam": "08.00 - 10.00"},
        {"nama": "Mobile Programming", "jam": "10.30 - 12.00"},
      ]
    },
    {
      "tanggal": "Kamis, 4 Sept 2025",
      "matkul": [
        {"nama": "Data Mining", "jam": "09.00 - 11.00"},
        {"nama": "Sistem Basis Data", "jam": "13.00 - 15.00"},
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _getMahasiswaData();
  }

  Future<void> _getMahasiswaData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      final email = prefs.getString("auth_email");

      Dio dio = Dio()
        ..options.headers = {
          'Authorization': 'Bearer $token',
          'Content-type': 'application/json',
        };

      final response = await dio.post(
        "${ApiService.baseUrl}mahasiswa/detail-mahasiswa",
        data: {"email": email},
      );

      setState(() => user = response.data["data"]);
    } catch (e) {
      debugPrint("Error getMahasiswa: $e");
    }
  }

  void _onMenuTap(String label) {
    final normalized = label.toLowerCase();

    if (normalized.contains("mata kuliah")) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const DaftarMatakuliahPage()));
    } else if (normalized.contains("krs")) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const InputKrsPage()));
    } else if (normalized.contains("profil")) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const ProfilePages()));
    } else if (normalized.contains("surat")) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const SuratKotakMasukPage()));
    } else if (normalized.contains("notifikasi")) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const NotifikasiPage()));
    } else if (normalized.contains("umpan balik") ||
        normalized.contains("feedback")) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const FeedbackPages()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF4C7F9A),
          content: Text('Menu "$label" belum tersedia'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFoto = (user?["foto"] != null &&
        (user?["foto"]?.toString().isNotEmpty ?? false));

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4C7F9A),
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.black26,
        title: const Text(
          "Dashboard Mahasiswa",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // putih
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4C7F9A)))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER PROFIL
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundImage: hasFoto
                              ? NetworkImage(user!["foto"])
                              : const AssetImage("assets/images/default_user.png") as ImageProvider,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?["nama"] ?? "-",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4C7F9A),
                                ),
                              ),
                              Text(
                                "Mahasiswa - ${user?["program_studi"]?["nama_prodi"] ?? '-'}",
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const NotifikasiPage()),
                            );
                          },
                          icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF4C7F9A)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // SEARCH BAR
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Search something...",
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // JADWAL CARD INTERAKTIF
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4C7F9A),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("JADWAL",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          const SizedBox(height: 6),

                          // Tanggal dan tombol < >
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (_jadwalIndex > 0) _jadwalIndex--;
                                    });
                                  },
                                  icon: const Icon(Icons.arrow_left, color: Colors.white)),
                              Text(
                                jadwalDummy[_jadwalIndex]["tanggal"],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (_jadwalIndex < jadwalDummy.length - 1)
                                        _jadwalIndex++;
                                    });
                                  },
                                  icon: const Icon(Icons.arrow_right, color: Colors.white)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(
                                jadwalDummy[_jadwalIndex]["matkul"].length,
                                (i) {
                                  final m = jadwalDummy[_jadwalIndex]["matkul"][i];
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(m["nama"], style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text(m["jam"]),
                                      if (i != jadwalDummy[_jadwalIndex]["matkul"].length - 1) const Divider(),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // TUGASKU HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Tugasku",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4C7F9A),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TugasListPage()),
                            );
                          },
                          child: const Text(
                            "Lihat Semua",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4C7F9A),
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    _tugasCard("Mobile Programming",
                        "Tugas Membuat Layout Login", "12 Jan 2025"),

                    const SizedBox(height: 10),

                    _tugasCard("Data Mining",
                        "Tugas Preprocessing Dataset", "18 Jan 2025"),

                    const SizedBox(height: 30),

                    const Text("Menu Akademikku",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF4C7F9A))),
                    const SizedBox(height: 12),

                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: List.generate(menuItems.length, (index) {
                        final item = menuItems[index];
                        final List<Color> colorOptions = [
                          const Color(0xFFD7C5F7),
                          const Color(0xFFA7D8F7),
                          const Color(0xFFB7E4C7),
                          const Color(0xFFFFE6A7),
                          const Color(0xFFFFB6A7),
                          const Color(0xFFE0E0E0),
                          const Color(0xFFF8C6D8),
                        ];

                        return GestureDetector(
                          onTap: () => _onMenuTap(item["label"]),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorOptions[index % colorOptions.length],
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Icon(item["icon"], color: const Color(0xFF3E657A), size: 26),
                              ),
                              const SizedBox(height: 6),
                              Text(item["label"],
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF4C7F9A),
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

      bottomNavigationBar: _bottomNavbar(),
    );
  }

  Widget _tugasCard(String matkul, String judul, String deadline) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 4,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF4C7F9A).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.description_outlined, color: Color(0xFF4C7F9A)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(judul, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(matkul, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF4C7F9A)),
              Text(deadline, style: const TextStyle(fontSize: 11, color: Color(0xFF4C7F9A))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bottomNavbar() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: 70,
          decoration: const BoxDecoration(
            color: Color(0xFF4C7F9A),
            borderRadius:
                BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const SuratKotakMasukPage()));
                },
                child: const Icon(Icons.mark_chat_unread_rounded, size: 26, color: Colors.white70),
              ),
              const SizedBox(width: 60),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const ProfilePages()));
                },
                child: const Icon(Icons.person_rounded, size: 26, color: Colors.white70),
              ),
            ],
          ),
        ),
        Positioned(
          top: -25,
          child: Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3))
              ],
            ),
            child: const Icon(Icons.home_rounded, size: 32, color: Color(0xFF4C7F9A)),
          ),
        )
      ],
    );
  }
}
