
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:maktub/core/l10n/app_localizations.dart';
import 'package:maktub/presentation/user/blocs/product/product_bloc.dart';
import 'package:maktub/presentation/user/screens/auth/register_screen.dart';

import 'package:provider/provider.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maktub/core/router/router.dart';
import 'package:maktub/data/mock_repos/ad_repo.dart';
import 'package:maktub/data/mock_repos/auth_repo.dart';
import 'package:maktub/data/mock_repos/cart_repo.dart';
import 'package:maktub/data/mock_repos/product_repo.dart';
import 'package:maktub/data/services/supabase/supabase_service.dart';
import 'package:maktub/presentation/blocs/auth/auth_bloc.dart';
import 'package:maktub/presentation/blocs/register/register_bloc.dart';
import 'package:maktub/presentation/user/blocs/ad/ad_bloc.dart';
import 'package:maktub/presentation/user/blocs/app_state_cubit.dart';
import 'package:maktub/presentation/user/blocs/cart/cart_bloc.dart';
import 'package:maktub/presentation/user/blocs/home/home_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maktub/config/supabase_config.dart';
import 'package:maktub/data/services/dadata_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final AuthRepository authRepository = AuthRepository();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Делает фон строки состояния прозрачным
      statusBarIconBrightness: Brightness.dark, // Для Android: иконки будут темными
      statusBarBrightness: Brightness.light,    // Для iOS: текст и иконки будут темными (для светлого фона)
      // Если у вас есть нижняя навигационная панель на Android:
      systemNavigationBarColor: Colors.white, // Цвет фона навигационной панели
      systemNavigationBarIconBrightness: Brightness.dark, // Цвет иконок навигационной панели
    ),
  );
    tz.initializeTimeZones();
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

    SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Прозрачный статусбар
      systemNavigationBarColor: Colors.white, // 👉 Белая нижняя панель
      systemNavigationBarIconBrightness: Brightness.dark, // Иконки тёмные
    ),
  );

    final prefs = await SharedPreferences.getInstance();
  final savedLocale = prefs.getString('locale') ?? 'ru';

  runApp( MaktubApp(Locale(savedLocale)));
}





class MaktubApp extends StatefulWidget {
    final Locale initialLocale;
  const MaktubApp(this.initialLocale, {super.key});

    static void setLocale(BuildContext context, Locale locale) {
    _MaktubAppState? state = context.findAncestorStateOfType<_MaktubAppState>();
    state?.setLocale(locale);
  }

  @override
  State<MaktubApp> createState() => _MaktubAppState();
}

class _MaktubAppState extends State<MaktubApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
    
  }
  
    void setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
    setState(() => _locale = locale);
  }

@override
Widget build(BuildContext context) {

  final registerBloc = RegisterBloc(
  repo: authRepository,
  dadataService: DadataService(),
  supabase: SupabaseService.client,
);

DeepLinkHandler.init(registerBloc);

  return MultiProvider(
    providers: [
      Provider<ProductRepository>(
        create: (_) => ProductRepository(supabase: SupabaseService.client),
      ),

      BlocProvider(
        create: (_) => registerBloc
      ),
      BlocProvider(
        create: (_) => AuthBloc(
          repo: authRepository,
          supabase: SupabaseService.client,
        ),
      ),
      BlocProvider(
        create: (_) => AdBloc(AdRepository()),
      ),
      BlocProvider(
        create: (_) => CartBloc(
          pRepository: ProductRepository(supabase: SupabaseService.client),
          repository: CartRepository(supabase: SupabaseService.client),
        ),
      ),
      BlocProvider(create: (_) => AppStateCubit()),
      BlocProvider(create: (_) => HomeBloc()),
           BlocProvider(
        create: (context) => ProductBloc(
          repository: context.read<ProductRepository>(),
        ),
      ),
    ],
    child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
      locale: _locale,
      scrollBehavior: NoGlowScrollBehavior(),
      supportedLocales: const [Locale('kk'), Locale('ru')],
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
   
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(boldText: false),
          child: child!,
        );
      },
      theme: ThemeData(
        useMaterial3: false,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        cupertinoOverrideTheme: const CupertinoThemeData(
          primaryColor: Color(0xFF01bc41),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF01bc41),
          selectionColor: Color(0xFFd5f2d6),
          selectionHandleColor: Color(0xFF01bc41),
        ),
      ),
    ),
  );
}
}



class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child; // убираем синий overscroll эффект
  }
}
