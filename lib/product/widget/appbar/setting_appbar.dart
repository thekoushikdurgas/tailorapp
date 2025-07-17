import 'package:tailorapp/product/init/lang/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SettingAppbar extends StatelessWidget implements PreferredSizeWidget {
  const SettingAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        LocaleKeys.settingTitle.tr(),
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
