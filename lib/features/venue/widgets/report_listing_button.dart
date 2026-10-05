import 'package:flutter/material.dart';

class ReportListingButton extends StatefulWidget {
  const ReportListingButton({super.key});

  @override
  State<ReportListingButton> createState() => _ReportListingButtonState();
}

class _ReportListingButtonState extends State<ReportListingButton> {
  void _showReportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return const _ReportBottomSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
      child: Center(
        child: TextButton.icon(
          onPressed: () => _showReportSheet(context),
          icon: const Icon(Icons.flag_outlined, color: Colors.grey, size: 20),
          label: const Text(
            'Report this listing',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ),
    );
  }
}

class _ReportBottomSheet extends StatefulWidget {
  const _ReportBottomSheet();

  @override
  State<_ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<_ReportBottomSheet> {
  String? _selectedReason;
  final TextEditingController _commentsController = TextEditingController();

  final List<String> _reasons = [
    'Abusive language',
    'Misleading price and photos',
    'Fake photos',
    'Duplicate listing',
    'Off-platform solicitation',
  ];

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  void _submitReport() {
    if (_selectedReason == null) return;
    
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report submitted for review.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: bottomInset + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Why are you reporting this listing?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._reasons.map((reason) {
            return RadioListTile<String>(
              title: Text(reason),
              value: reason,
              groupValue: _selectedReason,
              onChanged: (value) {
                setState(() {
                  _selectedReason = value;
                });
              },
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            );
          }),
          const SizedBox(height: 16),
          TextField(
            controller: _commentsController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Additional comments (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _selectedReason != null ? _submitReport : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Submit Report'),
          ),
        ],
      ),
    );
  }
}
