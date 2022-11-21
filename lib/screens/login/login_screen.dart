import 'package:auto_route/auto_route.dart';
import 'package:chat/bloc/login/login_cubit.dart';
import 'package:chat/theme/color.dart';
import 'package:chat/widgets/custom_elevated_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../theme/dimension.dart';
import '../../theme/style.dart';
import '../../widgets/custom_text_form_field.dart';

class LoginScreen extends StatefulWidget implements AutoRouteWrapper {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: this, // this as the child Important!
    );
  }
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = BlocProvider.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginCheckBox) {
            cubit.check = state.check;
          }
          else if(state is LoginObscureText){
            cubit.obscureText = state.obscureText;
          }
        },
        builder: (context, state) {
          return CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: size_23_w, vertical: size_10_h),
                    child: Form(
                      key: cubit.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          headerBuilder(),
                          emailBuilder(),
                          SizedBox(
                            height: size_12_h,
                          ),
                          passwordBuilder(),
                          textButtons(),
                          CustomElevatedButton(
                              child: const Text("Log in"), onPressed: () {
                                cubit.validateAndSave(context);
                          }),
                          const Spacer(),
                          register()
                        ],
                      ),
                    ),
                  ),
                )
              ]);
        },
      ),
    );
  }

  Widget emailBuilder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Email",
          style: title,
        ),
        SizedBox(
          height: size_7_h,
        ),
        CustomTextFormField(
          controller: cubit.emailController,
          hintText: "Please enter your email",
          validator: (val) => cubit.emailValidator(val!),
        )
      ],
    );
  }

  Widget headerBuilder() {
    return Column(
      children: [
        SizedBox(
          height: size_55_h,
        ),
        Text(
          "Hi, Welcome Back!",
          style: header,
        ),
        Text(
          "Hello again, you've been missed",
          style: subtitle,
        ),
        SizedBox(
          height: size_52_h,
        ),
      ],
    );
  }

  Widget passwordBuilder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Password",
          style: title,
        ),
        SizedBox(
          height: size_7_h,
        ),
        CustomTextFormField(
          hintText: "Please enter your password",
          obscureText: cubit.obscureText,
          controller: cubit.passwordController,
          validator: (val) => cubit.passwordValidator(val!),
          suffix: IconButton(
            icon: Icon(
              cubit.obscureText ? Icons.visibility : Icons.visibility_off,
              color: black,
            ),
            onPressed: () {
              cubit.onClickObscureText();
            },
          ),
        )
      ],
    );
  }

  Widget textButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
                value: cubit.check,
                onChanged: (val) {
                  cubit.onClickCheckbox(val!);
                }),
            Text(
              "Remember Me",
              style: title.copyWith(color: black),
            )
          ],
        ),
        TextButton(
            onPressed: () {},
            child: Text(
              "Forgot Password",
              style: title.copyWith(color: red),
            ))
      ],
    );
  }

  Widget register() {
    return Center(
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: 'Don\'t have an account? ', style: subtitle),
            TextSpan(
                text: 'Sign up',
                style: subtitle.copyWith(color: blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => context.router.pushNamed("/register-screen")),
          ],
        ),
      ),
    );
  }
}
