import 'package:flutter/material.dart';
import 'package:vegesea/layout/notifications_screen/widgets/noti_item.dart';
import 'package:vegesea/shared/shared/app_localization.dart';
import 'package:vegesea/shared/shared/components/components.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      floatingActionButton: const MovableFloatingButton(),
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios)),
        title: Text(
          AppLocalizations.of(context).translate('noti'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [
          HomeButton(),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Align(
            //   alignment: Alignment.centerRight,
            //   child: TextButton(
            //       onPressed: () {
            //         //TODO: CLEARE ALL NOTIS
            //       },
            //       child: Text(
            //           AppLocalizations.of(context).translate('clear all'))),
            // ),
            Expanded(child: NotiItem())
          ],
        ),
      ),
    );
  }
}
