import 'dart:async';

import 'package:chat/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labalaba/models/local_message.dart';
import 'package:labalaba/states_management/home/chats_cubit.dart';
import 'package:labalaba/states_management/message_bloc.dart';
import 'package:labalaba/states_management/message_thread/message_thread_cubit.dart';
import 'package:labalaba/states_management/receipt_bloc.dart';
import 'package:labalaba/states_management/typing_bloc.dart';

import '../../widgets/message_thread/receiver_message.dart';
import '../../widgets/message_thread/sender_message.dart';
import '../../widgets/shared/header_status.dart';

class MessageThread extends StatefulWidget {
  final User receiver;
  final User me;
  final String chatId;
  final MessageBloc messageBloc;
  final TypingNotificationBloc typingNotificationBloc;
  final ChatsCubit chatsCubit;
  const MessageThread(
    this.receiver,
    this.me,
    this.messageBloc,
    this.typingNotificationBloc,
    this.chatsCubit, {
    Key key,
    this.chatId = '',
  }) : super(key: key);

  @override
  State<MessageThread> createState() => _MessageThreadState();
}

class _MessageThreadState extends State<MessageThread> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();
  String chatId = '';
  User receiver;
  StreamSubscription _subscription;
  List<LocalMessage> messages = [];
  Timer _startTypingTimer;
  Timer _stopTypingTimer;

  @override
  void initState() {
    super.initState();
    chatId = widget.chatId;
    receiver = widget.receiver;
    _updateOnMessageReceived();
    _updateOnReceiptReceived();
    context.read<ReceiptBloc>().add(ReceiptEvent.onSubscribe(widget.me));
    context.read<TypingNotificationBloc>().add(
        TypingNotificationEvent.onSubscribe(widget.me,
            userWithChat: [receiver.getId]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                icon: const Icon(Icons.arrow_back_ios_new_rounded)),
            Expanded(
                child: BlocBuilder<TypingNotificationBloc,
                        TypingNotificationState>(
                    bloc: widget.typingNotificationBloc,
                    builder: (_, state) {
                      bool typing;
                      if (state is TypingNotificationReceivedSuccess &&
                          state.typingEvent.event == Typing.start &&
                          state.typingEvent.from == receiver.getId) {
                        typing = true;
                      }
                      return HeaderStatus(
                        receiver.username,
                        receiver.photoURL,
                        receiver.active,
                        lastSeen: receiver.lastSeen,
                        typing: typing,
                      );
                    }))
          ],
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(
          children: [
            Flexible(
                flex: 6,
                child: BlocBuilder<MessageThreadCubit, List<LocalMessage>>(
                  builder: (__, messages) {
                    this.messages = messages;
                    if (this.messages.isEmpty) return Container();
                    WidgetsBinding.instance
                        .addPostFrameCallback((timeStamp) => _scrollRoEnd());
                    return _buildListOfMessages();
                  },
                )),
            Expanded(
              child: Container(
                height: 100,
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, -3),
                      blurRadius: 6,
                      color: Colors.black12,
                    )
                  ],
                ),
                alignment: Alignment.topCenter,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _buildMessageInput(context),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: SizedBox(
                          height: 45,
                          width: 45,
                          child: RawMaterialButton(
                            onPressed: () {
                              _sendMessage();
                            },
                            child: const Icon(Icons.send),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _updateOnMessageReceived() {
    final messageThreadCubit = context.read<MessageThreadCubit>();
    if (chatId.isNotEmpty) messageThreadCubit.messages(chatId);
    _subscription = widget.messageBloc.stream.listen((state) async {
      if (state is MessageReceivedSuccess) {
        await messageThreadCubit.viewModel.receivedMessage(state.message);
        final receipt = Receipt(
          recipient: state.message.from,
          messageId: state.message.getId,
          status: ReceiptStatus.read,
          timeStamp: DateTime.now(),
        );
        context.read<ReceiptBloc>().add(ReceiptEvent.onMessageSent(receipt));
      }
      if (state is MessageSentSuccess) {
        await messageThreadCubit.viewModel.sentMessage(state.message);
      }
      if (chatId.isEmpty) chatId = messageThreadCubit.viewModel.getChatId;
      messageThreadCubit.messages(chatId);
    });
  }

  Widget _buildListOfMessages() => ListView.builder(
        padding: const EdgeInsets.only(top: 16, bottom: 20, left: 16),
        itemBuilder: (__, index) {
          if (messages[index].message.from == receiver.getId) {
            _sendReceipt(messages[index]);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ReceiverMessage(messages[index], receiver.photoURL),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SenderMessage(messages[index]),
            );
          }
        },
        itemCount: messages.length,
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        addAutomaticKeepAlives: true,
      );

  _buildMessageInput(BuildContext context) {
    OutlineInputBorder border = const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(90)));

    return Focus(
      onFocusChange: (focus) {
        if (_startTypingTimer == null || (_startTypingTimer != null && focus)) {
          return;
        }
        _stopTypingTimer?.cancel();
        _dispatchTyping(Typing.stop);
      },
      child: TextFormField(
        controller: _textEditingController,
        textInputAction: TextInputAction.newline,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        style: Theme.of(context).textTheme.caption,
        onChanged: _sendTypingNotification,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
          enabledBorder: border,
          filled: true,
          focusedBorder: border,
        ),
      ),
    );
  }

  void _updateOnReceiptReceived() {
    final messageThreadCubit = context.read<MessageThreadCubit>();
    context.read<ReceiptBloc>().stream.listen((state) async {
      if (state is ReceiptReceivedSuccess) {
        await messageThreadCubit.viewModel.updateMessageReceipt(state.receipt);
        messageThreadCubit.messages(chatId);
        widget.chatsCubit.chats();
      }
    });
  }

  void _sendMessage() {
    if (_textEditingController.text.trim().isEmpty) return;
    final message = Message(
        from: widget.me.getId,
        to: receiver.getId,
        timeStamp: DateTime.now(),
        contents: _textEditingController.text);
    final sendMessageEvent = MessageEvent.onMessageSent(message);
    widget.messageBloc.add(sendMessageEvent);

    _textEditingController.clear();
    _startTypingTimer?.cancel();
    _stopTypingTimer?.cancel();
    _dispatchTyping(Typing.stop);
  }

  void _dispatchTyping(Typing event) {
    final typing =
        TypingEvent(from: widget.me.getId, to: receiver.getId, event: event);
    widget.typingNotificationBloc
        .add(TypingNotificationEvent.onTypingEventSent(typing));
  }

  void _sendTypingNotification(String text) {
    if (text.trim().isEmpty || messages.isEmpty) return;
    if (_startTypingTimer?.isActive ?? false) return;
    if (_stopTypingTimer?.isActive ?? false) _stopTypingTimer?.cancel();
    _dispatchTyping(Typing.start);

    _startTypingTimer = Timer(const Duration(seconds: 5), () {});
    _stopTypingTimer =
        Timer(const Duration(seconds: 5), () => _dispatchTyping(Typing.stop));
  }

  _scrollRoEnd() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  _sendReceipt(LocalMessage message) async {
    if (message.receipt == ReceiptStatus.read) return;
    final receipt = Receipt(
      recipient: message.message.from,
      messageId: message.getId,
      status: ReceiptStatus.read,
      timeStamp: DateTime.now(),
    );
    context.read<ReceiptBloc>().add(ReceiptEvent.onMessageSent(receipt));
    await context
        .read<MessageThreadCubit>()
        .viewModel
        .updateMessageReceipt(receipt);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _subscription?.cancel();
    _stopTypingTimer?.cancel();
    _startTypingTimer?.cancel();
    super.dispose();
  }
}
