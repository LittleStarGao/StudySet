//user_model.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
// 该命令生成对应json解析文件  flutter packages pub run build_runner build  生成 user_model.g.dart 文件
part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends Equatable {
  @JsonKey(name: 'user_name')
  final String username;

  @JsonKey(name: 'avatar_url')
  final String avatarUrl;

  @JsonKey(name: 'cover_url')
  final String coverUrl;

  @JsonKey(name: 'introduce')
  final String introduce;

  UserModel({this.username, this.avatarUrl, this.coverUrl, this.introduce});

  factory UserModel.fromJson(Map<String, dynamic> srcJson) =>
      _$UserModelFromJson(srcJson);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  @override
  List<Object> get props => [username, avatarUrl, coverUrl, introduce];
}

