import 'package:flutter/material.dart';

import '../../domain/ground.dart';

class PricingRuleEditor extends StatefulWidget {
  const PricingRuleEditor({
    super.key,
    required this.title,
    required this.initial,
    required this.showTimeWindow,
    required this.onChanged,
  });

  final String title;
  final SurchargeRule initial;
  final bool showTimeWindow;
  final ValueChanged<SurchargeRule> onChanged;

  @override
  State<PricingRuleEditor> createState() => _PricingRuleEditorState();
}

class _PricingRuleEditorState extends State<PricingRuleEditor> {
  late bool _enabled;
  late TimeOfDay _start;
  late TimeOfDay _end;
  late SurchargeType _type;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _enabled = widget.initial.enabled;
    _start = _parseTime(widget.initial.start);
    _end = _parseTime(widget.initial.end);
    _type = widget.initial.type;
    _amountController = TextEditingController(
      text: widget.initial.amount.toStringAsFixed(0),
    );
    _amountController.addListener(_notify);
  }

  @override
  void dispose() {
    _amountController.removeListener(_notify);
    _amountController.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onChanged(
      SurchargeRule(
        enabled: _enabled,
        start: _format(_start),
        end: _format(_end),
        type: _type,
        amount: double.tryParse(_amountController.text) ?? 0,
      ),
    );
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(widget.title),
              value: _enabled,
              onChanged: (value) {
                setState(() => _enabled = value);
                _notify();
              },
            ),
            if (_enabled) ...[
              if (widget.showTimeWindow)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickTime(isStart: true),
                        icon: const Icon(Icons.schedule),
                        label: Text('From ${_format(_start)}'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickTime(isStart: false),
                        icon: const Icon(Icons.schedule),
                        label: Text('To ${_format(_end)}'),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<SurchargeType>(
                      initialValue: _type,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: const [
                        DropdownMenuItem(
                          value: SurchargeType.percent,
                          child: Text('Percent (%)'),
                        ),
                        DropdownMenuItem(
                          value: SurchargeType.fixed,
                          child: Text('Fixed amount'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _type = value);
                        _notify();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: _type == SurchargeType.percent
                            ? 'Extra percent'
                            : 'Extra amount',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  static TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts.first) ?? 0,
      minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
  }

  static String _format(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }
}
