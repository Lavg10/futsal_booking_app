import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../owner/presentation/screens/owner_registration_screen.dart';
import 'user_register_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        initialIndex: initialTab,
        child: Column(
          children: [
            SizedBox(
              height: 168,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 140,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryDark, AppColors.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(28),
                      ),
                    ),
                    child: SafeArea(
                      top: true,
                      bottom: false,
                      left: false,
                      right: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Container(
                              height: 52,
                              width: 52,
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.sports_soccer,
                                color: AppColors.primaryDark,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Flexible(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Create account\n',
                                      style: TextStyle(
                                        color: AppColors.accent,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Choose your account type',
                                      style: TextStyle(
                                        color: AppColors.textOnDark,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 0,
                    child: Card(
                      child: SizedBox(
                        height: 52,
                        child: TabBar(
                          tabs: const [
                            Tab(text: 'Player'),
                            Tab(text: 'Owner'),
                          ],
                        labelColor: AppColors.primaryDark,
                        unselectedLabelColor: AppColors.textSecondary,
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        indicator: const BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        indicatorPadding: const EdgeInsets.all(6),
                        dividerColor: const Color(0x00000000),
                      ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: const UserRegisterScreen(embedded: true),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: const OwnerRegistrationScreen(embedded: true),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surfaceBright,
                  border: Border(top: BorderSide(color: AppColors.line)),
                ),
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Already have an account? Sign in'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
