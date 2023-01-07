import 'package:chat/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labalaba/states_management/home/chats_cubit.dart';
import 'package:labalaba/states_management/home/home_cubit.dart';
import 'package:labalaba/states_management/message_bloc.dart';
import 'package:labalaba/ui/pages/home/home_router.dart';
import 'package:labalaba/ui/widgets/home/active/active_users.dart';
import 'package:labalaba/ui/widgets/home/chats/chats.dart';
import 'package:labalaba/ui/widgets/shared/header_status.dart';

class Home extends StatefulWidget {
  final User me;
  final IHomeRouter router;
  const Home(this.me, this.router, {Key key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  User _user;
  @override
  void initState() {
    super.initState();
    _user = widget.me;
    _initialSetup();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: HeaderStatus(_user.username, _user.photoURL, true),
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.label,
            indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: const Color.fromARGB(255, 180, 38, 28)),
            indicatorPadding: const EdgeInsets.symmetric(vertical: 10),
            tabs: [
              Tab(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Align(
                    alignment: Alignment.center,
                    child: Text('Messages'),
                  ),
                ),
              ),
              Tab(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: BlocBuilder<HomeCubit, HomeState>(
                      builder: (_, state) {
                        if (state is HomeSuccess) {
                          return Text("Active(${state.onlineUser.length})");
                        } else {
                          return const Text("Active(0)");
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(children: [
          Chats(_user, widget.router),
          ActiveUsers(_user, widget.router),
        ]),
      ),
    );
  }

  _initialSetup() async {
    //active ? await
    final user = !_user.active ? context.read<HomeCubit>().connect() : _user;
    context.read<ChatsCubit>().chats();
    context.read<HomeCubit>().activeUser(user);
    context.read<MessageBloc>().add(MessageEvent.onSubscribe(_user));
  }

  @override
  bool get wantKeepAlive => true;
}
