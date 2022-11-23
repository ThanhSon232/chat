part of 'profile_cubit.dart';

@immutable
abstract class ProfileState extends Equatable{
  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {

}

class ProfileLoading extends ProfileState{}

class ProfileLoaded extends ProfileState{
  List<Post> posts;
  DateTime dateTime;

  ProfileLoaded({required this.posts, required this.dateTime});

  @override
  List<Object> get props => [
    posts,
    dateTime
  ];
}

class ProfileSendRequest extends ProfileState{
  bool isSend;

  ProfileSendRequest({required this.isSend});

  @override
  List<Object> get props => [
    isSend
  ];
}