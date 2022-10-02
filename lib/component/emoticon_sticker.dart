import 'package:flutter/material.dart';

class EmoticonSticker extends StatefulWidget {
  final VoidCallback onTransform;
  final String imgPath;
  final bool isSelected;

  const EmoticonSticker({
    required this.onTransform,
    required this.imgPath,
    required this.isSelected,
    Key? key,
  }) : super(key: key);

  @override
  State<EmoticonSticker> createState() => _EmoticonStickerState();
}

class _EmoticonStickerState extends State<EmoticonSticker> {
  // 확대/축소 배율
  double scale = 1;

  // 가로의 움직임
  double hTransform = 0;

  // 세로의 움직임
  double vTransform = 0;

  // 위젯의 초기 크기 기준 확대/축소 배율
  double actualScale = 1;

  @override
  Widget build(BuildContext context) {
    return Transform(   // ➊ child 위젯을 변형할 수 있는 위젯
    transform: Matrix4.identity()
        ..translate(hTransform, vTransform) // ➋ 상/하 움직임 정의
        ..scale(scale, scale),  // ➌ 확대/축소 정의
      // 기존 작성해둔 Container 위젯
      child: Container(
        decoration: widget.isSelected
            ? BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(
            color: Colors.blue,
            width: 1.0,
          ),
        )
            : BoxDecoration(
          border: Border.all(
            width: 1.0,
            color: Colors.transparent,
          ),
        ),
        child: GestureDetector(
          onTap: () {
            widget.onTransform();
          },
          onScaleUpdate: (ScaleUpdateDetails details) {
            widget.onTransform();
            setState(() {
              scale = details.scale * actualScale;
              vTransform += details.focalPointDelta.dy;
              hTransform += details.focalPointDelta.dx;
            });
          },
          onScaleEnd: (ScaleEndDetails details) {
            actualScale = scale;
          },
          child: Image.asset(
            widget.imgPath,
          ),
        ),
      ),
    );
  }
}
