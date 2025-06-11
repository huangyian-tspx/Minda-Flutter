// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiError _$ApiErrorFromJson(Map<String, dynamic> json) => ApiError(
  message: json['message'] as String,
  statusCode: (json['statusCode'] as num?)?.toInt(),
  type:
      $enumDecodeNullable(_$ApiErrorTypeEnumMap, json['type']) ??
      ApiErrorType.unknown,
  technicalDetails: json['technicalDetails'] as String?,
  errorCode: json['errorCode'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  timestamp: json['timestamp'] == null
      ? null
      : DateTime.parse(json['timestamp'] as String),
  requestId: json['requestId'] as String?,
);

Map<String, dynamic> _$ApiErrorToJson(ApiError instance) => <String, dynamic>{
  'message': instance.message,
  'statusCode': instance.statusCode,
  'type': _$ApiErrorTypeEnumMap[instance.type]!,
  'technicalDetails': instance.technicalDetails,
  'errorCode': instance.errorCode,
  'metadata': instance.metadata,
  'timestamp': instance.timestamp.toIso8601String(),
  'requestId': instance.requestId,
};

const _$ApiErrorTypeEnumMap = {
  ApiErrorType.network: 'network',
  ApiErrorType.timeout: 'timeout',
  ApiErrorType.connection: 'connection',
  ApiErrorType.server: 'server',
  ApiErrorType.unauthorized: 'unauthorized',
  ApiErrorType.forbidden: 'forbidden',
  ApiErrorType.notFound: 'not_found',
  ApiErrorType.rateLimit: 'rate_limit',
  ApiErrorType.validation: 'validation',
  ApiErrorType.invalidInput: 'invalid_input',
  ApiErrorType.incompleteData: 'incomplete_data',
  ApiErrorType.businessLogic: 'business_logic',
  ApiErrorType.aiProcessing: 'ai_processing',
  ApiErrorType.parsing: 'parsing',
  ApiErrorType.unknown: 'unknown',
};
