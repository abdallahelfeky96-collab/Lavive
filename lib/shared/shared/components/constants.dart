import '../Network/cache_helper.dart';

void signOut(context) {
  CacheHelper.removeData(
    key: 'token',
  ).then((value) {
    if (value != null) {
      // navigateAndFinish(
      //   context, ShopLoginScreen(),
      //   );
    }
  });
}
