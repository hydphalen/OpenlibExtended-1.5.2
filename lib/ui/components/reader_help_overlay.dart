import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReaderHelpOverlay extends StatelessWidget {
  final VoidCallback onDismiss;
  final bool isDesktop;

  const ReaderHelpOverlay({
    super.key,
    required this.onDismiss,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.85),
      child: InkWell(
        onTap: onDismiss,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Close hint
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: onDismiss,
              ),
            ),

            // Content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.menu_book, color: Colors.white, size: 60),
                const SizedBox(height: 20),
                                Text(
                  AppLocalizations.of(context)!.readerControls,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 40),

                // Controls Grid
                Wrap(
                  spacing: 40,
                  runSpacing: 30,
                  alignment: WrapAlignment.center,
                  children: [
                                        _buildHelpItem(
                      context,
                      icon: isDesktop ? Icons.keyboard : Icons.touch_app,
                      title: isDesktop ? AppLocalizations.of(context)!.arrowKeys : AppLocalizations.of(context)!.tapSides,
                      subtitle: isDesktop
                          ? AppLocalizations.of(context)!.useArrowKeysToTurnPages
                          : AppLocalizations.of(context)!.tapEdgesToTurnPages,
                    ),
                    _buildHelpItem(
                      context,
                      icon: Icons.zoom_in,
                      title: AppLocalizations.of(context)!.zoom,
                      subtitle: isDesktop
                          ? AppLocalizations.of(context)!.useProvidedControls
                          : AppLocalizations.of(context)!.pinchToZoomPdf,
                    ),
                    _buildHelpItem(
                      context,
                      icon: Icons.list,
                      title: AppLocalizations.of(context)!.menu,
                      subtitle: isDesktop
                          ? AppLocalizations.of(context)!.tableOfContentsViaSidebar
                          : AppLocalizations.of(context)!.tapCenterOrSwipeForMenu,
                    ),
                  ],
                ),

                const SizedBox(height: 50),
                OutlinedButton(
                  onPressed: onDismiss,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                                    child: Text(AppLocalizations.of(context)!.gotIt),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return SizedBox(
      width: 150,
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 40),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
