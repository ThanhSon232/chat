part of 'home_cubit.dart';

@immutable
abstract class HomeState extends Equatable{
  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {

}

class HomeLoading extends HomeState {


}

class HomeLoaded extends HomeState {
  List<Post> posts;

  HomeLoaded({required this.posts});


  @override
  List<Object> get props => [
    posts
  ];
}
