class InfoCPNData {
  final String accessToken;
  final String uId;

  InfoCPNData({required this.accessToken,required this.uId});

  @override
  String toString() {
    return '$runtimeType($accessToken, $uId)';
  }

  @override
  bool operator ==(Object other) {
    if (other is InfoCPNData) {
      return accessToken == other.accessToken && uId == other.uId;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(accessToken, uId);
}