import 'package:flutter/material.dart';

import '../labs/labs.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Лабораторные работы'),
      ),
      body: ListView.separated(
        itemCount: labs.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final lab = labs[index];
          return ListTile(
            leading: CircleAvatar(child: Text(lab.number)),
            title: Text(lab.title),
            subtitle: Text(lab.description),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: lab.builder),
              );
            },
          );
        },
      ),
    );
  }
}
