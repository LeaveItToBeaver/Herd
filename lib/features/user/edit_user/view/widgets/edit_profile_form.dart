import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../user_profile/data/models/user_model.dart';
import '../providers/edit_profile_provider.dart';

class EditProfileForm extends ConsumerWidget {
  final UserModel user;

  const EditProfileForm({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editProfileProvider(user));
    final notifier = ref.read(editProfileProvider(user).notifier);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              initialValue: state.username,
              decoration: const InputDecoration(labelText: 'Username'),
              onChanged: notifier.usernameChanged,
            ),
            const SizedBox(height: 16),
            TextFormField(
              maxLines: 5,
              initialValue: state.bio,
              decoration: const InputDecoration(labelText: 'Bio'),
              onChanged: notifier.bioChanged,
            ),
          ],
        ),
      ),
    );
  }
}
