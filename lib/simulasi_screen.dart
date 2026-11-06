import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'listrik_provider.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  String? _selectedDevice1;
  double _reduction1 = 2;
  String? _selectedDevice2;
  double _reduction2 = 1;

  final TextEditingController _nominalController = TextEditingController(
    text: '20000',
  );
  double _pjuTax = 2;

  final double _adminFee = 2000;
  final double _kwhPrice = 1444.70;

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    final listrik = Provider.of<ListrikProvider>(context);
    final List<Perangkat> daftarAlat = listrik.perangkatList;

    double dailyConsumption = (listrik.totalKwh / 30) > 0
        ? (listrik.totalKwh / 30)
        : 5.0;

    if (daftarAlat.isNotEmpty) {
      if (_selectedDevice1 == null ||
          !daftarAlat.any((p) => p.nama == _selectedDevice1)) {
        _selectedDevice1 = daftarAlat.first.nama;
      }
      if (_selectedDevice2 == null ||
          !daftarAlat.any((p) => p.nama == _selectedDevice2)) {
        _selectedDevice2 = daftarAlat.length > 1
            ? daftarAlat[1].nama
            : daftarAlat.first.nama;
      }
    } else {
      _selectedDevice1 = null;
      _selectedDevice2 = null;
    }

    double totalSavingMonthly = 0;

    if (daftarAlat.isNotEmpty &&
        _selectedDevice1 != null &&
        _selectedDevice2 != null) {
      // PERBAIKAN: Menambahkan tipe kembalian <Perangkat> secara eksplisit
      Perangkat alat1 = daftarAlat.firstWhere(
        (p) => p.nama == _selectedDevice1,
        orElse: () => daftarAlat.first,
      );
      Perangkat alat2 = daftarAlat.firstWhere(
        (p) => p.nama == _selectedDevice2,
        orElse: () => daftarAlat.first,
      );

      double saving1Monthly =
          (alat1.watt / 1000) * _reduction1 * _kwhPrice * 30;
      double saving2Monthly =
          (alat2.watt / 1000) * _reduction2 * _kwhPrice * 30;
      totalSavingMonthly = saving1Monthly + saving2Monthly;
    }

    double totalSavingYearly = totalSavingMonthly * 12;

    double nominal = double.tryParse(_nominalController.text) ?? 0;
    double netNominal = nominal > _adminFee ? nominal - _adminFee : 0;
    double pjuAmount = netNominal * (_pjuTax / 100);
    double electricityNet = netNominal - pjuAmount;
    double kwhReceived = electricityNet > 0 ? electricityNet / _kwhPrice : 0;
    int estimatedDays = (kwhReceived / dailyConsumption).floor();

    if (estimatedDays < 0) {
      estimatedDays = 0;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: Container(
          height: 100.0,
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
                      Image.asset('assets/logo.png', width: 30),
                      const SizedBox(width: 8),
                      const Text(
                        "Simulasi",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.info, color: Colors.amber),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FF),
                border: Border.all(color: const Color(0xFF3F51B5), width: 1.5),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: daftarAlat.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "Tambahkan alat di menu Perangkat terlebih dahulu.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.layers_outlined,
                              color: Color(0xFF3F51B5),
                              size: 28,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Simulator Hemat Mandiri',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildDynamicSliderBox(
                          daftarAlat: daftarAlat,
                          selectedValue: _selectedDevice1!,
                          reductionValue: _reduction1,
                          onDeviceChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() => _selectedDevice1 = newValue);
                            }
                          },
                          onSliderChanged: (val) {
                            setState(() => _reduction1 = val);
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildDynamicSliderBox(
                          daftarAlat: daftarAlat,
                          selectedValue: _selectedDevice2!,
                          reductionValue: _reduction2,
                          onDeviceChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() => _selectedDevice2 = newValue);
                            }
                          },
                          onSliderChanged: (val) {
                            setState(() => _reduction2 = val);
                          },
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            border: Border.all(color: Colors.green, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Potensi Uang Hemat',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Rp ${_formatCurrency(totalSavingMonthly)} / Bulan',
                                    style: const TextStyle(
                                      color: Color(0xFF2E7D32),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '~${(totalSavingYearly / 1000).toStringAsFixed(0)}k/thn',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF2),
                border: Border.all(color: Colors.amber, width: 1.5),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.menu_book, color: Colors.amber, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Kalkulator Token Listrik',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [20000, 50000, 100000, 200000].map((preset) {
                      bool isSelected = nominal == preset;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: InkWell(
                            onTap: () {
                              setState(
                                () =>
                                    _nominalController.text = preset.toString(),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.amber.shade100
                                    : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.amber
                                      : Colors.grey.shade400,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${preset ~/ 1000}RB',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? Colors.amber.shade700
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Nominal Pembelian Token (Rp)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: TextField(
                      controller: _nominalController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) {
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Pajak Penerangan Jalan (PJU): ${_pjuTax.toInt()}%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black54,
                    ),
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 6,
                      activeTrackColor: Colors.amber,
                      inactiveTrackColor: Colors.grey.shade300,
                      thumbColor: Colors.amber,
                    ),
                    child: Slider(
                      value: _pjuTax,
                      min: 0,
                      max: 10,
                      divisions: 10,
                      onChanged: (val) {
                        setState(() => _pjuTax = val);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF282A7C),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildResultRow(
                          'Biaya Admin Bank:',
                          'Rp ${_formatCurrency(_adminFee)}',
                          Colors.white70,
                          Colors.white,
                        ),
                        const Divider(
                          color: Colors.white24,
                          height: 24,
                          thickness: 1,
                        ),
                        _buildResultRow(
                          'Pajak PJU (${_pjuTax.toInt()}%):',
                          'Rp ${_formatCurrency(pjuAmount)}',
                          Colors.white70,
                          Colors.white,
                        ),
                        const Divider(
                          color: Colors.white24,
                          height: 24,
                          thickness: 1,
                        ),
                        _buildResultRow(
                          'Dapat Listrik Bersih:',
                          '${kwhReceived.toStringAsFixed(2)} kWh',
                          Colors.white70,
                          Colors.amber,
                        ),
                        const Divider(
                          color: Colors.white24,
                          height: 24,
                          thickness: 1,
                        ),
                        _buildResultRow(
                          'Estimasi Habis Dalam:',
                          '$estimatedDays Hari',
                          Colors.white70,
                          Colors.greenAccent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicSliderBox({
    required List<Perangkat> daftarAlat,
    required String selectedValue,
    required double reductionValue,
    required ValueChanged<String?> onDeviceChanged,
    required Function(double) onSliderChanged,
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFC5CAE9).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedValue,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFF3F51B5),
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                    onChanged: onDeviceChanged,
                    items: daftarAlat.map<DropdownMenuItem<String>>((
                      Perangkat device,
                    ) {
                      return DropdownMenuItem<String>(
                        value: device.nama,
                        child: Text(
                          'Kurangi ${device.nama}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${reductionValue.toInt()} Jam/hari',
                style: const TextStyle(
                  color: Color(0xFF3F51B5),
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 12,
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white,
              thumbColor: const Color(0xFF5C6BC0),
              overlayColor: const Color(0xFF5C6BC0).withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: reductionValue,
              min: 0,
              max: 24,
              divisions: 24,
              onChanged: onSliderChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(
    String label,
    String value,
    Color labelColor,
    Color valueColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
