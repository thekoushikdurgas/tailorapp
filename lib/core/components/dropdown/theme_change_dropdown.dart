import 'package:tailorapp/core/init/cubit/radio_cubit.dart';
import 'package:tailorapp/core/init/cubit/theme_cubit.dart';
import 'package:tailorapp/core/constants/string/string_constants.dart';
import 'package:tailorapp/product/init/lang/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeChangeDropdown extends StatelessWidget {
  const ThemeChangeDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RadioCubit(),
      child: BlocBuilder<RadioCubit, String>(
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _systemRadio(state, context),
              _lightRadio(state, context),
              _darkRadio(state, context),
              _actions(context, state),
            ],
          );
        },
      ),
    );
  }

  ListTile _darkRadio(String state, BuildContext context) {
    return ListTile(
      leading: Radio(
        value: StringConstants.darkRadio,
        groupValue: state,
        onChanged: (value) {
          context.read<RadioCubit>().changeValue(value.toString());
        },
      ),
      title: Text(
        LocaleKeys.theme_dark,
        style: Theme.of(context).textTheme.titleMedium,
      ).tr(),
    );
  }

  ListTile _lightRadio(String state, BuildContext context) {
    return ListTile(
      leading: Radio(
        value: StringConstants.lightRadio,
        groupValue: state,
        onChanged: (value) {
          context.read<RadioCubit>().changeValue(value.toString());
        },
      ),
      title: Text(
        LocaleKeys.theme_light,
        style: Theme.of(context).textTheme.titleMedium,
      ).tr(),
    );
  }

  ListTile _systemRadio(String state, BuildContext context) {
    return ListTile(
      leading: Radio(
        value: StringConstants.sysRadio,
        groupValue: state,
        onChanged: (value) {
          context.read<RadioCubit>().changeValue(value.toString());
        },
      ),
      title: Text(
        LocaleKeys.theme_default,
        style: Theme.of(context).textTheme.titleMedium,
      ).tr(),
    );
  }

  Row _actions(BuildContext context, String state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [_cancelTextButton(context), _okTextButton(state, context)],
    );
  }

  TextButton _okTextButton(String state, BuildContext context) {
    return TextButton(
      onPressed: () {
        switch (state) {
          case StringConstants.lightRadio:
            BlocProvider.of<ThemeCubit>(context).makelight();
            Navigator.pop(context);
            break;
          case StringConstants.darkRadio:
            BlocProvider.of<ThemeCubit>(context).makeDark();
            Navigator.pop(context);
            break;
          default:
            BlocProvider.of<ThemeCubit>(context).makeSystem();
            Navigator.pop(context);
            break;
        }
      },
      child: Text(
        LocaleKeys.button_ok,
        style: Theme.of(context).textTheme.labelLarge,
      ).tr(),
    );
  }

  TextButton _cancelTextButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text(
        LocaleKeys.button_cancel,
        style: Theme.of(context).textTheme.labelLarge,
      ).tr(),
    );
  }
}
