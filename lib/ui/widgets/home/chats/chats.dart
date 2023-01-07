import 'package:chat/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:labalaba/models/chat.dart';
import 'package:labalaba/states_management/home/chats_cubit.dart';
import 'package:labalaba/states_management/message_bloc.dart';
import 'package:labalaba/states_management/typing_bloc.dart';
import 'package:labalaba/ui/pages/home/home_router.dart';
import 'package:labalaba/ui/widgets/home/profile_image.dart';

class Chats extends StatefulWidget {
  final User user;
  final IHomeRouter router;
  const Chats(this.user, this.router, {Key key}) : super(key: key);

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  List<Chat> chats = [];
  final typingEvent = [];
  @override
  void initState() {
    super.initState();
    _updateChatsOnMessangeReceived();
    context.read<ChatsCubit>().chats();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatsCubit, List<Chat>>(
      builder: (__, chats) {
        this.chats = chats;
        if (this.chats.isEmpty) return Container();
        context.read<TypingNotificationBloc>().add(
            TypingNotificationEvent.onSubscribe(widget.user,
                userWithChat: chats.map((e) => e.from.getId).toList()));

        return _buildListView();
      },
    );
  }

  ListView _buildListView() {
    return ListView.separated(
        padding: const EdgeInsets.only(top: 30, right: 16),
        itemBuilder: (_, index) => GestureDetector(
              child: _chatItem(chats[index]),
              onTap: () async {
                await widget.router.onShowMessageThread(
                    context, chats[index].from, widget.user,
                    chatId: chats[index].id);
                await context.read<ChatsCubit>().chats();
              },
            ),
        separatorBuilder: (_, index) => const Divider(
              thickness: 1.5,
              indent: 75,
            ),
        itemCount: chats.length);
  }

  _chatItem(Chat chat) => ListTile(
        contentPadding: const EdgeInsets.only(left: 16),
        leading: ProfileImage(
            imageUrl: chat.from.photoURL, online: chat.from.active),
        title: Text(
          chat.from.username,
          style: Theme.of(context)
              .textTheme
              .subtitle2
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: BlocBuilder<TypingNotificationBloc, TypingNotificationState>(
            builder: (context, state) {
          if (state is TypingNotificationReceivedSuccess &&
              state.typingEvent.event == Typing.start &&
              state.typingEvent.from == chat.from.getId) {
            typingEvent.add(state.typingEvent.from);
          }
          if (state is TypingNotificationReceivedSuccess &&
              state.typingEvent.event == Typing.stop &&
              state.typingEvent.from == chat.from.getId) {
            typingEvent.remove(state.typingEvent.from);
          }
          if (typingEvent.contains(chat.from.getId)) {
            return Text(
              'typing...',
              style: Theme.of(context).textTheme.overline?.copyWith(
                  fontWeight:
                      chat.unread > 0 ? FontWeight.bold : FontWeight.normal),
            );
          }
          return Text(
            chat.mostRecent.message.contents,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            style: Theme.of(context).textTheme.overline?.copyWith(
                fontWeight:
                    chat.unread > 0 ? FontWeight.bold : FontWeight.normal),
          );
        }),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              DateFormat('h:mm a').format(chat.mostRecent.message.timeStamp),
              style: Theme.of(context).textTheme.overline,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: chat.unread > 0
                    ? Container(
                        alignment: Alignment.center,
                        height: 15,
                        width: 15,
                        color: Colors.red.shade900,
                        child: Text(
                          chat.unread.toString(),
                          style: Theme.of(context).textTheme.overline,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            )
          ],
        ),
      );

  void _updateChatsOnMessangeReceived() {
    final chatsCubit = context.read<ChatsCubit>();
    context.read<MessageBloc>().stream.listen((state) async {
      if (state is MessageReceivedSuccess) {
        await chatsCubit.viewModel.receivedMessage(state.message);
        chatsCubit.chats();
      }
    });
  }
}
