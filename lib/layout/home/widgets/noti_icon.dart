import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vegesea/cubits/notis_cubit/notis_cubit.dart';

class NotiIcon extends StatefulWidget {
  const NotiIcon({super.key});

  @override
  State<NotiIcon> createState() => _NotiIconState();
}

class _NotiIconState extends State<NotiIcon> {
  @override
  void initState() {
    BlocProvider.of<NotisCubit>(context).getNotisCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotisCubit, NotisState>(
      builder: (context, state) {
        if (state is GetNotisCountSuccess) {
          final notisCount = state.notisCount.data;
          return Stack(
            children: [
              const Icon(
                Icons.notifications,
                // color: Colors.black,
                size: 45,
              ),
              CircleAvatar(
                backgroundColor: Colors.red,
                maxRadius: 10,
                child: Text(
                  notisCount.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              )
            ],
          );
        } else {
          return Stack(
            children: [
              Icon(
                Icons.notifications,
                // color: Colors.black,
                size: 45.w,
              ),
              const CircleAvatar(
                backgroundColor: Colors.red,
                maxRadius: 10,
                child: Text(
                  "0",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          );
        }
      },
    );
  }
}
