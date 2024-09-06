import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/utils.dart';
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:reddit/features/post/controller/post_controller.dart';
import 'package:reddit/models/community_model.dart';
import 'package:reddit/responsive/responsive.dart';
import 'package:reddit/theme/pallete.dart';

class AddPostTypeScreen extends ConsumerStatefulWidget {
  final String type;
  const AddPostTypeScreen({
    super.key,
    required this.type,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddPostTypeScreenState();
}

class _AddPostTypeScreenState extends ConsumerState<AddPostTypeScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkController = TextEditingController();
  File? bannerFile;
  Uint8List? bannerWebFile;
  List<Community> communities = [];
  Community? selectedCommunity;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
    super.dispose();
  }

  Future<void> selectBannerImage() async {
    final res = await pickImage();

    if (res != null) {
      setState(() {
        if (kIsWeb) {
          bannerWebFile = res.files.first.bytes;
        } else {
          bannerFile = File(res.files.first.path!);
        }
      });
    }
  }

  void sharePost() {
    if (titleController.text.isEmpty) {
      showSnackBar(context, 'Please enter a title');
      return;
    }

    if (selectedCommunity == null && communities.isNotEmpty) {
      selectedCommunity = communities[0];
    }

    if (widget.type == 'image' && (bannerFile != null || bannerWebFile != null)) {
      ref.read(postControllerProvider.notifier).shareImagePost(
            context: context,
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity!,
            file: bannerFile,
            webFile: bannerWebFile,
          );
    } else if (widget.type == 'text') {
      ref.read(postControllerProvider.notifier).shareTextPost(
            context: context,
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity!,
            description: descriptionController.text.trim(),
          );
    } else if (widget.type == 'link' && linkController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareLinkPost(
            context: context,
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity!,
            link: linkController.text.trim(),
          );
    } else {
      showSnackBar(context, 'Please enter all the fields');
    }
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: selectBannerImage,
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(10),
        dashPattern: const [10, 4],
        strokeCap: StrokeCap.round,
        color: ref.watch(themeNotifierProvider).textTheme.bodyMedium!.color!,
        child: Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: bannerWebFile != null
              ? Image.memory(bannerWebFile!)
              : bannerFile != null
                  ? Image.file(bannerFile!)
                  : const Center(
                      child: Icon(
                        Icons.camera_alt_outlined,
                        size: 40,
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {int maxLines = 1, int? maxLength}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        hintText: hint,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(18),
      ),
      maxLines: maxLines,
      maxLength: maxLength,
    );
  }

  Widget _buildCommunityDropdown() {
    return ref.watch(userCommunitiesProvider).when(
          data: (data) {
            communities = data;

            if (data.isEmpty) {
              return const Text('No communities found.');
            }

            return DropdownButton<Community>(
              value: selectedCommunity ?? data[0],
              items: data.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e.name),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  selectedCommunity = val;
                });
              },
            );
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(postControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Post ${widget.type}'),
        actions: [
          TextButton(
            onPressed: sharePost,
            child: const Text('Share'),
          ),
        ],
      ),
      body: isLoading
          ? const Loader()
          : Responsive(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    _buildTextField('Enter Title here', titleController, maxLength: 30),
                    const SizedBox(height: 10),
                    if (widget.type == 'image') _buildImagePicker(),
                    if (widget.type == 'text') _buildTextField('Enter Description here', descriptionController, maxLines: 5),
                    if (widget.type == 'link') _buildTextField('Enter link here', linkController),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Text('Select Community'),
                    ),
                    _buildCommunityDropdown(),
                  ],
                ),
              ),
            ),
    );
  }
}
