import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/note.dart';

class ExportService {
  static Future<String> exportNoteAsPdf(Note note) async {
    final pw.Document pdf = pw.Document();

    final String title = note.title.trim().isEmpty ? 'Untitled Note' : note.title;
    final String content = note.content;
    final List<String> tags = note.allTags;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.Header(
              level: 0,
              child: pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            if (tags.isNotEmpty) ...<pw.Widget>[
              pw.SizedBox(height: 8),
              pw.Wrap(
                spacing: 8,
                children: tags.map((String tag) => pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey300,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text('#$tag', style: const pw.TextStyle(fontSize: 10)),
                )).toList(),
              ),
            ],
            pw.SizedBox(height: 20),
            pw.Text(content, style: const pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 40),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Text(
              'Created: ${_formatDate(note.createdAt)}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
            pw.Text(
              'Last updated: ${_formatDate(note.updatedAt)}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ];
        },
      ),
    );

    final Directory dir = await getApplicationDocumentsDirectory();
    final String fileName = '${note.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final File file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  static Future<String> exportNoteAsTxt(Note note) async {
    final StringBuffer buffer = StringBuffer();

    buffer.writeln(note.title.trim().isEmpty ? 'Untitled Note' : note.title);
    buffer.writeln('=' * 40);
    buffer.writeln();

    final List<String> tags = note.allTags;
    if (tags.isNotEmpty) {
      buffer.writeln('Tags: ${tags.map((String t) => '#$t').join(', ')}');
      buffer.writeln();
    }

    buffer.writeln(note.content);
    buffer.writeln();
    buffer.writeln('-' * 40);
    buffer.writeln('Created: ${_formatDate(note.createdAt)}');
    buffer.writeln('Updated: ${_formatDate(note.updatedAt)}');

    final Directory dir = await getApplicationDocumentsDirectory();
    final String fileName = '${note.id}_${DateTime.now().millisecondsSinceEpoch}.txt';
    final File file = File('${dir.path}/$fileName');
    await file.writeAsString(buffer.toString());

    return file.path;
  }

  static Future<void> shareNote(Note note) async {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln(note.title.trim().isEmpty ? 'Untitled Note' : note.title);
    buffer.writeln();
    buffer.writeln(note.content);
    
    await Share.share(
      buffer.toString(),
      subject: note.title.trim().isEmpty ? 'Note' : note.title,
    );
  }

  static Future<void> shareMultipleNotes(List<Note> notes) async {
    final StringBuffer buffer = StringBuffer();

    for (final Note note in notes) {
      buffer.writeln('=' * 40);
      buffer.writeln(note.title.trim().isEmpty ? 'Untitled Note' : note.title);
      buffer.writeln('-' * 40);
      buffer.writeln(note.content);
      buffer.writeln();
    }

    await Share.share(
      buffer.toString(),
      subject: '${notes.length} Notes exported',
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}