String _userProfile({required String userId}) => '/api/users/$userId';

enum ApiGet<T> {
  users('/api/users'),
  userOf(_userProfile),
  profile('/api/profile');

  final T path;
  const ApiGet(this.path);
}

enum ApiPost<T> {
  login('/api/auth/login'),
  register('/api/auth/register'),

  profileUpdateName('/api/profile/update-name'),
  profileUpdatePhoto('/api/profile/update-photo'),
  profileUpdatePassword('/api/profile/update-password');

  final T path;
  const ApiPost(this.path);
}
