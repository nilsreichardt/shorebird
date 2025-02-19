import 'package:json_annotation/json_annotation.dart';
import 'package:shorebird_code_push_protocol/shorebird_code_push_protocol.dart';

part 'create_artifact_request.g.dart';

/// {@template create_artifact_request}
/// The request body for POST /api/v1/artifacts
/// {@endtemplate}
@JsonSerializable()
class CreateArtifactRequest {
  /// {@macro create_artifact_request}
  const CreateArtifactRequest({
    required this.arch,
    required this.platform,
    required this.hash,
    required this.size,
  });

  /// Converts a Map<String, dynamic> to a [CreateArtifactRequest]
  factory CreateArtifactRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateArtifactRequestFromJson(json);

  /// Converts a [CreateArtifactRequest] to a Map<String, dynamic>.
  Json toJson() => _$CreateArtifactRequestToJson(this);

  /// The arch of the artifact.
  final String arch;

  /// The platform of the artifact.
  final String platform;

  /// The hash of the artifact.
  final String hash;

  /// The size of the artifact in bytes.
  @JsonKey(fromJson: _parseStringToInt, toJson: _parseIntToString)
  final int size;

  static int _parseStringToInt(dynamic value) => int.parse(value as String);

  static String _parseIntToString(dynamic value) => value.toString();
}
