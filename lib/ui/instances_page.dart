// Flutter imports:
import 'package:flutter/material.dart';
import 'package:openlib/gen_l10n/app_localizations.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:openlib/services/instance_manager.dart';
import 'package:openlib/state/state.dart';
import 'package:openlib/ui/components/page_title_widget.dart';

class InstancesPage extends ConsumerStatefulWidget {
  const InstancesPage({super.key});

  @override
  ConsumerState<InstancesPage> createState() => _InstancesPageState();
}

class _InstancesPageState extends ConsumerState<InstancesPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  Map<String, int?> _responseTimes = {};
  bool _isTesting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testAllInstances() async {
    if (_isTesting) return;

    setState(() {
      _isTesting = true;
      _responseTimes = {};
    });

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final manager = ref.read(instanceManagerProvider);
      final results = await manager.rankInstancesBySpeed();

      if (mounted) {
        setState(() {
          _responseTimes = results;
          _isTesting = false;
        });

        // Refresh the list to show new order
        ref.invalidate(archiveInstancesProvider);

                scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.instancesTestedAndRanked),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTesting = false;
        });
                scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.testingFailed}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddInstanceDialog() {
    _nameController.clear();
    _urlController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
                return AlertDialog(
          title: Text(AppLocalizations.of(context)!.addCustomInstance),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.name,
                                    hintText: AppLocalizations.of(context)!.instanceNameHint,
                ),
              ),
              const SizedBox(height: 16),
                            TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.url,
                                    hintText: AppLocalizations.of(context)!.instanceUrlHint,
                ),
                keyboardType: TextInputType.url,
              ),
            ],
          ),
                    actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                final url = _urlController.text.trim();

                                if (name.isEmpty || url.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.pleaseFillAllFields)),
                  );
                  return;
                }

                final uri = Uri.tryParse(url);
                                if (uri == null ||
                    (uri.scheme != 'http' && uri.scheme != 'https') ||
                    uri.host.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.pleaseEnterValidUrl),
                    ),
                  );
                  return;
                }

                // Capture context-dependent objects before async gap
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                final manager = ref.read(instanceManagerProvider);
                await manager.addInstance(name, url);

                // Refresh the instances list
                ref.invalidate(archiveInstancesProvider);

                if (mounted) {
                  if (navigator.canPop()) {
                    navigator.pop();
                  }
                                    scaffoldMessenger.showSnackBar(
                    SnackBar(
                        content: Text(AppLocalizations.of(context)!.instanceAddedSuccessfully)),
                  );
                }
              },
                            child: Text(AppLocalizations.of(context)!.add),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(ArchiveInstance instance) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
                return AlertDialog(
          title: Text(AppLocalizations.of(context)!.deleteInstance),
          content: Text(AppLocalizations.of(context)!.areYouSureDeleteInstance(instance.name)),
                    actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () async {
                // Capture context-dependent objects before async gap
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                final manager = ref.read(instanceManagerProvider);
                final success = await manager.removeInstance(instance.id);

                if (!mounted) return;

                                if (success) {
                  ref.invalidate(archiveInstancesProvider);
                  navigator.pop();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.instanceDeleted)),
                  );
                } else {
                  navigator.pop();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                        content: Text(AppLocalizations.of(context)!.cannotDeleteDefaultInstances)),
                  );
                }
              },
                            child: Text(AppLocalizations.of(context)!.delete, style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final instancesAsync = ref.watch(archiveInstancesProvider);

    return Scaffold(
      appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.manageInstances),
        actions: [
          IconButton(
            icon: _isTesting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.speed),
            onPressed: _isTesting ? null : _testAllInstances,
                        tooltip: AppLocalizations.of(context)!.testAndRankAllInstances,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddInstanceDialog,
                        tooltip: AppLocalizations.of(context)!.addCustomInstance,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              // Capture context-dependent objects before async gap
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              final manager = ref.read(instanceManagerProvider);
              await manager.resetToDefaults();
              ref.invalidate(archiveInstancesProvider);
              if (!mounted) return;
                            scaffoldMessenger.showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.resetToDefaultInstances)),
              );
            },
                        tooltip: AppLocalizations.of(context)!.resetToDefaults,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                        Padding(
              padding: const EdgeInsets.all(8.0),
              child: TitleText(AppLocalizations.of(context)!.archiveInstances),
            ),
                        Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                AppLocalizations.of(context)!.dragToReorderPriority,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            Expanded(
              child: instancesAsync.when(
                                data: (instances) {
                  if (instances.isEmpty) {
                    return Center(
                      child: Text(AppLocalizations.of(context)!.noInstancesAvailable),
                    );
                  }

                  return ReorderableListView.builder(
                    itemCount: instances.length,
                    onReorder: (oldIndex, newIndex) async {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }

                      final newList = List<ArchiveInstance>.from(instances);
                      final item = newList.removeAt(oldIndex);
                      newList.insert(newIndex, item);

                      final manager = ref.read(instanceManagerProvider);
                      await manager.reorderInstances(newList);
                      ref.invalidate(archiveInstancesProvider);
                    },
                    itemBuilder: (context, index) {
                      final instance = instances[index];
                      final responseTime = _responseTimes[instance.id];

                      return Card(
                        key: ValueKey(instance.id),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.drag_handle,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                            ],
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  instance.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              // Show response time badge if available
                              if (_responseTimes.containsKey(instance.id))
                                Container(
                                  margin: const EdgeInsets.only(right: 4),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: responseTime != null
                                        ? (responseTime < 500
                                            ? Colors.green
                                                .withValues(alpha: 0.2)
                                            : responseTime < 1500
                                                ? Colors.orange
                                                    .withValues(alpha: 0.2)
                                                : Colors.red
                                                    .withValues(alpha: 0.2))
                                        : Colors.grey.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                                                    child: Text(
                                    responseTime != null
                                        ? '${responseTime}ms'
                                        : AppLocalizations.of(context)!.offline,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: responseTime != null
                                          ? (responseTime < 500
                                              ? Colors.green
                                              : responseTime < 1500
                                                  ? Colors.orange
                                                  : Colors.red)
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              if (instance.isCustom)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                                                    child: Text(
                                    AppLocalizations.of(context)!.custom,
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.blue),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Text(
                            instance.baseUrl,
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: instance.enabled,
                                thumbColor: WidgetStateProperty.resolveWith(
                                    (states) =>
                                        states.contains(WidgetState.selected)
                                            ? Colors.green
                                            : null),
                                onChanged: (value) async {
                                  final manager =
                                      ref.read(instanceManagerProvider);
                                  await manager.toggleInstance(
                                      instance.id, value);
                                  ref.invalidate(archiveInstancesProvider);
                                },
                              ),
                              if (instance.isCustom)
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _showDeleteConfirmDialog(instance),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 48),
                                            const SizedBox(height: 16),
                      Text('${AppLocalizations.of(context)!.error}: $error'),
                      const SizedBox(height: 16),
                                            ElevatedButton(
                        onPressed: () =>
                            ref.invalidate(archiveInstancesProvider),
                        child: Text(AppLocalizations.of(context)!.retry),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
