import 'package:flutter/material.dart';

class TrackListTile extends StatelessWidget {
  final String name;
  final double distance;
  final String region;
  final DateTime createdAt;

  const TrackListTile({
    super.key,
    required this.name,
    required this.distance,
    required this.region,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.orangeAccent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.map, color: Colors.white),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          "$distance km · $region\n${_formatDate(createdAt)}",
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // 트랙 상세 페이지로 이동
          print("Tapped on $name");
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}";
  }
}
