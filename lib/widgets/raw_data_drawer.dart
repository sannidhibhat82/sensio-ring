import 'package:flutter/material.dart';

/// Bottom drawer to show raw data from the device (hex, decoded).
/// Slide up to view; for developer to inspect raw BLE notifications.
class RawDataDrawer extends StatelessWidget {
  const RawDataDrawer({
    super.key,
    required this.title,
    required this.rawLines,
  });

  final String title;
  final List<String> rawLines;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(title, style: Theme.of(context).textTheme.titleMedium),
            ),
            const Divider(height: 1),
            Expanded(
              child: rawLines.isEmpty
                  ? const Center(child: Text('No raw data yet'))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: rawLines.length,
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: SelectableText(
                            rawLines[i],
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
