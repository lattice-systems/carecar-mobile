import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/excepciones.dart';
import '../../../api/modelos/problema.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../dominio/pase_de_wallet.dart';
import 'proveedores_pase_wallet.dart';

/// Boton «Agregar a Wallet» del comprobante (V2-M25.03).
///
/// Pide el pase firmado de la cita al backend y lo entrega al sistema: Google
/// Wallet en Android, el `.pkpass` en iOS. Muestra carga mientras pide, y el
/// error en linea (sin red, cita cancelada, Wallet no configurado) con la
/// posibilidad de reintentar. Donde no hay Wallet no se dibuja. El pase no se
/// guarda: cada toque lo pide de nuevo.
class BotonAgregarAWallet extends ConsumerStatefulWidget {
  const BotonAgregarAWallet({
    required this.citaId,
    super.key,
    this.pildora = false,
  });

  final int citaId;

  /// Dibuja la acción como píldora del estilo portada (comprobante) en vez
  /// del botón secundario. Mismos estados y mismos errores en línea.
  final bool pildora;

  @override
  ConsumerState<BotonAgregarAWallet> createState() =>
      _BotonAgregarAWalletState();
}

enum _Falla { generica, sinConexion, citaCancelada, noDisponible }

class _BotonAgregarAWalletState extends ConsumerState<BotonAgregarAWallet> {
  bool _cargando = false;
  _Falla? _falla;

  Future<void> _agregar(PlataformaWallet plataforma) async {
    setState(() {
      _cargando = true;
      _falla = null;
    });
    _Falla? falla;
    try {
      final pase = await ref
          .read(repositorioPaseWalletProvider)
          .obtener(widget.citaId, plataforma);
      await ref
          .read(entregaDePaseProvider)
          .entregar(pase, citaId: widget.citaId);
    } on SinConexion {
      falla = _Falla.sinConexion;
    } on ExcepcionApi catch (e) {
      falla = switch (e.problema?.codigo) {
        CodigoProblema.citaCancelada => _Falla.citaCancelada,
        CodigoProblema.walletNoConfigurado => _Falla.noDisponible,
        _ => _Falla.generica,
      };
    } on Object {
      falla = _Falla.generica;
    }
    if (!mounted) return;
    setState(() {
      _cargando = false;
      _falla = falla;
    });
  }

  /// Píldora llena; mientras pide el pase queda deshabilitada y el lector de
  /// pantalla anuncia «cargando», igual que el botón secundario.
  Widget _pildora(BuildContext context, String texto, PlataformaWallet p) {
    final pildora = BotonPildora(
      texto: texto,
      icono: Icons.account_balance_wallet_outlined,
      expandido: true,
      alPresionar: _cargando ? null : () => _agregar(p),
    );
    if (!_cargando) return pildora;
    return Semantics(
      button: true,
      label: AppLocalizations.of(context).botonCargando(texto),
      excludeSemantics: true,
      child: pildora,
    );
  }

  @override
  Widget build(BuildContext context) {
    final plataforma = ref.watch(plataformaWalletProvider);
    if (plataforma == null) return const SizedBox.shrink();

    final textos = AppLocalizations.of(context);
    final falla = _falla;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.pildora)
          _pildora(context, textos.citasWalletAgregar, plataforma)
        else
          Boton(
            texto: textos.citasWalletAgregar,
            icono: Icons.account_balance_wallet_outlined,
            variante: VarianteBoton.secundario,
            anchoCompleto: true,
            cargando: _cargando,
            alPresionar: () => _agregar(plataforma),
          ),
        if (falla != null) ...[
          const SizedBox(height: Espaciado.e3),
          Aviso(
            tono: Tono.advertencia,
            mensaje: switch (falla) {
              _Falla.generica => textos.citasWalletErrorGenerico,
              _Falla.sinConexion => textos.citasWalletErrorSinConexion,
              _Falla.citaCancelada => textos.citasWalletErrorCancelada,
              _Falla.noDisponible => textos.citasWalletErrorNoDisponible,
            },
          ),
        ],
      ],
    );
  }
}
