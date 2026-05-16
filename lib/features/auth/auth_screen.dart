import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_providers.dart';
import '../../widgets/adaptive_page.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key, this.startupMessage});

  final String? startupMessage;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(authFormProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: AdaptivePage(
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 74,
                        height: 74,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.electric_bolt_rounded,
                          color: Colors.black,
                          size: 42,
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      formState.isRegistering
                          ? 'Create your KX Wave account'
                          : 'Welcome back',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Sign in to keep your library and future playlists in sync.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 28),
                    if (widget.startupMessage != null)
                      _InlineMessage(message: widget.startupMessage!),
                    if (formState.errorMessage != null)
                      _InlineMessage(message: formState.errorMessage!),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            autofillHints: const [AutofillHints.email],
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.mail_outline_rounded),
                            ),
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _passwordController,
                            autofillHints: const [AutofillHints.password],
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_outline_rounded),
                            ),
                            validator: _validatePassword,
                            onFieldSubmitted: (_) => _submitEmail(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: formState.isLoading ? null : _submitEmail,
                      child: formState.isLoading
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(formState.isRegistering ? 'Create account' : 'Sign in'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: formState.isLoading ? null : _submitGoogle,
                      icon: const Icon(Icons.account_circle_outlined),
                      label: const Text('Continue with Google'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: formState.isLoading
                          ? null
                          : ref.read(authFormProvider.notifier).toggleMode,
                      child: Text(
                        formState.isRegistering
                            ? 'Already have an account? Sign in'
                            : 'New here? Create an account',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email is required.';
    }
    if (!email.contains('@') || !email.contains('.')) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  Future<void> _submitEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref.read(authFormProvider.notifier).submitEmail(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  Future<void> _submitGoogle() async {
    await ref.read(authFormProvider.notifier).submitGoogle();
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.errorContainer.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: scheme.error.withValues(alpha: 0.32)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onErrorContainer,
                ),
          ),
        ),
      ),
    );
  }
}
