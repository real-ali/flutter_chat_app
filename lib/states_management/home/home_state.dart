part of 'home_cubit.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {
  @override
  List<Object> get props => [];
}

class HomeSuccess extends HomeState {
  final List<User> onlineUser;

  const HomeSuccess(this.onlineUser);
  @override
  List<Object> get props => [onlineUser];
}
