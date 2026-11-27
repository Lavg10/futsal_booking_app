import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';

class ImagePickerField extends StatefulWidget {
  const ImagePickerField({
    super.key,
    required this.onChanged,
    this.maxImages = 5,
    this.initialUrls = const [],
    this.label = 'Images',
  });

  final ValueChanged<List<XFile>> onChanged;
  final int maxImages;
  final List<String> initialUrls;
  final String label;

  @override
  State<ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends State<ImagePickerField> {
  final List<XFile> _files = [];

  Future<void> _pickImages() async {
    final remaining = widget.maxImages - _files.length - widget.initialUrls.length;
    if (remaining <= 0) return;

    final picked = await ImagePicker().pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;

    setState(() {
      _files.addAll(picked.take(remaining));
    });
    widget.onChanged(List.unmodifiable(_files));
  }

  void _removeFile(int index) {
    setState(() => _files.removeAt(index));
    widget.onChanged(List.unmodifiable(_files));
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.initialUrls.length + _files.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            TextButton.icon(
              onPressed: total >= widget.maxImages ? null : _pickImages,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text('Add ($total/${widget.maxImages})'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (total == 0)
          Container(
            height: 112,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.image_outlined,
                  size: 30,
                  color: AppColors.primary,
                ),
                SizedBox(height: 8),
                Text(
                  'Add photos to make your listing stand out',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: total,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                if (index < widget.initialUrls.length) {
                  return _preview(
                    image: Image.network(
                      widget.initialUrls[index],
                      fit: BoxFit.cover,
                    ),
                    onRemove: null,
                  );
                }
                final fileIndex = index - widget.initialUrls.length;
                return _preview(
                  image: Image.file(
                    File(_files[fileIndex].path),
                    fit: BoxFit.cover,
                  ),
                  onRemove: () => _removeFile(fileIndex),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _preview({required Widget image, required VoidCallback? onRemove}) {
    return Stack(
      children: [
        Container(
          height: 112,
          width: 112,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: image,
        ),
        if (onRemove != null)
          Positioned(
            top: 6,
            right: 6,
            child: CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.dark,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.close,
                  size: 15,
                  color: AppColors.surfaceBright,
                ),
                onPressed: onRemove,
              ),
            ),
          ),
      ],
    );
  }
}
