import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../app_info.dart';
import '../../widgets/formatting.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.about)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset('assets/icon/icon.png', width: 96, height: 96),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              l.appTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Center(child: Text('${l.version} $appVersion')),
          const SizedBox(height: 16),
          Text(l.aboutDescription),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: Text(l.privacyPromise),
              subtitle: Text(l.localDataNotice),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: Text(l.privacyPolicy),
            subtitle: const SelectableText(privacyPolicyUrl),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l.license),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const _LicenseScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _LicenseScreen extends StatelessWidget {
  const _LicenseScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.license)),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('assets/licenses/LICENSE.md'),
        builder: (context, snap) => snap.hasData
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SelectableText(snap.data!),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
