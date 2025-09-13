// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:maktub/core/constants/constants.dart';
import 'package:maktub/core/l10n/app_localizations.dart';
import 'package:maktub/core/router/permission_manager.dart';
import 'package:maktub/core/router/route_names.dart';
import 'package:maktub/data/models/category.dart';
import 'package:maktub/presentation/blocs/auth/user_role.dart';
import 'package:maktub/presentation/user/blocs/ad/ad_bloc.dart';
import 'package:maktub/presentation/user/blocs/ad/ad_event.dart';
import 'package:maktub/presentation/user/blocs/app_state_cubit.dart';
import 'package:maktub/presentation/user/blocs/cart/cart_bloc.dart';
import 'package:maktub/presentation/user/blocs/home/home_bloc.dart';
import 'package:maktub/presentation/user/blocs/home/home_event.dart';
import 'package:maktub/presentation/user/blocs/home/home_state.dart';
import 'package:maktub/presentation/user/blocs/product/product_bloc.dart';
import 'package:maktub/presentation/user/screens/product/product_card.dart';
import 'package:maktub/presentation/user/widgets/ad/ad_banner.dart';
import 'package:maktub/presentation/user/widgets/ad/ad_carousel.dart';
import 'package:maktub/data/models/banner.dart' as banner;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Map<Category, List<Category>> categories = {};
    int organizationId = context.read<AppStateCubit>().state!.workplaceId;
    int regionId = context.read<AppStateCubit>().state!.regionId;
       context.read<CartBloc>().add(
        LoadCart(organizationId, regionId),
      );
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (_) =>
                  HomeBloc()..add(
                    LoadHomeWidgets(
                      context.read<AppStateCubit>().state!.regionId,
                    ),
                  ),
        ),
        BlocProvider(
          create:
              (_) => ProductBloc(repository: context.read())..add(
                LoadProducts(
                  organizationId: organizationId,
                  categoryId: 101,
                  regionId: regionId,
                ),
              ),
        ),
        


      ],
      child: 
      
      BlocListener<AppStateCubit, AppState?>(
        listenWhen: (prev, curr) => prev?.regionId != curr?.regionId,
        listener: (context, state) {
          if (state != null) {
            context.read<HomeBloc>().add(LoadHomeWidgets(state.regionId));

            context.read<AdBloc>().add(LoadCarousel(state.regionId));

            context.read<CartBloc>().add(LoadCart(organizationId, state.regionId));
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          extendBodyBehindAppBar: true,
          appBar: const MaktubAppBar(),
          body: BlocListener<HomeBloc, HomeState>(
            listener: (context, state) {
            if(state is HomeLoaded){
                  categories = state.categories;
                  context.read<AppStateCubit>().updateCategories(categories);
            }
            },
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state is HomeLoading) {
                  return Center(
                    child: LoadingAnimationWidget.waveDots(
                      color: Gradients.primary,
                      size: 25,
                    ),
                  );
                } else if (state is HomeLoaded) {
                  final animatedChildren = <Widget>[];
                  
                  final staticChildren = [
                     Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Carousel(
                        subcategories: categories
                      ),
                    ),
                  ];

                  // Добавляем анимации к staticChildren
                  for (var i = 0; i < staticChildren.length; i++) {
                    animatedChildren.add(
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: Duration(milliseconds: 1000 + i * 100),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, (1 - value) * 20),
                              child: child,
                            ),
                          );
                        },
                        child: staticChildren[i],
                      ),
                    );
                  }
                  animatedChildren.add(
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 500),
                      tween: Tween<double>(begin: 0, end: 1),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, (1 - value) * 20),
                            child: child,
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GlassButton(
                            icon: Image.asset(
                              'assets/icons-system/order.png',
                              width: 25,
                              height: 25,
                            ),
                            text: AppLocalizations.of(context)!.order,
                            onTap:  () {
                              final isGuest =
                                  context.read<AppStateCubit>().state?.role ==
                                  UserRole.guest.name;
                              if (isGuest) {
                                context.push(RouteNames.login);
                              } else {
                                context.push(RouteNames.order);
                              }
                            },
                          ),
                          const SizedBox(width: 12),
                          GlassButton(
                            icon: Image.asset(
                              'assets/icons-system/catalog-filled.png',
                              width: 25,
                              height: 25,
                            ),
                            text: 'Каталог',
                            onTap: () {
                              context.go(RouteNames.catalog);
                            },
                          ),
                          const SizedBox(width: 12),
                          GlassButton(
                            icon:
                                context.read<AppStateCubit>().state?.role ==
                                        UserRole.guest.name
                                    ? Image.asset(
                                      'assets/icons-system/login.png',
                                      width: 25,
                                      height: 25,
                                    )
                                    : Image.asset(
                                      'assets/icons/bottombar/profile-filled.png',
                                      width: 25,
                                      height: 25,
                                    ),
                            text:
                                context.watch<AppStateCubit>().state?.role ==
                                        UserRole.guest.name
                                    ?  AppLocalizations.of(context)!.login
                                    : 'Профиль',
                            onTap: () {
                              final isGuest =
                                  context.read<AppStateCubit>().state?.role ==
                                  UserRole.guest.name;
                              if (isGuest) {
                                context.push(RouteNames.login);
                              } else {
                                context.go(RouteNames.profile);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );

                  // Добавляем BlocBuilder-анимированные виджеты
       
                  // Добавляем виджеты из state.widgets (без анимации — можешь обернуть их так же)
                  animatedChildren.addAll(
                    state.widgets.map((w) {
                      switch (w.type) {
                        case 'banner':
                          final bannerFromJson = banner.Banner.fromJson(w.data);
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.05),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              key: ValueKey(
                                w.data.hashCode,
                              ), // <-- ключ для переключения анимации
                              padding: const EdgeInsets.only(top: 12),
                              child: BannerWidget(
                                model: bannerFromJson,
                                subcategories: categories,
                              ),
                            ),
                          );
case 'product_list': {
  final hpl = banner.HorizontalList.fromJson(w.data);
  final filterType = hpl.filterType;
  final targetId   = hpl.targetId;
  final hplTitle   = hpl.title;
  final regionId   = context.read<AppStateCubit>().state!.regionId;
  final organizationId = context.read<AppStateCubit>().state!.workplaceId;
  LoadProducts event;
  switch (filterType) {
    case 'category':
      event = LoadProducts(
        organizationId: organizationId,
        categoryId: targetId,
        regionId: regionId,
      );
      break;
    case 'brand':
      event = LoadProducts(
        organizationId: organizationId,
        brandId: targetId,
        regionId: regionId,
      );
      break;
    case 'supplier':
      event = LoadProducts(
        organizationId: organizationId,
        supplierId: targetId,
        regionId: regionId,
      );
      break;
    default:
      return const SizedBox.shrink();
  }

  // Возвращаем единый виджет
  return AnimatedSize(
    duration: const Duration(milliseconds: 700),
    curve: Curves.easeInOut,
    child: BlocProvider(
      create: (_) => ProductBloc(repository: context.read())..add(event),
      child: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: Builder(
              key: ValueKey(state.runtimeType), // чтобы AnimatedSwitcher знал, когда ребёнок изменился
              builder: (_) {
                // if (state is ProductLoading) {
                //   return const Center(child: CircularProgressIndicator());
                // } else
                 if (state is ProductLoaded) {
                  return HorizontalProductList(
                    filterType: filterType,
                    filterId: targetId,
                    title: hplTitle,
                    products: state.products,
                    organizationId: organizationId,
                    categoriesMap: categories,
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          );
        },
      ),
    ),
  );
}

          
                        case 'bigProductCard':
                        
                        default:
                          return const SizedBox.shrink();
                      }
                    }),
                  );

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                    ) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.05),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: ListView(children: animatedChildren),
                  );
                } else if (state is HomeError) {
                  return Center(child: Text(AppLocalizations.of(context)!.error));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class MaktubAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MaktubAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final city = context.watch<AppStateCubit>().state?.cityName ?? 'Қала';
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),

        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: Gradients.primary,
                width: 0.7,
              ),
            ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Container(
              padding: const EdgeInsets.only(right: 10, left: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.white,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    'maktub',
                    style: const TextStyle(
                      fontFamily: 'AudreyScript',
                      fontSize: 60,
                      color: Gradients.primary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      final appState = context.read<AppStateCubit>().state;
                      final userRole = UserRole.values.firstWhere(
                        (e) => e.name == appState?.role,
                        orElse: () => UserRole.guest,
                      );
                      final hasAccess = PermissionManager.canAccess(
                        userRole,
                        'map',
                      );
                      if (hasAccess) {
                        context.push(
                          RouteNames.addressList,
                          extra: {
                            'workplaceId':
                                context
                                    .read<AppStateCubit>()
                                    .state!
                                    .workplaceId,
                          },
                        );
                      } else {
                        context.push(RouteNames.login); // Нет доступа — вход
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: Colors.blueGrey.withOpacity(0.4),
                          width: 0.5,
                        ),
                        gradient: LinearGradient(
                          colors: [
                            Gradients.primary,
                            Gradients.primary,
                            // Colors.white.withOpacity(0.05),
                            // Colors.white.withOpacity(0.05),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            city,
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
            
                          const SizedBox(width: 4),
                          Image.asset(
                            'assets/icons/location.png',
                            width: 24,
                            height: 24,
                          ),
                        ],
                      ),
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

  @override
  Size get preferredSize => const Size.fromHeight(90);
}

class GlassButton extends StatelessWidget {
  final String text;
  final Widget icon;
  final VoidCallback onTap;

  const GlassButton({
    required this.icon,
    required this.text,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
             decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 0.5,
              ),
            ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(
              width: 110,
              height: 80,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.blueGrey.withOpacity(0.3),
                  width: 0.5,
                ),
                color: Colors.white.withOpacity(0.9),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(height: 8),
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Gradients.primary,
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

