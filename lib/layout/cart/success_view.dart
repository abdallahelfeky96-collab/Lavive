import 'package:flutter/material.dart';
import 'package:vegesea/shared/shared/components/components.dart';
import '../root_view.dart';

class SuccessView extends StatelessWidget {
  const SuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              height: height / 1.5,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Stack(
                      children: [
                        Image.asset(
                          'assets/images/rb_76300.png',
                          height: height / 3,
                        ),
                        Image.asset(
                          'assets/images/shopping_bag.png',
                          height: height / 3,
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Text(
                      "Order done!",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      "Thanks! your order will arrive soon",
                      style: TextStyle(fontSize: 18),
                    ),
                    const Spacer(),
                    defaultButton(
                        function: () {
                          //Navigator.pop(context);
                          navigateAndFinish(context, const RootView());
                        },
                        text: 'OK'),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
