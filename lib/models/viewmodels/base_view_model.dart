import 'package:flutter/material.dart';
import 'package:labalaba/data/datasources/datasource_contract.dart';
import 'package:labalaba/models/chat.dart';
import 'package:labalaba/models/local_message.dart';

abstract class BaseViewModel {
  @protected
  final IDataSource _dataSource;

  BaseViewModel(this._dataSource);

  @protected
  Future<void> addMessage(LocalMessage message) async {
    if (!await _isExistingChat(message.chatId)) {
      await _createNewChat(message.chatId);
    }
    await _dataSource.addMessage(message);
  }

  Future<bool> _isExistingChat(String chatId) async {
    return await _dataSource.findChat(chatId) != null;
  }

  Future<void> _createNewChat(String chatId) async {
    final chat = Chat(chatId);
    await _dataSource.addChat(chat);
  }
}
