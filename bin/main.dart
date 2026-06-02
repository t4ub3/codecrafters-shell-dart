import 'dart:io';

void main(List<String> arguments) {
  while (true) {
    stdout.write('\$ ');
    final String command = stdin.readLineSync()!;
    if (command.startsWith("echo ")) {
      stdout.write(command.substring(5));
    } else if (command == "exit") {
      break;
    } else {
      stdout.write("${command}: command not found");
    }
    stdout.write("\n");
  }
}
