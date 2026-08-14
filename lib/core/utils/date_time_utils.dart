
import '../models/turma/Turma.dart';

class DateTimeUtils {
  /// Retorna lista de siglas dos dias com aula na turma
  static List<String> obterDiasAtivos(Turma turma) {
    final dias = <String>[];
    if (turma.aulaSegunda == true) dias.add("SEG");
    if (turma.aulaTerca == true) dias.add("TER");
    if (turma.aulaQuarta == true) dias.add("QUA");
    if (turma.aulaQuinta == true) dias.add("QUI");
    if (turma.aulaSexta == true) dias.add("SEX");
    if (turma.aulaSabado == true) dias.add("SÁB");
    if (turma.aulaDomingo == true) dias.add("DOM");
    return dias;
  }

  /// Transforma "08:30:00" em "08:30"
  static String formatarHora(String? hora) {
    if (hora == null || hora.isEmpty) return "--:--";
    return hora.length >= 5 ? hora.substring(0, 5) : hora;
  }
}