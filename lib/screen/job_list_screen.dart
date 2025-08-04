import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:tracking_app/model/customer.dart';
import 'package:tracking_app/service/api_service.dart';
import 'package:tracking_app/service/auth_service.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  List<Customer> _jobList = [];
  String? username;

  @override
  void initState() {
    super.initState();
    loadUsername();
    fetchJobData();
  }

  Future<void> loadUsername() async {
    final user = await AuthService.getUserData();
    setState(() {
      username = user?['username'];
    });
  }

  Future<void> fetchJobData() async {
    final userId = await AuthService.getUserId();

    if (userId != null) {
      List<Customer> data = await APIService().getCustomerByUser(userId);
      setState(() {
        _jobList = data;
      });
    } else {
      print('User ID tidak ditemukan');
    }
  }

  Future<void> _updateStatus(int customerId) async {
    try {
      final response = await APIService().updateStatus(customerId, 1);
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Status berhasil diperbarui")),
        );
        await fetchJobData(); // refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: ${response['message']}")),
        );
      }
    } catch (e) {
      print("❌ Error saat update status: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan saat update status")),
      );
    }
  }

  Future<void> _showDialog(int customerId, String customer) async {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      title: 'Ubah Status',
      desc: "Apakah Anda yakin ingin mengubah status untuk $customer?",
      btnOkText: "Ubah",
      btnOkOnPress: () => _updateStatus(customerId),
      btnCancelOnPress: () {},
      btnCancelText: "Batal",
    ).show();
  }

  Widget statusIcon(String status) {
    switch (status) {
      case '0':
        return const Icon(Icons.close, color: Colors.red);
      case '1':
        return const Icon(Icons.check, color: Colors.green);
      default:
        return const Icon(Icons.question_mark);
    }
  }

  String status(String status) {
    switch (status) {
      case '0':
        return "Belum Selesai";
      case '1':
        return "Selesai";
      default:
        return "Tidak diketahui";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Pelanggan ${username ?? ""}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => fetchJobData(),
        child:
            _jobList.isEmpty
                ? const Center(child: Text("Tidak Ada Data Pelanggan"))
                : ListView.separated(
                  itemCount: _jobList.length,
                  separatorBuilder:
                      (context, index) => const Divider(
                        color: Colors.grey,
                        thickness: 1,
                        indent: 16,
                        endIndent: 16,
                      ),
                  itemBuilder: (context, index) {
                    final item = _jobList[index];
                    return InkWell(
                      onTap: () => _showDialog(item.id!, item.customerName),
                      child: ListTile(
                        leading: statusIcon(item.status.toString()),
                        title: Text(item.customerName),
                        subtitle: Text("Alamat Pelanggan: ${item.address}"),
                        trailing: Text(status(item.status.toString())),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
