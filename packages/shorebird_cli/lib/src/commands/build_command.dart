import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:shorebird_cli/src/command.dart';
import 'package:shorebird_cli/src/shorebird_build_mixin.dart';
import 'package:shorebird_cli/src/shorebird_config_mixin.dart';
import 'package:shorebird_cli/src/shorebird_engine_mixin.dart';

/// {@template build_command}
///
/// `shorebird build`
/// Build a new release of your application.
/// {@endtemplate}
class BuildCommand extends ShorebirdCommand
    with ShorebirdConfigMixin, ShorebirdEngineMixin, ShorebirdBuildMixin {
  /// {@macro build_command}
  BuildCommand({
    required super.logger,
    super.auth,
    super.buildCodePushClient,
    super.runProcess,
  });

  @override
  String get description => 'Build a new release of your application.';

  @override
  String get name => 'build';

  @override
  Future<int> run() async {
    if (!auth.isAuthenticated) {
      logger
        ..err('You must be logged in to build.')
        ..err("Run 'shorebird login' to log in and try again.");
      return ExitCode.noUser.code;
    }

    try {
      await ensureEngineExists();
    } catch (error) {
      logger.err(error.toString());
      return ExitCode.software.code;
    }

    final buildProgress = logger.progress('Building release ');
    try {
      await buildRelease();
      buildProgress.complete();
    } on ProcessException catch (error) {
      buildProgress.fail('Failed to build: ${error.message}');
      return ExitCode.software.code;
    }

    return ExitCode.success.code;
  }
}
