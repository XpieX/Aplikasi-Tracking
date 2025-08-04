class Customer {
  final int id;
  final String username;
  final String customerName;
  final String address;
  final int status;
  final double lat;
  final double long;

  Customer({
    required this.id,
    required this.username,
    required this.customerName,
    required this.address,
    required this.status,
    required this.lat,
    required this.long,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      username: json['nama_user'],
      customerName: json['nama_pelanggan'],
      address: json['alamat'],
      status: json['status'],
      lat: double.parse(json['latitude']),
      long: double.parse(json['longitude']),
    );
  }
}
