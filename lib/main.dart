import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/theme_provider.dart';
import 'screens/home_feed_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/leaves_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/rendering.dart';
import 'screens/profile_screen.dart';
import 'data/sample_data.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const KoalaApp());
}

/// Global theme provider instance
final themeProvider = ThemeProvider();

class KoalaApp extends StatefulWidget {
  const KoalaApp({super.key});

  @override
  State<KoalaApp> createState() => _KoalaAppState();
}

class _KoalaAppState extends State<KoalaApp> {
  @override
  void initState() {
    super.initState();
    themeProvider.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Koala',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isNavBarVisible = true;

  // GlobalKeys for accessing screen states
  final GlobalKey<HomeFeedScreenState> _homeKey = GlobalKey<HomeFeedScreenState>();
  final GlobalKey<DiscoverScreenState> _discoverKey = GlobalKey<DiscoverScreenState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeFeedScreen(key: _homeKey),
      DiscoverScreen(key: _discoverKey),
      const LeavesScreen(),
      const ProfileScreen(),
    ];
  }

  void _onNavTap(int index) {
    // If tapping the current tab, trigger refresh
    if (_currentIndex == index) {
      if (index == 0) {
        _homeKey.currentState?.refresh();
      }
    }
    
    
    setState(() {
      _currentIndex = index;
      _isNavBarVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.reverse && _isNavBarVisible) {
            setState(() => _isNavBarVisible = false);
          } else if (notification.direction == ScrollDirection.forward && !_isNavBarVisible) {
            setState(() => _isNavBarVisible = true);
          }
          return true;
        },
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isNavBarVisible ? kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom : 0,
        child: Wrap(
          children: [
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: isDark ? AppColors.darkShadow : AppColors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: _onNavTap,
                backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: AppColors.brandAccent,
                unselectedItemColor: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                iconSize: 30.0,
                elevation: 0,
                items: [
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      'assets/images/home_icon.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                        BlendMode.srcIn,
                      ),
                    ),
                    activeIcon: SvgPicture.asset(
                      'assets/images/home_icon.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.brandAccent,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: 'Home',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.explore_outlined),
                    activeIcon: Icon(Icons.explore),
                    label: 'Discover',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.eco_outlined),
                    activeIcon: Icon(Icons.eco),
                    label: 'Leaves',
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          SampleData.currentUser.avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const CircleAvatar(
                            child: Icon(Icons.person, size: 16),
                          ),
                        ),
                      ),
                    ),
                    activeIcon: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.brandAccent,
                          width: 2.5,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          SampleData.currentUser.avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const CircleAvatar(
                            child: Icon(Icons.person, size: 16),
                          ),
                        ),
                      ),
                    ),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
