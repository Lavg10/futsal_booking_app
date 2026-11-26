import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/image_picker_field.dart';
import '../../../../shared/widgets/location_fields.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../domain/ground.dart';
import '../../domain/slot_generator.dart';
import '../../providers/owner_providers.dart';
import '../widgets/pricing_rule_editor.dart';

class GroundEditorScreen extends ConsumerStatefulWidget {
  const GroundEditorScreen({super.key, this.ground});

  final Ground? ground;

  @override
  ConsumerState<GroundEditorScreen> createState() => _GroundEditorScreenState();
}

class _GroundEditorScreenState extends ConsumerState<GroundEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _amenitiesController;
  late final TextEditingController _basePriceController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  late SurchargeRule _morning;
  late SurchargeRule _night;
  late SurchargeRule _saturday;
  late TimeOfDay _open;
  late TimeOfDay _close;
  late int _durationMinutes;
  final List<XFile> _newImages = [];

  @override
  void initState() {
    super.initState();
    final ground = widget.ground;
    _nameController = TextEditingController(text: ground?.name ?? '');
    _addressController = TextEditingController(text: ground?.address ?? '');
    _descriptionController =
        TextEditingController(text: ground?.description ?? '');
    _amenitiesController =
        TextEditingController(text: ground?.amenities.join(', ') ?? '');
    _basePriceController = TextEditingController(
      text: ground?.basePrice.toStringAsFixed(0) ?? '',
    );
    _latitudeController = TextEditingController(
      text: ground?.latitude.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: ground?.longitude.toString() ?? '',
    );
    _morning = ground?.pricingRules.morning ?? PricingRules.defaults.morning;
    _night = ground?.pricingRules.night ?? PricingRules.defaults.night;
    _saturday = ground?.pricingRules.saturday ?? PricingRules.defaults.saturday;
    _open = const TimeOfDay(hour: 8, minute: 0);
    _close = const TimeOfDay(hour: 22, minute: 0);
    _durationMinutes = 60;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _amenitiesController.dispose();
    _basePriceController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool isOpen}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isOpen ? _open : _close,
    );
    if (picked == null) return;
    setState(() {
      if (isOpen) {
        _open = picked;
      } else {
        _close = picked;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final ownerId = ref.read(currentUserProvider)?.uid;
    if (ownerId == null) return;

    final slots = SlotGenerator.generate(
      open: _open,
      close: _close,
      durationMinutes: _durationMinutes,
    );
    if (slots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Time window is too short for a slot')),
      );
      return;
    }

    final ground = Ground(
      id: widget.ground?.id ?? const Uuid().v4(),
      ownerId: ownerId,
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      description: _descriptionController.text.trim(),
      amenities: _amenitiesController.text
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(),
      latitude: double.parse(_latitudeController.text),
      longitude: double.parse(_longitudeController.text),
      geohash: widget.ground?.geohash ?? '',
      basePrice: double.parse(_basePriceController.text),
      pricingRules: PricingRules(
        morning: _morning,
        night: _night,
        saturday: _saturday,
      ),
      slots: slots,
      imageUrls: widget.ground?.imageUrls ?? const [],
      isActive: widget.ground?.isActive ?? true,
      createdAt: widget.ground?.createdAt,
      updatedAt: widget.ground?.updatedAt,
    );

    await ref.read(groundSaveControllerProvider.notifier).save(
          ground: ground,
          isNew: widget.ground == null,
          newImages: _newImages,
        );

    if (!mounted) return;
    final result = ref.read(groundSaveControllerProvider);
    if (result.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: ${result.error}')),
      );
      return;
    }
    context.go('/owner');
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(groundSaveControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ground == null ? 'Add ground' : 'Edit ground'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: _nameController,
                  label: 'Ground name',
                  validator: (value) => Validators.required(value, 'Ground name'),
                ),
                AppTextField(
                  controller: _addressController,
                  label: 'Address',
                  maxLines: 2,
                  validator: (value) => Validators.required(value, 'Address'),
                ),
                AppTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  maxLines: 3,
                ),
                AppTextField(
                  controller: _amenitiesController,
                  label: 'Amenities (comma separated)',
                  hint: 'Parking, Changing room, AC',
                ),
                LocationFields(
                  latitudeController: _latitudeController,
                  longitudeController: _longitudeController,
                ),
                AppTextField(
                  controller: _basePriceController,
                  label: 'Base price per slot',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) => Validators.positiveNumber(value, 'Price'),
                ),
                const SizedBox(height: 8),
                const Text('Playing slots',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickTime(isOpen: true),
                        icon: const Icon(Icons.login),
                        label: Text('Open ${_format(_open)}'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickTime(isOpen: false),
                        icon: const Icon(Icons.logout),
                        label: Text('Close ${_format(_close)}'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  initialValue: _durationMinutes,
                  decoration: const InputDecoration(labelText: 'Slot duration'),
                  items: const [
                    DropdownMenuItem(value: 30, child: Text('30 minutes')),
                    DropdownMenuItem(value: 45, child: Text('45 minutes')),
                    DropdownMenuItem(value: 60, child: Text('60 minutes')),
                    DropdownMenuItem(value: 90, child: Text('90 minutes')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _durationMinutes = value);
                  },
                ),
                const SizedBox(height: 16),
                const Text('Price rules',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                PricingRuleEditor(
                  title: 'Morning surcharge',
                  initial: _morning,
                  showTimeWindow: true,
                  onChanged: (rule) => _morning = rule,
                ),
                PricingRuleEditor(
                  title: 'Night surcharge',
                  initial: _night,
                  showTimeWindow: true,
                  onChanged: (rule) => _night = rule,
                ),
                PricingRuleEditor(
                  title: 'Saturday surcharge',
                  initial: _saturday,
                  showTimeWindow: false,
                  onChanged: (rule) => _saturday = rule,
                ),
                ImagePickerField(
                  maxImages: 5,
                  initialUrls: widget.ground?.imageUrls ?? const [],
                  onChanged: (files) => _newImages
                    ..clear()
                    ..addAll(files),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: isLoading ? null : _save,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save ground'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _format(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }
}
