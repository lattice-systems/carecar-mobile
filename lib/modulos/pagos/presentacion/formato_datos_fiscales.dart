import '../../../l10n/app_localizations.dart';
import '../dominio/datos_fiscales.dart';

String textoPersona(AppLocalizations textos, TipoPersona persona) =>
    switch (persona) {
      TipoPersona.fisica => textos.datosFiscalesPersonaFisica,
      TipoPersona.moral => textos.datosFiscalesPersonaMoral,
    };

/// Por que un campo no sirve, en palabras para la persona.
String textoMotivoFiscal(AppLocalizations textos, MotivoFiscal motivo) =>
    switch (motivo) {
      MotivoFiscal.rfcVacio => textos.datosFiscalesErrorRfcVacio,
      MotivoFiscal.rfcLargo => textos.datosFiscalesErrorRfcLargo,
      MotivoFiscal.rfcForma => textos.datosFiscalesErrorRfcForma,
      MotivoFiscal.rfcGenerico => textos.datosFiscalesErrorRfcGenerico,
      MotivoFiscal.rfcFecha => textos.datosFiscalesErrorRfcFecha,
      MotivoFiscal.rfcDigito => textos.datosFiscalesErrorRfcDigito,
      MotivoFiscal.razonSocialVacia => textos.datosFiscalesErrorRazonVacia,
      MotivoFiscal.razonSocialLarga => textos.datosFiscalesErrorRazonLarga,
      MotivoFiscal.codigoPostal => textos.datosFiscalesErrorCodigoPostal,
      MotivoFiscal.regimenFalta => textos.datosFiscalesErrorRegimenFalta,
      MotivoFiscal.regimenNoAplica => textos.datosFiscalesErrorRegimenNoAplica,
      MotivoFiscal.usoFalta => textos.datosFiscalesErrorUsoFalta,
      MotivoFiscal.usoNoAplica => textos.datosFiscalesErrorUsoNoAplica,
      MotivoFiscal.usoNoAceptaRegimen =>
        textos.datosFiscalesErrorUsoNoAceptaRegimen,
      MotivoFiscal.correo => textos.datosFiscalesErrorCorreo,
    };
