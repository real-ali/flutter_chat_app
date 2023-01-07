import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labalaba/states_management/onboarding/profile_image_cubit.dart';

class ProfileUpload extends StatelessWidget {
  const ProfileUpload({Key key}) : super(key: key);

  Future<void> getImage(BuildContext context) async =>
      await context.read<ProfileImageCubit>().getImage();

  @override
  Widget build(BuildContext context) {
    const addButton = Align(
      alignment: Alignment.bottomRight,
      child: Icon(
        Icons.add_circle_rounded,
        size: 38,
        color: Color.fromARGB(255, 228, 39, 25),
      ),
    );
    var image = CircleAvatar(
      child: BlocBuilder<ProfileImageCubit, File>(
        builder: (context, state) {
          if (state == null) return const Icon(Icons.person, size: 120);

          return ClipRRect(
            borderRadius: BorderRadius.circular(126),
            child: Image.file(
              state,
              width: 126,
              height: 126,
              fit: BoxFit.fill,
            ),
          );
        },
      ),
    );
    var child = InkWell(
      borderRadius: BorderRadius.circular(126),
      onTap: () => getImage(context),
      child: Stack(
        fit: StackFit.expand,
        children: [image, addButton],
      ),
    );
    return SizedBox(
      height: 126,
      width: 126,
      child: Material(
        borderRadius: BorderRadius.circular(126),
        child: child,
      ),
    );
  }
}
