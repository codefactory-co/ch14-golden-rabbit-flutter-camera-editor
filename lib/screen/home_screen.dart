import 'dart:io';

import 'package:camera_editor/component/emoticon_sticker.dart';
import 'package:camera_editor/component/footer.dart';
import 'package:camera_editor/component/main_app_bar.dart';
import 'package:camera_editor/model/sticker_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'dart:typed_data';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? image;
  Set<StickerModel> stickers = {};
  String? selectedId;
  GlobalKey imgKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          renderBody(), // ➊ Body 위치하기
          MainAppBar(
            // ➋ AppBar 위치하기
            onPickImage: onPickImage,
            onSaveImage: onSaveImage,
            onDeleteItem: onDeleteItem,
          ),
          if (image != null) // ➌ image가 선택되면 Footer 위치하기
            Positioned(
              // 맨 아래에 Footer 위젯 위치하기
              bottom: 0,
              left: 0, // left와 right를 모두 0을 주면 좌, 우로 최대크기를 차지함
              right: 0,
              child: Footer(
                onEmoticonTap: onEmoticonTap,
              ),
            ),
        ],
      ),
    );
  }

  void onPickImage() async {
    final image = await ImagePicker()
        .pickImage(source: ImageSource.gallery); // ➊ 갤러리에서 이미지 선택

    setState(() {
      this.image = image;
    });
  }

  void onSaveImage() async {
    RenderRepaintBoundary boundary = imgKey.currentContext!
        .findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(); // ➊ 바운더리를 이미지로 변경
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png); // ➋ byte data 형태로 형태 변경
    Uint8List pngBytes = byteData!.buffer.asUint8List(); // ➌ Unit8List 형태로 형태 변경

    await ImageGallerySaver.saveImage(pngBytes, quality: 100); // ➊ 이미지 저장하기

    ScaffoldMessenger.of(context).showSnackBar(  // ➋ Snackbar 보여주기
      SnackBar(
        content: Text('저장되었습니다!'),
      ),
    );
  }

  void onDeleteItem() async {
    setState(() {
      stickers = stickers
          .where((sticker) => sticker.id != selectedId)
          .toSet(); // ➊ ID값이 유일무이한 스티커들만 남기기
    });
  }

  Widget renderBody() {
    if (image != null) {
      return RepaintBoundary(
        // ➊ 위젯을 이미지로 저장하기 위해 사용
        key: imgKey,
        child: InteractiveViewer(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(image!.path),
                fit: BoxFit.cover,
              ),
              ...stickers.map(
                (sticker) => Center(
                  child: EmoticonSticker(
                    key: ObjectKey(sticker.id),
                    onTransform: () {
                      onTransform(sticker.id); // ➊ 스티커의 ID값 함수의 매개변수로 전달
                    },
                    imgPath: sticker.imgPath,
                    isSelected: selectedId == sticker.id,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Center(
        // ➋ 이미지 선택이 안 된 경우 이미지선택 버튼 표시
        child: TextButton(
          style: TextButton.styleFrom(
            primary: Colors.grey,
          ),
          onPressed: onPickImage,
          child: Text('이미지 선택하기'),
        ),
      );
    }
  }

  void onEmoticonTap(int index) async {
    setState(() {
      stickers = {
        ...stickers,
        StickerModel(
          id: Uuid().v4(), // ➊ 스티커의 고유 ID
          imgPath: 'asset/img/emoticon_$index.png',
        ),
      };
    });
  }

  void onTransform(String id) {
    setState(() {
      selectedId = id;
    });
  }
}
