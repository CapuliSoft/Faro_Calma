import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gtc6/core/database/local_database_service.dart';
import 'package:gtc6/core/theme/colors.dart';
import 'package:gtc6/features/journal/domain/models/journal_note.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final LocalDatabaseService _db = LocalDatabaseService.instance;
  List<JournalNote> _notes = [];
  bool _isLoading = true;

  static const List<({String key, String es, String en, Color color})> _moods =
      [
        (key: 'calm', es: 'Calma', en: 'Calm', color: SensoryColors.zenTeal),
        (
          key: 'grateful',
          es: 'Agradecido',
          en: 'Grateful',
          color: SensoryColors.zenSage,
        ),
        (
          key: 'focused',
          es: 'Enfocado',
          en: 'Focused',
          color: SensoryColors.zenIndigo,
        ),
        (
          key: 'reflective',
          es: 'Reflexivo',
          en: 'Reflective',
          color: SensoryColors.secondary,
        ),
        (
          key: 'anxious',
          es: 'Ansioso',
          en: 'Anxious',
          color: SensoryColors.zenAmber,
        ),
      ];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    try {
      final notes = await _db.getAllNotes();
      if (!mounted) return;
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final isEs = Localizations.localeOf(context).languageCode == 'es';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEs ? 'Error al cargar notas: $e' : 'Error loading notes: $e',
          ),
          backgroundColor: SensoryColors.error,
        ),
      );
    }
  }

  Future<void> _openNoteEditor({JournalNote? existing}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Theme.of(context).cardTheme.color ??
          Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          _NoteEditorSheet(existing: existing, moods: _moods, db: _db),
    );

    if (saved == true) {
      await _loadNotes();
    }
  }

  Future<void> _deleteNote(JournalNote note) async {
    if (note.id == null) return;
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isEs ? '¿Eliminar nota?' : 'Delete note?'),
        content: Text(
          isEs
              ? 'Esta acción eliminará "${note.title}" de tu diario.'
              : 'This will remove "${note.title}" from your journal.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isEs ? 'Cancelar' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: SensoryColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(isEs ? 'Eliminar' : 'Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _db.deleteNote(note.id!);
      await _loadNotes();
    }
  }

  Future<void> _resetAllNotes() async {
    if (_notes.isEmpty) return;
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.amber,
              size: 26,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isEs ? '¿Reiniciar diario?' : 'Reset journal?',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          isEs
              ? 'Se borrarán todas tus notas guardadas (${_notes.length}). Esta acción no se puede deshacer.'
              : 'All your saved notes (${_notes.length}) will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isEs ? 'Cancelar' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: SensoryColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(isEs ? 'Borrar todo' : 'Delete all'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _db.deleteAllNotes();
      await _loadNotes();
    }
  }

  ({String label, Color color})? _moodInfo(String? moodKey, bool isEs) {
    if (moodKey == null) return null;
    for (final m in _moods) {
      if (m.key == moodKey) {
        return (label: isEs ? m.es : m.en, color: m.color);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final dateFmt = DateFormat('dd/MM/yyyy • HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEs ? 'Diario Personal' : 'Personal Journal',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_notes.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.delete_sweep_rounded,
                color: SensoryColors.error.withValues(alpha: 0.85),
              ),
              tooltip: isEs ? 'Reiniciar diario' : 'Reset journal',
              onPressed: _resetAllNotes,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNoteEditor(),
        backgroundColor: SensoryColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_note_rounded),
        label: Text(isEs ? 'Nueva nota' : 'New note'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: SensoryColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        size: 44,
                        color: SensoryColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isEs ? 'Tu diario está vacío' : 'Your journal is empty',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isEs
                          ? 'Escribe pensamientos, emociones o logros del día. Todo se guarda de forma local en tu dispositivo.'
                          : 'Write down thoughts, feelings, or daily wins. Everything is saved locally on your device.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
              itemCount: _notes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final note = _notes[index];
                final mood = _moodInfo(note.mood, isEs);

                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _openNoteEditor(existing: note),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                note.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                size: 20,
                                color: SensoryColors.error.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                              onPressed: () => _deleteNote(note),
                              tooltip: isEs ? 'Eliminar' : 'Delete',
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        if (note.content.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            note.content,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.4,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.82),
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            if (mood != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: mood.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  mood.label,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: mood.color,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: Text(
                                dateFmt.format(note.updatedAt),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _NoteEditorSheet extends StatefulWidget {
  final JournalNote? existing;
  final List<({String key, String es, String en, Color color})> moods;
  final LocalDatabaseService db;

  const _NoteEditorSheet({
    required this.existing,
    required this.moods,
    required this.db,
  });

  @override
  State<_NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<_NoteEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  String? _selectedMood;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existing?.title ?? '',
    );
    _contentController = TextEditingController(
      text: widget.existing?.content ?? '',
    );
    _selectedMood = widget.existing?.mood;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    FocusScope.of(context).unfocus();

    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context, false);
      return;
    }

    setState(() => _isSaving = true);
    final now = DateTime.now();
    final finalTitle = title.isEmpty
        ? (isEs ? 'Nota sin título' : 'Untitled note')
        : title;

    if (widget.existing == null) {
      await widget.db.insertNote(
        JournalNote(
          title: finalTitle,
          content: content,
          mood: _selectedMood,
          createdAt: now,
          updatedAt: now,
        ),
      );
    } else {
      await widget.db.updateNote(
        widget.existing!.copyWith(
          title: finalTitle,
          content: content,
          mood: _selectedMood,
          clearMood: _selectedMood == null,
          updatedAt: now,
        ),
      );
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.existing == null
                  ? (isEs ? 'Nueva Nota' : 'New Note')
                  : (isEs ? 'Editar Nota' : 'Edit Note'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: isEs ? 'Título' : 'Title',
                hintText: isEs
                    ? '¿Cómo te sientes hoy?'
                    : 'How are you feeling today?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 5,
              minLines: 3,
              decoration: InputDecoration(
                labelText: isEs ? 'Tus pensamientos' : 'Your thoughts',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              isEs ? 'Estado de ánimo (opcional)' : 'Mood (optional)',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: widget.moods.map((m) {
                final isSelected = _selectedMood == m.key;
                return ChoiceChip(
                  label: Text(isEs ? m.es : m.en),
                  selected: isSelected,
                  selectedColor: m.color.withValues(alpha: 0.22),
                  onSelected: (val) {
                    setState(() {
                      _selectedMood = val ? m.key : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: const Icon(Icons.save_rounded),
              label: Text(isEs ? 'Guardar nota' : 'Save note'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SensoryColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
