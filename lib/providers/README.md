# Providers

## Descripción
Los providers son clases que implementan el patrón de gestión de estado recomendado para Flutter. Utilizamos la biblioteca `provider` para compartir datos entre widgets de manera eficiente.

## Contenido

### AuthProvider
Gestiona el estado de autenticación de los usuarios:
- Almacena el usuario actual
- Proporciona métodos para iniciar y cerrar sesión
- Maneja estados de carga y errores durante la autenticación
- Verifica si hay sesiones activas

### ThemeProvider
Controla el tema visual de la aplicación:
- Gestiona el modo claro/oscuro
- Persiste la preferencia de tema usando FlutterSecureStorage
- Permite cambiar entre temas con una sola función

## Uso

```dart
// Acceder a un provider (lectura)
final authProvider = Provider.of<AuthProvider>(context, listen: true);
// O usando el método abreviado:
final authProvider = context.watch<AuthProvider>();

// Acceder a un provider (sin reconstrucción)
final authProvider = Provider.of<AuthProvider>(context, listen: false);
// O usando el método abreviado:
final authProvider = context.read<AuthProvider>();

// Ejemplo de uso:
ElevatedButton(
  onPressed: () async {
    final success = await context.read<AuthProvider>().login(username, password);
    if (success) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  },
  child: Text('Iniciar sesión'),
)
``` 