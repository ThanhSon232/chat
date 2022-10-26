import 'package:chat/data/model/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/color.dart';
import '../theme/dimension.dart';

class CustomCircleAvatarStatus extends StatelessWidget {
  final UserModel user;
  final double? radius;
  const CustomCircleAvatarStatus({Key? key, required this.user, this.radius}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return     Stack(children: [
      CircleAvatar(
        radius: radius ?? size_35_w,
        backgroundImage: user.avatarURL.isNotEmpty
            ? NetworkImage(user.avatarURL)
            : null,
        child: user.avatarURL.isEmpty
            ? Text(user.fullName[0])
            : const SizedBox.shrink(),
      ),
      if (user.isOnline)
        Positioned.fill(
          top: size_30_h,
          left: size_40_w,
          child: Container(
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: green),
          ),
        )
    ]);
  }
}
