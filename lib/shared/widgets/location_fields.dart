import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/location/location_providers.dart';
import '../../core/utils/validators.dart';
import 'app_text_field.dart';

class LocationFields extends ConsumerStatefulWidget {
  const LocationFields({
    super.key,
    required this.latitudeController,
    required this.longitudeController,
  });

  final TextEditingController latitudeController;
  final TextEditingController longitudeController;

  @override
  ConsumerState<LocationFields> createState() => _LocationFieldsState();
}

class _LocationFieldsState extends ConsumerState<LocationFields> {
  bool _loading = false;

  Future<void> _useGps() async {
    setState(() => _loading = true);
    final coordinates = await ref.read(locationServiceProvider).getCurrentLocation();
    if (!mounted) return;
    setState(() => _loading = false);

    if (coordinates == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location unavailable. Enter latitude and longitude manually.'),
        ),
      );
      return;
    }

    widget.latitudeController.text = coordinates.latitude.toStringAsFixed(6);
    widget.longitudeController.text = coordinates.longitude.toStringAsFixed(6);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text('Location', style: TextStyle(fontWeight: FontWeight.w600)),
            const Spacer(),
            TextButton.icon(
              onPressed: _loading ? null : _useGps,
              icon: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: const Text('Use GPS'),
            ),
          ],
        ),
        AppTextField(
          controller: widget.latitudeController,
          label: 'Latitude',
          hint: '23.8103',
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          validator: (value) => Validators.latitude(value),
        ),
        AppTextField(
          controller: widget.longitudeController,
          label: 'Longitude',
          hint: '90.4125',
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          validator: (value) => Validators.longitude(value),
        ),
      ],
    );
  }
}
