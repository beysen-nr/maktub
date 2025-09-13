import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:maktub/core/constants/constants.dart';
import 'package:maktub/core/l10n/app_localizations.dart';
import 'package:maktub/core/router/permission_manager.dart';
import 'package:maktub/core/router/route_names.dart';
import 'package:maktub/presentation/blocs/auth/user_role.dart';
import 'package:maktub/presentation/user/blocs/app_state_cubit.dart';
import 'package:maktub/presentation/user/screens/cart/cart_screen.dart';
import 'package:maktub/presentation/user/screens/main/profile_screen.dart';
import 'package:maktub/presentation/user/screens/product/catalog_screen.dart';
import 'package:maktub/presentation/user/screens/main/home_screen.dart';

class UserScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  UserScaffold({super.key, required this.navigationShell});
    static const int _cartTabIndex = 2;
    
  int _currentTabIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(RouteNames.catalog)) return 1;
    
    // if (location.startsWith(RouteNames.favorites)) return 2;
    if (location.startsWith(RouteNames.cart)) return 2;
    if (location.startsWith(RouteNames.profile)) return 3;
    return 0;
  }

  final tabs = [
    const HomeScreen(),
    CatalogScreen(),
    
    // const FavoritesScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentTabIndex(context);
    final selectedItemColor = Gradients.primary;
        
        // currentIndex == 2
        
        //     ? const Color(0xFFF44F4F) 
        
        //     : Gradients.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: navigationShell,
      extendBody: true,
      bottomNavigationBar:
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 4),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Gradients.primary,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(25)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: BottomNavigationBar(
                  currentIndex: currentIndex,
                  onTap: (index) async { 
                    if (index == _cartTabIndex) {
                      
                      final appState = context.read<AppStateCubit>().state;
                      
                      final userRole = appState != null
                          ? UserRole.values.firstWhere(
                              (e) => e.name == appState.role,
                              orElse: () => UserRole.guest,
                            )
                          : UserRole.guest; 
                
                      
                      final hasAccess = PermissionManager.canAccess(
                        userRole,
                        'cart', 
                      );
                
                      if (hasAccess) {
                        
                        navigationShell.goBranch(
                          index,
                          initialLocation: false,
                        );
                      } else {
                   context.push(RouteNames.login);
                     
                      }
                    } else {
                      navigationShell.goBranch(
                        index,
                        initialLocation: false,
                      );
                    }
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
                
                  items: List.generate(4, (index) {
                    final isSelected = index == currentIndex;
                    final iconPaths = [
                      [
                        'assets/icons/bottombar/home.png',
                        'assets/icons/bottombar/home-filled.png',
                      ],
                      [
                        'assets/icons/bottombar/catalog.png',
                        'assets/icons/bottombar/catalog-filled.png',
                      ],
                      
                      // [
                      
                      //   'assets/icons/bottombar/favorites.png',
                      
                      //   'assets/icons/bottombar/favorites-filled.png',
                      
                      // ],
                      [
                        'assets/icons/bottombar/cart.png',
                        'assets/icons/bottombar/cart-filled.png',
                      ],
                      [
                        'assets/icons/bottombar/profile.png',
                        'assets/icons/bottombar/profile-filled.png',
                      ],
                    ];
                
                    final labels = [
                      AppLocalizations.of(context)!.home,
                      'каталог',
                      
                      // 'сүйікті',
                       AppLocalizations.of(context)!.cart,
                      'профиль',
                    ];
                
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
