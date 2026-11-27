import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/location/location_providers.dart';
import '../../core/theme/app_colors.dart';
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
  final _nameController = TextEditingController();
  final _locationFieldKey = GlobalKey<FormFieldState<String>>();
  bool _loading = false;
  bool _showManual = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _useGps() async {
    setState(() => _loading = true);
    final coordinates =
        await ref.read(locationServiceProvider).getCurrentLocation();
    if (!mounted) return;
    setState(() => _loading = false);

    if (coordinates == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location unavailable. Try again or enter coordinates manually.',
          ),
        ),
      );
      return;
    }

    widget.latitudeController.text = coordinates.latitude.toStringAsFixed(6);
    widget.longitudeController.text = coordinates.longitude.toStringAsFixed(6);
    setState(() {
      _nameController.text = coordinates.name ?? 'Current location';
    });
    _locationFieldKey.currentState?.validate();
  }

  String? _validateLocation(String? _) {
    if (_showManual) return null;
    final latitudeError = Validators.latitude(widget.latitudeController.text);
    if (latitudeError != null) {
      return 'Location required. Tap Use GPS or enter coordinates manually.';
    }
    final longitudeError = Validators.longitude(widget.longitudeController.text);
    if (longitudeError != null) {
      return 'Location required. Tap Use GPS or enter coordinates manually.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Location',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
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
        const SizedBox(height: 8),
        FormField<String>(
          key: _locationFieldKey,
          validator: _validateLocation,
          builder: (state) {
            return AppTextField(
              controller: _nameController,
              label: 'Location name',
              hint: 'Tap Use GPS to detect your location',
              prefixIcon: Icons.place_outlined,
              errorText: state.errorText,
            );
          },
        ),
        if (_showManual) ...[
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: widget.latitudeController,
                  label: 'Latitude',
                  hint: '23.8103',
                  prefixIcon: Icons.explore_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  validator: Validators.latitude,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  controller: widget.longitudeController,
                  label: 'Longitude',
                  hint: '90.4125',
                  prefixIcon: Icons.explore_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  validator: Validators.longitude,
                ),
              ),
            ],
          ),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              setState(() => _showManual = !_showManual);
              _locationFieldKey.currentState?.validate();
            },
            icon: Icon(
              _showManual ? Icons.expand_less : Icons.edit_outlined,
              size: 18,
            ),
            label: Text(
              _showManual ? 'Hide coordinates' : 'Enter coordinates manually',
            ),
          ),
        ),
      ],
    );
  }
}
