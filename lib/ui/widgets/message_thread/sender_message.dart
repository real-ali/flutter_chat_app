import 'package:chat/chat.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/local_message.dart';

class SenderMessage extends StatelessWidget {
  final LocalMessage _message;
  const SenderMessage(this._message, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.topLeft,
      widthFactor: 0.75,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.red.shade500,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  position: DecorationPosition.background,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    child: Text(
                      _message.message.contents.trim(),
                      softWrap: true,
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          ?.copyWith(height: 1.2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 12),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      DateFormat('hLmn a').format(_message.message.timeStamp),
                      style: Theme.of(context).textTheme.overline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: Align(
              alignment: Alignment.centerRight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(30)),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: _message.receipt == ReceiptStatus.read
                      ? Colors.green.shade700
                      : Colors.grey,
                  size: 20,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
