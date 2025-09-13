// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maktub/config/aitu_pass_config.dart';
import 'package:maktub/core/constants/constants.dart';
import 'package:maktub/core/l10n/app_localizations.dart';
import 'package:maktub/core/router/route_names.dart';
import 'package:maktub/core/router/router.dart';
import 'package:maktub/core/utils/formatter.dart';
import 'package:maktub/data/services/aitu_passort_service.dart';
import 'package:maktub/presentation/blocs/auth/auth_bloc.dart';
import 'package:maktub/presentation/blocs/auth/auth_event.dart';
import 'package:maktub/presentation/blocs/register/register_bloc.dart';
import 'package:maktub/presentation/blocs/register/register_event.dart';
import 'package:maktub/presentation/blocs/register/register_state.dart';
import 'package:maktub/presentation/user/widgets/common/bottom_sheet_type_mismatch.dart';
import 'package:maktub/presentation/user/widgets/common/seller_bottom_sheet.dart';
import 'package:maktub/presentation/user/widgets/common/top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maktub/presentation/user/widgets/common/web_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final TextEditingController _iinController = TextEditingController();
  final TextEditingController _ownerController = TextEditingController();
  final TextEditingController _orgNameController = TextEditingController();

  String formattedIin = '';
  bool isButtonEnabled = false;
  bool isLoading = false;
  bool hasError = false;
  bool isValid = false;
  String? lastQueriedIin;
  String? lastQueriedAcceptedIin;
String? savedIin;
String? savedOwner;
String? savedOrg;
  


  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
    savedIin = prefs.getString('iin');
    savedOwner = prefs.getString('owner');
    savedOrg = prefs.getString('org');

    // Optionally: заполнить контроллеры
    if (savedIin != null) {
      _iinController.text = savedIin!;
    }
    if (savedOwner != null) {
      _ownerController.text = savedOwner!;
    }
    if (savedOrg != null) {
      _orgNameController.text = savedOrg!;
    }
  });

   _iinController.addListener(() {
      final digitsOnly = _iinController.text.replaceAll(RegExp(r'\D'), '');
      // if(digitsOnly==lastQueriedIin)  return;
      if (digitsOnly.length < 12) {
        setState(() {
          isButtonEnabled = false;
        });
      }
      if (digitsOnly.length == 12 && digitsOnly == lastQueriedAcceptedIin) {
        setState(() {
          isButtonEnabled = true;
        });
      }
      if (digitsOnly == lastQueriedIin) return;

      if (digitsOnly.length == 12 && digitsOnly != lastQueriedIin) {
        lastQueriedIin = digitsOnly;
        context.read<RegisterBloc>().add(RegisterCheckIin(digitsOnly));
      }
    });
  }

  @override
  void dispose() {
    _iinController.dispose();
    _ownerController.dispose();
    _orgNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    
    return MultiBlocListener(
      listeners: [
        BlocListener<RegisterBloc, RegisterState>(
          listener: (context, state) async {
            if (state is RegisterVerificationFailed) {
              showTopSnackbar(
                context: context,
                vsync: this,
                message: 'тіркелу сәтті болмады, қайталап көріңіз',
                isError: true,
                withLove: false,
              );
            }
            if (state is RegisterShowWebView) {
              final String iin = state.iin;
              final String stateUrl = state.name;
            final String scope = 'openid+phone+idpc_verification';
final provider = AituPassportConfig.url;
final iinSignature = AituPassportConfig.signAndEncode(iin);

final queryParams = {
  'response_type': 'code',
  'client_id': AituPassportConfig.clientId,
  'state': stateUrl,
  'redirect_uri': AituPassportConfig.redirectUrl,
  'scope': scope,
  'iin': iin,
  'locale': 'kz',
  'iin_signature': iinSignature,
};

final uriString = Uri(
  scheme: 'https',
  host: provider,
  path: '/oauth2/auth',
).toString();

final queryString = queryParams.entries.map((e) {
  final key = Uri.encodeQueryComponent(e.key);
  final value = (e.key == 'scope') ? e.value : Uri.encodeQueryComponent(e.value);
  return '$key=$value';
}).join('&');
final prefs = await SharedPreferences.getInstance();
await prefs.setString('iin', iin);
await prefs.setString('owner', _ownerController.text);
await prefs.setString('org', _orgNameController.text);

final oauthUrl = '$uriString?$queryString';
  launchUrl(Uri.parse(oauthUrl), mode: LaunchMode.externalApplication);

            }
            if (state is RegisterFailureAitu) {
              showTopSnackbar(context: context, vsync: this, message: 'жеке басын растау кезінде қате шықты, телеграм @maktubSupport жазыңыз', isError: true, withLove: false);
            } else if (state is RegisterNotIndividual) {
              _ownerController.text = state.owner;
              _orgNameController.text = state.name;
              setState(() {
                isButtonEnabled = false;
              });
              showBottomSheetTypeMismatch(context, state.name, state.bin);
            } else if (state is RegisterBusinessExists) {
              _ownerController.text = state.owner;
              _orgNameController.text = state.name;
              if (!mounted) return;
              showTopSnackbar(
                context: context,
                message: 'бұл ұйым maktub сервисінде тіркелген',
                isError: true,
                vsync: this,
                withLove: false,
              );
              setState(() {
                isButtonEnabled = false;
              });
            } else if (state is RegisterSuccess) {
              _orgNameController.text = state.name;
              _ownerController.text = state.owner;
              setState(() {
                isValid = true;
                isButtonEnabled = true;
                hasError = false;
              });
            } else if (state is RegisterVerificationSuccess) {
              if (!mounted) return;
              showTopSnackbar(
                context: context,
                vsync: this,
                message: "//${state.phone} сәтті тіркелді",
                isError: false,
                withLove: false,
              );
            } else if (state is RegisterPhoneNotFound &&
                !state.fromManualPhoneScreen) {
                    showTopSnackbar(
                context: context,
                vsync: this,
                message: 'Добро пожаловать в Maktub! \nВведите номер телефона, чтобы продолжить',
                isError: false,
                withLove: false,
              );
              context.read<RegisterBloc>().add(
                RegisterOrganization(
                  ownerName: _ownerController.text,
                  organizationId: _iinController.text.replaceAll(
                    RegExp(r'\D'),
                    '',
                  ),
                  name: _orgNameController.text,
                  phoneNumber: state.phone,
                ),
              );
            } else if (state is RegisterPhoneExists &&
                !state.fromManualPhoneScreen) {
      

              final text =
                savedOwner; // "Beisen Adilov" или "Beisen Nur Adilov"
              final words = text?.split(' ');
              final name = words?[1].toLowerCase();
              context.push(
                RouteNames.registerPhone,
                extra: {
                  'fullName': name,
                  'ownerName': savedOwner,
                  'roleId': 1,
                  'workplaceId': savedIin,
                  'workplaceName': savedOrg,
                },
              );
            } else if (state is OrganizationRegisterSuccess &&
                !state.fromManualPhoneScreen) {
              if (!mounted) return;
      
              await Future.delayed(Duration(seconds: 1));
              final text =
                  _ownerController.text
                      .trim(); // "Beisen Adilov" или "Beisen Nur Adilov"
              final words = text.split(' ');
              final name = words[1].toLowerCase();

          
              context.read<RegisterBloc>().add(
                RegisterUser(
                  phone: state.phone,
                  workplaceId: state.organizationId,
                  roleId: 1,
                  fullName: name,
                  regionId: 1,
                ),
              );
            } else if (state is RegisterUserSuccess &&
                !state.fromManualPhoneScreen) {
           final prefs = await SharedPreferences.getInstance();
prefs.remove('iin');
prefs.remove('owner');
prefs.remove('org');
isButtonEnabled = false;
            } else if (state is RegisterFailure) {
              if (!mounted) return;
              showTopSnackbar(
                context: context,
                vsync: this,
                message: AppLocalizations.of(context)!.enterTheIINCorrectly,
                isError: true,
                withLove: false,
              );
              _ownerController.text =AppLocalizations.of(context)!.ownerNotIdentified;
              _orgNameController.text = AppLocalizations.of(context)!.iPNotDefined;
              setState(() {
                isValid = false;
                isButtonEnabled = false;
                hasError = true;
              });
            }

            setState(() {
              isLoading = state is RegisterLoading;
            });
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () => context.pop(),
                  ),
                ),

                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    AppLocalizations.of(context)!.entryIIN,
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.weUseYourIIN,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,

                        // height: 1.4,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                TextField(
                  controller: _iinController,
                  keyboardType: TextInputType.number,
                  style: mainText,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.entryIIN,
                    hintStyle: hint,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Gradients.borderGray),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Colors.green,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Gradients.primary),
                    ),
                  ),
                  inputFormatters: [IinInputFormatter()],
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _ownerController,
                  enabled: false,
                  style: mainText,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.owner,
                    hintStyle: hint,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color:
                            hasError
                                ? Gradients.error
                                : isValid
                                ? Gradients.primary
                                : Gradients.borderGray,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _orgNameController,
                  enabled: false,
                  style: mainText,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.businessName,
                    hintStyle: hint,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color:
                            hasError
                                ? Colors.red
                                : isValid
                                ? Gradients.primary
                                : Gradients.borderGray,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed:
                      (isButtonEnabled && !isLoading)
                          ? () {
                            final text = _ownerController.text;
                            final words = text.split(' ');
                            final secondWord = words.length > 1 ? words[1] : '';

                            context.read<RegisterBloc>().add(
                              RegisterVerifyOwner(
                                _iinController.text.replaceAll(
                    RegExp(r'\D'),
                    '',
                  ),
                                transliterateKazakh(secondWord),
                              ),
                            );
                          }
                          : null,
                  style: ButtonStyle(
                    elevation: WidgetStateProperty.all(0),
                    backgroundColor: WidgetStateProperty.all(
                      isButtonEnabled && !isLoading
                          ? Gradients.primary
                          : const Color(0xFFd4f2d6),
                    ),
                    minimumSize: WidgetStateProperty.all(
                      const Size(double.infinity, 50),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                  ),
                  child:
                      isLoading
                          ? SizedBox(
                            height: 20,
                            width: 20,
                            child: LoadingAnimationWidget.waveDots(
                              color: Colors.white,
                              size: 25,
                            ),
                          )
                          : Text(
                            AppLocalizations.of(context)!.continueB,
                            style: GoogleFonts.montserrat(
                              color:
                                  isButtonEnabled
                                      ? Colors.white
                                      : const Color(0xFFa9e4ac),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
           
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => showSupplierBottomSheet(context),
                  child: Text(
                    AppLocalizations.of(context)!.areYouSupplier,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Gradients.primary,
                      decoration: TextDecoration.underline,
                      decorationColor: Gradients.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String transliterateKazakh(String text) {
    final Map<String, String> map = {
      'а': 'a',
      'ә': 'a',
      'б': 'b',
      'в': 'v',
      'г': 'g',
      'ғ': 'g',
      'д': 'd',
      'е': 'e',
      'ё': 'yo',
      'ж': 'zh',
      'з': 'z',
      'и': 'i',
      'й': 'y',
      'к': 'k',
      'қ': 'q',
      'л': 'l',
      'м': 'm',
      'н': 'n',
      'ң': 'ng',
      'о': 'o',
      'ө': 'o',
      'п': 'p',
      'р': 'r',
      'с': 's',
      'т': 't',
      'у': 'u',
      'ұ': 'u',
      'ү': 'u',
      'ф': 'f',
      'х': 'h',
      'һ': 'h',
      'ц': 'ts',
      'ч': 'ch',
      'ш': 'sh',
      'щ': 'shch',
      'ъ': '',
      'ы': 'y',
      'і': 'i',
      'ь': '',
      'э': 'e',
      'ю': 'yu',
      'я': 'ya',

      'А': 'A',
      'Ә': 'A',
      'Б': 'B',
      'В': 'V',
      'Г': 'G',
      'Ғ': 'G',
      'Д': 'D',
      'Е': 'E',
      'Ё': 'Yo',
      'Ж': 'Zh',
      'З': 'Z',
      'И': 'I',
      'Й': 'Y',
      'К': 'K',
      'Қ': 'Q',
      'Л': 'L',
      'М': 'M',
      'Н': 'N',
      'Ң': 'Ng',
      'О': 'O',
      'Ө': 'O',
      'П': 'P',
      'Р': 'R',
      'С': 'S',
      'Т': 'T',
      'У': 'U',
      'Ұ': 'U',
      'Ү': 'U',
      'Ф': 'F',
      'Х': 'H',
      'Һ': 'H',
      'Ц': 'Ts',
      'Ч': 'Ch',
      'Ш': 'Sh',
      'Щ': 'Shch',
      'Ъ': '',
      'Ы': 'Y',
      'І': 'I',
      'Ь': '',
      'Э': 'E',
      'Ю': 'Yu',
      'Я': 'Ya',
    };

    return text.split('').map((char) => map[char] ?? char).join();
  }
  
   Map extractDataIdToken(String idToken) {
    final parts = idToken.split('.');
    if (parts.length != 3) {
      throw Exception('Неверный JWT токен');
    }

    final payload = _decodeBase64(parts[1]);

    final payloadMap = json.decode(payload);

    return payloadMap;
  }
  
  String extractPhoneFromData(Map map) {
    return map['phone'] as String;
  }


}

  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Неверная длина base64 строки');
    }
    return utf8.decode(base64Url.decode(output));
  }


class DeepLinkHandler {
  static StreamSubscription<Uri>? _sub;

  static void init(RegisterBloc bloc){
    final appLinks = AppLinks();
    _sub = appLinks.uriLinkStream.listen((uri) async {
      if (uri.host != 'callback') return;


      if (uri.queryParameters.containsKey('error')) {
        bloc.add(RegisterFailureEvent(uri.queryParameters['error']!));
        return;
      }

      if (uri.queryParameters.containsKey('code')) {
        final code = uri.queryParameters['code']!;
        final response = await http.post(
          Uri.parse('https://zmnbmhkgdhijswyggghx.supabase.co/functions/v1/smart-responder'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'code': code}),
        );





        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
                  final String idToken = data['id_token'];



                  var map = extractDataIdToken(idToken);

                  String phone = extractPhoneFromData(map).substring(1);

        GoRouter.of(rootNavigatorKey.currentContext!).push(
  RouteNames.register,
  extra: phone,
);

          bloc.add(RegisterCheckPhoneExists(phone));
        } else {
          bloc.add(RegisterFailureEvent('Ошибка авторизации'));
        }
      }
    });
  }

  static void dispose() {
    _sub?.cancel();
  }

  static String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Неверная длина base64 строки');
    }
    return utf8.decode(base64Url.decode(output));
  }
  
 static String extractPhoneFromData(Map map) {
    return map['phone'] as String;
  }

  static Map extractDataIdToken(String idToken) {
    final parts = idToken.split('.');
    if (parts.length != 3) {
      throw Exception('Неверный JWT токен');
    }

    final payload = _decodeBase64(parts[1]);

    final payloadMap = json.decode(payload);

    return payloadMap;
  }

}
