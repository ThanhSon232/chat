import 'package:auto_route/auto_route.dart';
import 'package:chat/bloc/register/register_cubit.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../theme/color.dart';
import '../../theme/dimension.dart';
import '../../theme/style.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_text_form_field.dart';

class RegisterScreen extends StatefulWidget implements AutoRouteWrapper {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(),
      child: this, // this as the child Important!
    );
  }
}

class _RegisterScreenState extends State<RegisterScreen> {
  late RegisterCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = BlocProvider.of(context);
  }

  final spacing = SizedBox(
    height: size_12_h,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            context.router.pop();
          },
          icon: const Icon(
            Icons.arrow_back,
            color: black,
          ),
        ),
      ),
      body: CustomScrollView(physics: const ClampingScrollPhysics(), slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: size_23_w, vertical: size_10_h),
            child: BlocConsumer<RegisterCubit, RegisterState>(
              listener: (context, state) {
                if (state is RegisterObscurePassword) {
                  cubit.obscurePassword = state.obscureText;
                } else if (state is RegisterObscureConfirmPassword) {
                  cubit.obscureConfirmPassword = state.obscureText;
                }
              },
              builder: (context, state) {
                return Form(
                  key: cubit.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      headerBuilder(),
                      nameBuilder(),
                      spacing,
                      emailBuilder(),
                      spacing,
                      passwordBuilder(),
                      spacing,
                      confirmPassword(),
                      spacing,
                      CustomElevatedButton(
                          child: const Text("Register"),
                          onPressed: () {
                            cubit.validateAndSave(context);
                          }),
                      const Spacer(),
                      login(),
                    ],
                  ),
                );
              },
            ),
          ),
        )
      ]),
    );
  }

  Widget nameBuilder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Name",
          style: title,
        ),
        SizedBox(
          height: size_7_h,
        ),
        CustomTextFormField(
          controller: cubit.nameController,
          hintText: "Please enter your name",
          validator: (val) => cubit.nameValidator(val!),
        ),
      ],
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
          controller: cubit.passwordController,
          hintText: "Please enter your password",
          obscureText: cubit.obscurePassword,
          suffix: IconButton(
            icon: Icon(
              cubit.obscurePassword ? Icons.visibility : Icons.visibility_off,
              color: black,
            ),
            onPressed: (){
              cubit.onClickObscurePassword();
            },
          ),
          validator: (val) => cubit.passwordValidator(val!),
        )
      ],
    );
  }

  Widget confirmPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Confirm password",
          style: title,
        ),
        SizedBox(
          height: size_7_h,
        ),
        CustomTextFormField(
          controller: cubit.confirmPasswordController,
          hintText: "Please confirm your password",
          obscureText: cubit.obscureConfirmPassword,
          suffix: IconButton(
            icon: Icon(
              cubit.obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
              color: black,
            ),
            onPressed: (){
              cubit.onClickObscureConfirmPassword();
            },
          ),
          validator: (val) => cubit.confirmPasswordValidator(val!),
        )
      ],
    );
  }

  Widget headerBuilder() {
    return Column(
      children: [
        Text(
          "Create an account",
          style: header,
        ),
        Text(
          "Connect with your friends today!",
          style: subtitle,
        ),
        SizedBox(
          height: size_52_h,
        ),
      ],
    );
  }

  Widget login() {
    return Center(
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: 'Already have an account? ', style: subtitle),
            TextSpan(
                text: 'Log in',
                style: subtitle.copyWith(color: blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => context.router.pop()),
          ],
        ),
      ),
    );
  }
}
