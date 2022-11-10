part of 'setting_cubit.dart';

@immutable
abstract class SettingState extends Equatable{
  @override
  List<Object> get props => [];
}

class SettingInitial extends SettingState {}

class SettingLoading extends SettingState{}

class SettingLoaded extends SettingState{

}