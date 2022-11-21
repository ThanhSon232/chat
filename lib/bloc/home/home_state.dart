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

// class HomeLoaded extends HomeState {
//   List<Post> posts;
//
//   HomeLoaded({required this.posts, required datetime});
//
//
//
//   @override
//   List<Object> get props => [
//     posts
//   ];
// }

class HomeLoaded extends HomeState {
  List<Post> posts;
  DateTime datetime;
  HomeLoaded({required this.posts, required this.datetime});


  @override
  List<Object> get props => [
    posts,
    datetime
  ];
}
