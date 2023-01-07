import 'dart:io';

import 'package:chat/chat.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labalaba/cache/local_cache.dart';
import 'package:labalaba/data/services/iamge_uploader.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final IUserService _iUserService;
  final ImageUploader _imageUploader;
  final ILocalCache _localCache;
  OnboardingCubit(this._iUserService, this._imageUploader, this._localCache)
      : super(OnboardingInitial());

  Future<void> connect(String name, File profileImage) async {
    emit(Loading());
    String url = await _imageUploader.uploadImage(profileImage);

    final user = User(
      username: name,
      photoURL: url,
      active: true,
      lastSeen: DateTime.now(),
    );

    final createdUser = await _iUserService.connect(user);
    final userJson = {
      'username': createdUser.username,
      'photoURL': createdUser.photoURL,
      'active': true,
      'id': createdUser.getId
    };
    await _localCache.save('USER', userJson);
    emit(OnboardingSuccess(createdUser));
  }
}
