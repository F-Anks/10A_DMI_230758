import 'package:flutter/material.dart';

class MessageFieldBox extends StatelessWidget {

  final ValueChanged<String>onValue;


  const MessageFieldBox({super.key, required this.onValue});

  //final void Function(String value) onValue;

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();
    final focusNode = FocusNode();

    final outlineInputBorder = UnderlineInputBorder(
      borderSide: const BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(40),
    );

    void submitMessage(String value) {
      final trimmedValue = value.trim();
      if (trimmedValue.isEmpty) return; // evita enviar mensajes vacíos

      onValue(trimmedValue);
      textController.clear();
      focusNode.requestFocus();
    }

    final inputDecoration = InputDecoration(
      filled: true,
      enabledBorder: outlineInputBorder,
      focusedBorder: outlineInputBorder,
      hintText: 'Escribe un mensaje...',
      suffixIcon: IconButton(
        icon: const Icon(Icons.send_outlined),
        onPressed: () {
          submitMessage(textController.text);
        },
      ),
    );

    return TextFormField(
      enableSuggestions: false,
      autocorrect: false,
      onTapOutside: (event) {
        focusNode.unfocus(); // Ocultar el teclado al tocar fuera del TextFormField
      },
      focusNode: focusNode,
      controller: textController,
      decoration: inputDecoration,
      onFieldSubmitted: submitMessage,
    );
  }
}