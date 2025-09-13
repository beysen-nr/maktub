import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maktub/core/constants/constants.dart';
import 'package:maktub/core/l10n/app_localizations.dart';
import 'package:maktub/presentation/user/widgets/common/seller_bottom_sheet.dart';
import 'package:maktub/presentation/user/widgets/common/web_view.dart';

void showBottomSheetTypeMismatch(
  BuildContext context,
  String bin,
  String name,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SafeArea(
        child: Material(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
    AppLocalizations.of(context)!.organizationIsLegal,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                 ElevatedButton(
                  onPressed: () async {
                    await Future(() => context.pop()).then((_) {
                      showOrganizationBottomSheet(context, bin: bin, name: name);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Gradients.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                    splashFactory: NoSplash.splashFactory,
                    elevation: 0,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.customer,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
           
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    await Future(() => context.pop()).then((_) {
                      showSupplierBottomSheet(context, bin: bin, name: name);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Gradients.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                    splashFactory: NoSplash.splashFactory,
                    elevation: 0,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.supplierSale,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
           
              ],
            ),
          ),
        ),
      );
    },
  );
}

void showWebViewBottomSheet(BuildContext context, String url, String webTitle) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    
    backgroundColor: Colors.transparent,
    builder: (context) => WebViewBottomSheet(url: url,webTitle:  webTitle),
  );
}

