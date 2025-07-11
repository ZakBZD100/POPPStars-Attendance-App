import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';


const host = '10.74.251.68';
const port = 22;
const username = 'groupe2';
const password = 'GaussFFT';


Future<void> uploadFile({
  required String localPath,
  required String remotePath,
}) async {
  try {
    debugPrint("🔄 Connexion au serveur SSH...");
    final socket = await SSHSocket.connect(host, port);
    final client = SSHClient(
      socket,
      username: username,
      onPasswordRequest: () => password,
    );


    debugPrint("✅ Connexion réussie !");
    final sftp = await client.sftp();


    if (!File(localPath).existsSync()) {
      debugPrint('❌ Le fichier local n\'existe pas : $localPath');
      sftp.close();
      client.close();
      return;
    }


    final remoteDir = remotePath.substring(0, remotePath.lastIndexOf('/'));
    try {
      await sftp.stat(remoteDir);
    } catch (_) {
      debugPrint('❌ Le dossier distant n\'existe pas !');
      sftp.close();
      client.close();
      return;
    }


    debugPrint("📂 Dossier distant trouvé !");
    debugPrint("🔄 Envoi du fichier...");


    final remoteFile = await sftp.open(
      remotePath,
      mode: SftpFileOpenMode.create | SftpFileOpenMode.truncate | SftpFileOpenMode.write,
    );


    final bytes = await File(localPath).readAsBytes();
    await remoteFile.writeBytes(bytes);


    remoteFile.close();
    sftp.close();
    client.close();


    debugPrint("✅ Upload terminé avec succès !");
    await verifyUpload(remotePath);
  } catch (e, st) {
    debugPrint('❌ Échec de l\'upload : $e');
    debugPrint(st.toString());
  }
}


Future<void> verifyUpload(String remotePath) async {
  try {
    debugPrint("🔍 Vérification du fichier $remotePath...");


    final socket = await SSHSocket.connect(host, port);
    final client = SSHClient(
      socket,
      username: username,
      onPasswordRequest: () => password,
    );


    final sftp = await client.sftp();
    final attrs = await sftp.stat(remotePath).catchError((_) => SftpFileAttrs(size: 0));


    if (attrs.size == 0) {
      debugPrint("❌ Le fichier ne semble pas exister sur le serveur.");
    } else {
      debugPrint("✅ Fichier présent ! Taille : ${attrs.size} octets");
    }


    sftp.close();
    client.close();
  } catch (e) {
    debugPrint("❌ Erreur lors de la vérification : $e");
  }
}


Future<void> downloadFile({
  required String remotePath,
  required String localPath,
}) async {
  try {
    debugPrint("🔄 Connexion au serveur pour download...");
    final socket = await SSHSocket.connect(host, port);
    final client = SSHClient(
      socket,
      username: username,
      onPasswordRequest: () => password,
    );


    final sftp = await client.sftp();
    final attrs = await sftp.stat(remotePath).catchError((_) => SftpFileAttrs(size: 0));


    if (attrs.size == 0) {
      debugPrint("❌ Le fichier distant n'existe pas !");
      sftp.close();
      client.close();
      return;
    }


    debugPrint("📥 Téléchargement...");
    final remoteFile = await sftp.open(remotePath, mode: SftpFileOpenMode.read);
    final file = File(localPath);
    final sink = file.openWrite();


    await for (var data in remoteFile.read()) {
      sink.add(data);
    }


    await sink.close();
    remoteFile.close();
    sftp.close();
    client.close();


    debugPrint("✅ Fichier téléchargé avec succès dans : $localPath");
  } catch (e) {
    debugPrint("❌ Erreur lors du téléchargement : $e");
  }
}


void main() async {
  await uploadFile(
    localPath: 'C:/Users/mayan/OneDrive/Bureau/test.txt',
    remotePath: '/data/data_test/test.txt',
  );


  await downloadFile(
    remotePath: '/data/data_test/test.txt',
    localPath: 'C:/Users/mayan/OneDrive/Bureau/test_downloaded.txt',
  );
}