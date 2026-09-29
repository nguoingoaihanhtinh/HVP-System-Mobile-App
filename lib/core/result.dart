import 'messages.dart';

/// Outcome of a repository call. Screens show [Msg.display] in both cases.
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;
}

class Ok<T> extends Result<T> {
  final T value;

  /// Optional message to show on success (e.g. MSG3, MSG7).
  final Msg? message;

  const Ok(this.value, {this.message});
}

class Err<T> extends Result<T> {
  final Msg message;

  const Err(this.message);
}
