# Práctica 05: Ridgets App — Catálogo Interactivo de Widgets con Material 3, GoRouter y Riverpod

- **Asignatura:** Desarrollo Móvil Integral (10° Cuatrimestre)
- **Carrera:** Ingeniería en Desarrollo y Gestión de Software
- **Docente:** M.T.I. Marco Antonio Ramírez Hernández
- **Alumno:** Francisco García García
- **Matrícula:** 230758
- **Periodo:** Septiembre - Diciembre 2026
- **Valor:** 40 Firmas

---

## Objetivo de la Práctica

Diseñar, estructurar y desarrollar una aplicación móvil multiplataforma en **Flutter** denominada **Ridgets App**, cuyo propósito es fungir como un catálogo interactivo y demostrativo de componentes visuales bajo las directrices de **Material Design 3**, integrando navegación declarativa mediante **GoRouter** y administración de estado reactiva global con **Riverpod** (`StateProvider` y `StateNotifierProvider`).

El proyecto consolida los siguientes conceptos clave de desarrollo móvil:
- **Gestión de Estado con Riverpod:** Implementación de `Provider`, `StateProvider` y `StateNotifierProvider` (`ThemeNotifier`) para sincronizar el contador reactivo, la paleta de colores y el cambio entre **Modo Claro y Modo Oscuro** tanto en `CounterScreen` como en `ThemeChangerScreen`.
- **Navegación Declarativa (`go_router`):** Configuración centralizada de rutas con nombres estáticos, transiciones desde `SplashScreen` hacia `HomeScreen` y navegación mediante `NavigationDrawer` (`SideMenu`).
- **Catálogo de Widgets Material 3:** Demostración práctica de botones (`ButtonsScreen`), tarjetas (`CardsScreen`), indicadores de progreso (`ProgressScreen`), notificaciones y modales (`SnackbarScreen`), contenedores animados (`AnimatedScreen`), controles de formulario (`UiControlsScreen`), carrusel introductorio (`AppTutorialScreen`) y listas asíncronas con paginación infinita (`InfiniteScrollScreen`).
- **Identidad Visual y Splash Screen Personalizado:** Eliminación del splash nativo por defecto de Flutter y reemplazo por un `SplashScreen` animado con fondo degradado basado en la paleta cromática del ícono oficial (`assets/images/logo.jpg`) y el color primario por defecto de la aplicación (`Colors.blue`), además de la configuración del ícono de lanzador nativo y el nombre comercial **Ridgets App**.

---

## Tecnologías y Dependencias Utilizadas

| Dependencia / Herramienta | Versión | Propósito en el Proyecto |
| :--- | :---: | :--- |
| **Flutter SDK** | `^3.13.3` | Framework multiplataforma para construcción de interfaces compiladas nativamente. |
| **Dart SDK** | `^3.13.3` | Lenguaje de programación orientado a objetos con tipado estático y nulabilidad segura. |
| **flutter_riverpod** | `^3.4.3` | Gestor de estado reactivo e inyección de dependencias (`ProviderScope`, `ConsumerWidget`, `StateNotifier`). |
| **go_router** | `^18.0.2` | Enrutador declarativo basado en URLs para navegación profunda y reemplazo de pila (`context.go`, `context.push`). |
| **animate_do** | `^5.1.0` | Biblioteca de animaciones declarativas (`FadeInRight`, `FadeIn`, `SpinPerfect`). |
| **flutter_launcher_icons** | `^0.14.4` | Generación automatizada de íconos nativos para Android, iOS, Web y Windows a partir de `assets/images/logo.jpg`. |
| **Material Design 3** | Nativo | Sistema de diseño moderno activado con `useMaterial3: true` y `colorSchemeSeed`. |
| **Archify** | `2.17.0` | Generación de diagramas interactivos de arquitectura en HTML/SVG con soporte Claro/Oscuro. |

---

## Guía de Instalación y Ejecución

### Requisitos Previos
1. **Flutter SDK** configurado en el `PATH` del sistema (`flutter doctor` sin errores).
2. Emulador Android (API 21+) o dispositivo físico con depuración USB activa.

### Pasos de Despliegue

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/F-Anks/10A_DMI_230758.git
   ```

2. **Navegar al directorio de la práctica:**
   ```bash
   cd 10A_DMI_230758/Practica05/flutter_widgets_app
   ```

3. **Instalar las dependencias:**
   ```bash
   flutter pub get
   ```

4. **Generar los íconos nativos de la aplicación (opcional si ya están generados):**
   ```bash
   dart run flutter_launcher_icons
   ```

5. **Ejecutar la aplicación en el emulador o dispositivo conectado:**
   ```bash
   flutter run
   ```

---

## Arquitectura del Proyecto

El código fuente sigue una estructura modular organizada en capas de configuración (`config`) y presentación (`presentation`):

```
📦 flutter_widgets_app/
├── 📂 assets/
│   └── 📂 images/                             ← Recursos gráficos, logo.jpg y capturas de evidencia
│
├── 📂 architecture/                           ← Diagramas interactivos generados con Archify
│
├── 📂 lib/
│   ├── 📂 config/                             ← Configuración transversal de la aplicación
│   │   ├── 📂 menu/
│   │   │   └── 📄 menu_items.dart             ← Definición inmutable de opciones de navegación (MenuItem)
│   │   ├── 📂 router/
│   │   │   └── 📄 app_router.dart             ← Configuración de GoRouter (12 rutas, inicio en /splash)
│   │   └── 📂 theme/
│   │       └── 📄 app_theme.dart              ← Clase AppTheme con paleta de 9 colores, modo oscuro y copyWith
│   │
│   ├── 📂 presentation/                       ← Capa de Presentación (UI, Widgets y Estado con Riverpod)
│   │   ├── 📂 providers/
│   │   │   ├── 📄 counter_provider.dart       ← StateProvider<int> para el contador reactivo
│   │   │   └── 📄 theme_provider.dart         ← StateNotifierProvider<ThemeNotifier, AppTheme> para tema y modo oscuro
│   │   ├── 📂 screens/
│   │   │   ├── 📂 splash/
│   │   │   │   └── 📄 splash_screen.dart      ← Splash animado con degradado, logo y título "Ridgets App"
│   │   │   ├── 📂 home/
│   │   │   │   └── 📄 home_screen.dart        ← Pantalla principal con listado de secciones y Drawer
│   │   │   ├── 📂 counter/
│   │   │   │   └── 📄 counter_screen.dart     ← Contador Riverpod con conmutador de Modo Oscuro / Claro
│   │   │   ├── 📂 buttons/
│   │   │   │   └── 📄 buttons_screen.dart     ← Demostración de variantes de botones Material 3 y botón personalizado
│   │   │   ├── 📂 cards/
│   │   │   │   └── 📄 cards_screen.dart       ← Tarjetas con elevación, bordes, relleno e imágenes de red
│   │   │   ├── 📂 progress/
│   │   │   │   └── 📄 progress_screen.dart    ← Indicadores de progreso circulares/lineales controlados por Stream
│   │   │   ├── 📂 snackbar/
│   │   │   │   └── 📄 snackbar_screen.dart    ← Snackbars personalizados y diálogos modales de licencias/alerta
│   │   │   ├── 📂 animated/
│   │   │   │   └── 📄 animated_screen.dart    ← AnimatedContainer con geometría, color y bordes aleatorios
│   │   │   ├── 📂 ui_controls/
│   │   │   │   └── 📄 ui_controls_screen.dart ← SwitchListTile, ExpansionTile, RadioListTile y CheckboxListTile
│   │   │   ├── 📂 app_tutorial/
│   │   │   │   └── 📄 app_tutorial_screen.dart← PageView introductorio con detección de última página
│   │   │   ├── 📂 infinite_scroll/
│   │   │   │   └── 📄 infinite_scroll_screen.dart ← Paginación asíncrona con Picsum Photos y Pull to Refresh
│   │   │   ├── 📂 theme_changer/
│   │   │   │   └── 📄 theme_changer_screen.dart   ← Selector reactivo de paleta de colores y modo oscuro/claro
│   │   │   └── 📄 screens.dart                ← Archivo barril (barrel file) de exportación de pantallas
│   │   └── 📂 widgets/
│   │       └── 📄 side_menu.dart              ← NavigationDrawer adaptable a notch con secciones divididas
│   │
│   └── 📄 main.dart                           ← Punto de entrada con ProviderScope y MaterialApp.router
│
└── 📄 pubspec.yaml                            ← Manifiesto de dependencias, assets e ícono nativo
```

---

## Diagrama de Arquitectura del Proyecto

Se incluye el diagrama interactivo de la arquitectura generado con **Archify**, ilustrando el flujo entre dependencias, proveedores de Riverpod (`ThemeNotifier` y `counterProvider`), enrutamiento con `GoRouter` y las pantallas de presentación:

- **[Ver Diagrama en Vivo (GitHub Pages)](https://f-anks.github.io/10A_DMI_230758/Practica05/flutter_widgets_app/architecture/flutter_widgets_app-architecture.html)**
- **[Archivo Local HTML](architecture/flutter_widgets_app-architecture.html)** | **[Esquema JSON](architecture/flutter_widgets_app.architecture.json)**

| Modo Oscuro | Modo Claro |
| :---: | :---: |
| ![Arquitectura Dark](architecture/flutter_widgets_app-architecture.visual-check.1440x900.dark.png) | ![Arquitectura Light](architecture/flutter_widgets_app-architecture.visual-check.1440x900.light.png) |

---

## Evidencias Visuales y Secciones Implementadas

### 1. Identidad de la App (`Ridgets App`) y Splash Screen Personalizado
Se reemplazó el splash de inicio por defecto de Flutter (ocultando el ícono nativo del sistema en Android 12+ mediante `transparent_icon.xml` y `styles.xml`) por un **`SplashScreen` personalizado** que muestra el ícono oficial (`assets/images/logo.jpg`), el título **Ridgets App** y un fondo con degradado dinámico que combina la paleta cromática del ícono (azul medianoche `#060B26`, violeta `#5E35B1`, cian `#00E5FF`, magenta `#AB47BC`) con el color por defecto de la aplicación (`Colors.blue`). Asimismo, se generó e instaló el ícono de lanzador nativo en el sistema operativo.

| Splash Screen con Degradado (`Ridgets App`) | Ícono Nativo en el Lanzador de Android | Logo Oficial (`assets/images/logo.jpg`) |
| :---: | :---: | :---: |
| <img src="assets/images/00_splash_screen.png" alt="Splash Screen Ridgets App" width="260"/> | <img src="assets/images/13_app_icon.png" alt="Icono Ridgets App en Android" width="260"/> | <img src="assets/images/logo.jpg" alt="Logo Ridgets App" width="240"/> |

---

### 2. Pantalla Principal (`HomeScreen`) y Menú Lateral (`SideMenu`)
Listado principal de secciones construido a partir de `appMenuItems` y menú de navegación lateral (`NavigationDrawer`) con soporte de *safe area* y *notch*.

| Pantalla Principal (`HomeScreen`) | Menú Lateral (`NavigationDrawer`) |
| :---: | :---: |
| <img src="assets/images/01_home_screen.png" alt="Home Screen" width="280"/> | <img src="assets/images/02_side_menu.png" alt="Side Menu" width="280"/> |

---

### 3. Riverpod Counter (Modo Claro y Modo Oscuro Sincronizados)
Gestión del contador mediante `counterProvider` y sincronización del botón de **Modo Oscuro / Modo Claro** en el `AppBar` conectándolo directamente a `themeNotifierProvider` (`ref.read(themeNotifierProvider.notifier).toggleDarkmode()`), permitiendo alternar el tema global de toda la aplicación desde esta pantalla al igual que en la sección *Cambiar tema*.

| Riverpod Counter — Modo Claro | Riverpod Counter — Modo Oscuro |
| :---: | :---: |
| <img src="assets/images/03_riverpod_counter.png" alt="Counter Screen Light Mode" width="280"/> | <img src="assets/images/03_riverpod_counter_dark.png" alt="Counter Screen Dark Mode" width="280"/> |

---

### 4. Botones (`ButtonsScreen`) y Tarjetas (`CardsScreen`)
Catálogo de botones de Material 3 (`ElevatedButton`, `FilledButton`, `OutlinedButton`, `TextButton`, `IconButton` y un botón personalizado con `InkWell`) y tarjetas con distintas configuraciones de elevación, bordes y fotografías cargadas desde red.

| Variantes de Botones | Tarjetas Estilizadas |
| :---: | :---: |
| <img src="assets/images/04_buttons_screen.png" alt="Buttons Screen" width="280"/> | <img src="assets/images/05_cards_screen.png" alt="Cards Screen" width="280"/> |

---

### 5. Indicadores de Progreso (`ProgressScreen`) y Snackbars / Diálogos (`SnackbarScreen`)
Indicadores de progreso indeterminados y controlados en tiempo real mediante `StreamBuilder`, junto con visualización de `SnackBar` y cuadros de diálogo modales (`AlertDialog` y `showAboutDialog`).

| Progress Indicators | Snackbars y Diálogos |
| :---: | :---: |
| <img src="assets/images/06_progress_screen.png" alt="Progress Screen" width="280"/> | <img src="assets/images/07_snackbars_dialogs.png" alt="Snackbars and Dialogs" width="280"/> |

---

### 6. Contenedor Animado (`AnimatedScreen`) y Controles de UI (`UiControlsScreen`)
Transiciones implícitas suaves con `AnimatedContainer` (dimensiones, radio de bordes y color aleatorios usando `Curves.elasticOut`) y controles interactivos de selección (`SwitchListTile`, `ExpansionTile`, `RadioListTile` y `CheckboxListTile`).

| Animated Container | UI Controls + Tiles |
| :---: | :---: |
| <img src="assets/images/08_animated_container.png" alt="Animated Container" width="280"/> | <img src="assets/images/09_ui_controls.png" alt="UI Controls" width="280"/> |

---

### 7. Tutorial Introductorio (`AppTutorialScreen`), Infinite Scroll (`InfiniteScrollScreen`) y Cambiar Tema (`ThemeChangerScreen`)
Carrusel de bienvenida con `PageView` y animación `FadeInRight`, lista infinita con carga diferida (`FadeInImage`) y `RefreshIndicator`, y pantalla de personalización del tema global (`ThemeChangerScreen`) gestionada con `StateNotifierProvider`.

| Introducción a la Aplicación | InfiniteScroll y Pull to Refresh | Cambiar Tema (`ThemeChangerScreen`) |
| :---: | :---: | :---: |
| <img src="assets/images/10_app_tutorial.png" alt="App Tutorial" width="260"/> | <img src="assets/images/11_infinite_scroll.png" alt="Infinite Scroll" width="260"/> | <img src="assets/images/12_theme_changer.png" alt="Theme Changer" width="260"/> |

---

## Conclusiones Técnicas

1. **Unificación del Estado Global con Riverpod (`StateNotifierProvider`):** Conectar tanto `CounterScreen` como `ThemeChangerScreen` al mismo `themeNotifierProvider` garantizó una única fuente de verdad (*Single Source of Truth*) para la instancia inmutable de `AppTheme`, logrando que el cambio entre modo claro y oscuro sea instantáneo y consistente en toda la aplicación.
2. **Navegación Declarativa Escalable:** El uso de `GoRouter` facilitó desacoplar las rutas de las vistas y permitió incorporar el nuevo `SplashScreen` como ruta inicial (`/splash`) que redirige limpiamente hacia `/` mediante `context.go('/')` sin contaminar el historial de navegación.
3. **Personalización Nativa y Experiencia de Inicio:** La supresión del splash nativo predeterminado de Flutter y su sustitución por un `SplashScreen` con animaciones acopladas a la paleta del logotipo (`logo.jpg`) y al color semilla por defecto (`Colors.blue`), junto con la generación de íconos nativos para **Ridgets App**, dotan al proyecto de un acabado visual profesional.

