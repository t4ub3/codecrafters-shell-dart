import 'dart:io';

void main(List<String> arguments) {
  while (true) {
    stdout.write('\$ ');
    final String command = stdin.readLineSync()!;
    if (command == "exit") {
      break;
    }
    stdout.write("${command}: command not found");
    stdout.write("\n");
  }
}
