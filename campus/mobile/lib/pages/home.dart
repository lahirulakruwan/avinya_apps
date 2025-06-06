// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mobile/codeviewer/code_displayer.dart';
import 'package:mobile/constants.dart';
import 'package:mobile/data/campus_apps_portal.dart';
// import 'package:mobile/data/demos.dart';
import 'package:mobile/data/gallery_options.dart';
import 'package:mobile/data/person.dart';
import 'package:mobile/layout/adaptive.dart';
import 'package:mobile/layout/image_placeholder.dart';
import 'package:mobile/pages/my_alumni_dashboard.dart';
import 'package:mobile/screens/bottom_navigation/bottom_navigation/screens/navigation_menu.dart';
// import 'package:pcti_notes/routes.dart' as campus_pcti_routes;
// import 'package:pcti_notes_admin/routes.dart' as campus_pcti_admin;
// import 'package:asset_admin/routes.dart' as asset_admin_routes;
// import 'package:pcti_notes/routes.dart' as campus_pcti_routes;
// import 'package:pcti_notes_admin/routes.dart' as campus_pcti_admin;
// import 'package:pcti_feedback/routes.dart' as feedback_routes;
// import 'package:consumable/routes.dart' as consumable_routes;

const _horizontalPadding = 32.0;
const _carouselItemMargin = 8.0;
const _horizontalDesktopPadding = 81.0;
const _carouselHeightMin = 200.0 + 2 * _carouselItemMargin;
const _desktopCardsPerPage = 4;
const String attendanceRoute = '/attendance_marker';
const String alumniHomeRoute = '/alumni_home';

class ToggleSplashNotification extends Notification {}

Map<String, GalleryDemo> studies() {
  return <String, GalleryDemo>{
    'attendanceApp': const GalleryDemo(
      title: "Attendance App",
      subtitle: "Attendance App for the Students",
      category: GalleryDemoCategory.study,
      studyId: 'starter',
    ),
    'alumni': GalleryDemo(
        title: "Alumni",
        subtitle: "Alumni App for the Users",
        category: GalleryDemoCategory.study,
        studyId: 'starter',
      ),
  };
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // var carouselHeight = _carouselHeight(.7, context);
    final isDesktop = isDisplayDesktop(context);
    final isTab = isDisplayTab(context);
    final studyDemos = studies();
    final carouselCards = <Widget>[
      if (campusAppsPortalInstance.getUserPerson().is_graduated != null &&
          !campusAppsPortalInstance.getUserPerson().is_graduated!)
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: _CarouselCard(
            demo: studyDemos['attendanceApp'],
            asset: const AssetImage(
              'assets/images/attendance_.png',
              //package: 'flutter_gallery_assets',
            ),
            assetColor: const Color(0xFFFFFFFF),
            // assetDark: const AssetImage(
            //   'assets/studies/shrine_card_dark.png',
            //   package: 'flutter_gallery_assets',
            // ),
            //assetDarkColor: const Color(0xFF543B3C),
            textColor: Colors.black,
            studyRoute: attendanceRoute,
          ),
        ),
    Padding(
        padding: const EdgeInsets.all(10.0),
        child: _CarouselCard(
          demo: studyDemos['alumni'],
          asset: const AssetImage(
            'assets/images/consumable.png',
            // package: 'flutter_gallery_assets',
          ),
          assetColor: const Color(0xFFFFFFFF),
          // assetDark: const AssetImage(
          //   'assets/studies/rally_card_dark.png',
          //   package: 'flutter_gallery_assets',
          // ),
          //assetDarkColor: const Color(0xFF253538),
          textColor: Colors.black,
          studyRoute: alumniHomeRoute,
        ),
      ),
      //2023-04-19 commented for prod and stag branches
      // Padding(
      //   padding: const EdgeInsets.all(10.0),
      //   child: _CarouselCard(
      //     //2023-03-09 lahiru added for campus_pcti
      //     demo: studyDemos['campuspctiApp'],
      //     asset: const AssetImage(
      //       'assets/images/pcti_notes.png',
      //       // package: 'flutter_gallery_assets',
      //     ),
      //     assetColor: const Color(0xFFFFFFFF),
      //     // assetDark: const AssetImage(
      //     //   'assets/studies/rally_card_dark.png',
      //     //   package: 'flutter_gallery_assets',
      //     // ),
      //     //assetDarkColor: const Color(0xFF253538),
      //     textColor: Colors.black,
      //     studyRoute: campus_pcti_routes.campuspctiRoute,
      //   ),
      // ),
      // Padding(
      //   padding: const EdgeInsets.all(10.0),
      //   child: _CarouselCard(
      //     //2023-03-09 lahiru added for campus_pcti_admin
      //     demo: studyDemos['campuspctiadminApp'],
      //     asset: const AssetImage(
      //       'assets/images/pcti_admin.png',
      //       // package: 'flutter_gallery_assets',
      //     ),
      //     assetColor: const Color(0xFFFFFFFF),
      //     // assetDark: const AssetImage(
      //     //   'assets/studies/shrine_card_dark.png',
      //     //   package: 'flutter_gallery_assets',
      //     // ),
      //     // assetDarkColor: const Color(0xFF543B3C),
      //     textColor: Colors.black,
      //     studyRoute: campus_pcti_admin.campuspctiadminRoute,
      //   ),
      // ),
      // Padding(
      //   padding: const EdgeInsets.all(10.0),
      //   child: _CarouselCard(
      //     //2023-03-09 lahiru added for campus_pcti_admin
      //     demo: studyDemos['feedbackApp'],
      //     asset: const AssetImage(
      //       'assets/images/feedback.png',
      //       // package: 'flutter_gallery_assets',
      //     ),
      //     assetColor: const Color(0xFFFFFFFF),
      //     // assetDark: const AssetImage(
      //     //   'assets/studies/rally_card_dark.png',
      //     //   package: 'flutter_gallery_assets',
      //     // ),
      //     // assetDarkColor: const Color(0xFF543B3C),
      //     textColor: Colors.black,
      //     studyRoute: feedback_routes.feedbackRoute,
      //   ),
      // ),
      // Padding(
      //   padding: const EdgeInsets.all(10.0),
      //   child: _CarouselCard(
      //     demo: studyDemos['assetApp'],
      //     asset: const AssetImage(
      //       'assets/images/asset.png',
      //       // package: 'flutter_gallery_assets',
      //     ),
      //     assetColor: const Color(0xFFFFFFFF),
      //     // assetDark: const AssetImage(
      //     //   'assets/studies/shrine_card_dark.png',
      //     //   package: 'flutter_gallery_assets',
      //     // ),
      //     //assetDarkColor: const Color(0xFF543B3C),
      //     textColor: Colors.black,
      //     studyRoute: asset_routes.assetRoute,
      //   ),
      // ),
      // if (campusAppsPortalInstance.isTeacher || campusAppsPortalInstance.isFoundation)
      // Padding(
      //   padding: const EdgeInsets.all(10.0),
      //   child: _CarouselCard(
      //     demo: studyDemos['assetadminApp'],
      //     asset: const AssetImage(
      //       'assets/images/pcti_admin.png',
      //       // package: 'flutter_gallery_assets',
      //     ),
      //     assetColor: const Color(0xFFFFFFFF),
      //     // assetDark: const AssetImage(
      //     //   'assets/studies/shrine_card_dark.png',
      //     //   package: 'flutter_gallery_assets',
      //     // ),
      //     //assetDarkColor: const Color(0xFF543B3C),
      //     textColor: Colors.black,
      //     studyRoute: asset_admin_routes.assetadminRoute,
      //   ),
      // ),
      //2023-04-19 commented for prod and stag branches
      // Padding(
      //   padding: const EdgeInsets.all(10.0),
      //   child: _CarouselCard(
      //     demo: studyDemos['consumableApp'],
      //     asset: const AssetImage(
      //       'assets/images/consumable.png',
      //       // package: 'flutter_gallery_assets',
      //     ),
      //     assetColor: const Color(0xFFFFFFFF),
      //     // assetDark: const AssetImage(
      //     //   'assets/studies/shrine_card_dark.png',
      //     //   package: 'flutter_gallery_assets',
      //     // ),
      //     // assetDarkColor: const Color(0xFF543B3C),
      //     //textColor: shrineBrown900,
      //     textColor: Colors.black,
      //     studyRoute: consumable_routes.consumableRoute,
      //   ),
      // ),
    ];

    if (isDesktop) {
      // uncomment this if you want to use the animated home page
      // return Scaffold(
      //   body: ListView(
      //     // Makes integration tests possible.
      //     key: const ValueKey('HomeListView'),
      //     primary: true,
      //     padding: const EdgeInsetsDirectional.only(
      //       top: firstHeaderDesktopTopPadding,
      //     ),
      //     children: [
      //       _DesktopCarousel(height: carouselHeight, children: carouselCards),
      //       const SizedBox(height: 109),
      //     ],
      //   ),
      // );
      return Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 70.0, horizontal: 70.0),
          child:
              // campusAppsPortalInstance.getUserPerson().is_graduated != null &&
              //         !campusAppsPortalInstance.getUserPerson().is_graduated!
              //     ? 
                  GridView.count(
                      crossAxisCount: 3,
                      childAspectRatio: 1.8,
                      children: carouselCards,
                    )
                  //: MyAlumniDashboardScreen(),
        ),
      );
    } else if (isTab) {
      return Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 50.0, horizontal: 20.0),
          child:
              // campusAppsPortalInstance.getUserPerson().is_graduated != null &&
              //         !campusAppsPortalInstance.getUserPerson().is_graduated!
              //     ? 
                  GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      children: carouselCards,
                    )
                  //: NavigationMenu(),
        ),
      );
    } else {
      // uncomment this if you want to use the animated home page
      // return Scaffold(
      //   body: _AnimatedHomePage(
      //     restorationId: 'animated_page',
      //     isSplashPageAnimationFinished:
      //         SplashPageAnimation.of(context)!.isFinished,
      //     carouselCards: carouselCards,
      //   ),
      // );
      return Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 50.0, horizontal: 20.0),
          child:
              // campusAppsPortalInstance.getUserPerson().is_graduated != null &&
              //         !campusAppsPortalInstance.getUserPerson().is_graduated!
              //     ?
                   GridView.count(
                      crossAxisCount: 1,
                      childAspectRatio: 1.5,
                      children: carouselCards,
                    )
                 // : NavigationMenu(),
        ),
      );
    }
  }

  List<Widget> spaceBetween(double paddingBetween, List<Widget> children) {
    return [
      for (int index = 0; index < children.length; index++) ...[
        Flexible(
          child: children[index],
        ),
        if (index < children.length - 1) SizedBox(width: paddingBetween),
      ],
    ];
  }
}

class _GalleryHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Header(
      color: Theme.of(context).colorScheme.primaryContainer,
      text: "Campus Apps Portal",
    );
  }
}

class Header extends StatelessWidget {
  const Header({super.key, required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: EdgeInsets.only(
          top: isDisplayDesktop(context) ? 63 : 15,
          bottom: isDisplayDesktop(context) ? 21 : 11,
        ),
        child: SelectableText(
          text,
          style: Theme.of(context).textTheme.headlineMedium!.apply(
                color: color,
                fontSizeDelta:
                    isDisplayDesktop(context) ? desktopDisplay1FontDelta : 0,
              ),
        ),
      ),
    );
  }
}

class _AnimatedHomePage extends StatefulWidget {
  const _AnimatedHomePage({
    required this.restorationId,
    required this.carouselCards,
    required this.isSplashPageAnimationFinished,
  });

  final String restorationId;
  final List<Widget> carouselCards;
  final bool isSplashPageAnimationFinished;

  @override
  _AnimatedHomePageState createState() => _AnimatedHomePageState();
}

class _AnimatedHomePageState extends State<_AnimatedHomePage>
    with RestorationMixin, SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Timer? _launchTimer;
  final RestorableBool _isMaterialListExpanded = RestorableBool(false);
  final RestorableBool _isCupertinoListExpanded = RestorableBool(false);
  final RestorableBool _isOtherListExpanded = RestorableBool(false);

  @override
  String get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_isMaterialListExpanded, 'material_list');
    registerForRestoration(_isCupertinoListExpanded, 'cupertino_list');
    registerForRestoration(_isOtherListExpanded, 'other_list');
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    if (widget.isSplashPageAnimationFinished) {
      // To avoid the animation from running when changing the window size from
      // desktop to mobile, we do not animate our widget if the
      // splash page animation is finished on initState.
      _animationController.value = 1.0;
    } else {
      // Start our animation halfway through the splash page animation.
      _launchTimer = Timer(
        const Duration(
          milliseconds: splashPageAnimationDurationInMilliseconds ~/ 2,
        ),
        () {
          _animationController.forward();
        },
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _launchTimer?.cancel();
    _launchTimer = null;
    _isMaterialListExpanded.dispose();
    _isCupertinoListExpanded.dispose();
    _isOtherListExpanded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          // Makes integration tests possible.
          key: const ValueKey('HomeListView'),
          primary: true,
          restorationId: 'home_list_view',
          children: [
            const SizedBox(height: 8),
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: _horizontalPadding),
              child: _GalleryHeader(),
            ),
            _Carousel(
              animationController: _animationController,
              restorationId: 'home_carousel',
              children: widget.carouselCards,
            ),
          ],
        ),
        Align(
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.velocity.pixelsPerSecond.dy > 200) {
                ToggleSplashNotification().dispatch(context);
              }
            },
            child: SafeArea(
              child: Container(
                height: 40,
                // If we don't set the color, gestures are not detected.
                color: Colors.transparent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Animates the category item to stagger in. The [_AnimatedCategoryItem.startDelayFraction]
/// gives a delay in the unit of a fraction of the whole animation duration,
/// which is defined in [_AnimatedHomePageState].
// Samisa - Delete later
// ignore: unused_element
class _AnimatedCategoryItem extends StatelessWidget {
  _AnimatedCategoryItem({
    required double startDelayFraction,
    required this.controller,
    required this.child,
  }) : topPaddingAnimation = Tween(
          begin: 60.0,
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.000 + startDelayFraction,
              0.400 + startDelayFraction,
              curve: Curves.ease,
            ),
          ),
        );

  final Widget child;
  final AnimationController controller;
  final Animation<double> topPaddingAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Padding(
          padding: EdgeInsets.only(top: topPaddingAnimation.value),
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Animates the carousel to come in from the right.
class _AnimatedCarousel extends StatelessWidget {
  _AnimatedCarousel({
    required this.child,
    required this.controller,
  }) : startPositionAnimation = Tween(
          begin: 1.0,
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(
              0.200,
              0.800,
              curve: Curves.ease,
            ),
          ),
        );

  final Widget child;
  final AnimationController controller;
  final Animation<double> startPositionAnimation;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          SizedBox(height: _carouselHeight(.4, context)),
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return PositionedDirectional(
                start: constraints.maxWidth * startPositionAnimation.value,
                child: child!,
              );
            },
            child: SizedBox(
              height: _carouselHeight(.4, context),
              width: constraints.maxWidth,
              child: child,
            ),
          ),
        ],
      );
    });
  }
}

/// Animates a carousel card to come in from the right.
class _AnimatedCarouselCard extends StatelessWidget {
  _AnimatedCarouselCard({
    required this.child,
    required this.controller,
  }) : startPaddingAnimation = Tween(
          begin: _horizontalPadding,
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(
              0.900,
              1.000,
              curve: Curves.ease,
            ),
          ),
        );

  final Widget child;
  final AnimationController controller;
  final Animation<double> startPaddingAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Padding(
          padding: EdgeInsetsDirectional.only(
            start: startPaddingAnimation.value,
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}

class _Carousel extends StatefulWidget {
  const _Carousel({
    required this.animationController,
    this.restorationId,
    required this.children,
  });

  final AnimationController animationController;
  final String? restorationId;
  final List<Widget> children;

  @override
  _CarouselState createState() => _CarouselState();
}

RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class _CarouselState extends State<_Carousel>
    with RestorationMixin, SingleTickerProviderStateMixin, RouteAware {
  PageController? _controller;

  final RestorableInt _currentPage = RestorableInt(0);

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_currentPage, 'carousel_page');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
    if (_controller == null) {
      // The viewPortFraction is calculated as the width of the device minus the
      // padding.
      final width = MediaQuery.of(context).size.width;
      const padding = (_horizontalPadding * 2) - (_carouselItemMargin * 2);
      _controller = PageController(
        initialPage: _currentPage.value,
        viewportFraction: (width - padding) / width,
      );
    }
  }

  @override
  void dispose() {
    _controller!.dispose();
    _currentPage.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    final route = ModalRoute.of(context)!.settings.name;
    _currentPage.dispose();
    setState(() {
      _currentPage.value = 0;
    });
    print('didPopNext route: $route');
  }

  // write a code to reset the state of the page
  @override
  void didPop() {
    final route = ModalRoute.of(context)!.settings.name;
    _currentPage.dispose();
    // setState(() {
    //   _currentPage.value = 0;
    // });
    print('didPop route: $route');
  }

  Widget builder(int index) {
    bool signedIn = campusAppsPortalInstance.getSignedIn();

    log('signedIn: $signedIn! with index: $index');
    print('signedIn: $signedIn! with index: $index');

    if (!signedIn && index > 1) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final carouselCard = AnimatedBuilder(
      animation: _controller!,
      builder: (context, child) {
        double value;
        if (_controller!.position.haveDimensions) {
          value = _controller!.page! - index;
        } else {
          // If haveDimensions is false, use _currentPage to calculate value.
          value = (_currentPage.value - index).toDouble();
        }
        // We want the peeking cards to be 160 in height and 0.38 helps
        // achieve that.
        value = (1 - (value.abs() * .38)).clamp(0, 1).toDouble();
        value = Curves.easeOut.transform(value);

        return Center(
          child: Transform(
            transform: Matrix4.diagonal3Values(1.0, value, 1.0),
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
      child: widget.children[index],
    );

    // We only want the second card to be animated.
    if (index == 1) {
      return _AnimatedCarouselCard(
        controller: widget.animationController,
        child: carouselCard,
      );
    } else {
      return carouselCard;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AnimatedCarousel(
      controller: widget.animationController,
      child: PageView.builder(
        // Makes integration tests possible.
        key: const ValueKey('studyDemoList'),
        onPageChanged: (value) {
          setState(() {
            _currentPage.value = value;
          });
        },
        controller: _controller,
        itemCount: widget.children.length,
        itemBuilder: (context, index) => builder(index),
        allowImplicitScrolling: true,
      ),
    );
  }
}

/// This creates a horizontally scrolling [ListView] of items.
///
/// This class uses a [ListView] with a custom [ScrollPhysics] to enable
/// snapping behavior. A [PageView] was considered but does not allow for
/// multiple pages visible without centering the first page.
class _DesktopCarousel extends StatefulWidget {
  const _DesktopCarousel({required this.height, required this.children});

  final double height;
  final List<Widget> children;

  @override
  _DesktopCarouselState createState() => _DesktopCarouselState();
}

class _DesktopCarouselState extends State<_DesktopCarousel> {
  static const cardPadding = 15.0;
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _builder(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: cardPadding,
      ),
      child: widget.children[index],
    );
  }

  @override
  Widget build(BuildContext context) {
    // uncomment this to show the previous and next buttons
    // var showPreviousButton = false;
    // var showNextButton = true;
    // // Only check this after the _controller has been attached to the ListView.
    // if (_controller.hasClients) {
    //   showPreviousButton = _controller.offset > 0;
    //   showNextButton =
    //       _controller.offset < _controller.position.maxScrollExtent;
    // }
    final totalWidth = MediaQuery.of(context).size.width -
        (_horizontalDesktopPadding - cardPadding) * 2;
    final itemWidth = totalWidth / _desktopCardsPerPage;

    return Align(
      alignment: Alignment.center,
      child: Container(
        height: widget.height,
        constraints: const BoxConstraints(maxWidth: maxHomeItemWidth),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _horizontalDesktopPadding - cardPadding,
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                primary: false,
                physics: const _SnappingScrollPhysics(),
                controller: _controller,
                itemExtent: itemWidth,
                itemCount: widget.children.length,
                itemBuilder: (context, index) => _builder(index),
              ),
            ),
            // if (showPreviousButton)
            //   _DesktopPageButton(
            //     onTap: () {
            //       _controller.animateTo(
            //         _controller.offset - itemWidth,
            //         duration: const Duration(milliseconds: 200),
            //         curve: Curves.easeInOut,
            //       );
            //     },
            //   ),
            // if (showNextButton)
            //   _DesktopPageButton(
            //     isEnd: true,
            //     onTap: () {
            //       _controller.animateTo(
            //         _controller.offset + itemWidth,
            //         duration: const Duration(milliseconds: 200),
            //         curve: Curves.easeInOut,
            //       );
            //     },
            //   ),
          ],
        ),
      ),
    );
  }
}

/// Scrolling physics that snaps to the new item in the [_DesktopCarousel].
class _SnappingScrollPhysics extends ScrollPhysics {
  const _SnappingScrollPhysics({super.parent});

  @override
  _SnappingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _SnappingScrollPhysics(parent: buildParent(ancestor));
  }

  double _getTargetPixels(
    ScrollMetrics position,
    Tolerance tolerance,
    double velocity,
  ) {
    final itemWidth = position.viewportDimension / _desktopCardsPerPage;
    var item = position.pixels / itemWidth;
    if (velocity < -tolerance.velocity) {
      item -= 0.5;
    } else if (velocity > tolerance.velocity) {
      item += 0.5;
    }
    return math.min(
      item.roundToDouble() * itemWidth,
      position.maxScrollExtent,
    );
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }

    // final tolerance = toleranceFor(position);
    final target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        target,
        velocity,
        tolerance: tolerance,
      );
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => true;
}
// uncomment this to show the page buttons
// class _DesktopPageButton extends StatelessWidget {
//   const _DesktopPageButton({
//     this.isEnd = false,
//     this.onTap,
//   });

//   final bool isEnd;
//   final GestureTapCallback? onTap;

//   @override
//   Widget build(BuildContext context) {
//     const buttonSize = 58.0;
//     const padding = _horizontalDesktopPadding - buttonSize / 2;
//     return ExcludeSemantics(
//       child: Align(
//         alignment: isEnd
//             ? AlignmentDirectional.centerEnd
//             : AlignmentDirectional.centerStart,
//         child: Container(
//           width: buttonSize,
//           height: buttonSize,
//           margin: EdgeInsetsDirectional.only(
//             start: isEnd ? 0 : padding,
//             end: isEnd ? padding : 0,
//           ),
//           child: Tooltip(
//             message: isEnd
//                 ? MaterialLocalizations.of(context).nextPageTooltip
//                 : MaterialLocalizations.of(context).previousPageTooltip,
//             child: Material(
//               color: Colors.black.withOpacity(0.5),
//               shape: const CircleBorder(),
//               clipBehavior: Clip.antiAlias,
//               child: InkWell(
//                 onTap: onTap,
//                 child: Icon(
//                   isEnd ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class GalleryDemo {
  const GalleryDemo({
    required this.title,
    required this.category,
    required this.subtitle,
    // This parameter is required for studies.
    this.studyId,
    // Parameters below are required for non-study demos.
    this.slug,
    this.icon,
    this.configurations = const [],
  })  : assert(category == GalleryDemoCategory.study ||
            (slug != null && icon != null)),
        assert(slug != null || studyId != null);

  final String title;
  final GalleryDemoCategory category;
  final String subtitle;
  final String? studyId;
  final String? slug;
  final IconData? icon;
  final List<GalleryDemoConfiguration> configurations;

  String get describe => '${slug ?? studyId}@${category.name}';
}

class GalleryDemoConfiguration {
  const GalleryDemoConfiguration({
    required this.title,
    required this.description,
    required this.documentationUrl,
    required this.buildRoute,
    required this.code,
  });

  final String title;
  final String description;
  final String documentationUrl;
  final WidgetBuilder buildRoute;
  final CodeDisplayer code;
}

enum GalleryDemoCategory {
  study,
  material,
  cupertino,
  other;

  @override
  String toString() {
    return name.toUpperCase();
  }

  String? displayTitle() {
    switch (this) {
      case GalleryDemoCategory.other:
        return "Other";
      case GalleryDemoCategory.material:
      case GalleryDemoCategory.cupertino:
        return toString();
      case GalleryDemoCategory.study:
    }
    return null;
  }
}

class _CarouselCard extends StatelessWidget {
  const _CarouselCard({
    required this.demo,
    this.asset,
    this.assetDark,
    this.assetColor,
    this.assetDarkColor,
    this.textColor,
    required this.studyRoute,
  });

  final GalleryDemo? demo;
  final ImageProvider? asset;
  final ImageProvider? assetDark;
  final Color? assetColor;
  final Color? assetDarkColor;
  final Color? textColor;
  final String studyRoute;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).colorScheme.brightness == Brightness.dark;
    final asset = isDark ? this.asset : this.asset;
    final assetColor = isDark ? assetDarkColor : this.assetColor;
    final textColor = isDark ? Colors.white.withOpacity(0.87) : this.textColor;

    return Container(
      // Makes integration tests possible.
      key: ValueKey(demo!.describe),
      margin:
          EdgeInsets.all(isDisplayDesktop(context) ? 0 : _carouselItemMargin),
      child: Material(
        elevation: 8,
        shadowColor: Colors.grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context)
                .popUntil((route) => route.settings.name == '/');
            Navigator.of(context).restorablePushNamed(studyRoute);
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (asset != null)
                Positioned(
                  left: 50,
                  top: 40,
                  bottom: 60,
                  right: 50,
                  child: FadeInImagePlaceholder(
                    image: asset,
                    placeholder: Container(
                      color: assetColor,
                    ),
                    child: Ink.image(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.height * 0.3,
                      image: asset,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Divider(
                      thickness: 1,
                    ),
                    Text(
                      demo!.title,
                      style: textTheme.bodyMedium!.apply(color: textColor),
                      maxLines: 3,
                      overflow: TextOverflow.visible,
                    ),
                    Text(
                      demo!.subtitle,
                      style: textTheme.labelMedium!.apply(color: textColor),
                      maxLines: 5,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

double _carouselHeight(double scaleFactor, BuildContext context) => math.max(
    _carouselHeightMin *
        GalleryOptions.of(context).textScaleFactor(context) *
        scaleFactor,
    _carouselHeightMin);

/// Wrap the studies with this to display a back button and allow the user to
/// exit them at any time.
class StudyWrapper extends StatefulWidget {
  const StudyWrapper({
    super.key,
    required this.study,
    this.alignment = AlignmentDirectional.bottomStart,
    this.hasBottomNavBar = false,
  });

  final Widget study;
  final bool hasBottomNavBar;
  final AlignmentDirectional alignment;

  @override
  State<StudyWrapper> createState() => _StudyWrapperState();
}

class _StudyWrapperState extends State<StudyWrapper> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ApplyTextOptions(
      child: Stack(
        children: [
          Semantics(
            sortKey: const OrdinalSortKey(1),
            child: RestorationScope(
              restorationId: 'study_wrapper',
              child: widget.study,
            ),
          ),
          if (!isDisplayFoldable(context))
            SafeArea(
              child: Align(
                alignment: widget.alignment,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: widget.hasBottomNavBar
                          ? kBottomNavigationBarHeight + 16.0
                          : 16.0),
                  child: Semantics(
                    sortKey: const OrdinalSortKey(0),
                    label: "Back",
                    button: true,
                    enabled: true,
                    excludeSemantics: true,
                    child: FloatingActionButton.extended(
                      heroTag: _BackButtonHeroTag(),
                      key: const ValueKey('Back'),
                      onPressed: () {
                        Navigator.of(context)
                            .popUntil((route) => route.settings.name == '/');
                      },
                      icon: IconTheme(
                        data: IconThemeData(color: colorScheme.onPrimary),
                        child: const BackButtonIcon(),
                      ),
                      label: Text(
                        MaterialLocalizations.of(context).backButtonTooltip,
                        style: textTheme.labelLarge!
                            .apply(color: colorScheme.onPrimary),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BackButtonHeroTag {}
