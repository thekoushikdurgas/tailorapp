import 'package:tailorapp/core/components/dots/dots_decoration.dart';
import 'package:tailorapp/core/components/text/text_with_theme_color.dart';
import 'package:tailorapp/core/init/cache/onboarding/intro_caching.dart';
import 'package:tailorapp/core/init/navigation/navigation_route.dart';
import 'package:tailorapp/product/init/lang/locale_keys.g.dart';
import 'package:tailorapp/view/_product/enum/route_enum.dart';
import 'package:tailorapp/view/introduction/view-model/intro_pages.dart';
import 'package:introduction_screen/introduction_screen.dart';

class Introduction {
  const Introduction._();
  static final intro = IntroductionScreen(
    pages: IntroPages.pageList,
    showSkipButton: true,
    showNextButton: false,
    skip: const TextLabelLargeTitle(text: LocaleKeys.buttonSkip),
    done: const TextLabelLargeTitle(text: LocaleKeys.buttonDone),
    onDone: () {
      IntroCaching.watchIntro();
      NavigationRoute.goRouteClear(RouteEnum.setting.rawValue);
    },
    dotsDecorator: DotsDecoration.decoration,
  );
}
