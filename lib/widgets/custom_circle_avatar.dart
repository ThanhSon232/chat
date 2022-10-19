import 'package:chat/data/model/user.dart';
import 'package:chat/widgets/custom_circle_avatar_status.dart';
import 'package:flutter/material.dart';

import '../theme/color.dart';
import '../theme/dimension.dart';
import '../theme/style.dart';

class CustomCircleAvatar extends StatelessWidget {
  final UserModel user;

  const CustomCircleAvatar({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomCircleAvatarStatus(user: user),
        SizedBox(
          height: size_5_h,
        ),
        Text(
          user.fullName,
          style: title.copyWith(color: black),
        )
      ],
    );
  }
}
