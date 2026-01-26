import 'package:flutter/material.dart';
import 'package:dr_shine_app/features/status/providers/status_provider.dart';

class StatusToggle extends StatelessWidget {
  final BusyStatus currentStatus;
  final Function(BusyStatus) onStatusChanged;

  const StatusToggle({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<BusyStatus>(
      segments: const [
        ButtonSegment(
          value: BusyStatus.notBusy,
          label: Text('Not Busy'),
          icon: Icon(Icons.check_circle),
        ),
        ButtonSegment(
          value: BusyStatus.busy,
          label: Text('Busy'),
          icon: Icon(Icons.access_time),
        ),
        ButtonSegment(
          value: BusyStatus.veryBusy,
          label: Text('Very Busy'),
          icon: Icon(Icons.error),
        ),
      ],
      selected: {currentStatus},
      onSelectionChanged: (set) => onStatusChanged(set.first),
    );
  }
}
