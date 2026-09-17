import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/local_agent.dart';
import '../data/local_speech.dart';
import '../data/model_library.dart';
import '../domain/schema.dart';
import 'app_model.dart';
import 'custom_pages.dart';
import 'local_model_settings.dart';

void showError(BuildContext context, Object error) => ScaffoldMessenger.of(
  context,
).showSnackBar(SnackBar(content: Text(error.toString())));

class LoginScreen extends StatefulWidget {
  final AppModel model;
  const LoginScreen(this.model, {super.key});
  @override
  State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final url = TextEditingController(
    text: const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:8082',
    ),
  );
  final user = TextEditingController(text: 'admin');
  final password = TextEditingController();
  bool waiting = false;
  bool useServer = false;
  @override
  void dispose() {
    url.dispose();
    user.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.account_balance_outlined, size: 56),
                const SizedBox(height: 20),
                Text(
                  widget.model.schema.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const Text('Tu gestion, tambien sin conexion.'),
                const SizedBox(height: 28),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Conectar a un servidor'),
                  value: useServer,
                  onChanged: waiting
                      ? null
                      : (value) => setState(() => useServer = value),
                ),
                if (useServer)
                  TextField(
                    controller: url,
                    decoration: const InputDecoration(
                      labelText: 'Direccion del backend',
                    ),
                    keyboardType: TextInputType.url,
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: user,
                  decoration: const InputDecoration(labelText: 'Usuario'),
                  autofillHints: const [AutofillHints.username],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  autofillHints: const [AutofillHints.password],
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: waiting
                      ? null
                      : () async {
                          setState(() => waiting = true);
                          try {
                            if (useServer) {
                              await widget.model.login(
                                url.text,
                                user.text,
                                password.text,
                              );
                            } else {
                              await widget.model.loginLocal(
                                user.text,
                                password.text,
                              );
                            }
                          } catch (e) {
                            if (context.mounted) showError(context, e);
                          } finally {
                            if (mounted) setState(() => waiting = false);
                          }
                        },
                  child: Text(waiting ? 'Iniciando…' : 'Iniciar sesion'),
                ),
                const SizedBox(height: 20),
                Text(
                  useServer
                      ? 'El acceso al servidor requiere conexion. Sus datos se guardan por separado de la cuenta local.'
                      : 'Acceso sin internet desde la primera instalacion. Usuario: admin · Contraseña: admin. Tus registros se guardan en este dispositivo.',
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class HomeScreen extends StatefulWidget {
  final AppModel model;
  const HomeScreen(this.model, {super.key});
  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> with WidgetsBindingObserver {
  int tab = 0;
  String query = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(widget.model.sync());
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.model;
    final pages = customPages.where((p) => p.supports(m)).toList();
    final visible = m.rows
        .where(
          (r) => r.values.join(' ').toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(m.schema.title),
        actions: [
          if (pages.isNotEmpty)
            PopupMenuButton<AppPage>(
              tooltip: 'Pantallas de la aplicacion',
              icon: const Icon(Icons.dashboard_customize_outlined),
              itemBuilder: (context) => pages
                  .map((p) => PopupMenuItem(value: p, child: Text(p.title)))
                  .toList(),
              onSelected: (page) => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => ListenableBuilder(
                    listenable: m,
                    builder: (context, _) => page.builder(context, m),
                  ),
                ),
              ),
            ),
          if (!m.isLocal)
            IconButton(
              tooltip: 'Sincronizar',
              onPressed: m.busy ? null : () => m.sync(),
              icon: const Icon(Icons.sync),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view),
            label: 'Registros',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome),
            label: 'Asistente',
          ),
          NavigationDestination(icon: Icon(Icons.tune), label: 'Ajustes'),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (m.busy) const LinearProgressIndicator(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    m.isLocal
                        ? Icons.phone_android
                        : m.queue.isEmpty
                        ? Icons.cloud_done_outlined
                        : Icons.cloud_upload_outlined,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      m.isLocal
                          ? 'Sin conexion · Guardado en este dispositivo'
                          : '${m.queue.length} pendientes · ${m.message}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: tab,
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButtonFormField<String>(
                          initialValue: m.selected.resource,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Coleccion',
                          ),
                          items: m.schema.resources
                              .map(
                                (r) => DropdownMenuItem(
                                  value: r.resource,
                                  child: Text(r.className),
                                ),
                              )
                              .toList(),
                          onChanged: m.busy
                              ? null
                              : (v) {
                                  if (v != null) m.select(m.schema.resource(v));
                                },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            labelText: 'Buscar en datos locales',
                          ),
                          onChanged: (v) => setState(() => query = v),
                        ),
                      ),
                      Expanded(
                        child: visible.isEmpty
                            ? const Center(
                                child: Text(
                                  'No hay registros. Crea el primero.',
                                ),
                              )
                            : ListView.builder(
                                itemCount: visible.length,
                                itemBuilder: (context, index) {
                                  final row = visible[index];
                                  final title =
                                      row.entries
                                          .where(
                                            (e) =>
                                                e.key !=
                                                    m.selected.primaryKey &&
                                                e.value is String,
                                          )
                                          .firstOrNull
                                          ?.value
                                          ?.toString() ??
                                      row[m.selected.primaryKey].toString();
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 5,
                                    ),
                                    child: ListTile(
                                      title: Text(title),
                                      subtitle: Text(
                                        row.entries
                                            .take(3)
                                            .map(
                                              (e) =>
                                                  '${e.key}: ${e.value ?? "—"}',
                                            )
                                            .join('\n'),
                                      ),
                                      isThreeLine: true,
                                      onTap: m.busy
                                          ? null
                                          : () => edit(context, m, row),
                                      trailing: IconButton(
                                        tooltip: 'Eliminar',
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: m.busy
                                            ? null
                                            : () async {
                                                final resource = m.selected;
                                                final yes = await confirm(
                                                  context,
                                                  'Eliminar $title',
                                                  m.isLocal
                                                      ? 'El cambio se guardara en este dispositivo.'
                                                      : 'El cambio se guardara localmente y se enviara al sincronizar.',
                                                );
                                                if (yes) {
                                                  try {
                                                    await m.delete(
                                                      resource,
                                                      row[resource.primaryKey],
                                                      expected: row,
                                                    );
                                                  } catch (e) {
                                                    if (context.mounted)
                                                      showError(context, e);
                                                  }
                                                }
                                              },
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: FilledButton.icon(
                          onPressed: m.busy
                              ? null
                              : () => edit(context, m, null),
                          icon: const Icon(Icons.add),
                          label: const Text('Nuevo registro'),
                        ),
                      ),
                    ],
                  ),
                  AgentScreen(m, visible),
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'Cuenta y sincronizacion',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${m.session!.username}\n${m.isLocal ? 'Cuenta local · funciona sin internet' : m.session!.url}',
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: m.busy
                            ? null
                            : () async {
                                if (await confirm(
                                  context,
                                  'Cerrar sesion',
                                  m.isLocal
                                      ? 'Tus registros se conservan. Puedes volver a entrar con admin / admin sin internet.'
                                      : 'Los datos pendientes se conservan para la misma cuenta. El siguiente acceso al servidor requiere conexion.',
                                )) {
                                  try {
                                    await m.logout();
                                  } catch (e) {
                                    if (context.mounted) showError(context, e);
                                  }
                                }
                              },
                        child: const Text('Cerrar sesion / cambiar cuenta'),
                      ),
                      const Divider(),
                      Text(
                        m.isLocal
                            ? 'La cuenta local utiliza el modelo incluido en esta app. Sus registros permanecen en este dispositivo y no se envian al servidor.'
                            : 'Para renovar el acceso remoto, vuelve a iniciar sesion con la misma cuenta. Los datos de otra cuenta o servidor se guardan por separado.',
                      ),
                      if (!m.isLocal)
                        ...m.queue.map(
                          (q) => Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${q["method"]} ${q["resource"]} · ${q["id"]}',
                                  ),
                                  Text(
                                    q['message']?.toString() ??
                                        'Pendiente de confirmacion',
                                  ),
                                  if (q['status'] == 'conflict')
                                    TextButton(
                                      onPressed: m.busy
                                          ? null
                                          : () async {
                                              if (await confirm(
                                                context,
                                                'Aceptar version del servidor',
                                                'Se descarta este cambio local rechazado. Los cambios dependientes podrian necesitar correccion.',
                                              )) {
                                                try {
                                                  await m.acceptServer(
                                                    q['operation_id'] as String,
                                                  );
                                                } catch (e) {
                                                  if (context.mounted)
                                                    showError(context, e);
                                                }
                                              }
                                            },
                                      child: const Text(
                                        'Descartar cambio y aceptar servidor',
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> confirm(
  BuildContext context,
  String title,
  String message,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    ) ??
    false;
Future<void> edit(
  BuildContext context,
  AppModel model,
  Map<String, dynamic>? value,
) async {
  final resource = model.selected;
  final result = await Navigator.push<Map<String, dynamic>>(
    context,
    MaterialPageRoute(builder: (_) => RecordForm(resource, model, value)),
  );
  if (result != null) {
    try {
      await model.save(
        resource,
        result,
        create: value == null,
        expected: value,
      );
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }
}

class RecordForm extends StatefulWidget {
  final ResourceSpec resource;
  final AppModel model;
  final Map<String, dynamic>? initial;
  const RecordForm(this.resource, this.model, this.initial, {super.key});
  @override
  State<RecordForm> createState() => _RecordFormState();
}

class _RecordFormState extends State<RecordForm> {
  late final Map<String, TextEditingController> fields;
  @override
  void initState() {
    super.initState();
    fields = {
      for (final f in widget.resource.fields)
        f.name: TextEditingController(
          text:
              widget.initial?[f.name]?.toString() ??
              (f.primaryKey && f.javaType == 'UUID' ? const Uuid().v4() : ''),
        ),
    };
  }

  @override
  void dispose() {
    for (final c in fields.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        '${widget.initial == null ? "Crear" : "Editar"} ${widget.resource.className}',
      ),
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ...widget.resource.fields.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextField(
                controller: fields[f.name],
                readOnly: f.primaryKey && widget.initial != null,
                keyboardType: f.numeric
                    ? const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      )
                    : TextInputType.text,
                decoration: InputDecoration(
                  labelText: '${f.name}${f.nullable ? "" : " *"}',
                  helperText: f.references != null
                      ? 'ID de ${f.references}'
                      : f.javaType,
                ),
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              try {
                final data = {
                  for (final f in widget.resource.fields)
                    f.name: f.parse(fields[f.name]!.text),
                };
                widget.resource.validate(data);
                Navigator.pop(context, data);
              } catch (e) {
                showError(context, e);
              }
            },
            child: const Text('Guardar en el dispositivo'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Los cambios se guardan en el dispositivo. Las claves deben ser unicas. En una cuenta de servidor, se sincronizan cuando este disponible.',
          ),
        ],
      ),
    ),
  );
}

class AgentScreen extends StatefulWidget {
  final AppModel model;
  final List<Map<String, dynamic>> rows;
  const AgentScreen(this.model, this.rows, {super.key});
  @override
  State<AgentScreen> createState() => _AgentState();
}

class _AgentState extends State<AgentScreen> with WidgetsBindingObserver {
  ModelLibrary? library;
  LocalAgent? agent;
  LocalSpeech? speech;
  final text = TextEditingController();
  String status = 'Abriendo biblioteca de modelos locales…';
  bool busy = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(initialize());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && (speech?.capturing ?? false)) {
      unawaited(cancelDictation());
    }
  }

  Future<void> initialize() async {
    try {
      final loaded = await ModelLibrary.open();
      if (!mounted) return;
      library = loaded;
      agent = LocalAgent(loaded);
      speech = LocalSpeech(loaded);
      status =
          'Elige el origen del texto y de la voz: modelo local importado o IA en linea. Puedes escribir sin voz.';
    } catch (error) {
      status = 'No se pudo abrir la biblioteca: $error';
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    text.dispose();
    unawaited(speech?.close());
    unawaited(agent?.close());
    super.dispose();
  }

  Future<void> run(Future<void> Function() action) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => status = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> finishDictation() => run(() async {
    final transcript = await speech!.finish(widget.model.selected);
    if (!mounted) return;
    text.text = transcript;
    status =
        '${speech!.engineLabel}: ${(speech!.lastMilliseconds / 1000).toStringAsFixed(1)} s. Revisa el texto antes de preparar la propuesta.';
  });

  Future<void> cancelDictation() async {
    try {
      await speech?.cancel();
      if (mounted) setState(() => status = 'Dictado cancelado');
    } catch (error) {
      if (mounted) setState(() => status = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text('Asistente', style: Theme.of(context).textTheme.headlineSmall),
      const Text('Una accion a la vez. Revisa la propuesta antes de guardar.'),
      const SizedBox(height: 16),
      if (library != null)
        LocalModelSettings(
          library: library!,
          disabled: busy || (speech?.recording ?? false),
          run: run,
        ),
      const SizedBox(height: 16),
      Text(status),
      if (busy) const LinearProgressIndicator(),
      const SizedBox(height: 16),
      Text(
        'Coleccion: ${widget.model.selected.className}. Registros filtrados: ${widget.rows.length}.',
      ),
      const SizedBox(height: 12),
      TextField(
        controller: text,
        minLines: 3,
        maxLines: 7,
        decoration: const InputDecoration(labelText: 'Instruccion'),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: busy || !(library?.speechReady ?? false)
                ? null
                : () async {
                    if (speech!.recording) {
                      await finishDictation();
                    } else {
                      await run(() async {
                        await speech!.start(() {
                          if (mounted) unawaited(finishDictation());
                        });
                        if (mounted)
                          setState(
                            () => status =
                                'Grabando localmente. Maximo 45 segundos.',
                          );
                      });
                    }
                  },
            icon: const Icon(Icons.mic_none),
            label: Text(
              (speech?.recording ?? false)
                  ? 'Parar y transcribir'
                  : 'Dictar',
            ),
          ),
          if (speech?.recording ?? false)
            TextButton(
              onPressed: busy
                  ? null
                  : () => run(() async {
                      await speech!.cancel();
                      status = 'Dictado cancelado';
                    }),
              child: const Text('Cancelar dictado'),
            ),
          FilledButton(
            onPressed:
                busy ||
                    (speech?.recording ?? false) ||
                    !(agent?.loaded ?? false)
                ? null
                : () => run(() async {
                    final resource = widget.model.selected;
                    final rows = widget.rows
                        .map((r) => Map<String, dynamic>.from(r))
                        .toList();
                    final proposal = await agent!.propose(
                      text.text,
                      widget.model.schema,
                      resource,
                      rows,
                    );
                    if (!context.mounted) return;
                    setState(
                      () => status =
                          'Texto (${agent!.engineLabel}): ' +
                          (agent!.lastMilliseconds / 1000).toStringAsFixed(1) +
                          ' s.',
                    );
                    if (proposal.action == 'LIST') {
                      await showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            '${resource.className}: ${rows.length} registros locales',
                          ),
                          content: SingleChildScrollView(
                            child: SelectableText(
                              const JsonEncoder.withIndent('  ').convert(rows),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cerrar'),
                            ),
                          ],
                        ),
                      );
                      return;
                    }
                    final expected = proposal.action == 'CREATE'
                        ? null
                        : rows
                              .where(
                                (r) =>
                                    r[resource.primaryKey].toString() ==
                                    proposal.id.toString(),
                              )
                              .firstOrNull;
                    if (proposal.action != 'CREATE' && expected == null)
                      throw StateError(
                        'Selecciona un registro presente en la lista local.',
                      );
                    if (!await confirm(
                      context,
                      'Revisar cambio',
                      const JsonEncoder.withIndent(
                        '  ',
                      ).convert(proposal.toJson()),
                    ))
                      return;
                    if (proposal.action == 'DELETE') {
                      await widget.model.delete(
                        resource,
                        proposal.id,
                        expected: expected,
                      );
                    } else {
                      await widget.model.save(
                        resource,
                        proposal.data!,
                        create: proposal.action == 'CREATE',
                        expected: expected,
                      );
                    }
                    if (mounted)
                      setState(
                        () => status =
                            'Cambio guardado localmente. Texto: ${(agent!.lastMilliseconds / 1000).toStringAsFixed(1)} s.',
                      );
                  }),
            child: const Text('Preparar propuesta'),
          ),
          if (busy && (agent?.processing ?? false))
            TextButton(
              onPressed: () => agent?.stop(),
              child: const Text('Detener IA'),
            ),
          if (busy && (speech?.transcribing ?? false))
            TextButton(
              onPressed: cancelDictation,
              child: const Text('Descartar transcripcion'),
            ),
        ],
      ),
      const SizedBox(height: 16),
      const Text(
        'Con modelos locales, voz y texto se procesan en el dispositivo sin llamar a ninguna API. Con IA en linea, la instruccion o el audio viajan al proveedor que configuraste con tu clave. En ambos casos la transcripcion no ejecuta cambios y cada propuesta se revisa y confirma antes de guardarse en el dispositivo.',
      ),
    ],
  );
}
