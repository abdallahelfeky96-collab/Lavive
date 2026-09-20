import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:vegesea/shared/shared/app_localization.dart';
import 'package:vegesea/shared/shared/components/components.dart';

class TrackOrderView extends StatelessWidget {
  TrackOrderView({super.key, required this.orderStatus});
  final int orderStatus;

  late List<String> statusTexts;

  void _initStatusTexts(BuildContext context) {
    statusTexts = [
      AppLocalizations.of(context).translate("order placed"),
      AppLocalizations.of(context).translate("order confirmed"),
      AppLocalizations.of(context).translate("preparing"),
      AppLocalizations.of(context).translate("out for delivery"),
      AppLocalizations.of(context).translate("delivered"),
      AppLocalizations.of(context).translate("refunded"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    _initStatusTexts(context);
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      floatingActionButton: const MovableFloatingButton(),
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios)),
        title: Text(
          AppLocalizations.of(context).translate("track order"),
        ),
        actions: const [
          HomeButton(),
        ],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: List.generate(statusTexts.length, (index) {
                  return TimeLineWidget(
                    isFirst: index == 0,
                    isLast: index == statusTexts.length - 1,
                    isPast: index < orderStatus,
                    eventText: statusTexts[index],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeLineWidget extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final bool isPast;
  final String eventText;

  const TimeLineWidget({
    super.key,
    required this.isFirst,
    required this.isLast,
    required this.isPast,
    required this.eventText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: TimelineTile(
        isFirst: isFirst,
        isLast: isLast,
        indicatorStyle: IndicatorStyle(
          iconStyle: IconStyle(
            iconData: isPast ? Icons.check : Icons.radio_button_unchecked,
            color: isPast ? Colors.white : Colors.grey,
          ),
          width: 40,
          color: isPast ? Colors.green : Colors.grey.shade400,
        ),
        beforeLineStyle: LineStyle(
          color: isPast ? Colors.green : Colors.grey.shade400,
          thickness: 2,
        ),
        afterLineStyle: LineStyle(
          color: isPast ? Colors.green : Colors.grey.shade400,
          thickness: 2,
        ),
        endChild: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              eventText,
              style: TextStyle(
                fontSize: 16,
                color: isPast ? Colors.black : Colors.grey,
                fontWeight: isPast ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
