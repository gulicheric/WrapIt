import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareWidget extends StatelessWidget {
  const ShareWidget({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: size.width,
        height: 60,
        decoration: BoxDecoration(
          color: Color.fromARGB(28, 255, 255, 255),
          border: Border.all(width: 2),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () async {
            const String url =
                'https://apps.apple.com/us/app/wrapit-social/id6468837687';
            const String text = 'Share your tefillin loud and proud $url';

            Share.share(text);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "Invite Friends",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(width: 10),
              Padding(
                padding: EdgeInsets.only(bottom: 5.0),
                child: Icon(Icons.ios_share),
              )
            ],
          ),
        ));
  }
}
