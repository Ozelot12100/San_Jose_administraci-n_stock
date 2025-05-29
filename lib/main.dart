import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/insumo_provider.dart';
import 'providers/proveedor_provider.dart';
import 'providers/movimiento_provider.dart';
import 'providers/reporte_provider.dart';
import 'providers/alerta_provider.dart';
import 'routes.dart';
import 'screens/auth/login_screen.dart';
import 'screens/layout/main_layout.dart';
import 'screens/movimientos/movimientos_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar localización para fechas en español
  initializeDateFormatting('es', null);
  Intl.defaultLocale = 'es';
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => InsumoProvider()),
        ChangeNotifierProvider(create: (_) => ProveedorProvider()),
        ChangeNotifierProvider(create: (_) => MovimientoProvider()),
        ChangeNotifierProvider(create: (_) => ReporteProvider()),
        ChangeNotifierProvider(create: (_) => AlertaProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.checkExistingSession();

    // Carga inicial de datos globales
    context.read<InsumoProvider>().fetchInsumos();
    context.read<MovimientoProvider>().fetchMovimientos();
    context.read<ProveedorProvider>().fetchProveedores();
    context.read<AlertaProvider>().fetchAlertas();

    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    
    // Mostrar un indicador de carga mientras se inicializa la aplicación
    if (!_initialized) {
      return MaterialApp(
        title: 'Sistema de Inventario - Clínica San José',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A237E),
            brightness: Brightness.light,
          ),
        ),
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    
    return MaterialApp(
      title: 'Sistema de Inventario - Clínica San José',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E), // Azul institucional
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      // Rutas de la aplicación
      home: authProvider.isAuthenticated
          ? (authProvider.currentUser?.isAdmin ?? false)
              ? const MainLayout()
              : const MovimientosScreen()
          : const LoginScreen(),
      routes: AppRoutes.routes,
    );
  }
}
