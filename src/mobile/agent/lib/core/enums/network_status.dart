/// Network connectivity status of the device.
enum NetworkStatus {
  online('ONLINE'),
  offline('OFFLINE'),
  weak('WEAK');

  final String code;
  const NetworkStatus(this.code);
}
