part of 'navigation_bloc.dart';

abstract class NavigationEvent {
  const NavigationEvent();
}

class NavigationTabChanged extends NavigationEvent {
  final int tabIndex;
  const NavigationTabChanged(this.tabIndex);
}
