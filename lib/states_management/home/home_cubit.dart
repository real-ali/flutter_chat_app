import 'package:chat/chat.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labalaba/cache/local_cache.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final IUserService _iUserService;
  final ILocalCache _localCache;
  HomeCubit(this._iUserService, this._localCache) : super(HomeInitial());

  Future<User> connect() async {
    final userJson = _localCache.fetch('USER');
    userJson['lastSeen'] = DateTime.now();
    userJson['active'] = true;

    final user = User.fromJson(userJson);
    await _iUserService.connect(user);
    return user;
  }

  Future<void> activeUser(User user) async {
    emit(HomeLoading());
    final users = await _iUserService.online();
    users.removeWhere((element) => element.getId == user.getId);
    emit(HomeSuccess(users));
  }
}
