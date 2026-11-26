import '../dominio/datos_fiscales.dart';
import '../dominio/repositorio_datos_fiscales.dart';

/// Datos fiscales en memoria para pruebas. Aplica las mismas reglas del
/// predeterminado que el servidor; el catalogo se le da (vacio si no). Con
/// [falla] todo falla como la red; con [rechazo] el alta y la edicion
/// responden lo que el servidor diria.
class RepositorioDatosFiscalesFake implements RepositorioDatosFiscales {
  RepositorioDatosFiscalesFake({
    CatalogoFiscal? catalogo,
    List<PerfilFiscal> perfiles = const [],
    this.falla,
    this.rechazo,
    DateTime Function()? reloj,
  }) : catalogoActual =
           catalogo ?? const CatalogoFiscal(regimenes: [], usosCfdi: []),
       perfilesActuales = [...perfiles],
       _reloj = reloj ?? DateTime.now;

  CatalogoFiscal catalogoActual;
  List<PerfilFiscal> perfilesActuales;
  Object? falla;
  Map<CampoFiscal, String>? rechazo;
  final DateTime Function() _reloj;

  int catalogosPedidos = 0;
  int listasPedidas = 0;
  final enviados = <BorradorPerfilFiscal>[];
  final borrados = <int>[];
  var _siguienteId = 300;

  Future<void> _quizaFalla() async {
    final error = falla;
    if (error != null) throw error;
  }

  @override
  Future<CatalogoFiscal> catalogo() async {
    catalogosPedidos++;
    await _quizaFalla();
    return catalogoActual;
  }

  @override
  Future<List<PerfilFiscal>> perfiles() async {
    listasPedidas++;
    await _quizaFalla();
    return _ordenados();
  }

  @override
  Future<PerfilFiscal> crear(BorradorPerfilFiscal borrador) async {
    enviados.add(borrador);
    await _quizaFalla();
    _quizaRechaza();
    final primero = perfilesActuales.isEmpty;
    final nuevo = _perfil(
      _siguienteId++,
      borrador,
      predeterminado: primero || borrador.predeterminado,
      creadoEn: _reloj(),
    );
    if (nuevo.predeterminado) _quitarPredeterminado();
    perfilesActuales = [...perfilesActuales, nuevo];
    return nuevo;
  }

  @override
  Future<PerfilFiscal> editar(int id, BorradorPerfilFiscal borrador) async {
    enviados.add(borrador);
    await _quizaFalla();
    _quizaRechaza();
    final actual = perfilesActuales.firstWhere((p) => p.id == id);
    final predeterminado = actual.predeterminado || borrador.predeterminado;
    if (predeterminado && !actual.predeterminado) _quitarPredeterminado();
    final editado = _perfil(
      id,
      borrador,
      predeterminado: predeterminado,
      creadoEn: actual.creadoEn,
    );
    perfilesActuales = [
      for (final p in perfilesActuales) p.id == id ? editado : p,
    ];
    return editado;
  }

  @override
  Future<void> borrar(int id) async {
    borrados.add(id);
    await _quizaFalla();
    final borrado = perfilesActuales.firstWhere((p) => p.id == id);
    perfilesActuales = perfilesActuales.where((p) => p.id != id).toList();
    if (borrado.predeterminado && perfilesActuales.isNotEmpty) {
      final siguiente = perfilesActuales.first;
      perfilesActuales = [
        for (final p in perfilesActuales)
          p.id == siguiente.id ? _conPredeterminado(p, true) : p,
      ];
    }
  }

  void _quizaRechaza() {
    final campos = rechazo;
    if (campos != null) throw DatosFiscalesRechazados(campos);
  }

  List<PerfilFiscal> _ordenados() => [
    ...perfilesActuales.where((p) => p.predeterminado),
    ...perfilesActuales.where((p) => !p.predeterminado),
  ];

  void _quitarPredeterminado() {
    perfilesActuales = [
      for (final p in perfilesActuales) _conPredeterminado(p, false),
    ];
  }

  static PerfilFiscal _conPredeterminado(PerfilFiscal p, bool valor) =>
      PerfilFiscal(
        id: p.id,
        rfc: p.rfc,
        tipoPersona: p.tipoPersona,
        razonSocial: p.razonSocial,
        regimenFiscal: p.regimenFiscal,
        codigoPostal: p.codigoPostal,
        usoCfdi: p.usoCfdi,
        correo: p.correo,
        predeterminado: valor,
        creadoEn: p.creadoEn,
      );

  static PerfilFiscal _perfil(
    int id,
    BorradorPerfilFiscal b, {
    required bool predeterminado,
    required DateTime creadoEn,
  }) {
    final correo = b.correo.trim();
    return PerfilFiscal(
      id: id,
      rfc: b.rfcNormalizado,
      tipoPersona: b.tipoPersona ?? TipoPersona.fisica,
      razonSocial: b.razonSocial.trim().toUpperCase(),
      regimenFiscal: b.regimenFiscal ?? '',
      codigoPostal: b.codigoPostal.trim(),
      usoCfdi: b.usoCfdi ?? '',
      correo: correo.isEmpty ? null : correo.toLowerCase(),
      predeterminado: predeterminado,
      creadoEn: creadoEn,
    );
  }
}
