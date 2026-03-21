// ════════════════════════════════════════════════════════════════════════════
// main.dart  — App entry point with Firebase initialization
// All Firebase config values come from FirebaseConfig — never hardcoded here.
// ════════════════════════════════════════════════════════════════════════════

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/app_state.dart';
import 'core/services/firebase_config.dart';
import 'core/theme/app_theme.dart';
import 'features/main_scaffold.dart';
import 'features/pin_lock_screen.dart';
import 'features/splash_screen.dart';
import 'features/company_login_screen.dart';

// Firebase Web SDK config for reference (already integrated into FirebaseConfig)
/*
// Your web app's Firebase configuration 
const firebaseConfig = { 
  apiKey: "AIzaSyDr6JHIReYMAT-gff_OZZtU2aaAj0zt2ho", 
  authDomain: "mrwaterprov1-54c3f.firebaseapp.com", 
  databaseURL: "https://mrwaterprov1-54c3f-default-rtdb.firebaseio.com", 
  projectId: "mrwaterprov1-54c3f", 
  storageBucket: "mrwaterprov1-54c3f.firebasestorage.app", 
  messagingSenderId: "199429585160", 
  appId: "1:199429585160:web:919155f8d921ab0790d4bd" 
}; 
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Firebase using our config constants from FirebaseConfig.
  try {
    await Firebase.initializeApp(options: FirebaseConfig.currentPlatform);
    debugPrint('Firebase connected successfully: ${FirebaseConfig.projectId}');
    
    // Test connectivity to RTDB
    final db = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: FirebaseConfig.databaseUrl,
    );
    final snap = await db.ref('.info/connected').get();
    debugPrint('RTDB Connection Status: ${snap.value}');
  } catch (e) {
    debugPrint('Firebase connection error: $e');
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const ProviderScope(child: MrWaterApp()));
}

class MrWaterApp extends ConsumerWidget {
  const MrWaterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings  = ref.watch(settingsProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: settings.appName,
      debugShowCheckedModeBanner: false,
      theme:     AppTheme.light(settings.accentColor),
      darkTheme: AppTheme.dark(settings.accentColor),
      themeMode: themeMode,
      home: const _AuthGate(),
    );
  }
}

// ── Auth Gate ────────────────────────────────────────────────────────────────
// App always starts on SplashScreen → _AppGate (PIN).
// The hidden admin portal is reached by long-pressing the logo on the PIN screen.
// This gate just handles the startup flow.
class _AuthGate extends StatelessWidget {
  const _AuthGate();
  @override
  Widget build(BuildContext context) =>
      SplashScreen(nextScreen: const _AppGate());
}

// ── App Gate — PIN lock within a company ──────────────────────────────────────
// Layer 3: staff PIN or owner bypass. Runs AFTER company auth.
class _AppGate extends ConsumerStatefulWidget {
  const _AppGate();
  @override
  ConsumerState<_AppGate> createState() => _AppGateState();
}

class _AppGateState extends ConsumerState<_AppGate> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache the logo to ensure immediate loading throughout the app
    precacheImage(const AssetImage('assets/images/mrwater_logo.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final pinUnlocked = ref.watch(pinUnlockedProvider);

    // Reset PIN unlock if Firebase user changes (sign out or switch)
    ref.listen(authStateProvider, (prev, next) {
      if (prev?.value != next.value) {
        ref.read(pinUnlockedProvider.notifier).state = false;
        ref.read(sessionUserProvider.notifier).state = null;
      }
    });

    return authState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Auth Error: $err')),
      ),
      data: (user) {
        // 1. If no owner is logged in via Firebase Auth, show the Admin Portal (Login)
        if (user == null) {
          return CompanyLoginScreen(
            onAuthenticated: ({required bool goDirectly}) {
              // Firebase Auth will update automatically and rebuild this widget
              if (goDirectly) {
                ref.read(pinUnlockedProvider.notifier).state = true;
              }
            },
          );
        }

        // 2. Owner is logged in. Ensure session is initialized.
        if (!CompanySession.isLoggedIn) {
          CompanySession.init(user.uid, name: user.displayName ?? user.email);
        }

        // Check for staff. Ensure owner is added as an admin staff member if not already present.
        final staff = ref.watch(staffProvider);
        final activeStaff = staff.where((s) => s.isActive).toList();

        if (activeStaff.isEmpty && user.uid.isNotEmpty) {
          // No staff yet? Add the owner as the first admin staff automatically.
          final ownerStaff = StaffMember(
            id: user.uid,
            name: user.displayName ?? 'Owner',
            phone: user.phoneNumber ?? '',
            pin: '0000', // Default PIN for new owner
            isActive: true,
            permissions: ['dashboard','transactions','customers','inventory','load_unload','payments','reports','notifications','settings'],
          );
          // We can't use await here in build, but we can trigger it.
          Future.microtask(() => ref.read(staffProvider.notifier).add(ownerStaff));
        }

        // 3. If we've already passed the PIN lock (or owner bypass), show the app.
        if (pinUnlocked) {
          return const MainScaffold();
        }

        // 4. Show the PIN lock screen.
        return PinLockScreen(
          onUnlocked: (isOwner) {
            ref.read(pinUnlockedProvider.notifier).state = true;
          },
        );
      },
    );
  }
}
