import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/data/model/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/color.dart';
import '../theme/dimension.dart';

class CustomCircleAvatarStatus extends StatelessWidget {
  final UserModel user;
  final double? radius;

  const CustomCircleAvatarStatus({Key? key, required this.user, this.radius})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      CachedNetworkImage(
        placeholder: (_, img) {
          return CircleAvatar(
            radius: radius ?? size_35_w,
            child: user.avatarURL.isEmpty
                ? Text(user.fullName[0])
                : const SizedBox.shrink(),
          );
        },
        imageUrl: user.avatarURL,
        cacheKey: user.avatarURL,
        errorWidget: (
          BuildContext context,
          String url,
          dynamic error,
        ) {
          return CircleAvatar(
            radius: radius ?? size_35_w,
            child: Text(user.fullName[0]),
          );
        },
        imageBuilder: (context, imageProvider) {
          return CircleAvatar(
            radius: radius ?? size_35_w,
            backgroundImage: imageProvider,
          );
        },
      ),
      if (user.isOnline)
        Positioned.fill(
          top: size_30_h,
          left: size_40_w,
          child: Container(
            decoration:
                const BoxDecoration(shape: BoxShape.circle, color: green),
          ),
        )
    ]);
  }
}
