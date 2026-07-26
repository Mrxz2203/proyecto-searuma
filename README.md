# 🐴 SearUma

**SearUma** es una aplicación web hecha en Flutter para buscar y explorar personajes de *Uma Musume: Pretty Derby*. Es un proyecto personal de aprendizaje, creado desde cero viniendo de un background principalmente en React/Vite, con el objetivo de familiarizarse con Flutter y Dart a través de un caso de uso real.

🔗 **Demo en vivo:** [proyecto-searuma.vercel.app](https://proyecto-searuma.vercel.app)

---

## 📖 Sobre el proyecto

SearUma consume la API pública de [Umapyoi.net](https://umapyoi.net) para mostrar información de los personajes del juego: nombre, cumpleaños, categoría, perfil, fortalezas/debilidades, colores oficiales y una línea de voz reproducible — todo traducido automáticamente al español.

## ✨ Características

### Página de bienvenida (`/`)
- Hero con imagen ilustrativa, CTA y "social proof"
- Navbar con scroll suave a cada sección (anclas internas con `GlobalKey` + `Scrollable.ensureVisible`)
- Sección "¿Cómo funciona?" con 3 tarjetas informativas (hover con elevación)
- Footer con links reales a GitHub, LinkedIn y la fuente de datos
- Botón flotante "volver arriba" que aparece tras cierto scroll
- Animaciones de entrada (fade + slide) en el hero

### Buscador (`/search`)
- Grid responsive de personajes con paginación (20 por página)
- Búsqueda en tiempo real con **debounce** (300ms) para no recalcular en cada tecla
- Estados diferenciados: cargando, error (con reintento), sin resultados, y resultados
- Cada tarjeta usa el color oficial del personaje como acento visual
- Navegación animada (`Hero` widget) hacia el detalle

### Detalle de personaje (`/detail/:id`)
- Animación **Hero** — la imagen "vuela" desde la tarjeta del buscador hasta el detalle
- Traducción automática al español de perfil, slogan, fortalezas y debilidades (vía `translator` package)
- Reproducción de la línea de voz del personaje (`audioplayers`)
- Animación de entrada en cascada por secciones
- Datos mostrados: nombre (EN/JP), categoría, cumpleaños, altura, peso/complexión, perfil, fortalezas y debilidades

## 🎨 Paleta de colores

Inspirada en el personaje **Nice Nature**:

| Color | Hex | Uso |
|---|---|---|
| Verde bosque | `#2F6B4A` | Color principal, botones, navbar |
| Verde oliva | `#5F8A4B` | Iconos, hover |
| Verde claro | `#A8C98C` | Fondos suaves |
| Crema | `#F8F1E3` | Fondo principal |
| Marrón cuero | `#7A5638` | Texto secundario |
| Marrón oscuro | `#4B3425` | Títulos |
| Dorado | `#D4B15A` | Acentos, CTAs |
| Blanco cálido | `#FFFDF8` | Tarjetas |

## 🛠️ Stack técnico

- **Flutter Web** (Dart)
- **go_router** — navegación y rutas con transiciones custom
- **provider** — manejo de estado (`CharacterProvider`)
- **http** — consumo de la API de Umapyoi.net
- **translator** — traducción automática EN → ES
- **audioplayers** — reproducción de líneas de voz
- **url_launcher** — links externos del footer

## 📂 Arquitectura

```
lib/
├── main.dart
├── models/
│   ├── character.dart          # Modelo para la lista de personajes
│   └── character_detail.dart   # Modelo extendido para el detalle
├── services/
│   ├── uma_api_service.dart    # Cliente HTTP de Umapyoi.net
│   └── translation_service.dart
├── providers/
│   └── character_provider.dart # Estado: lista, filtro, paginación
├── screens/
│   ├── welcome_page.dart
│   ├── search_page.dart
│   └── detail_page.dart
├── widgets/
│   ├── nav_bar.dart
│   ├── feature_card.dart
│   └── character_tile.dart
├── theme/
│   └── app_colors.dart
└── router/
    └── app_router.dart
```

## 🌐 Fuente de datos

Toda la información de personajes proviene de la API pública y gratuita de **[Umapyoi.net](https://umapyoi.net)**:
- `GET /api/v1/character/list` — listado completo
- `GET /api/v1/character/{id}` — detalle individual

## 🚀 Cómo correrlo localmente

```bash
flutter pub get
flutter run -d chrome
```

## 📦 Deployment

Desplegado en **Vercel**, con build command personalizado (Vercel no tiene preset nativo para Flutter):

```bash
git clone https://github.com/flutter/flutter.git -b stable --depth 1 && export PATH="$PATH:`pwd`/flutter/bin" && flutter doctor && flutter pub get && flutter build web --release
```
Output Directory: `build/web`

## 🔭 Posibles mejoras futuras

- Favoritos persistentes (`shared_preferences`)
- Filtro por categoría (Umamusume / Staff)
- Compartir personaje vía link directo
- Meta tags Open Graph para previews en redes sociales

## 👤 Autor

**Gabriel García**
- GitHub: [@Mrxz2203](https://github.com/Mrxz2203)
- LinkedIn: [jarold-gabriel-garcia-cartagena](https://www.linkedin.com/in/jarold-gabriel-garcia-cartagena-54b80b20b/)

---

*Proyecto personal sin fines de lucro, hecho para practicar Flutter. Los derechos de Uma Musume: Pretty Derby pertenecen a Cygames.*