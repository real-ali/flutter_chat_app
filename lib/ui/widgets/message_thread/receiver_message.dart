import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:labalaba/models/local_message.dart';

class ReceiverMessage extends StatelessWidget {
  final LocalMessage _message;
  final String _url;

  const ReceiverMessage(this._message, this._url, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.topLeft,
      widthFactor: 0.75,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
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
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      DateFormat('hLmn a').format(_message.message.timeStamp),
                      style: Theme.of(context).textTheme.overline,
                    ),
                  ),
                ),
                CircleAvatar(
                  radius: 18,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      _url,
                      width: 30,
                      height: 30,
                      fit: BoxFit.fill,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
