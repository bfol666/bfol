import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'presentation/pages/home/home_page.dart';
import 'presentation/pages/calendar/calendar_page.dart';
import 'presentation/pages/weekly_report/weekly_report_page.dart';
import 'presentation/pages/profile/profile_page.dart';
import 'presentation/pages/create_entry/create_entry_page.dart';
import 'presentation/pages/entry_detail/entry_detail_page.dart';
import 'presentation/pages/auth/login_page.dart';
import 'data/models/entry.dart';

class MoodiaryApp extends StatelessWidget {
  const MoodiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moodiary',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(
              builder: (_) => const LoginPage(),
            );
          case '/home':
            return MaterialPageRoute(
              builder: (_) => const MainShell(),
            );
          case '/create':
            return MaterialPageRoute(
              builder: (_) => const CreateEntryPage(),
              settings: settings,
            );
          case '/report':
            return MaterialPageRoute(
              builder: (_) => const WeeklyReportPage(),
            );
          case '/calendar':
            return MaterialPageRoute(
              builder: (_) => const CalendarPage(),
            );
          case '/profile':
            return MaterialPageRoute(
              builder: (_) => const ProfilePage(),
            );
          case '/detail':
            final entry = settings.arguments as Entry?;
            if (entry == null) {
              return MaterialPageRoute(
                builder: (_) => const MainShell(),
              );
            }
            return MaterialPageRoute(
              builder: (_) => EntryDetailPage(entry: entry),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const MainShell(),
            );
        }
      },
    );
  }
}

/// Main app shell with bottom navigation
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  final _pages = const [
    HomePage(),
    CalendarPage(),
    WeeklyReportPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.surfaceMuted,
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: '首页',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: '日历',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_outlined),
              activeIcon: Icon(Icons.auto_awesome),
              label: '周报',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: '我的',
            ),
          ],
        ),
      ),
    );
  }
}
