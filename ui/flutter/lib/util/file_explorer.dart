import 'dart:io';

class FileExplorer {
  static Future<void> openAndSelectFile(String filePath) async {
    if (!await FileSystemEntity.isDirectory(filePath) &&
        !await FileSystemEntity.isFile(filePath)) {
      return;
    }
    if (await FileSystemEntity.isDirectory(filePath)) {
      if (Platform.isWindows) {
        Process.run('explorer.exe', [filePath]);
      } else if (Platform.isMacOS || Platform.isLinux) {
        Process.run('xdg-open', [filePath]);
      }
    } else if (await FileSystemEntity.isFile(filePath)) {
      if (Platform.isWindows) {
        Process.run('explorer.exe', ['/select,', filePath]);
      } else if (Platform.isMacOS) {
        Process.run('open', ['-R', filePath]);
      } else if (Platform.isLinux) {
        if (await _isUbuntuOrDebian()) {
          Process.run('xdg-open', [filePath]);
        } else if (await _isCentOS()) {
          Process.run('nautilus', ['--select', filePath]);
        }
      }
    }
  }

  static Future<bool> _isUbuntuOrDebian() async {
    final result = await Process.run('lsb_release', ['-i']);
    if (result.exitCode != 0) {
      return false;
    }
    final output = result.stdout.toString().toLowerCase();
    return output.contains('ubuntu') || output.contains('debian');
  }

  static Future<bool> _isCentOS() async {
    final result = await Process.run('cat', ['/etc/os-release']);
    if (result.exitCode != 0) {
      return false;
    }
    final output = result.stdout.toString().toLowerCase();
    return output.contains('centos');
  }
}
