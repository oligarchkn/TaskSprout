import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/category_provider.dart';
import '../l10n/app_localizations.dart';
import '../models/task.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  TaskPriority _selectedPriority = TaskPriority.none;
  String? _selectedCategory;
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedTime;
  bool _isFocused = false;

  // Speech to text
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      _speechAvailable = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          setState(() => _isListening = false);
        },
      );
      setState(() {});
    }
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')),
      );
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _descriptionController.text = result.recognizedWords;
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: Localizations.localeOf(context).languageCode,
      );
    }
  }

  @override
  void dispose() {
    _speech.cancel();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitTask() {
    if (_formKey.currentState!.validate()) {
      DateTime? finalDueDate = _selectedDueDate;

      // Combine date and time if both are selected
      if (_selectedDueDate != null && _selectedTime != null) {
        finalDueDate = DateTime(
          _selectedDueDate!.year,
          _selectedDueDate!.month,
          _selectedDueDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );
      }

      context.read<TaskProvider>().addTask(
            _titleController.text,
            description: _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text
                : null,
            priority: _selectedPriority,
            category: _selectedCategory,
            dueDate: finalDueDate,
            isFocused: _isFocused,
          );
      Navigator.pop(context);
    }
  }

  Future<void> _selectDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? now,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _showAddCategoryDialog() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    // Отримуємо провайдер до будь-якого await, щоб не використовувати
    // BuildContext після асинхронної паузи.
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addCategory),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.enterCategoryName,
            border: const OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, controller.text);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      final success = await categoryProvider.addCategory(result.trim());

      if (success) {
        setState(() {
          _selectedCategory = result.trim();
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.categoryExists)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: 16 + bottomPadding,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                l10n.addTask,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // Task title input
              TextFormField(
                controller: _titleController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: l10n.taskTitle,
                  prefixIcon: const Icon(Icons.task_alt),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Task description input
              TextFormField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: l10n.taskDescription,
                  prefixIcon: const Icon(Icons.notes_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening ? Colors.red : null,
                    ),
                    onPressed: _toggleListening,
                    tooltip: _isListening ? 'Stop listening' : 'Voice input',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Priority selector
              DropdownButtonFormField<TaskPriority>(
                initialValue: _selectedPriority,
                decoration: InputDecoration(
                  labelText: l10n.taskPriority,
                  prefixIcon: const Icon(Icons.flag_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: TaskPriority.none,
                    child: Text(l10n.priorityNone),
                  ),
                  DropdownMenuItem(
                    value: TaskPriority.low,
                    child: Row(
                      children: [
                        const Icon(Icons.flag_rounded,
                          color: Colors.blue, size: 16),
                        const SizedBox(width: 8),
                        Text(l10n.priorityLow),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: TaskPriority.medium,
                    child: Row(
                      children: [
                        const Icon(Icons.flag_rounded,
                          color: Colors.orange, size: 16),
                        const SizedBox(width: 8),
                        Text(l10n.priorityMedium),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: TaskPriority.high,
                    child: Row(
                      children: [
                        const Icon(Icons.flag_rounded,
                          color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Text(l10n.priorityHigh),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value ?? TaskPriority.none;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Category selector
              Consumer<CategoryProvider>(
                builder: (context, categoryProvider, child) {
                  return Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          decoration: InputDecoration(
                            labelText: l10n.taskCategory,
                            prefixIcon: const Icon(Icons.label_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          hint: Text(l10n.taskCategory),
                          items: categoryProvider.categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(_getCategoryLabel(category, l10n)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: _showAddCategoryDialog,
                        tooltip: l10n.addCategory,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // Due date selector
              InkWell(
                onTap: _selectDueDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.taskDueDate,
                    prefixIcon: const Icon(Icons.calendar_today_rounded),
                    suffixIcon: _selectedDueDate != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _selectedDueDate = null;
                                _selectedTime = null;
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _selectedDueDate != null
                        ? DateFormat.yMMMd().format(_selectedDueDate!)
                        : 'Select date',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _selectedDueDate != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Time selector (only shown if date is selected)
              if (_selectedDueDate != null)
                InkWell(
                  onTap: _selectTime,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.dueTime,
                      prefixIcon: const Icon(Icons.access_time_rounded),
                      suffixIcon: _selectedTime != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _selectedTime = null;
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _selectedTime != null
                          ? _selectedTime!.format(context)
                          : l10n.selectTime,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: _selectedTime != null
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),

              if (_selectedDueDate != null) const SizedBox(height: 16),

              // Focus toggle
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: Row(
                    children: [
                      Icon(
                        _isFocused ? Icons.star : Icons.star_border,
                        color: _isFocused ? Colors.amber : null,
                      ),
                      const SizedBox(width: 8),
                      Text(l10n.addToFocus),
                    ],
                  ),
                  value: _isFocused,
                  onChanged: (value) {
                    setState(() {
                      _isFocused = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _submitTask,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.save),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryLabel(String category, AppLocalizations l10n) {
    switch (category) {
      case 'Work':
        return l10n.categoryWork;
      case 'Personal':
        return l10n.categoryPersonal;
      case 'Shopping':
        return l10n.categoryShopping;
      case 'Health':
        return l10n.categoryHealth;
      case 'Other':
        return l10n.categoryOther;
      default:
        return category;
    }
  }
}
