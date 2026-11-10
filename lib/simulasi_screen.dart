import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'listrik_provider.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  String? _selectedDeviceId1;
  double _reduction1 = 2;
  String? _selectedDeviceId2;
  double _reduction2 = 1;

  final TextEditingController _nominalController = TextEditingController(
    text: '20000',
  );
  double _pjuTax = 2;

  final double _adminFee = 2000;

  @override
  void dispose() {
    _nominalController.dispose();
    super.dispose();
  }

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
    final double kwhPrice = listrik.tarifKwh;

    double dailyConsumption = (listrik.totalKwh / 30) > 0
        ? (listrik.totalKwh / 30)
        : 5.0;

    if (daftarAlat.isNotEmpty) {
      if (_selectedDeviceId1 == null ||
          !daftarAlat.any((p) => p.id == _selectedDeviceId1)) {
        _selectedDeviceId1 = daftarAlat.first.id;
      }
      if (daftarAlat.length > 1) {
        if (_selectedDeviceId2 == null ||
            !daftarAlat.any((p) => p.id == _selectedDeviceId2) ||
            _selectedDeviceId2 == _selectedDeviceId1) {
          final secondDevice = daftarAlat.firstWhere(
            (p) => p.id != _selectedDeviceId1,
            orElse: () => daftarAlat[1],
          );
          _selectedDeviceId2 = secondDevice.id;
        }
      } else {
        _selectedDeviceId2 = null;
      }
    } else {
      _selectedDeviceId1 = null;
      _selectedDeviceId2 = null;
    }

    double totalSavingMonthly = 0;
    Perangkat? alat1;
    Perangkat? alat2;

    if (daftarAlat.isNotEmpty && _selectedDeviceId1 != null) {
      alat1 = daftarAlat.firstWhere(
        (p) => p.id == _selectedDeviceId1,
        orElse: () => daftarAlat.first,
      );
      final double maxJam1 = alat1.jam.toDouble().clamp(1.0, 24.0);
      final double effReduction1 = _reduction1.clamp(0.0, maxJam1);
      double saving1Monthly =
          (alat1.watt / 1000) * effReduction1 * kwhPrice * 30;
      totalSavingMonthly += saving1Monthly;

      if (daftarAlat.length > 1 && _selectedDeviceId2 != null) {
        alat2 = daftarAlat.firstWhere(
          (p) => p.id == _selectedDeviceId2,
          orElse: () => daftarAlat[1],
        );
        final double maxJam2 = alat2.jam.toDouble().clamp(1.0, 24.0);
        final double effReduction2 = _reduction2.clamp(0.0, maxJam2);
        if (alat2.id != alat1.id) {
          double saving2Monthly =
              (alat2.watt / 1000) * effReduction2 * kwhPrice * 30;
          totalSavingMonthly += saving2Monthly;
        }
      }
    }

    double totalSavingYearly = totalSavingMonthly * 12;

    double nominal = double.tryParse(_nominalController.text) ?? 0;
    double netNominal = nominal > _adminFee ? nominal - _adminFee : 0;
    double pjuAmount = netNominal * (_pjuTax / 100);
    double electricityNet = netNominal - pjuAmount;
    double kwhReceived = electricityNet > 0 ? electricityNet / kwhPrice : 0;
    int estimatedDays = (kwhReceived / dailyConsumption).floor();

    if (estimatedDays < 0) {
      estimatedDays = 0;
    }

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
                        "Simulasi",
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
          children: [
            Container(
              padding: const EdgeInsets.all(16),
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
                        const Row(
                          children: [
                            Icon(
                              Icons.layers_outlined,
                              color: Color(0xFF3F51B5),
                              size: 26,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Simulator Hemat Mandiri',
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildDynamicSliderBox(
                          daftarAlat: daftarAlat,
                          selectedId: _selectedDeviceId1!,
                          maxJam: (alat1?.jam ?? 24)
                              .toDouble()
                              .clamp(1.0, 24.0),
                          reductionValue: _reduction1.clamp(
                            0.0,
                            (alat1?.jam ?? 24).toDouble().clamp(1.0, 24.0),
                          ),
                          onDeviceChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() => _selectedDeviceId1 = newValue);
                            }
                          },
                          onSliderChanged: (val) {
                            setState(() => _reduction1 = val);
                          },
                        ),
                        if (daftarAlat.length > 1 &&
                            _selectedDeviceId2 != null) ...[
                          const SizedBox(height: 12),
                          _buildDynamicSliderBox(
                            daftarAlat: daftarAlat,
                            selectedId: _selectedDeviceId2!,
                            maxJam: (alat2?.jam ?? 24)
                                .toDouble()
                                .clamp(1.0, 24.0),
                            reductionValue: _reduction2.clamp(
                              0.0,
                              (alat2?.jam ?? 24).toDouble().clamp(1.0, 24.0),
                            ),
                            onDeviceChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() => _selectedDeviceId2 = newValue);
                              }
                            },
                            onSliderChanged: (val) {
                              setState(() => _reduction2 = val);
                            },
                          ),
                        ],
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
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
                                  fontSize: 12.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Rp ${_formatCurrency(totalSavingMonthly)} / Bulan',
                                      style: const TextStyle(
                                        color: Color(0xFF2E7D32),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16.5,
                                      ),
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
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
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
                  const Row(
                    children: [
                      Icon(Icons.menu_book, color: Colors.amber, size: 26),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Kalkulator Token Listrik',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [20000, 50000, 100000, 200000].map((preset) {
                      bool isSelected = nominal == preset;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3.0),
                          child: InkWell(
                            onTap: () {
                              setState(
                                () =>
                                    _nominalController.text = preset.toString(),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
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
                                  fontSize: 12,
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
                  const SizedBox(height: 14),
                  const Text(
                    'Nominal Pembelian Token (Rp)',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 42,
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
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) {
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Pajak Penerangan Jalan (PJU): ${_pjuTax.toInt()}%',
                    style: const TextStyle(
                      fontSize: 12.5,
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
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
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
                          height: 18,
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
                          height: 18,
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
                          height: 18,
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
    required String selectedId,
    required double maxJam,
    required double reductionValue,
    required ValueChanged<String?> onDeviceChanged,
    required Function(double) onSliderChanged,
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 6, left: 12, right: 12, bottom: 6),
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
                    value: selectedId,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFF3F51B5),
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12.5,
                      color: Colors.black87,
                    ),
                    onChanged: onDeviceChanged,
                    items: daftarAlat.map<DropdownMenuItem<String>>((
                      Perangkat device,
                    ) {
                      return DropdownMenuItem<String>(
                        value: device.id,
                        child: Text(
                          'Kurangi ${device.nama} (${device.ruangan})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${reductionValue.toInt()} / ${maxJam.toInt()} Jam',
                style: const TextStyle(
                  color: Color(0xFF3F51B5),
                  fontWeight: FontWeight.w900,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 10,
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white,
              thumbColor: const Color(0xFF5C6BC0),
              overlayColor: const Color(0xFF5C6BC0).withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
            ),
            child: Slider(
              value: reductionValue,
              min: 0,
              max: maxJam,
              divisions: maxJam.toInt() > 0 ? maxJam.toInt() : 1,
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
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.w800,
            fontSize: 13.5,
          ),
        ),
      ],
    );
  }
}
