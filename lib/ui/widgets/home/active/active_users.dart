import 'package:chat/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labalaba/states_management/home/home_cubit.dart';
import 'package:labalaba/ui/pages/home/home_router.dart';
import 'package:labalaba/ui/widgets/home/profile_image.dart';

class ActiveUsers extends StatefulWidget {
  final User me;
  final IHomeRouter router;
  const ActiveUsers(this.me, this.router, {Key key}) : super(key: key);

  @override
  State<ActiveUsers> createState() => _ActiveUsersState();
}

class _ActiveUsersState extends State<ActiveUsers> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is HomeSuccess) {
          return _buildList(context, users: state.onlineUser);
        }
        return Container();
      },
    );
  }

  ListView _buildList(BuildContext context, {List<User> users = const []}) {
    return ListView.separated(
        padding: const EdgeInsets.only(top: 30, right: 16),
        itemBuilder: (_, index) => GestureDetector(
              child: _listItem(context, user: users[index]),
              onTap: () => widget.router.onShowMessageThread(
                context,
                users[index],
                widget.me,
                chatId: users[index].getId,
              ),
            ),
        separatorBuilder: (_, index) => const Divider(
              thickness: 1.5,
              indent: 75,
            ),
        itemCount: users.length);
  }

  _listItem(BuildContext context, {@required User user}) => ListTile(
        contentPadding: const EdgeInsets.only(left: 16),
        leading: ProfileImage(imageUrl: user.photoURL, online: user.active),
        title: Text(
          user.username,
          style: Theme.of(context)
              .textTheme
              .subtitle2
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      );
}
