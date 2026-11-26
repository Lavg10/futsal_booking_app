import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(widget.label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const Spacer(),
            TextButton.icon(
              onPressed: total >= widget.maxImages ? null : _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: Text('Add ($total/${widget.maxImages})'),
            ),
          ],
        ),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (var i = 0; i < widget.initialUrls.length; i++)
                _preview(
                  image: Image.network(widget.initialUrls[i], fit: BoxFit.cover),
                  onRemove: null,
                ),
              for (var i = 0; i < _files.length; i++)
                _preview(
                  image: Image.file(File(_files[i].path), fit: BoxFit.cover),
                  onRemove: () => _removeFile(i),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _preview({required Widget image, required VoidCallback? onRemove}) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: 8),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: image,
        ),
        if (onRemove != null)
          Positioned(
            top: 2,
            right: 10,
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.black54,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.close, size: 16, color: Colors.white),
                onPressed: onRemove,
              ),
            ),
          ),
      ],
    );
  }
}
