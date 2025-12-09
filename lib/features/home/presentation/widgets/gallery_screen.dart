// lib/gallery_screen.dart
import 'dart:io';
import 'package:capture_campus/core/service/storage_service.dart';
import 'package:capture_campus/features/home/presentation/bloc/home_bloc.dart';
import 'package:capture_campus/features/home/presentation/bloc/home_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<File> images = [];
  List<XFile> selectedImages = [];
  bool selectionMode = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    images = await StorageService.listSavedImages();
    selectedImages.clear();
    selectionMode = false;
    setState(() => loading = false);
  }

  void toggleSelect(XFile file) {
    if (selectedImages.contains(file)) {
      selectedImages.remove(file);
    } else {
      selectedImages.add(file);
    }

    if (selectedImages.isEmpty) {
      selectionMode = false;
    }

    setState(() {});
  }

  Future<void> deleteSelected() async {
    for (var img in selectedImages) {
      final data = File(img.path);
      await StorageService.deleteFile(data);
    }
    await _load();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Deleted successfully")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: selectionMode
            ? Text("${selectedImages.length} selected")
            : Text("Captured Photos"),
        actions: [
          if (selectionMode)
            IconButton(icon: Icon(Icons.delete), onPressed: deleteSelected)
          else
            IconButton(icon: Icon(Icons.refresh), onPressed: _load),
        ],
      ),

      floatingActionButton: selectionMode && selectedImages.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                context.read<HomeBloc>().add(
                  NavToAddInfoEvent(selectedFiles: selectedImages),
                );
              },
              label: Text("Next"),
              icon: Icon(Icons.arrow_forward),
            )
          : null,

      body: loading
          ? Center(child: CircularProgressIndicator())
          : images.isEmpty
          ? Center(child: Text("No photos yet."))
          : GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final file = images[index];
                final data = XFile(file.path);
                // Check if this file is selected by comparing paths
                final isSelected = selectedImages.any(
                  (xfile) => xfile.path == file.path,
                );
                return GestureDetector(
                  onLongPress: () {
                    selectionMode = true;
                    toggleSelect(data);
                  },
                  onTap: () {
                    if (selectionMode) {
                      toggleSelect(data);
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FullImageScreen(image: file),
                        ),
                      );
                    }
                  },
                  child: Stack(
                    children: [
                      Hero(
                        tag: file.path,
                        child: Image.file(
                          file,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),

                      if (isSelected)
                        Container(
                          color: Colors.black45,
                          child: Center(
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class FullImageScreen extends StatelessWidget {
  final File image;
  const FullImageScreen({required this.image, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: Center(
        child: Hero(tag: image.path, child: Image.file(image)),
      ),
    );
  }
}
