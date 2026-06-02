import 'dart:io';

void main(List<String> arguments) {
  while (true) {
    stdout.write('\$ ');
    final String command = stdin.readLineSync()!;
    if (command.startsWith("echo ")) {
      print(command.substring(5));
    } else if (command.startsWith("type ")) {
      checkType(command);
    } else if (command == "exit") {
      break;
    } else {
      print("${command}: command not found");
    }
  }
}

void checkType(String command) {
  final String toCheck = command.substring(5);
  final List<String> builtIns = ["type", "echo", "exit"];
  print(
    "$toCheck${builtIns.contains(toCheck) ? " is a shell built in" : ": not found"}",
  );
}

// TODO: handle input "echo " and "type " (exactly 5 chars)!!
