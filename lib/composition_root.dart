import 'package:chat/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labalaba/cache/local_cache.dart';
import 'package:labalaba/data/datasources/datasource_contract.dart';
import 'package:labalaba/data/datasources/sqflit_dataource.dart';
import 'package:labalaba/data/factory/db_factory.dart';
import 'package:labalaba/data/services/iamge_uploader.dart';
import 'package:labalaba/models/viewmodels/chat_view_model.dart';
import 'package:labalaba/models/viewmodels/chats_view_model.dart';
import 'package:labalaba/states_management/home/chats_cubit.dart';
import 'package:labalaba/states_management/home/home_cubit.dart';
import 'package:labalaba/states_management/message_bloc.dart';
import 'package:labalaba/states_management/message_thread/message_thread_cubit.dart';
import 'package:labalaba/states_management/onboarding/onboarding_cubit.dart';
import 'package:labalaba/states_management/onboarding/profile_image_cubit.dart';
import 'package:labalaba/states_management/receipt_bloc.dart';
import 'package:labalaba/states_management/typing_bloc.dart';
import 'package:labalaba/ui/pages/home/home.dart';
import 'package:labalaba/ui/pages/home/home_router.dart';
import 'package:labalaba/ui/pages/onboarding/onboarding.dart';
import 'package:labalaba/ui/pages/onboarding/onboarding_router.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqlite_api.dart';

import 'ui/pages/messages_thread/message_thread.dart';

class CompositionRoot {
  static Rethinkdb _r;

  static Connection _connection;
  static IUserService _iUserService;
  static Database _db;

  static IMessageService _iMessageService;
  static IDataSource _dataSource;
  static ILocalCache _localCache;
  static MessageBloc _messageBloc;
  static TypingNotificationBloc _typingNotificationBloc;
  static ITypingNotification _iTypingNotification;
  static ChatsCubit _chatsCubit;

  static configur() async {
    _r = Rethinkdb();
    _connection = await _r.connect(host: '172.17.0.2', port: 28015);

    _iUserService = UserService(_r, _connection);
    _iMessageService = MessageService(_connection, _r);

    _db = await LocalDatabseFactory().createDatabse();

    _dataSource = SqfLitDataSource(_db);
    final sp = await SharedPreferences.getInstance();
    _localCache = LocalCache(sp);
    _messageBloc = MessageBloc(_iMessageService);
    _typingNotificationBloc = TypingNotificationBloc(_iTypingNotification);
    final viewModel = ChatsViewModel(_dataSource, _iUserService);
    _chatsCubit = ChatsCubit(viewModel);

    _db.delete('chats');
    _db.delete('messages');
  }

  static Widget start() {
    final user = _localCache.fetch('USER');
    return user.isEmpty
        ? composeOnboardingUi()
        : composeHomeUi(User.fromJson(user));
  }

  static Widget composeOnboardingUi() {
    ImageUploader imageUploader =
        ImageUploader('http://172.18.0.1:3000/upload/');
    OnboardingCubit onboardingCubit =
        OnboardingCubit(_iUserService, imageUploader, _localCache);
    ProfileImageCubit profileImageCubit = ProfileImageCubit();

    IOnboardingRouter router = OnboardingRouter(composeHomeUi);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (BuildContext context) => onboardingCubit),
        BlocProvider(create: (BuildContext context) => profileImageCubit),
      ],
      child: const OnBoarding(),
    );
  }

  static Widget composeHomeUi(User me) {
    HomeCubit homeCubit = HomeCubit(_iUserService, _localCache);
    IHomeRouter router = HomeRouter(showMessageThread: composeMessageThreadUi);

    ChatsViewModel viewModel = ChatsViewModel(_dataSource, _iUserService);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (BuildContext context) => homeCubit),
        BlocProvider(create: (BuildContext context) => _messageBloc),
        BlocProvider(create: (BuildContext context) => _typingNotificationBloc),
        BlocProvider(create: (BuildContext context) => _chatsCubit),
      ],
      child: Home(me, router),
    );
  }

  static Widget composeMessageThreadUi(User receiver, User me,
      {String chatId}) {
    ChatViewModel viewModel = ChatViewModel(_dataSource);
    MessageThreadCubit messageThreadCubit = MessageThreadCubit(viewModel);
    IReceiptService receiptService = ReceiptService(_connection, _r);
    ReceiptBloc receiptBloc = ReceiptBloc(receiptService);

    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (BuildContext context) => messageThreadCubit),
          BlocProvider(create: (BuildContext context) => receiptBloc),
          BlocProvider(
              create: (BuildContext context) => _typingNotificationBloc),
        ],
        child: MessageThread(
            receiver, me, _messageBloc, _typingNotificationBloc, _chatsCubit,
            chatId: chatId));
  }
}
