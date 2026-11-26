import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'How do you want to use Futsal?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Player'),
                  subtitle: const Text('Find and book a nearby futsal ground'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/register/user'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.sports_soccer),
                  title: const Text('Futsal owner'),
                  subtitle: const Text('Register your venue and get approved by admin'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/register/owner'),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Already have an account? Sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
