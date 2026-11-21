import 'package:flutter/material.dart';

import '../tema/tema_carecar.dart';

/// Logo de CareCar: icono de Agencia360 en tarjeta y wordmark «CareCar».
/// [tamano] es el lado del icono; el texto se escala con el.
/// [claro] es la variante para fondo oscuro (texto blanco).
class LogoCareCar extends StatelessWidget {
  const LogoCareCar({
    this.tamano = 40,
    this.claro = true,
    this.vertical = false,
    this.llaveIcono,
    super.key,
  });

  final double tamano;
  final bool claro;
  final bool vertical;
  final Key? llaveIcono;

  @override
  Widget build(BuildContext context) {
    final radio = tamano * 0.25;
    final grande = tamano > 80;
    final icono = Container(
      key: llaveIcono,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radio + 2),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: grande ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: TemaCareCar.turquesa.withValues(alpha: 0.35),
            blurRadius: tamano * 0.36,
            spreadRadius: grande ? 2 : 0,
          ),
          if (grande)
            const BoxShadow(
              color: Color(0x66000000),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radio),
        child: Image.asset(
          'assets/marca/agencia360-icono.png',
          width: tamano,
          height: tamano,
          filterQuality: FilterQuality.high,
          isAntiAlias: true,
          semanticLabel: 'CareCar',
        ),
      ),
    );
    final texto = Text.rich(
      TextSpan(
        children: [
          const TextSpan(text: 'Care'),
          TextSpan(
            text: 'Car',
            style: TextStyle(
              color: claro ? TemaCareCar.turquesa : TemaCareCar.turquesaOscuro,
            ),
          ),
        ],
      ),
      maxLines: 1,
      // El logo es una marca: no crece con el tamano de texto del sistema.
      textScaler: TextScaler.noScaling,
      style: TextStyle(
        fontFamily: 'Inter',
        color: claro ? Colors.white : TemaCareCar.azulProfundo,
        fontSize: vertical ? tamano * 0.4 : tamano * 0.5,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    );
    return vertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icono,
              SizedBox(height: tamano * 0.25),
              texto,
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icono,
              SizedBox(width: tamano * 0.25),
              texto,
            ],
          );
  }
}
