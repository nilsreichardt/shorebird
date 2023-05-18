import 'dart:async';

import 'package:barbecue/barbecue.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:shorebird_cli/src/auth_logger_mixin.dart';
import 'package:shorebird_cli/src/command.dart';
import 'package:shorebird_cli/src/shorebird_config_mixin.dart';
import 'package:shorebird_code_push_client/shorebird_code_push_client.dart';

/// {@template list_apps_command}
///
/// `shorebird apps list`
/// List all apps using Shorebird.
/// {@endtemplate}
class ListAppsCommand extends ShorebirdCommand
    with AuthLoggerMixin, ShorebirdConfigMixin {
  /// {@macro list_apps_command}
  ListAppsCommand({
    required super.logger,
    super.buildCodePushClient,
    super.auth,
  });

  @override
  String get description => 'List all apps using Shorebird.';

  @override
  String get name => 'list';

  @override
  List<String> get aliases => ['ls'];

  @override
  Future<int>? run() async {
    if (!auth.isAuthenticated) {
      printNeedsAuthInstructions();
      return ExitCode.noUser.code;
    }

    final client = buildCodePushClient(
      httpClient: auth.client,
      hostedUri: hostedUri,
    );

    final List<AppMetadata> apps;
    try {
      apps = await client.getApps();
    } catch (error) {
      logger.err('$error');
      return ExitCode.software.code;
    }

    logger.info('📱 Apps');

    if (apps.isEmpty) {
      logger.info('(empty)');
      return ExitCode.success.code;
    }

    // Sort the apps by name to make the output more readable. Otherwise the
    // list of apps is completely mixed up which is hard to read when using
    // flavors, see https://github.com/shorebirdtech/shorebird/issues/513.
    apps.sort((a, b) => a.displayName.compareTo(b.displayName));

    logger.info(apps.prettyPrint());

    return ExitCode.success.code;
  }
}

extension on List<AppMetadata> {
  String prettyPrint() {
    const cellStyle = CellStyle(
      paddingLeft: 1,
      paddingRight: 1,
      borderBottom: true,
      borderTop: true,
      borderLeft: true,
      borderRight: true,
    );
    return Table(
      cellStyle: cellStyle,
      header: const TableSection(
        rows: [
          Row(
            cells: [
              Cell('Name'),
              Cell('ID'),
              Cell('Release'),
              Cell('Patch'),
            ],
          )
        ],
      ),
      body: TableSection(
        rows: [
          for (final app in this)
            Row(
              cells: [
                Cell(app.displayName),
                Cell(app.appId),
                Cell(app.latestReleaseVersion ?? '--'),
                Cell(app.latestPatchNumber?.toString() ?? '--'),
              ],
            ),
        ],
      ),
    ).render();
  }
}
