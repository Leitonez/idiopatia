import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Grava um arquivo em pasta temporária e abre a folha de compartilhamento
/// do sistema. O app nunca envia o arquivo a lugar algum por conta própria.
class FileShare {
  FileShare._();

  static Future<void> shareBytes({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    String? subject,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: mimeType, name: fileName)],
        subject: subject,
      ),
    );
  }

  /// Abre o seletor de arquivos e devolve o conteúdo como texto, ou nulo se
  /// o usuário cancelar.
  static Future<String?> pickTextFile() async {
    final result = await FilePicker.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return null;
    final f = result.files.single;
    if (f.bytes != null) return String.fromCharCodes(_stripBom(f.bytes!));
    if (f.path != null) return File(f.path!).readAsString();
    return null;
  }

  static Uint8List _stripBom(Uint8List b) =>
      b.length >= 3 && b[0] == 0xEF && b[1] == 0xBB && b[2] == 0xBF
      ? b.sublist(3)
      : b;
}
