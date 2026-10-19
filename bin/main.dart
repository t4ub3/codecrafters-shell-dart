import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as p;

final bool isWindows = Platform.isWindows;

void main(List<String> arguments) {
  while (true) {
    stdout.write('\$ ');
    final String command = stdin.readLineSync()!;
    if (command.startsWith("echo ")) {
      print(command.substring(4).trim());
    } else if (command.startsWith("type ")) {
      checkType(command);
    } else if (command == "exit") {
      break;
    } else {
      break;
      // checkForExecutable(command);
    }
  }
}

void checkType(String command) async {
  final String toCheck = command.substring(4).trim();
  if (toCheck == "type") {
    await checkForExecutable(command);
  }
  final List<String> builtIns = ["type", "echo", "exit"];
  print(
    "$toCheck${builtIns.contains(toCheck) ? " is a shell builtin" : ": not found"}",
  );
}

Future<void> checkForExecutable(String command) async {
  final execString = command.substring(4);
  final pathSep = isWindows ? ';' : ':';
  final paths = Platform.environment['PATH']?.split(pathSep) ?? [];
  print(paths);
  for (var path in paths) {
    final fullPath = p.join(path, execString);
    if (await fileExists(path, execString)) {
      if (await isExecutable(fullPath)) {
        print("$execString is $fullPath");
        return;
      }
    }
  }
  print("${execString}: not found");
}

Future<bool> fileExists(String directoryPath, String fileName) async {
  final dir = Directory(directoryPath);
  if (!await dir.exists()) {
    return false;
  }

  try {
    await for (var entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        final name = entity.uri.pathSegments.last;
        if (name.toLowerCase() == fileName.toLowerCase()) {
          return true;
        }
      } else {
        return false;
      }
    }
  } catch (e) {
    print('Error while searching: $e');
  }
  return false;
}

Future<bool> isExecutable(String fullPath) async {
  if (isWindows) {
    final executableExtensions = ['.exe', '.bat', '.cmd', '.ps1'];
    final ext = fullPath.toLowerCase().split('.').last;
    return executableExtensions.contains('.$ext');
  } else {
    try {
      final result = await Process.run('stat', ['-c', '%A', fullPath]);

      if (result.exitCode != 0) {
        print("Error checking permissions: ${result.stderr}");
        return false;
      }

      final permissions = result.stdout.toString().trim();
      // Example output: "-rwxr-xr-x"
      // Check if the execute bit is set for user, group, or others
      return permissions.contains('x');
    } catch (e) {
      print("Exception: $e");
      return false;
    }
  }
}
