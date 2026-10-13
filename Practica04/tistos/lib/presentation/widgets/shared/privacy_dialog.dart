import 'package:flutter/material.dart';
import 'package:tistos/infrastructure/services/local_storage_service.dart';

class PrivacyDialog {
  static void show(BuildContext context) {
    if (LocalStorageService.hasAcceptedPrivacy) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black87,
        builder: (context) => const _PrivacyNoticeWidget(),
      );
    });
  }
}

class _PrivacyNoticeWidget extends StatelessWidget {
  const _PrivacyNoticeWidget();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Aviso de Privacidad', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: const SingleChildScrollView(
        child: Text(
          'En cumplimiento con la Ley Federal de Protección de Datos Personales en Posesión de los Particulares (LFPDPPP) de los Estados Unidos Mexicanos, le informamos que los datos recabados por Tistos serán utilizados exclusivamente para mejorar la experiencia del usuario y proveer las funciones de la aplicación.\n\nAl presionar "Aceptar", confirmas que has leído y comprendes nuestro aviso de privacidad.',
          style: TextStyle(color: Colors.white70),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              barrierDismissible: false,
              barrierColor: Colors.black87,
              builder: (context) => const _TermsAndConditionsWidget(),
            );
          },
          child: const Text('Aceptar', style: TextStyle(color: Colors.pinkAccent)),
        ),
      ],
    );
  }
}

class _TermsAndConditionsWidget extends StatefulWidget {
  const _TermsAndConditionsWidget();

  @override
  State<_TermsAndConditionsWidget> createState() => _TermsAndConditionsWidgetState();
}

class _TermsAndConditionsWidgetState extends State<_TermsAndConditionsWidget> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Términos y Condiciones', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Al utilizar esta aplicación, aceptas regirte por las leyes aplicables de los Estados Unidos Mexicanos. El contenido generado es responsabilidad del usuario.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _accepted,
                  activeColor: Colors.pinkAccent,
                  onChanged: (val) {
                    setState(() {
                      _accepted = val ?? false;
                    });
                  },
                ),
                const Expanded(
                  child: Text('Acepto los términos y condiciones', style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _accepted
              ? () async {
                  await LocalStorageService.acceptPrivacy();
                  if (context.mounted) Navigator.pop(context);
                }
              : null, // Disabled if not accepted
          child: Text('Aceptar', style: TextStyle(color: _accepted ? Colors.pinkAccent : Colors.grey)),
        ),
      ],
    );
  }
}
