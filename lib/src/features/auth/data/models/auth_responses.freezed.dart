// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_responses.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthEnvelope {

 String get token; UserDto get user;
/// Create a copy of AuthEnvelope
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthEnvelopeCopyWith<AuthEnvelope> get copyWith => _$AuthEnvelopeCopyWithImpl<AuthEnvelope>(this as AuthEnvelope, _$identity);

  /// Serializes this AuthEnvelope to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthEnvelope&&(identical(other.token, token) || other.token == token)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,user);

@override
String toString() {
  return 'AuthEnvelope(token: $token, user: $user)';
}


}

/// @nodoc
abstract mixin class $AuthEnvelopeCopyWith<$Res>  {
  factory $AuthEnvelopeCopyWith(AuthEnvelope value, $Res Function(AuthEnvelope) _then) = _$AuthEnvelopeCopyWithImpl;
@useResult
$Res call({
 String token, UserDto user
});


$UserDtoCopyWith<$Res> get user;

}
/// @nodoc
class _$AuthEnvelopeCopyWithImpl<$Res>
    implements $AuthEnvelopeCopyWith<$Res> {
  _$AuthEnvelopeCopyWithImpl(this._self, this._then);

  final AuthEnvelope _self;
  final $Res Function(AuthEnvelope) _then;

/// Create a copy of AuthEnvelope
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? user = null,}) {
  return _then(_self.copyWith(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserDto,
  ));
}
/// Create a copy of AuthEnvelope
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserDtoCopyWith<$Res> get user {
  
  return $UserDtoCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [AuthEnvelope].
extension AuthEnvelopePatterns on AuthEnvelope {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthEnvelope value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthEnvelope() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthEnvelope value)  $default,){
final _that = this;
switch (_that) {
case _AuthEnvelope():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthEnvelope value)?  $default,){
final _that = this;
switch (_that) {
case _AuthEnvelope() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token,  UserDto user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthEnvelope() when $default != null:
return $default(_that.token,_that.user);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token,  UserDto user)  $default,) {final _that = this;
switch (_that) {
case _AuthEnvelope():
return $default(_that.token,_that.user);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token,  UserDto user)?  $default,) {final _that = this;
switch (_that) {
case _AuthEnvelope() when $default != null:
return $default(_that.token,_that.user);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthEnvelope implements AuthEnvelope {
  const _AuthEnvelope({this.token = '', required this.user});
  factory _AuthEnvelope.fromJson(Map<String, dynamic> json) => _$AuthEnvelopeFromJson(json);

@override@JsonKey() final  String token;
@override final  UserDto user;

/// Create a copy of AuthEnvelope
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthEnvelopeCopyWith<_AuthEnvelope> get copyWith => __$AuthEnvelopeCopyWithImpl<_AuthEnvelope>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthEnvelopeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthEnvelope&&(identical(other.token, token) || other.token == token)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,user);

@override
String toString() {
  return 'AuthEnvelope(token: $token, user: $user)';
}


}

/// @nodoc
abstract mixin class _$AuthEnvelopeCopyWith<$Res> implements $AuthEnvelopeCopyWith<$Res> {
  factory _$AuthEnvelopeCopyWith(_AuthEnvelope value, $Res Function(_AuthEnvelope) _then) = __$AuthEnvelopeCopyWithImpl;
@override @useResult
$Res call({
 String token, UserDto user
});


@override $UserDtoCopyWith<$Res> get user;

}
/// @nodoc
class __$AuthEnvelopeCopyWithImpl<$Res>
    implements _$AuthEnvelopeCopyWith<$Res> {
  __$AuthEnvelopeCopyWithImpl(this._self, this._then);

  final _AuthEnvelope _self;
  final $Res Function(_AuthEnvelope) _then;

/// Create a copy of AuthEnvelope
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? user = null,}) {
  return _then(_AuthEnvelope(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserDto,
  ));
}

/// Create a copy of AuthEnvelope
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserDtoCopyWith<$Res> get user {
  
  return $UserDtoCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
