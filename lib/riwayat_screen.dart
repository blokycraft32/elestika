import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'listrik_provider.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  int? _selectedBarIndex = 5;

  // Trik spasi agar tulisan tidak hilang dimakan sistem layar Anda
  final List<Map<String, dynamic>> monthlyHistory = [
    {
      'month': 'Jan',
      'fullMonth': 'Januari 2026',
      'amount': 185000,
      'kwh': 128,
      'paymentDate': DateTime(2026, 1, 15),
      'devices': [
        {
          'name': 'AC 1/2 PK',
          'watt': '350 Watt',
          'usage': '8 Jam/hari',
          'cost': 84000,
        },
        {
          'name': 'Kulkas 1 Pintu',
          'watt': '100 Watt',
          'usage': '24 Jam/hari',
          'cost': 52000,
        },
        {
          'name': 'TV LED 32"',
          'watt': '50 Watt',
          'usage': '6 Jam/hari',
          'cost': 18000,
        },
        {
          'name': 'Lampu LED (5x)',
          'watt': '50 Watt',
          'usage': '10 Jam/hari',
          'cost': 31000,
        },
      ],
    },
    {
      'month': 'Feb',
      'fullMonth': 'Februari 2026',
      'amount': 195000,
      'kwh': 135,
      'paymentDate': DateTime(2026, 2, 14),
      'devices': [
        {
          'name': 'AC 1/2 PK',
          'watt': '350 Watt',
          'usage': '8 Jam/hari',
          'cost': 84000,
        },
        {
          'name': 'Kulkas 1 Pintu',
          'watt': '100 Watt',
          'usage': '24 Jam/hari',
          'cost': 52000,
        },
        {
          'name': 'Setrika Listrik',
          'watt': '300 Watt',
          'usage': '2 Jam/hari',
          'cost': 28000,
        },
        {
          'name': 'Lampu LED (5x)',
          'watt': '50 Watt',
          'usage': '10 Jam/hari',
          'cost': 31000,
        },
      ],
    },
    {
      'month': 'Mar',
      'fullMonth': 'Maret 2026',
      'amount': 220000,
      'kwh': 152,
      'paymentDate': DateTime(2026, 3, 18),
      'devices': [
        {
          'name': 'AC 1/2 PK',
          'watt': '350 Watt',
          'usage': '12 Jam/hari',
          'cost': 126000,
        },
        {
          'name': 'Kulkas 1 Pintu',
          'watt': '100 Watt',
          'usage': '24 Jam/hari',
          'cost': 52000,
        },
        {
          'name': 'Mesin Cuci',
          'watt': '350 Watt',
          'usage': '2 Jam/hari',
          'cost': 24000,
        },
        {
          'name': 'Lampu LED (5x)',
          'watt': '50 Watt',
          'usage': '10 Jam/hari',
          'cost': 18000,
        },
      ],
    },
    {
      'month': 'Apr',
      'fullMonth': 'April 2026',
      'amount': 175000,
      'kwh': 121,
      'paymentDate': DateTime(2026, 4, 12),
      'devices': [
        {
          'name': 'AC 1/2 PK',
          'watt': '350 Watt',
          'usage': '7 Jam/hari',
          'cost': 74000,
        },
        {
          'name': 'Kulkas 1 Pintu',
          'watt': '100 Watt',
          'usage': '24 Jam/hari',
          'cost': 52000,
        },
        {
          'name': 'TV LED 32"',
          'watt': '50 Watt',
          'usage': '5 Jam/hari',
          'cost': 18000,
        },
        {
          'name': 'Lampu LED (5x)',
          'watt': '50 Watt',
          'usage': '10 Jam/hari',
          'cost': 31000,
        },
      ],
    },
    {
      'month': 'Mei',
      'fullMonth': 'Mei 2026',
      'amount': 160000,
      'kwh': 110,
      'paymentDate': DateTime(2026, 5, 10),
      'devices': [
        {
          'name': 'AC 1/2 PK',
          'watt': '350 Watt',
          'usage': '6 Jam/hari',
          'cost': 63000,
        },
        {
          'name': 'Kulkas 1 Pintu',
          'watt': '100 Watt',
          'usage': '24 Jam/hari',
          'cost': 52000,
        },
        {
          'name': 'Lampu LED (5x)',
          'watt': '50 Watt',
          'usage': '8 Jam/hari',
          'cost': 25000,
        },
        {
          'name': 'Dispenser',
          'watt': '80 Watt',
          'usage': '24 Jam/hari',
          'cost': 20000,
        },
      ],
    },
    {
      'month': 'Jun',
      'fullMonth': 'Juni 2026',
      'amount': 215000,
      'kwh': 148,
      'paymentDate': DateTime(2026, 6, 16),
      'devices': [
        {
          'name': 'AC 1/2 PK',
          'watt': '350 Watt',
          'usage': '10 Jam/hari',
          'cost': 105000,
        },
        {
          'name': 'Kulkas 1 Pintu',
          'watt': '100 Watt',
          'usage': '24 Jam/hari',
          'cost': 52000,
        },
        {
          'name': 'Pompa Air',
          'watt': '250 Watt',
          'usage': '2 Jam/hari',
          'cost': 27000,
        },
        {
          'name': 'Lampu LED (5x)',
          'watt': '50 Watt',
          'usage': '10 Jam/hari',
          'cost': 31000,
        },
      ],
    },
  ];

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month - 1];
  }

  String _getFullMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month - 1];
  }

  Future<void> _selectPaymentDate(
    BuildContext context,
    Map<String, dynamic> item,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: item['paymentDate'] as DateTime,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF191970),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        item['paymentDate'] = picked;
        item['month'] = _getMonthName(picked.month);
        item['fullMonth'] = '${_getFullMonthName(picked.month)} ${picked.year}';
      });
    }
  }

  void _showDeviceDetailsBottomSheet(
    BuildContext context,
    Map<String, dynamic> item,
    double budgetTarget,
  ) {
    bool isOver = (item['amount'] as num) > budgetTarget;
    final List<dynamic> devices = item['devices'] as List<dynamic>;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rincian ${item['fullMonth']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: Color(0xFF191970),
                        ),
                      ),
                      Text(
                        'Dibayar: ${_formatDate(item['paymentDate'] as DateTime)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isOver ? Colors.redAccent : Colors.green,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Rp ${_formatCurrency((item['amount'] as num).toDouble())}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              const Text(
                'Perangkat Pengguna Listrik',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.indigo.shade50),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF191970,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.power_rounded,
                                    color: Color(0xFF191970),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        device['name'].toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${device['watt']} • ${device['usage']}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Rp ${_formatCurrency((device['cost'] as num).toDouble())}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF191970),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final listrik = Provider.of<ListrikProvider>(context);
    final double budgetTarget = listrik.batasAnggaran;

    double maxHistoryAmount = monthlyHistory
        .map((m) => (m['amount'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);
    double maxChartValue =
        (maxHistoryAmount > budgetTarget ? maxHistoryAmount : budgetTarget) *
        1.25;

    final selectedMonthData =
        monthlyHistory[_selectedBarIndex ?? (monthlyHistory.length - 1)];
    final bool isOverBudget =
        (selectedMonthData['amount'] as num) > budgetTarget;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64.0),
        child: Container(
          height: 64.0,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF111147), Color.fromARGB(255, 18, 18, 219)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/logo.png', width: 26),
                      const SizedBox(width: 8),
                      const Text(
                        "Estikalis",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Atur IP Server API Dosen',
                        onPressed: () => showServerApiDialog(context),
                        icon: Icon(
                          Icons.dns_rounded,
                          color: listrik.isApiConnected
                              ? Colors.greenAccent
                              : Colors.white70,
                          size: 21,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Info Kode Meteran Fisik',
                        onPressed: () => showKodeMeteranDialog(context),
                        icon: const Icon(
                          Icons.info,
                          color: Colors.amber,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FF),
                border: Border.all(
                  color: const Color(0xFF3F51B5).withValues(alpha: 0.3),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.bar_chart,
                              color: Color(0xFF3F51B5),
                              size: 26,
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Tren Pemakaian',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Sentuh batang grafik',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 180,
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: (budgetTarget / maxChartValue) * 120,
                          left: 0,
                          right: 0,
                          child: Row(
                            children: List.generate(
                              40,
                              (index) => Expanded(
                                child: Container(
                                  height: 1.5,
                                  color: index % 2 == 0
                                      ? Colors.redAccent
                                      : Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: ((budgetTarget / maxChartValue) * 120) + 4,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Batas Anggaran',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(monthlyHistory.length, (
                              index,
                            ) {
                              final data = monthlyHistory[index];
                              double barHeight =
                                  ((data['amount'] as num) / maxChartValue) *
                                  120;
                              bool over =
                                  (data['amount'] as num) > budgetTarget;
                              bool isSelected = _selectedBarIndex == index;

                              return GestureDetector(
                                onTap: () {
                                  setState(() => _selectedBarIndex = index);
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (isSelected)
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        margin: const EdgeInsets.only(
                                          bottom: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF191970),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          'Rp ${_formatCurrency((data['amount'] as num).toDouble())}\n(${data['kwh']} kWh)',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    Container(
                                      width: 26,
                                      height: barHeight,
                                      decoration: BoxDecoration(
                                        color: over
                                            ? Colors.redAccent
                                            : const Color(0xFF5C6BC0),
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(6),
                                            ),
                                        border: isSelected
                                            ? Border.all(
                                                color: Colors.amber,
                                                width: 2.5,
                                              )
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      data['month'].toString(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isSelected
                                            ? FontWeight.w900
                                            : FontWeight.w700,
                                        color: isSelected
                                            ? const Color(0xFF191970)
                                            : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isOverBudget
                    ? const Color(0xFFFFEBEE)
                    : const Color(0xFFE8F5E9),
                border: Border.all(
                  color: isOverBudget
                      ? Colors.redAccent.withValues(alpha: 0.5)
                      : Colors.green.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isOverBudget ? Colors.redAccent : Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isOverBudget
                          ? Icons.warning_rounded
                          : Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOverBudget
                              ? 'Peringatan Anggaran!'
                              : 'Anggaran Terkendali!',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: isOverBudget
                                ? Colors.red.shade900
                                : Colors.green.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isOverBudget
                              ? 'Bulan ini tagihan Anda melebihi target Rp ${_formatCurrency(budgetTarget)}. Evaluasi penggunaan listrik Anda!'
                              : 'Pemakaian listrik bulan ini berhasil ditekan. Pertahankan!',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Expanded(
                  child: Text(
                    'Rincian Tagihan',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      color: Color(0xFF191970),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Klik untuk detail',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: monthlyHistory.length,
              itemBuilder: (context, index) {
                final item = monthlyHistory[monthlyHistory.length - 1 - index];
                final bool itemOver = (item['amount'] as num) > budgetTarget;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      _showDeviceDetailsBottomSheet(
                        context,
                        item,
                        budgetTarget,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: itemOver
                                            ? const Color(0xFFFFEBEE)
                                            : const Color(0xFFE8F5E9),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        itemOver
                                            ? Icons.trending_up
                                            : Icons.trending_down,
                                        color: itemOver
                                            ? Colors.redAccent
                                            : Colors.green,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Bulan ${item['month']}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 14.5,
                                              color: Colors.black87,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Total: ${item['kwh']} kWh',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Rp ${_formatCurrency((item['amount'] as num).toDouble())}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14.5,
                                      color: Color(0xFF191970),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: itemOver
                                          ? Colors.redAccent
                                          : Colors.green,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      itemOver
                                          ? 'Over Budget'
                                          : 'Sesuai Target',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.event_available,
                                      size: 16,
                                      color: Color(0xFF191970),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'Tgl Bayar: ${_formatDate(item['paymentDate'] as DateTime)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          color: Colors.black87,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  _selectPaymentDate(context, item);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.edit_calendar,
                                        size: 14,
                                        color: Color(0xFF191970),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Ubah Tgl',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF191970),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
