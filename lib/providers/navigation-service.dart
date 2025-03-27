import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;

  static Future<dynamic> navigateTo(Widget myPage, {Object? arguments}) {
    // return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
    return navigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => myPage,
      ),
    );
  }

  static Future<dynamic> navigateReplacementTo(Widget myPage, {Object? arguments}) {
    // return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
    return navigatorKey.currentState!.pushReplacement(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => myPage,
      ),
    );
  }

  static void goBack() {
    return navigatorKey.currentState!.pop();
  }
}
