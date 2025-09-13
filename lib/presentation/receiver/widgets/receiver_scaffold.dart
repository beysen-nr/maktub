import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maktub/core/constants/constants.dart';
import 'package:maktub/core/l10n/app_localizations.dart';
import 'package:maktub/core/router/route_names.dart';
import 'package:maktub/presentation/receiver/screens/order_receiver_screen.dart';
import 'package:maktub/presentation/receiver/screens/profile_receiver_screen.dart';

class ReceiverScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  ReceiverScaffold({super.key, required this.navigationShell});

  int _currentTabIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(RouteNames.receiverOrder)) return 0;
    if (location.startsWith(RouteNames.profile)) return 1;
    return 0;
  }

  final tabs = [OrderReceiverScreen(), const ProfileReceiverScreen()];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentTabIndex(context);
    final selectedItemColor = Gradients.primary;


    return Scaffold(
      backgroundColor: Colors.white,
      body: navigationShell,
      extendBody: true,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 4),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Gradients.primary,
                width: 0.7,
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(25)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: BottomNavigationBar(
                  currentIndex: currentIndex,
                  onTap: (index) {
                    navigationShell.goBranch(index, initialLocation: false);
                  },
                
                  backgroundColor: Colors.white,
                  elevation: 0,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: selectedItemColor,
                  unselectedItemColor: Gradients.bigTextColor,
                  enableFeedback: false,
                  selectedFontSize: 12,
                  selectedLabelStyle: selectedLabel,
                  unselectedLabelStyle: unselectedLabel,
                  iconSize: 25,
                
                  items: List.generate(2, (index) {
                    final isSelected = index == currentIndex;
                    final iconPaths = [
                      [
                        'assets/icons/bottombar/catalog.png',
                        'assets/icons/bottombar/catalog-filled.png',
                      ],
                      [
                        'assets/icons/bottombar/profile.png',
                        'assets/icons/bottombar/profile-filled.png',
                      ],
                    ];
                
                    final labels = [   AppLocalizations.of(context)!.orders,
                      'профиль'];
                
                    return BottomNavigationBarItem(
                      icon: Image.asset(
                        isSelected
                            ? iconPaths[index][1]
                            : iconPaths[index][0],
                        width: 25,
                        height: 25,
                      ),
                      label: labels[index],
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
