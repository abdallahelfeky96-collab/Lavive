// // ignore_for_file: unused_local_variable, file_names
//
// import 'package:flutter/material.dart';
// import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:vegesea/layout/root_view.dart';
// import '../../shared/shared/components/components.dart';
//
// class OnBoarding extends StatelessWidget {
//   const OnBoarding({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     bool isAppOpend = false;
//     double height = MediaQuery.of(context).size.height;
//     double width = MediaQuery.of(context).size.width;
//
//     return
//     //   Stack(
//     //   alignment: Alignment.topRight,
//     //   children: [
//     //      const Image(
//     //     image: AssetImage('assets/images/boarding-.png')),
//     //
//     //        OnBoardingSlider(
//     //         centerBackground: true,
//     //         finishButtonText: 'GET STARTED',
//     //         onFinish: () async {
//     //           navigateAndFinish(context, const RootView());
//     //           isAppOpend = true;
//     //           SharedPreferences prefs = await SharedPreferences.getInstance();
//     //           prefs.setBool("isAppOpend", isAppOpend);
//     //
//     //           //  navigateAndFinish(context,  ShopLoginScreen());
//     //         },
//     //         finishButtonStyle: const FinishButtonStyle(
//     //             backgroundColor: kMainColor,
//     //             shape: RoundedRectangleBorder(
//     //                 borderRadius: BorderRadius.all(Radius.circular(30.0)))),
//     //         skipTextButton: const Text(
//     //           'Skip',
//     //           style: TextStyle(
//     //             fontSize: 16,
//     //             color: Colors.green,
//     //             fontWeight: FontWeight.w600,
//     //           ),
//     //         ),
//     //         controllerColor: Colors.green,
//     //         totalPage: 2,
//     //         headerBackgroundColor: Colors.white,
//     //         pageBackgroundColor: Colors.white,
//     //         background: [
//     //           Image.asset(
//     //             'assets/images/basket.png',
//     //             height: height * 0.35,
//     //           ),
//     //           Image.asset(
//     //             'assets/images/Group.png',
//     //             height: height * 0.35,
//     //           ),
//     //         ],
//     //         speed: 1.8,
//     //         pageBodies: [
//     //           Container(
//     //             alignment: Alignment.center,
//     //             width: MediaQuery.of(context).size.width,
//     //             padding: const EdgeInsets.symmetric(horizontal: 40),
//     //             child: const Column(
//     //               mainAxisAlignment: MainAxisAlignment.start,
//     //               crossAxisAlignment: CrossAxisAlignment.center,
//     //               children: <Widget>[
//     //                 Spacer(
//     //                   flex: 2,
//     //                 ),
//     //                 Text(
//     //                   'On your way...',
//     //                   textAlign: TextAlign.center,
//     //                   style: TextStyle(
//     //                     color: Color(0xFF053149),
//     //                     fontSize: 24.0,
//     //                     fontWeight: FontWeight.w600,
//     //                   ),
//     //                 ),
//     //                 // SizedBox(
//     //                 //   height: 20,
//     //                 // ),
//     //                 Text(
//     //                   'find the favourites stores you want by '
//     //                   'your locations or neighborhood',
//     //                   textAlign: TextAlign.center,
//     //                   style: TextStyle(
//     //                     color: Colors.black54,
//     //                     fontSize: 20.0,
//     //                     fontWeight: FontWeight.w600,
//     //                   ),
//     //                 ),
//     //                 Spacer()
//     //               ],
//     //             ),
//     //           ),
//     //           Container(
//     //             alignment: Alignment.center,
//     //             width: MediaQuery.of(context).size.width,
//     //             padding: const EdgeInsets.symmetric(horizontal: 40),
//     //             child: const Column(
//     //               mainAxisAlignment: MainAxisAlignment.start,
//     //               crossAxisAlignment: CrossAxisAlignment.center,
//     //               children: <Widget>[
//     //                 Spacer(
//     //                   flex: 2,
//     //                 ),
//     //                 // SizedBox(
//     //                 //   height: 350,
//     //                 // ),
//     //                 Text(
//     //                   'Offers Fresh & Quality '
//     //                   'Groceries for you',
//     //                   textAlign: TextAlign.center,
//     //                   style: TextStyle(
//     //                     color: Color(0xFF053149),
//     //                     fontSize: 24.0,
//     //                     fontWeight: FontWeight.w600,
//     //                   ),
//     //                 ),
//     //
//     //                 Text(
//     //                   'All items have real freshness'
//     //                   'and intended for your needs',
//     //                   textAlign: TextAlign.center,
//     //                   style: TextStyle(
//     //                     color: Colors.black54,
//     //                     fontSize: 18.0,
//     //                     fontWeight: FontWeight.w600,
//     //                   ),
//     //                 ),
//     //                 Spacer(),
//     //               ],
//     //             ),
//     //           ),
//     //           // Container(
//     //           //   alignment: Alignment.center,
//     //           //   width: MediaQuery.of(context).size.width,
//     //           //   padding: const EdgeInsets.symmetric(horizontal: 40),
//     //           //   child: const Column(
//     //           //     mainAxisAlignment: MainAxisAlignment.start,
//     //           //     crossAxisAlignment: CrossAxisAlignment.center,
//     //           //     children: <Widget>[
//     //           //       SizedBox(
//     //           //         height: 480,
//     //           //       ),
//     //           //       Text(
//     //           //         'Start now!',
//     //           //         textAlign: TextAlign.center,
//     //           //         style: TextStyle(
//     //           //           color: Color(0xFF053149),
//     //           //           fontSize: 24.0,
//     //           //           fontWeight: FontWeight.w600,
//     //           //         ),
//     //           //       ),
//     //           //       SizedBox(
//     //           //         height: 20,
//     //           //       ),
//     //           //       Text(
//     //           //         'Where everything is possible and customize your onboarding.',
//     //           //         textAlign: TextAlign.center,
//     //           //         style: TextStyle(
//     //           //           color: Colors.black26,
//     //           //           fontSize: 18.0,
//     //           //           fontWeight: FontWeight.w600,
//     //           //         ),
//     //           //       ),
//     //           //     ],
//     //           //   ),
//     //           // ),
//     //         ],
//     //       ),
//     //
//     //
//     //     ],
//     // );
//
//
//       Container(
//       decoration: const BoxDecoration(
//         image: DecorationImage(
//           image: AssetImage('assets/images/Oon.jpeg'),
//           fit: BoxFit.cover,
//         ),
//       ),
//       child: OnBoardingSlider(
//         centerBackground: true,
//         finishButtonText: 'GET STARTED',
//         onFinish: () async {
//           navigateAndFinish(context, const RootView());
//           isAppOpend = true;
//           SharedPreferences prefs = await SharedPreferences.getInstance();
//           prefs.setBool("isAppOpend", isAppOpend);
//
//           //  navigateAndFinish(context,  ShopLoginScreen());
//         },
//         finishButtonStyle: const FinishButtonStyle(
//             backgroundColor: kMainColor,
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(30.0)))),
//         skipTextButton: const Text(
//           'Skip',
//           style: TextStyle(
//             fontSize: 16,
//             color: Colors.green,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         controllerColor: Colors.green,
//         totalPage: 2,
//         headerBackgroundColor: Colors.white,
//         pageBackgroundColor: Colors.white,
//         background: [
//           Image.asset(
//             'assets/images/basket.png',
//             height: height * 0.35,
//           ),
//           Image.asset(
//             'assets/images/Group.png',
//             height: height * 0.35,
//           ),
//         ],
//         speed: 1.8,
//         pageBodies: [
//           Container(
//             alignment: Alignment.center,
//             width: MediaQuery.of(context).size.width,
//             padding: const EdgeInsets.symmetric(horizontal: 40),
//             child: const Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: <Widget>[
//                 Spacer(
//                   flex: 2,
//                 ),
//                 Text(
//                   'On your way...',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: Color(0xFF053149),
//                     fontSize: 24.0,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 // SizedBox(
//                 //   height: 20,
//                 // ),
//                 Text(
//                   'find the favourites stores you want by '
//                   'your locations or neighborhood',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: Colors.black54,
//                     fontSize: 20.0,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 Spacer()
//               ],
//             ),
//           ),
//           Container(
//             alignment: Alignment.center,
//             width: MediaQuery.of(context).size.width,
//             padding: const EdgeInsets.symmetric(horizontal: 40),
//             child: const Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: <Widget>[
//                 Spacer(
//                   flex: 2,
//                 ),
//                 // SizedBox(
//                 //   height: 350,
//                 // ),
//                 Text(
//                   'Offers Fresh & Quality '
//                   'Groceries for you',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: Color(0xFF053149),
//                     fontSize: 24.0,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//
//                 Text(
//                   'All items have real freshness'
//                   'and intended for your needs',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: Colors.black54,
//                     fontSize: 18.0,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 Spacer(),
//               ],
//             ),
//           ),
//           // Container(
//           //   alignment: Alignment.center,
//           //   width: MediaQuery.of(context).size.width,
//           //   padding: const EdgeInsets.symmetric(horizontal: 40),
//           //   child: const Column(
//           //     mainAxisAlignment: MainAxisAlignment.start,
//           //     crossAxisAlignment: CrossAxisAlignment.center,
//           //     children: <Widget>[
//           //       SizedBox(
//           //         height: 480,
//           //       ),
//           //       Text(
//           //         'Start now!',
//           //         textAlign: TextAlign.center,
//           //         style: TextStyle(
//           //           color: Color(0xFF053149),
//           //           fontSize: 24.0,
//           //           fontWeight: FontWeight.w600,
//           //         ),
//           //       ),
//           //       SizedBox(
//           //         height: 20,
//           //       ),
//           //       Text(
//           //         'Where everything is possible and customize your onboarding.',
//           //         textAlign: TextAlign.center,
//           //         style: TextStyle(
//           //           color: Colors.black26,
//           //           fontSize: 18.0,
//           //           fontWeight: FontWeight.w600,
//           //         ),
//           //       ),
//           //     ],
//           //   ),
//           // ),
//         ],
//       ),
//     );
//   }
// }
