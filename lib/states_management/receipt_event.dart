part of 'receipt_bloc.dart';

abstract class ReceiptEvent extends Equatable {
  const ReceiptEvent();
  @override
  List<Object> get props => [];

  factory ReceiptEvent.onSubscribe(User user) => Subscribed(user);
  factory ReceiptEvent.onMessageSent(Receipt receipt) => ReceiptSent(receipt);
}

class Subscribed extends ReceiptEvent {
  final User user;

  const Subscribed(this.user);
  @override
  List<Object> get props => [user];
}

class ReceiptSent extends ReceiptEvent {
  final Receipt receipt;

  const ReceiptSent(this.receipt);
  @override
  List<Object> get props => [receipt];
}

class _ReceiptReceived extends ReceiptEvent {
  final Receipt receipt;

  const _ReceiptReceived(this.receipt);
  @override
  List<Object> get props => [receipt];
}
