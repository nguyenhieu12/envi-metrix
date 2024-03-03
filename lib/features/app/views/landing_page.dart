import 'package:envi_metrix/core/models/nav_model.dart';
import 'package:envi_metrix/features/air_pollution/presentation/pages/air_pollution_page.dart';
import 'package:envi_metrix/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:envi_metrix/features/disaster/presentation/pages/disaster_page.dart';
import 'package:envi_metrix/features/app/views/chatbot_page.dart';
import 'package:envi_metrix/features/news/presentation/pages/news_page.dart';
import 'package:envi_metrix/services/tab_change/tab_change_cubit.dart';
import 'package:envi_metrix/utils/page_transition.dart';
import 'package:envi_metrix/widgets/custom_navbar.dart';
import 'package:facebook_messenger_share/facebook_messenger_share.dart';
import 'package:floating_draggable_widget/floating_draggable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final dashboardNavKey = GlobalKey<NavigatorState>();
  final airNavKey = GlobalKey<NavigatorState>();
  final newsNavKey = GlobalKey<NavigatorState>();
  final mapNavKey = GlobalKey<NavigatorState>();
  int selectedTab = 0;
  List<NavModel> items = [];

  @override
  void initState() {
    super.initState();
    items = [
      NavModel(page: const DashboardPage(), navKey: dashboardNavKey),
      NavModel(page: const AirPollutionPage(), navKey: airNavKey),
      NavModel(page: const NewsPage(), navKey: newsNavKey),
      NavModel(page: const DisasterPage(), navKey: mapNavKey),
    ];
  }

  List<Widget> pages = const [
    DashboardPage(),
    AirPollutionPage(),
    NewsPage(),
    DisasterPage()
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TabChangeCubit>(
      create: (context) => TabChangeCubit(),
      child: FloatingDraggableWidget(
        autoAlign: true,
        mainScreenWidget: Scaffold(
          body: IndexedStack(
            index: selectedTab,
            children: items
                .map((page) => Navigator(
                      key: page.navKey,
                      onGenerateInitialRoutes: (navigator, initialRoute) {
                        return [
                          MaterialPageRoute(builder: (context) => page.page)
                        ];
                      },
                    ))
                .toList(),
          ),
          bottomNavigationBar: CustomNavbar(
              index: selectedTab,
              onTap: (index) {
                if (index == selectedTab) {
                  items[index]
                      .navKey
                      .currentState
                      ?.popUntil((route) => route.isFirst);
                } else {
                  setState(() {
                    selectedTab = index;
                  });
                }
              }),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: _buildFloatingActionButton(),
        ),
        floatingWidget: _buildChatbotButton(),
        floatingWidgetWidth: 54.w,
        floatingWidgetHeight: 54.w,
        dx: 10.w,
        dy: 580.h,
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Padding(
      padding: const EdgeInsets.all(2.5),
      child: SizedBox(
        width: 55,
        height: 55,
        child: SpeedDial(
          animationDuration: const Duration(milliseconds: 700),
          gradientBoxShape: BoxShape.circle,
          childrenButtonSize: Size(50.w, 50.w),
          animatedIcon: AnimatedIcons.menu_close,
          animatedIconTheme: const IconThemeData(color: Colors.white),
          overlayColor: Colors.grey,
          overlayOpacity: 0.5,
          backgroundColor: Colors.green,
          children: [
            _buildSpeedDialChild(
                path: './assets/icons/share_icon.png',
                color: Colors.blue,
                size: 25.w,
                onTap: _onShareTap),
            _buildSpeedDialChild(
                path: './assets/icons/compare_icon.png',
                color: Colors.orange,
                size: 32.w,
                onTap: _onCompareTap),
            _buildSpeedDialChild(
                path: './assets/icons/ar_icon.png',
                color: Colors.red,
                size: 30.w,
                onTap: _onArTap),
          ],
        ),
      ),
    );
  }

  SpeedDialChild _buildSpeedDialChild(
      {required String path,
      required Color color,
      required double size,
      required Function() onTap}) {
    return SpeedDialChild(
        onTap: () async => onTap,
        backgroundColor: color,
        elevation: 0,
        child: Image.asset(
          path,
          width: size,
          height: size,
          color: Colors.white,
        ));
  }

  Widget _buildChatbotButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context)
          .push(PageTransition.slideTransition(const ChatbotPage())),
      child: Container(
        decoration: BoxDecoration(
            image: const DecorationImage(
                image: AssetImage(
                  './assets/images/gemini_ai.png',
                ),
                fit: BoxFit.cover),
            borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Future<void> _onShareTap() async {}

  Future<void> _onCompareTap() async {}

  Future<void> _onArTap() async {}
}
