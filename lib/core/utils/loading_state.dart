enum LoadingState {
  idle,
  loading,
  success,
  error,
}

class LoadingStateManager {
  LoadingState _state = LoadingState.idle;
  String? _errorMessage;

  LoadingState get state => _state;
  String? get errorMessage => _errorMessage;
  
  bool get isLoading => _state == LoadingState.loading;
  bool get isSuccess => _state == LoadingState.success;
  bool get isError => _state == LoadingState.error;
  bool get isIdle => _state == LoadingState.idle;

  void setLoading() {
    _state = LoadingState.loading;
    _errorMessage = null;
  }

  void setSuccess() {
    _state = LoadingState.success;
    _errorMessage = null;
  }

  void setError(String message) {
    _state = LoadingState.error;
    _errorMessage = message;
  }

  void setIdle() {
    _state = LoadingState.idle;
    _errorMessage = null;
  }

  void reset() {
    _state = LoadingState.idle;
    _errorMessage = null;
  }
}
