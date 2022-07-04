import 'package:flutter/material.dart';

class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({
    WidgetBuilder builder,
    RouteSettings settings,
  }) : super(
          builder: builder,
          settings: settings,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (settings.name == '/') {
      return child; // this is the first page and we dont want to animate it
    } else {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    }
  }
}

class CustomPageTransitionBuilder extends PageTransitionsBuilder {
  // copy the above buildTransitions method and make few changes
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (route.settings.name == '/') {
      return child; // this is the first page and we dont want to animate it
    } else {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    }
  }
}
