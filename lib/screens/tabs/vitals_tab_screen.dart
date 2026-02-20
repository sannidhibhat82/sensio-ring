import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/ble_service.dart';
import '../../widgets/raw_data_drawer.dart';

/// Combined screen for STS40 Temperature, Significant Motion, Stored Vitals (GETVITALS).
class VitalsTabScreen extends StatefulWidget {
  const VitalsTabScreen({super.key});

  @override
  State<VitalsTabScreen> createState() => _VitalsTabScreenState();
}

class _VitalsTabScreenState extends State<VitalsTabScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BleService _ble = BleService.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vitals'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'STS40 Temperature'),
            Tab(text: 'Significant Motion'),
            Tab(text: 'Stored Vitals'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _Sts40Tab(ble: _ble),
          _SigMotTab(ble: _ble),
          _GetVitalsTab(ble: _ble),
        ],
      ),
    );
  }
}

class _Sts40Tab extends StatefulWidget {
  const _Sts40Tab({required this.ble});

  final BleService ble;

  @override
  State<_Sts40Tab> createState() => _Sts40TabState();
}

class _Sts40TabState extends State<_Sts40Tab> {
  StreamSubscription<List<int>>? _subCustom;
  StreamSubscription<List<int>>? _subVitals;
  double? _lastTempC;
  int? _lastRawByte;
  final List<String> _rawLogs = [];
  bool _streaming = false;

  static bool _isCommandEcho(List<int> bytes) {
    if (bytes.length < 6 || bytes.length > 16) return false;
    return bytes.every((b) => b >= 0x20 && b <= 0x7E);
  }

  void _onSts40Data(List<int> bytes) {
    if (_isCommandEcho(bytes)) return;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
    final converted = bytes.map((b) => '${((b + 200) / 10.0).toStringAsFixed(1)} °C').join(', ');
    if (mounted) {
      setState(() {
        _rawLogs.add('$hex  (${bytes.length} B) → $converted');
        if (bytes.isNotEmpty) {
          _lastRawByte = bytes.last;
          _lastTempC = (bytes.last + 200) / 10.0;
        }
      });
    }
  }

  Future<void> _start() async {
    if (_streaming) return;
    setState(() {
      _streaming = true;
      _rawLogs.clear();
      _lastTempC = null;
      _lastRawByte = null;
    });
    await widget.ble.writeCustom('STARTSTS40');
    // Device may send STS40 temperature on Custom or on Vitals; listen to both.
    _subCustom = widget.ble.customNotifications.listen(_onSts40Data);
    _subVitals = widget.ble.vitalsNotifications.listen((bytes) {
      if (_isCommandEcho(bytes)) return;
      _onSts40Data(bytes);
    });
  }

  Future<void> _stop() async {
    _subCustom?.cancel();
    _subCustom = null;
    _subVitals?.cancel();
    _subVitals = null;
    await widget.ble.writeCustom('STOPSTS40');
    setState(() => _streaming = false);
  }

  @override
  void dispose() {
    _subCustom?.cancel();
    _subVitals?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('STS40 Temperature', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(
                    _lastTempC != null ? '${_lastTempC!.toStringAsFixed(1)} °C' : '-- °C',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  if (_lastRawByte != null) Text('Raw value: $_lastRawByte', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(onPressed: _streaming ? null : _start, icon: const Icon(Icons.play_arrow), label: const Text('Start')),
          const SizedBox(height: 8),
          OutlinedButton.icon(onPressed: _streaming ? _stop : null, icon: const Icon(Icons.stop), label: const Text('Stop')),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => RawDataDrawer(title: 'Raw data (STS40 Temperature)', rawLines: List.from(_rawLogs)),
            ),
            icon: const Icon(Icons.code),
            label: const Text('View raw data'),
          ),
        ],
      ),
    );
  }
}

class _SigMotTab extends StatefulWidget {
  const _SigMotTab({required this.ble});

  final BleService ble;

  @override
  State<_SigMotTab> createState() => _SigMotTabState();
}

class _SigMotTabState extends State<_SigMotTab> {
  StreamSubscription<List<int>>? _sub;
  final List<int> _values = [];
  final List<String> _rawLogs = [];
  bool _streaming = false;

  Future<void> _start() async {
    if (_streaming) return;
    setState(() {
      _streaming = true;
      _values.clear();
      _rawLogs.clear();
    });
    await widget.ble.writeVitals('sigmot');
    _sub = widget.ble.vitalsNotifications.listen((bytes) {
      final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
      if (mounted) setState(() {
        _rawLogs.add('$hex  (${bytes.length} B)');
        _values.addAll(bytes);
      });
    });
  }

  Future<void> _stop() async {
    _sub?.cancel();
    setState(() => _streaming = false);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Significant Motion', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 4),
                  const Text('Count per 30 s window (no unit)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  if (_values.isEmpty)
                    const Text('--', style: TextStyle(fontSize: 20))
                  else
                    Text('Last: ${_values.last}', style: Theme.of(context).textTheme.headlineSmall),
                  if (_values.isNotEmpty) Text('Total values: ${_values.length}', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
          if (_values.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _values.length,
                itemBuilder: (context, i) => ListTile(
                  title: Text('30 s window ${i + 1}: ${_values[i]}'),
                ),
              ),
            ),
          ElevatedButton.icon(onPressed: _streaming ? null : _start, icon: const Icon(Icons.play_arrow), label: const Text('Start')),
          const SizedBox(height: 8),
          OutlinedButton.icon(onPressed: _streaming ? _stop : null, icon: const Icon(Icons.stop), label: const Text('Stop')),
          OutlinedButton.icon(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => RawDataDrawer(title: 'Raw data (Significant Motion)', rawLines: List.from(_rawLogs)),
            ),
            icon: const Icon(Icons.code),
            label: const Text('View raw data'),
          ),
        ],
      ),
    );
  }
}

class _GetVitalsTab extends StatefulWidget {
  const _GetVitalsTab({required this.ble});

  final BleService ble;

  @override
  State<_GetVitalsTab> createState() => _GetVitalsTabState();
}

class _GetVitalsTabState extends State<_GetVitalsTab> {
  StreamSubscription<List<int>>? _sub;
  List<int> _sigMot = [];
  List<int> _steps = [];
  List<double> _temps = [];
  List<int> _hr = [];
  final List<String> _rawLogs = [];
  final List<int> _vitalsBuffer = [];
  int _sigF = 0, _stepF = 0, _tempF = 0, _hrF = 0;
  bool _loading = false;
  bool _headerRead = false;

  void _drainVitalsBuffer() {
    if (!_headerRead || _vitalsBuffer.isEmpty) return;
    // Doc: "number of frame" with chunks up to 60 bytes → max = count * 60.
    // Some devices send sample counts (1 byte = 1 value); if any count > 60 use as byte counts.
    final useSampleCounts = _sigF > 60 || _stepF > 60 || _tempF > 60 || _hrF > 60;
    final maxSig = useSampleCounts ? _sigF : _sigF * 60;
    final maxStep = useSampleCounts ? _stepF : _stepF * 60;
    final maxTemp = useSampleCounts ? _tempF : _tempF * 60;
    final maxHr = useSampleCounts ? _hrF : _hrF * 60;
    int i = 0;
    while (i < _vitalsBuffer.length) {
      if (_sigMot.length < maxSig) {
        _sigMot.add(_vitalsBuffer[i++]);
      } else if (_steps.length < maxStep) {
        _steps.add(_vitalsBuffer[i++]);
      } else if (_temps.length < maxTemp) {
        _temps.add((_vitalsBuffer[i++] + 200) / 10.0);
      } else if (_hr.length < maxHr) {
        _hr.add(_vitalsBuffer[i++]);
      } else {
        break;
      }
    }
    if (i > 0) _vitalsBuffer.removeRange(0, i);
  }

  Future<void> _fetch() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _sigMot = [];
      _steps = [];
      _temps = [];
      _hr = [];
      _rawLogs.clear();
      _vitalsBuffer.clear();
      _sigF = _stepF = _tempF = _hrF = 0;
      _headerRead = false;
    });
    await widget.ble.writeVitals('GETVITALS');
    // Skip command echo: device echoes "GETVITALS" (9 bytes) back; do not add to buffer (overview.md)
    const getVitalsEcho = [0x47, 0x45, 0x54, 0x56, 0x49, 0x54, 0x41, 0x4c, 0x53];
    bool isGetVitalsEcho(List<int> b) =>
        b.length == 9 &&
        b[0] == 0x47 && b[1] == 0x45 && b[2] == 0x54 && b[3] == 0x56 &&
        b[4] == 0x49 && b[5] == 0x54 && b[6] == 0x41 && b[7] == 0x4c && b[8] == 0x53;
    _sub = widget.ble.vitalsNotifications.listen((bytes) {
      final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
      if (mounted) {
        setState(() {
          _rawLogs.add('$hex  (${bytes.length} B)');
          if (isGetVitalsEcho(bytes)) return;
          _vitalsBuffer.addAll(bytes);
          if (!_headerRead && _vitalsBuffer.length >= 4) {
            _headerRead = true;
            _sigF = _vitalsBuffer[0];
            _stepF = _vitalsBuffer[1];
            _tempF = _vitalsBuffer[2];
            _hrF = _vitalsBuffer[3];
            _vitalsBuffer.removeRange(0, 4);
          }
          _drainVitalsBuffer();
        });
      }
    });
    await Future.delayed(const Duration(seconds: 32));
    _sub?.cancel();
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Stored Vitals (GETVITALS)', style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          const Text('Data order: SigMot → Steps → Temperature (°C) → Heart Rate. Wait up to 30s for full transfer.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          if (_headerRead) ...[
            const SizedBox(height: 8),
            Text('Header (counts): SigMot $_sigF, Steps $_stepF, Temp $_tempF, HR $_hrF', style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loading ? null : _fetch,
            icon: const Icon(Icons.download),
            label: Text(_loading ? 'Waiting up to 30 s…' : 'Fetch stored vitals'),
          ),
          const SizedBox(height: 16),
          if (_sigMot.isNotEmpty) _SummaryRow('Significant motion', '${_sigMot.length} values', null),
          if (_steps.isNotEmpty) _SummaryRow('Step count', '${_steps.length} values', null),
          if (_temps.isNotEmpty) _SummaryRow('Temperature', '${_temps.length} values', '°C'),
          if (_hr.isNotEmpty) _SummaryRow('Heart rate', '${_hr.length} values', 'BPM'),
          if (_sigMot.isNotEmpty || _steps.isNotEmpty || _temps.isNotEmpty || _hr.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const Text('Parsed values (per overview.md)', style: TextStyle(fontSize: 12, color: Colors.grey)),
            if (_sigMot.isNotEmpty)
              _VitalsValueSection(title: 'SigMot (per 30s)', values: _sigMot.map((v) => v.toString()).toList()),
            if (_steps.isNotEmpty)
              _VitalsValueSection(title: 'Steps', values: _steps.map((v) => v.toString()).toList()),
            if (_temps.isNotEmpty)
              _VitalsValueSection(title: 'Temperature (°C)', values: _temps.map((v) => v.toStringAsFixed(1)).toList()),
            if (_hr.isNotEmpty)
              _VitalsValueSection(title: 'Heart rate (BPM)', values: _hr.map((v) => v.toString()).toList()),
          ],
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => RawDataDrawer(title: 'Raw data (Stored Vitals)', rawLines: List.from(_rawLogs)),
            ),
            icon: const Icon(Icons.code),
            label: const Text('View raw data'),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, this.unit);

  final String label;
  final String value;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text('$value${unit != null ? ' $unit' : ''}'),
        ],
      ),
    );
  }
}

class _VitalsValueSection extends StatelessWidget {
  const _VitalsValueSection({required this.title, required this.values});

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 160),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: values.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('${i + 1}. ${values[i]}', style: Theme.of(context).textTheme.bodySmall),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
