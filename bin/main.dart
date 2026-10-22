import 'dart:io';
import 'dart:math';
import 'built-in.dart';
import 'helpers.dart';
import 'package:path/path.dart' as p;

final bool isWindows = Platform.isWindows;
final List<String> paths =
    Platform.environment['PATH']?.split(isWindows ? ';' : ':') ?? [];
const List<String> builtIn = ["type", "echo", "exit"];

void main(List<String> arguments) {
  shellLoop:
  while (true) {
    stdout.write('\$ ');
    final String commandLine = stdin.readLineSync()!;
    final splitCmd = split(commandLine, " ", max: 1);
    final String command = splitCmd[0];
    if (splitCmd.length == 1) {
      // process commands without subcommands
      switch (command) {
        case "exit":
          break shellLoop;
        default:
          checkForExecutable(command);
          break;
      }
    } else {
      // process subcommands
      final String subCommand = splitCmd[1];
      switch (command) {
        case "echo":
          print(subCommand);
          break;
        case "type":
          checkType(subCommand);
          break;
        default:
          checkForExecutable(command);
          break;
      }
    }
  }
}

void checkType(String subCommand) {
  final String toCheck = subCommand.split(" ").first;
  if (builtIn.contains(toCheck)) {
    print("$toCheck is a shell builtin");
  } else {
    print("$toCheck: not found");
  }
}

void checkForExecutable(String command) {
  final pathSep = isWindows ? ';' : ':';
  final paths = Platform.environment['PATH']?.split(pathSep) ?? [];
  for (var path in paths) {
    final fullPath = p.join(path, command);
    if (File(fullPath).existsSync() && isExecutable(fullPath)) {
      print("$command is $fullPath");
      return;
    }
  }
  print("${command}: not found");
}

bool isExecutable(String fullPath) {
  if (isWindows) {
    final executableExtensions = ['.exe', '.bat', '.cmd', '.ps1'];
    final ext = fullPath.toLowerCase().split('.').last;
    return executableExtensions.contains('.$ext');
  } else {
    try {
      final result = Process.runSync('stat', ['-c', '%A', fullPath]);

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
