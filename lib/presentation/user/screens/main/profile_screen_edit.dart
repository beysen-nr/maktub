import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maktub/core/constants/constants.dart';
import 'package:maktub/core/l10n/app_localizations.dart';
import 'package:maktub/presentation/user/blocs/app_state_cubit.dart';
import 'package:go_router/go_router.dart';

class ProfileEditScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String phoneNumber = context.read<AppStateCubit>().state!.phone;

    
    final String fullName =context
        .read<AppStateCubit>()
        .state!
        .fullName;
    final String organizationName = context
        .read<AppStateCubit>()
        .state!
        .organizationName;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.only(top: 8),
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(3.1416),
                          child: Image.asset(
                            'assets/icons-system/arrow.png',
                            width: 25,
                            height: 25,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, right: 8),
                    child: Text(
                     AppLocalizations.of(context)!.myData,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
 Align(
  alignment: Alignment.centerLeft,
   child: Text(
    
    AppLocalizations.of(context)!.fullName,
     style: GoogleFonts.montserrat(
       fontSize: 18,
       fontWeight: FontWeight.bold,
       color: Gradients.primary,
     ),
   ),
 ),

  Align(
  alignment: Alignment.centerLeft,
   child: Container(
    width: double.infinity,
    height: 40,
    // decoration: BoxDecoration(
    //   color: Gradients.primary,
    //   border: Border.all(color: Gradients.primary,)
    //   ,
    //   borderRadius: BorderRadius.circular(16)
    // ),
     child: Align(
      alignment: Alignment.centerLeft,
       child: Padding(
         padding: const EdgeInsets.all(8.0),
         child: Text(
          
          
           fullName,
           style: GoogleFonts.montserrat(
             fontSize: 18,
             fontWeight: FontWeight.bold,
             color: const Color(0xFF333333),
           ),
         ),
       ),
     ),
   ),
 ),

 Align(
  alignment: Alignment.centerLeft,
   child: Text(
    
   AppLocalizations.of(context)!.privateEntrepreneurship,
     style: GoogleFonts.montserrat(
       fontSize: 18,
       fontWeight: FontWeight.bold,
       color: Gradients.primary,
     ),
   ),
 ),

  Align(
  alignment: Alignment.centerLeft,
   child: Container(
    width: double.infinity,
    height: 40,
    // decoration: BoxDecoration(
    //   color: Gradients.primary,
    //   border: Border.all(color: Gradients.primary,)
    //   ,
    //   borderRadius: BorderRadius.circular(16)
    // ),
     child: Align(
      alignment: Alignment.centerLeft,
       child: Padding(
         padding: const EdgeInsets.all(8.0),
         child: Text(
          
          
           organizationName,
           style: GoogleFonts.montserrat(
             fontSize: 18,
             fontWeight: FontWeight.bold,
             color: const Color(0xFF333333),
           ),
         ),
       ),
     ),
   ),
 ),
                

 Align(
  alignment: Alignment.centerLeft,
   child: Text(
    
      AppLocalizations.of(context)!.phoneNumber,
     style: GoogleFonts.montserrat(
       fontSize: 18,
       fontWeight: FontWeight.bold,
       color: Gradients.primary,
     ),
   ),
 ),

  Align(
  alignment: Alignment.centerLeft,
   child: Container(
    width: double.infinity,
    height: 40,
    // decoration: BoxDecoration(
    //   color: Gradients.primary,
    //   border: Border.all(color: Gradients.primary,)
    //   ,
    //   borderRadius: BorderRadius.circular(16)
    // ),
     child: Align(
      alignment: Alignment.centerLeft,
       child: Padding(
         padding: const EdgeInsets.all(8.0),
         child: Text(
          
          
           phoneNumber,
           style: GoogleFonts.montserrat(
             fontSize: 18,
             fontWeight: FontWeight.bold,
             color: const Color(0xFF333333),
           ),
         ),
       ),
     ),
   ),
 ),
        
            ],
          ),
        ),
      ),
    );
  }
}
