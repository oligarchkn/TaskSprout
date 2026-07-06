import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Тестова сторінка для перевірки SharedPreferences
class StorageTestScreen extends StatefulWidget {
  const StorageTestScreen({super.key});

  @override
  State<StorageTestScreen> createState() => _StorageTestScreenState();
}

class _StorageTestScreenState extends State<StorageTestScreen> {
  String _status = 'Ready';
  List<String> _savedData = [];

  Future<void> _testSave() async {
    setState(() => _status = 'Saving...');

    try {
      final prefs = await SharedPreferences.getInstance();
      final testData = {
        'test': 'value',
        'timestamp': DateTime.now().toIso8601String(),
      };

      await prefs.setString('test_key', json.encode(testData));
      setState(() => _status = 'Saved successfully!');

      // Читаємо одразу для перевірки
      _testLoad();
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  Future<void> _testLoad() async {
    setState(() => _status = 'Loading...');

    try {
      final prefs = await SharedPreferences.getInstance();

      // Отримуємо всі ключі
      final keys = prefs.getKeys();

      final data = <String>[];
      for (final key in keys) {
        final value = prefs.get(key);
        data.add('$key: $value');
      }

      setState(() {
        _savedData = data;
        _status = 'Loaded ${keys.length} keys';
      });
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  Future<void> _testClear() async {
    setState(() => _status = 'Clearing...');

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      setState(() {
        _status = 'Cleared!';
        _savedData = [];
      });
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _testLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Status: $_status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _testSave,
              child: const Text('Save Test Data'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testLoad,
              child: const Text('Load All Data'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testClear,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Clear All'),
            ),
            const SizedBox(height: 24),
            Text(
              'Saved Data:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _savedData.isEmpty
                  ? const Center(child: Text('No data'))
                  : ListView.builder(
                      itemCount: _savedData.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(_savedData[index]),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
