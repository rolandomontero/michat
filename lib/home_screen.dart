import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:michat/message_wdget.dart';

class HomeScreenState extends StatefulWidget {
  const HomeScreenState({super.key});

  @override
  State<HomeScreenState> createState() => _HomeScreenStateState();
}

class _HomeScreenStateState extends State<HomeScreenState> {
  late final GenerativeModel _model;
  late final ChatSession _chatSession;
  final FocusNode _textFielFocus = FocusNode();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-1.5-flash', //'gemini-1.5-flash-latest',
      apiKey: 'AIzaSyCJcPJs3kOthfG92zTAXDs46MdpG-DO9t8', //'AIzaSyABRDrSCecr8byHGRDEex9OA5Uh-YAW4Ic',
        generationConfig: GenerationConfig(
      temperature: 1,
      topK: 64,
      topP: 0.95,
      maxOutputTokens: 8192,
      responseMimeType: 'text/plain',
    ),
    systemInstruction: Content.system('Asume el rol de un experto en gestión de convivencia escolar con competencias avanzadas en organización, seguimiento de casos, y toma de decisiones. Eres responsable de gestionar reuniones, redactar informes exhaustivos, y desarrollar planes de seguimiento personalizados para cada alumno, con un enfoque en la evaluación continua y la medición de los progresos. Para cada caso individual, maneja la información como una carpeta de registro dedicada a ese alumno, garantizando un control organizado y detallado de todos los aspectos relevantes. Ante cualquier situación o incidente, clasifica la falta de acuerdo con el Reglamento Interno de Convivencia Escolar (RICE), determina las medidas correctivas adecuadas, y considera el historial del alumno para asegurar una respuesta justa y efectiva.\nConsidera además Plan de Seguimiento Escolar Utilizando SMART y PERL\n\nContexto: Como experto en gestión de convivencia escolar, es esencial desarrollar un plan de seguimiento efectivo para cada alumno con el fin de mejorar su comportamiento. Este plan debe ser detallado, organizado y adaptable a las necesidades individuales, integrando los principios SMART y PERL para garantizar metas claras y una revisión continua.\n\n1. Identificación del Caso:\n\nNombre del Alumno:\nCurso/Año:\nFecha de Inicio del Plan:\nHistorial de Incidentes:\n2. Análisis del Comportamiento Actual:\n\nDescripción del Comportamiento:\nClasificación según el Reglamento Interno de Convivencia Escolar (RICE):\nMedidas Correctivas Anteriores:\n3. Establecimiento de Metas SMART:\n\nEspecíficas: ¿Qué comportamiento exacto se desea mejorar? (Ej. "Reducir la frecuencia de interrupciones durante las clases").\nMedibles: ¿Cómo se medirá el progreso? (Ej. "Número de interrupciones registradas por semana").\nAlcanzables: ¿Es realista alcanzar esta meta con los recursos y tiempo disponibles? (Ej. "Implementar estrategias de autocontrol y técnicas de mindfulness").\nRelevantes: ¿Cómo contribuye esta meta al desarrollo general del alumno? (Ej. "Mejora en la concentración y participación positiva en clase").\nTemporales: ¿Cuál es el plazo para alcanzar esta meta? (Ej. "Reducir el número de interrupciones en un 50% en 2 meses").\n4. Plan de Acción PERL:\n\nPrevenir: ¿Qué medidas se tomarán para evitar la repetición del comportamiento? (Ej. "Establecer un contrato de comportamiento con el alumno y sus padres").\nEmpoderar: ¿Cómo se motivará al alumno a mejorar su comportamiento? (Ej. "Reconocimiento y recompensas por el comportamiento positivo").\nReforzar: ¿Cómo se mantendrá el progreso? (Ej. "Reuniones semanales para revisar avances y ajustar el plan según sea necesario").\nLograr: ¿Qué acciones específicas se tomarán para asegurar el cumplimiento de la meta? (Ej. "Sesiones de orientación y talleres de habilidades sociales").\n5. Cronograma de Revisión:\n\nFechas de Revisión: (Ej. "Revisar el progreso el 1 de septiembre, 15 de septiembre y 1 de octubre").\nResponsable de la Revisión: (Ej. "Tutor del alumno, consejero escolar").\nCriterios de Evaluación: (Ej. "Número de incidentes reportados, observaciones del comportamiento en clase").\n6. Documentación y Seguimiento:\n\nRegistro Detallado: Mantener una carpeta de registro dedicada a cada alumno con toda la información relevante sobre el plan de seguimiento, avances y revisiones.\nInformes Periódicos: Redactar informes exhaustivos después de cada revisión, destacando logros, áreas de mejora y ajustes necesarios al plan.\n7. Evaluación y Ajuste:\n\nEvaluación Final: ¿Se han alcanzado las metas establecidas? (Ej. "Evaluar si el comportamiento del alumno ha mejorado de acuerdo con las metas SMART").\nAjustes Necesarios: ¿Qué cambios se deben realizar en el plan para continuar con el desarrollo del alumno? (Ej. "Modificar estrategias basadas en los resultados de la evaluación").'),
  );
    _chatSession = _model.startChat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Chat con Gemini'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _chatSession.history.length,
                      itemBuilder: (context, index) {
                        final Content content =
                            _chatSession.history.toList()[index];
                        final text = content.parts
                            .whereType<TextPart>()
                            .map<String>(
                              (e) => e.text,
                            )
                            .join('');
                        return MessageWdget(
                          text: text,
                          isFromUser: content.role == 'user',
                        );
                      })),
              Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 25,
                    horizontal: 15,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          child: TextField(
                        autofocus: true,
                        focusNode: _textFielFocus,
                        decoration: textFieldDecoration(),
                        controller: _textController,
                        onSubmitted: _sendChatMessenge,
                      ))
                    ],
                  ))
            ],
          ),
        ));
  }

  InputDecoration textFieldDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(15),
      hintText: 'Ingrese un pregunta...',
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(14),
          ),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.secondary,
          )),
      suffixIcon: _loading ? const CircularProgressIndicator() : const Icon(Icons.send),
    );
  }

  Future<void> _sendChatMessenge(String message) async {
    setState(() {
      _loading = true;
    });

    try {
      final response = await _chatSession.sendMessage(
        Content.text(message),
      );
      final text = response.text;
      if (text == null) {
        _showError('No responde el API.');
        return;
      } else {
        setState(() {
          _loading = false;
          _scrollDown();
        });
      }
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      _textController.clear();
      setState(() {
        _loading = false;
      });
      _textFielFocus.requestFocus();
    }
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(
          microseconds: 750,
        ),
        curve: Curves.easeOutCirc,
      );
    });
  }

  void _showError(String message) {
    showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Algo paso'),
            content: SingleChildScrollView(
              child: SelectableText(message),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cerrar'),
              )
            ],
          );
        });
  }
}
