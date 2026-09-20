import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vegesea/layout/chat/chat_screen.dart';
import 'package:vegesea/services/floating_action_provider.dart';
import '../../Shared/colors.dart';

const kMainColor = Color(0xFF14522d);
const kSecondaryColor = Color(0xFFE9E19C); // D0E4A4  // E9E19C

// Widget defaultFloatingButton(BuildContext context) {
//   // final buttonPositionProvider = Provider.of<ButtonPositionProvider>(context);
//   final screenSize = MediaQuery.of(context).size;
//   return Stack(
//     children: [
//       Positioned(
//         left: screenSize.width - 56,
//         top: screenSize.height - 150,
//         child: GestureDetector(
//           // onPanUpdate: (details) {
//           //   Offset newPosition = Offset(
//           //     (buttonPositionProvider.buttonPosition.dx + details.delta.dx)
//           //         .clamp(0, screenSize.width - 56), // Adjust for button size
//           //     (buttonPositionProvider.buttonPosition.dy + details.delta.dy)
//           //         .clamp(0, screenSize.height - 56),
//           //   );
//           //   buttonPositionProvider.updatePosition(newPosition);
//           // },
//           child: FloatingActionButton(
//             heroTag: 'uniqueTag2', // Provide a unique tag here
//             backgroundColor: kMainColor,
//             onPressed: () {
//               navigateTo(context, const ChatScreen());
//             },
//             child: const Icon(
//               Icons.support_agent,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ),
//     ],
//   );
// }

class MovableFloatingButton extends StatelessWidget {
  const MovableFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    final buttonPositionProvider = Provider.of<ButtonPositionProvider>(context);
    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context)
        .padding; // Get system padding (e.g., status bar, navigation bar)
    const buttonSize = 56.0; // Size of the FloatingActionButton

    // Calculate the initial position (bottom-right corner, above the navigation bar)
    final initialPosition = Offset(
      screenSize.width - buttonSize - 16, // 16 is padding from the right edge
      screenSize.height -
          padding.bottom -
          buttonSize -
          16, // 16 is padding from the bottom edge
    );

    // Ensure the button position is initialized only once
    if (buttonPositionProvider.buttonPosition == Offset.zero) {
      buttonPositionProvider.updatePosition(initialPosition);
    }

    return Stack(
      children: [
        Positioned(
          left: buttonPositionProvider.buttonPosition.dx,
          top: buttonPositionProvider.buttonPosition.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              // Calculate new position while ensuring it stays within screen bounds
              Offset newPosition = Offset(
                (buttonPositionProvider.buttonPosition.dx + details.delta.dx)
                    .clamp(
                        0,
                        screenSize.width -
                            buttonSize), // Constrain to screen width
                (buttonPositionProvider.buttonPosition.dy + details.delta.dy).clamp(
                    0,
                    screenSize.height -
                        padding.bottom -
                        buttonSize), // Constrain to screen height (above navigation bar)
              );
              buttonPositionProvider.updatePosition(newPosition);
            },
            child: FloatingActionButton(
              heroTag: 'uniqueTag2',
              backgroundColor: kMainColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              onPressed: () {
                navigateTo(context, const ChatScreen());
              },
              child: const Icon(
                Icons.support_agent,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget defaultButton(
        {double width = double.infinity,
        Color background = kMainColor,
        bool isUpperCase = true,
        double? radius,
        double? height,
        Function? function,
        required String text,
        Color textColor = Colors.white,
        Widget? icon}) =>
    Container(
      width: width,
      height: height ?? 70.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 15),
        color: background,
      ),
      child: MaterialButton(
        onPressed: function as void Function()?,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon ?? const SizedBox(),
            Text(
              isUpperCase ? text.toUpperCase() : text,
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );

Widget defaultTextButton({
  required Function function,
  required String text,
  String? color,
}) =>
    TextButton(
      onPressed: function as void Function()?,
      child: Text(
        text.toUpperCase(),
      ),
    );

class HomeButton extends StatelessWidget {
  const HomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.pushNamedAndRemoveUntil(
            context, 'root_view', (route) => false);
      },
      icon: CircleAvatar(
        radius: 20,
        backgroundColor: kMainColor,
        child: SvgPicture.asset(
          "assets/images/home.svg",
          height: 20,
          width: 20,
          color: Colors.white,
        ),
      ),
    );
  }
}

Widget defaultFormField({
  required TextEditingController controller,
  required TextInputType type,
  Function? onSubmit,
  Function? onChange,
  Function? onTap,
  bool isPassword = false,
  String? Function(String?)? validate, // Update validate to return hints
  required String label,
  IconData? prefix,
  IconData? suffix,
  Color? fillColor,
  Color? color,
  Function? suffixPressed,
  bool isClickable = true,
  int? maxLines = 1,
  String? hintText,
}) =>
    StatefulBuilder(
      builder: (context, setState) {
        return TextFormField(
          cursorColor: color,
          controller: controller,
          keyboardType: type,
          obscureText: isPassword,
          enabled: isClickable,
          maxLines: isPassword ? 1 : maxLines,

          onFieldSubmitted: onSubmit as void Function(String)?,
          onChanged: onChange as void Function(String)?,
          onTap: onTap as void Function()?,
          validator: validate, // Use the validation function directly
          decoration: InputDecoration(
            fillColor: fillColor,
            filled: true,
            labelText: label,
            hintText: hintText,
            prefixIcon: Icon(
              prefix,
              color: color,
            ),
            suffixIcon: suffix != null
                ? IconButton(
                    color: color,
                    onPressed: () {
                      setState(() {
                        isPassword = !isPassword; // Toggle password visibility
                      });
                      if (suffixPressed != null) {
                        suffixPressed();
                      }
                    },
                    icon: Icon(
                      isPassword
                          ? Icons.visibility
                          : Icons.visibility_off, // Toggle icon based on state
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );

Widget myDivider() => Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 20.0,
      ),
      child: Container(
        width: double.infinity,
        height: 1.0,
        color: Colors.grey[300],
      ),
    );

void navigateTo(context, widget) => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => widget,
      ),
    );

void navigateAndFinish(
  context,
  widget,
) =>
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => widget,
      ),
      (route) {
        return false;
      },
    );

void showToast({
  required String text,
  required ToastStates state,
}) =>
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 5,
      backgroundColor: chooseToastColor(state),
      textColor: Colors.white,
      fontSize: 16.0,
    );

// enum
enum ToastStates { SUCCESS, ERROR, WARNING }

Color chooseToastColor(ToastStates state) {
  Color color;

  switch (state) {
    case ToastStates.SUCCESS:
      color = Colors.green;
      break;
    case ToastStates.ERROR:
      color = Colors.red;
      break;
    case ToastStates.WARNING:
      color = Colors.amber;
      break;
  }

  return color;
}

Widget buildListProduct(
  model,
  context, {
  bool isOldPrice = true,
}) =>
    Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        height: 120.0,
        child: Row(
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomStart,
              children: [
                Image(
                  image: NetworkImage(model.image),
                  width: 120.0,
                  height: 120.0,
                ),
                if (model.discount != 0 && isOldPrice)
                  Container(
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5.0,
                    ),
                    child: const Text(
                      'DISCOUNT',
                      style: TextStyle(
                        fontSize: 8.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.0,
                      height: 1.3,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        model.price.toString(),
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: defaultColor,
                        ),
                      ),
                      const SizedBox(
                        width: 5.0,
                      ),
                      if (model.discount != 0 && isOldPrice)
                        Text(
                          model.oldPrice.toString(),
                          style: const TextStyle(
                            fontSize: 10.0,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      const Spacer(),
                      // IconButton(
                      //   onPressed: () {
                      //     ShopCubit.get(context).changeFavorites(model.id);
                      //   },
                      //   icon: CircleAvatar(
                      //     radius: 15.0,
                      //     backgroundColor:
                      //     ShopCubit.get(context).favorites[model.id]
                      //         ? defaultColor
                      //         : Colors.grey,
                      //     child: const Icon(
                      //       Icons.favorite_border,
                      //       size: 14.0,
                      //       color: Colors.white,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

void showSnackBarMessage(
    BuildContext context, String message, Color color, IconData icon) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => _SnackBarWidget(
      message: message,
      color: color,
      icon: icon,
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 4), () {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  });
}

class _SnackBarWidget extends StatefulWidget {
  final String message;
  final Color color;
  final IconData icon;

  const _SnackBarWidget({
    required this.message,
    required this.color,
    required this.icon,
  });

  @override
  State<_SnackBarWidget> createState() => _SnackBarWidgetState();
}

class _SnackBarWidgetState extends State<_SnackBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    _controller.forward();

    // Start exit animation after delay
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: size.width * 0.05,
      right: size.width * 0.05,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _offsetAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _controller.reverse(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
