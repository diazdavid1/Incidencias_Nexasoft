import '../data/almacen_local.dart';
import '../model/incidencia.dart';

class GestorIncidencias {
  final AlmacenLocal datos = AlmacenLocal();
  List<Incidencia> incidencias = [];
  int cantidadPendientes = 0;

  Future<void> iniciar() async {
    incidencias = await datos.leer();
    cantidadPendientes =
        incidencias.where((x) => x.estado == 'Pendiente').length;
  }

  List<Incidencia> buscar(
      String texto, String estadoFiltro, String prioridadFiltro) {
    final busqueda = texto.trim().toLowerCase();

    return incidencias.where((x) {
      // 1. Condición de texto
      bool coincideTexto = true;
      if (busqueda.isNotEmpty) {
        final titulo = x.titulo.toLowerCase();
        final descripcion = x.descripcion.toLowerCase();
        coincideTexto =
            titulo.contains(busqueda) || descripcion.contains(busqueda);
      }

      // 2. Condición de estado
      bool coincideEstado = estadoFiltro == 'Todos' || x.estado == estadoFiltro;

      // 3. Condición de prioridad
      bool coincidePrioridad =
          prioridadFiltro == 'Todas' || x.prioridad == prioridadFiltro;

      // Retorna true solo si pasa los tres filtros al mismo tiempo
      return coincideTexto && coincideEstado && coincidePrioridad;
    }).toList();
  }

  Incidencia? porId(String id) {
    for (var x in incidencias) {
      if (x.id == id) return x;
    }
    return null;
  }

  int contar(String estado) {
    return incidencias.where((x) => x.estado == estado).length;
  }

  Future<void> cambiarEstado(String id, String estado) async {
    for (var i = 0; i < incidencias.length; i++) {
      if (incidencias[i].id == id) {
        incidencias[i].estado = estado;
        break;
      }
    }
    await datos.guardar(incidencias);
  }

  Future<void> crear(String titulo, String descripcion, String cliente,
      String categoria, String prioridad) async {
    final nuevo = Incidencia(
        id: 'INC-${DateTime.now().microsecondsSinceEpoch}',
        titulo: titulo,
        descripcion: descripcion,
        cliente: cliente,
        categoria: categoria,
        estado: 'Pendiente',
        fecha: DateTime.now().toIso8601String().split('T').first,
        prioridad: prioridad);
    incidencias.insert(0, nuevo);
    cantidadPendientes++;
    await datos.guardar(incidencias);
  }

  Future<void> reiniciarDemo() async {
    await datos.restaurarDatosDeEjemplo();
    await iniciar();
  }
}
