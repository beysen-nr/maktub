import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:maktub/core/router/route_names.dart';
import 'package:maktub/data/mock_repos/ad_repo.dart';
import 'package:maktub/data/mock_repos/address_repo.dart';
import 'package:maktub/data/mock_repos/employee_repo.dart';
import 'package:maktub/data/mock_repos/product_repo.dart';
import 'package:maktub/data/models/category.dart';
import 'package:maktub/data/models/order.dart';
import 'package:maktub/data/services/supabase/supabase_service.dart';
import 'package:maktub/domain/repositories/order_repo.dart';
import 'package:maktub/presentation/delivery/blocs/orders/orders_bloc.dart';
import 'package:maktub/presentation/delivery/screens/date_orders_screen.dart';
import 'package:maktub/presentation/delivery/screens/order_dates_screen.dart';
import 'package:maktub/presentation/delivery/screens/order_delivery_screen.dart';
import 'package:maktub/presentation/delivery/screens/profile_delivery_screen.dart';
import 'package:maktub/presentation/receiver/screens/order_receiver_screen.dart';
import 'package:maktub/presentation/receiver/screens/profile_receiver_screen.dart';
import 'package:maktub/presentation/receiver/widgets/receiver_scaffold.dart';
import 'package:maktub/presentation/user/blocs/ad/ad_bloc.dart';
import 'package:maktub/presentation/user/blocs/ad/ad_event.dart';
import 'package:maktub/presentation/user/blocs/address/address_bloc.dart';
import 'package:maktub/presentation/user/blocs/address/address_event.dart';
import 'package:maktub/presentation/user/blocs/app_state_cubit.dart';
import 'package:maktub/presentation/user/blocs/employee/employee_bloc.dart';
import 'package:maktub/presentation/user/blocs/employee/employee_event.dart';
import 'package:maktub/presentation/user/blocs/order/order_bloc.dart';
import 'package:maktub/presentation/user/blocs/product/product_bloc.dart';
import 'package:maktub/presentation/user/screens/address/address_details_screen.dart';
import 'package:maktub/presentation/user/screens/address/address_screen.dart';
import 'package:maktub/presentation/user/screens/cart/cart_screen.dart';
import 'package:maktub/presentation/user/screens/cart/order_details_screen.dart';
import 'package:maktub/presentation/user/screens/cart/order_screen.dart';
import 'package:maktub/presentation/user/screens/main/employee_list_screen.dart';
import 'package:maktub/presentation/user/screens/main/employee_screen.dart';
import 'package:maktub/presentation/user/screens/main/profile_screen.dart';
import 'package:maktub/presentation/user/screens/product/catalog_screen.dart';
import 'package:maktub/presentation/user/screens/main/home_screen.dart';
import 'package:maktub/presentation/user/screens/auth/login_screen.dart';
import 'package:maktub/presentation/user/screens/address/map_screen.dart';
import 'package:maktub/presentation/user/screens/main/profile_screen_edit.dart';
import 'package:maktub/presentation/user/screens/auth/register_phone_screen.dart';
import 'package:maktub/presentation/user/screens/auth/register_screen.dart';
import 'package:maktub/presentation/user/screens/main/splash_screen.dart';
import 'package:maktub/presentation/user/screens/product/product_list_screen.dart';
import 'package:maktub/presentation/user/widgets/user_scaffold.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final shellNavigatorKey = GlobalKey<NavigatorState>();
final _catalogNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: RouteNames.splash,

  routes: [
    
    GoRoute(
      path: RouteNames.order,
      builder: (context, state) =>  OrderScreen(),
    ),

    


GoRoute(
  path: RouteNames.employee,
  builder: (context, state) {
    return BlocProvider(
      create: (_) => EmployeeBloc(EmployeeRepository()),
      child: const RegisterEmployeeScreen(),
    );
  },
),
    GoRoute(
      path: RouteNames.orderDetails,
      builder: (context, state) {
        final map = state.extra! as Map;
        final order = map['order'] as Order;
        final bloc = map['bloc'] as OrderBloc;

        return BlocProvider.value(
          value: bloc,
          child: OrderDetailsScreen(order: order),
        );
      },
    ),

    GoRoute(
      path: RouteNames.orderDeliveryDetails,
      builder: (context, state) {
        final map = state.extra! as Map;
        final order = map['order'] as Order;
        final bloc = map['bloc'] as DeliveryOrdersBloc;
        final day = map['day'] as DateTime;
        return BlocProvider.value(
          value: bloc,
          child: OrderDetailsDeliveryScreen(order: order, day: day,),
        );
      },
    ),

    

    GoRoute(
      path: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      
      path: RouteNames.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: RouteNames.registerPhone,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return RegisterPhoneScreen(data: data);
      },
    ),
    GoRoute(
      path: RouteNames.map,
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) {
              final bloc = AddressBloc(AddressRepository());
              bloc.add(LoadRegions());
              return bloc;
            },
          ),
        ],
        child: MapScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.addressDetails,
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>;
        final addressSuggestion = extras['address'] as AddressSuggestion;
        final addressBloc = extras['bloc'] as AddressBloc;

        return BlocProvider.value(
          value: addressBloc,
          child: AddressDetailsScreen(context: context, address: addressSuggestion),
        );
      },
    ),

      GoRoute(
      path: RouteNames.employeeList,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final workplaceId = extra['workplaceId'] as int;

        return BlocProvider(
          create: (_) {
            final bloc = EmployeeBloc(EmployeeRepository());
            bloc.add(LoadEmployeees(workplaceId));
            return bloc;
          },
          child: const EmployeeListScreen(),
        );
      },
    ),


    GoRoute(
      path: RouteNames.addressList,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final workplaceId = extra['workplaceId'] as int;

        return BlocProvider(
          create: (_) {
            final bloc = AddressBloc(AddressRepository());
            bloc.add(LoadAddresses(workplaceId));
            return bloc;
          },
          child: const AddressScreen(),
        );
      },
    ),

    GoRoute(
  path: RouteNames.dayOrders,
  builder: (context, state) {
    final day = state.extra as DateTime;
    return DeliveryOrdersScreen(day: day);
  },
),


    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ReceiverScaffold(navigationShell: navigationShell);
      },
      branches: [
    
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.deliveryOrder,
              builder: (context, state) => BlocProvider(
                create: (context) =>
                    OrderBloc(OrderRepository(client: SupabaseService.client)),
                child: DeliveryDaysScreen(),
              ),
              routes: [
              
              ],
            ),
          ],
        ),
    
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.deliverProfile,
              builder: (context, state) => const ProfileDeliverScreen(),
              routes: [
                // GoRoute(
                //   name: RouteNames.profileEdit,
                //   path: '/edit',
                //   builder: (context, state) => const ProfileEditScreen(),
                // ),
              ],
            ),
          ],
        ),
      ],
    ),
  

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ReceiverScaffold(navigationShell: navigationShell);
      },
      branches: [
    
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.receiverOrder,
              builder: (context, state) => BlocProvider(
                create: (context) =>
                    OrderBloc(OrderRepository(client: SupabaseService.client)),
                child: OrderReceiverScreen(),
              ),
              routes: [
              
              ],
            ),
          ],
        ),
    
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.receiverProfile,
              builder: (context, state) => const ProfileReceiverScreen(),
              routes: [
                // GoRoute(
                //   name: RouteNames.profileEdit,
                //   path: '/edit',
                //   builder: (context, state) => const ProfileEditScreen(),
                // ),
              ],
            ),
          ],
        ),
      ],
    ),
  
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return UserScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.home,
              builder: (context, state) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (_) => AdBloc(AdRepository())
                      ..add(
                        LoadCarousel(
                          context.read<AppStateCubit>().state!.regionId,
                        ),
                      ),
                  ),
                ],
                child: HomeScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _catalogNavigatorKey,
          routes: [
            GoRoute(
              path: RouteNames.catalog,
              builder: (context, state) => BlocProvider(
                create: (context) =>
                    ProductBloc(repository: context.read<ProductRepository>()),
                child: CatalogScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'product-list',
                  name: 'productList',
                  pageBuilder: (context, state) {
                    final extra = state.extra! as Map<String, dynamic>;
                    return MaterialPage(
                      key: UniqueKey(),
                      child: ProductListScreen(
                        categoryId: extra['categoryId'] as int?,
                        subcategories: extra['subcategories'] as List<Category>,
                        title: extra['title'] as String,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.cart,
              builder: (context, state) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (_) {
                      final bloc = AddressBloc(AddressRepository());
                      bloc.add(LoadRegions());
                      return bloc;
                    },
                  ),
                ],
                child: CartScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.profile,
              builder: (context, state) => const ProfileScreen(),
              routes: [
                GoRoute(
                  name: RouteNames.profileEdit,
                  path: '/edit',
                  builder: (context, state) =>  ProfileEditScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  
  ],
);
