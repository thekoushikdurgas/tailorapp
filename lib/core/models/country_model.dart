import 'package:equatable/equatable.dart';

class CountryModel extends Equatable {
  final String name;
  final String code;
  final String flag;

  const CountryModel({
    required this.name,
    required this.code,
    required this.flag,
  });

  factory CountryModel.fromMap(Map<String, String> map) {
    return CountryModel(
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      flag: map['flag'] ?? '',
    );
  }

  Map<String, String> toMap() {
    return {
      'name': name,
      'code': code,
      'flag': flag,
    };
  }

  @override
  List<Object> get props => [name, code, flag];

  @override
  String toString() => 'CountryModel(name: $name, code: $code, flag: $flag)';
}
