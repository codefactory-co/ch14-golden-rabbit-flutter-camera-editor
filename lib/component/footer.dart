import 'package:flutter/material.dart';

typedef OnEmoticonTap = void Function(int id); // ➋ 스티커 선택할 때마다 실행할 함수의 시그니처

class Footer extends StatelessWidget {
  final OnEmoticonTap onEmoticonTap;

  const Footer({
    required this.onEmoticonTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.9),
      height: 150,
      child: SingleChildScrollView(  // ➊ 스티커를 가로로 스크롤 가능하게 구현
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            7,
                (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: GestureDetector(
                onTap: () {
                  onEmoticonTap(index + 1);  // ➌ 스티커 선택할 때마다 실행할 함수
                },
                child: Image.asset(
                  'asset/img/emoticon_${index + 1}.png',
                  height: 100,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
