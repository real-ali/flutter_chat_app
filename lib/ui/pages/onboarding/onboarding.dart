import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labalaba/states_management/onboarding/onboarding_cubit.dart';
import 'package:labalaba/states_management/onboarding/profile_image_cubit.dart';
import 'package:labalaba/ui/pages/onboarding/onboarding_router.dart';
import 'package:labalaba/ui/widgets/onboarding/logo.dart';
import 'package:labalaba/ui/widgets/onboarding/profile_upload.dart';
import 'package:labalaba/ui/widgets/shared/custom_text_field.dart';

class OnBoarding extends StatefulWidget {
  final IOnboardingRouter router;
  const OnBoarding({Key key, this.router}) : super(key: key);

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  String _username = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _logo(context),
            const Spacer(),
            const ProfileUpload(),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 20, left: 20),
              child: CustomTextField(
                hint: "What is Your Name",
                hieght: 45,
                onChanged: (val) => setState(() => _username = val),
                textInputAction: TextInputAction.done,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () async {
                  final error = _checkInputs();
                  final snackBar = SnackBar(
                    content: Text(
                      error,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                  if (error.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else {
                    await _connectSession();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 187, 38, 27),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(45),
                  ),
                ),
                child: Container(
                  height: 45,
                  alignment: Alignment.center,
                  child: Text(
                    "Make a chat",
                    style: Theme.of(context)
                        .textTheme
                        .button
                        ?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const Spacer(),
            BlocConsumer<OnboardingCubit, OnboardingState>(
              builder: (context, state) {
                return state is Loading
                    ? const Center(child: CircularProgressIndicator())
                    : Container();
              },
              listener: (_, state) {
                if (state is OnboardingSuccess) {
                  widget.router.onSessionSuccess(context, state.user);
                }
              },
            ),
            const Spacer(flex: 1)
          ],
        ),
      )),
    );
  }

  _logo(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Laba",
          style: Theme.of(context)
              .textTheme
              .headline4
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        const Logo(),
        const SizedBox(width: 8),
        Text(
          "Laba",
          style: Theme.of(context)
              .textTheme
              .headline4
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _checkInputs() {
    String error;
    if (_username.isEmpty) error = 'Enter display name';

    return error ?? '';
  }

  _connectSession() async {
    final profileImafge = context.read<ProfileImageCubit>().state;

    await context.read<OnboardingCubit>().connect(_username, profileImafge);
  }
}
