import 'package:auto_route/auto_route.dart';
import 'package:better_player/better_player.dart';
import 'package:chat/bloc/new_posts/new_post_cubit.dart';
import 'package:chat/widgets/custom_circle_avatar_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/model/user.dart';
import '../../theme/color.dart';
import '../../theme/dimension.dart';
import '../../theme/style.dart';

class NewPostsPage extends StatefulWidget implements AutoRouteWrapper {
  final UserModel user;
  final XFile? xFile;
  final String? type;
  const NewPostsPage({Key? key, required this.user, this.xFile, this.type}) : super(key: key);

  @override
  State<NewPostsPage> createState() => _NewPostsPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => NewPostCubit(),
          child: this, // this as the child Important!
        ),
      ],
      child: this,
    );
  }
}

class _NewPostsPageState extends State<NewPostsPage> {
  late NewPostCubit cubit;

  @override
  void initState() {
    cubit = BlocProvider.of<NewPostCubit>(context);
    cubit.init(widget.user, widget.xFile, widget.type);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: black,
          ),
          onPressed: () {
            context.router.pop({"result": false});
          },
        ),
        title: const Text(
          "Create post",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: grey_100,
        actions: [
          IconButton(
              onPressed: () async{
               await cubit.publish().then((value) {
                 context.router.pop({"result": true});
               });
              },
              icon: const Icon(
                Icons.send,
                color: Colors.grey,
              ))
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              leading: CustomCircleAvatarStatus(
                onOff: false,
                user: cubit.userModel!,
                radius: 20,
              ),
              title: Text(
                cubit.userModel!.fullName,
                style: title,
              ),
            ),
            TextField(
              controller: cubit.textEditingController,
              decoration: const InputDecoration(
                  hintText: "Insert your message", border: InputBorder.none),
              scrollPadding: EdgeInsets.all(20.0),
              keyboardType: TextInputType.multiline,
              maxLines: 8,
              autofocus: true,
            ),
            BlocBuilder<NewPostCubit, NewPostState>(builder: (context, state) {
              if(state is NewPostAdded){
                if(state.type == "video"){
                  BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
                      BetterPlayerDataSourceType.file,
                      state.xFile.path);
                  BetterPlayerController betterPlayerController = BetterPlayerController(
                      const BetterPlayerConfiguration(
                        expandToFill: false,
                        fit: BoxFit.fitHeight
                      ),
                      betterPlayerDataSource: betterPlayerDataSource);
                  return closeButton(child: BetterPlayer(controller: betterPlayerController));
                }
                return state.type == "image" ? closeButton(child:  Image.asset(state.xFile.path)) : Container();
              }
              return const SizedBox.shrink();
            })
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: customElevatedButton(
                  prefix: SvgPicture.asset(
                    "assets/picture-icon.svg",
                    semanticsLabel: 'A red up arrow',
                    height: size_22_w,
                  ),
                  text: Text(
                    "Pictures",
                    style: subtitle.copyWith(color: black),
                  ),
                  onPressed: () async {
                    await cubit.sendPicture("gallery");
                  }),
            ),
            SizedBox(
              width: size_10_w,
            ),
            Expanded(
              flex: 5,
              child: customElevatedButton(
                  prefix: SvgPicture.asset(
                    "assets/video-icon.svg",
                    semanticsLabel: 'A red up arrow',
                    height: size_22_w,
                  ),
                  text: Text(
                    "Videos",
                    style: subtitle.copyWith(color: black),
                  ),
                  onPressed: () async {
                    await cubit.sendVideo("gallery");
                  }),
            )
          ],
        ),
      ),
    );
  }

  Widget closeButton({required Widget child}){
    return Stack(
      children: [
        child,
      Align(
          alignment: Alignment.topRight,
          child: CircleAvatar(
            backgroundColor: grey,
            child: IconButton(
              onPressed: (){
                cubit.removeMedias();
              },
              icon: const Icon(
                Icons.close_sharp,
                color: white,
              ),
            ),
          )
      )
      ],
    );
  }

  Widget customElevatedButton(
      {required Widget text,
      Widget? prefix,
      Color? backgroundColor,
      required void Function()? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          backgroundColor: backgroundColor ?? grey_100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          prefix ?? const SizedBox.shrink(),
          SizedBox(
            width: size_5_w,
          ),
          text
        ],
      ),
    );
  }
}
