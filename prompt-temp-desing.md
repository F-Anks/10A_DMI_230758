Actúa como un Diseñador y Desarrollador Frontend Senior experto en gráficos interactivos SVG, Canvas y diseño UI/UX de nivel Apple ("Liquid Glass / Glassmorphism").

Tu objetivo es generar o maquetar un DIAGRAMA DE ARQUITECTURA interactivo en un archivo HTML monolítico funcional, aplicando un sistema de diseño premium inspirado en Apple, con físicas reactivas y soporte dual para modo oscuro y claro.

=======================================================
1. CONTEXTO Y COMPONENTES DEL DIAGRAMA DE ARQUITECTURA
=======================================================
[REEMPLAZA ESTE BLOQUE CON EL CONTEXTO DE TU ARQUITECTURA:
- Nombre del sistema: (ej. "Arquitectura de Microservicios Cloud / Sistema Bancario")
- Capas o módulos: (ej. Frontend Web/Mobile, API Gateway, Servicios Core, Base de Datos, Message Broker, Cloud Ops)
- Flujos e interacciones clave: (conexiones entre componentes y protocolos HTTP/gRPC/Kafka)]

=======================================================
2. FONDOS Y SISTEMA DE TEMA (DARK / LIGHT)
=======================================================
- Fondo en Modo Oscuro (por defecto):
  * Debe aplicar 'bg_dark.jpg' como background-image (cover, fixed, centered) sobre un fondo base #000.
- Fondo en Modo Claro:
  * Debe aplicar 'bg_light.jpg' como background-image (cover, fixed, centered) sobre un fondo base #FFF cuando 'html[data-theme="light"]' esté activo.
- Barra de herramientas (Toolbar):
  * Incluir un botón de alternancia de tema (Toggle Dark/Light) con el atajo de teclado 'T', centrado en la parte superior debajo del título, con diseño de cápsula translúcida.

=======================================================
3. ESTÉTICA DE LOS NODOS Y CONECTORES (LIQUID GLASS)
=======================================================
- Nodos del diagrama (SVG Rectangles):
  * Fondo: 'rgba(30, 30, 35, 0.4)' en modo oscuro y 'rgba(255, 255, 255, 0.5)' en modo claro.
  * Borde: '1px solid rgba(255, 255, 255, 0.15)' en oscuro, '1px solid rgba(255, 255, 255, 0.8)' en claro.
  * Bordes redondeados: 'rx: 24px'.
  * Cristal esmerilado: 'backdrop-filter: blur(25px) saturate(200%)'.
  * Sombra: 'filter: drop-shadow(0 15px 30px rgba(0,0,0,0.4))'.
  * Efecto Hover: Elevar ligeramente, aumentar opacidad del fondo a 'rgba(255, 255, 255, 0.15)' y emitir un resplandor dinámico en acento vibrante (ej. 'drop-shadow(0 20px 50px rgba(250, 45, 72, 0.3))').
- Flechas y conectores (Edges / Paths):
  * Líneas en color de acento llamativo (ej. Apple Red '#FA2D48' o degradado hacia '#FC5C7D') con grosor 'stroke-width: 2.5px'.
  * Marcadores de punta de flecha con el mismo color sólido '#FA2D48'.
  * Al interactuar con un nodo, los nodos y conexiones no relacionados deben atenuarse a opacidad 0.1 ('custom-node-dimmed' y 'custom-edge-dimmed').

=======================================================
4. TIPOGRAFÍA Y BRANDING ADAPTATIVO
=======================================================
- Tipografía global: 'Inter', -apple-system, BlinkMacSystemFont, "SF Pro Display", sans-serif.
- Textos de los nodos:
  * Blanco puro '#FFFFFF' con sutil sombra de lectura 'text-shadow: 0 2px 5px rgba(0,0,0,0.5)' en modo oscuro; gris grafito '#1C1C1E' en modo claro.
  * Jerarquía clara: Títulos en 'font-weight: 700', métricas y subtítulos con opacidad reducida (0.6).
- Encabezado principal (Header):
  * Debe abarcar 'grid-column: 1 / -1' sin romper el contenedor. Título h1 grande (38-40px), en una sola línea (nowrap), centrado junto con su subtítulo descriptivo.
- Logotipo de esquina (Corner Logo):
  * Un icono o logotipo SVG ubicado en 'position: absolute; top: 15px; left: 15px; width: 60px; height: 60px; z-index: 9999'.
  * Adaptativo al tema: Blanco puro (#FFFFFF) en modo oscuro, grafito oscuro (#1D1D1F) en modo claro, con transición suave de color (0.4s).

=======================================================
5. SISTEMA DE EXPANSIÓN Y MODAL INTERACTIVO
=======================================================
- Al hacer clic sobre cualquier nodo o bloque de la arquitectura:
  * El bloque se anima suavemente mediante 'requestAnimationFrame' expandiéndose hasta convertirse en una tarjeta central espaciosa (ej. 1100x750px).
  * Oculta el contenido minimalista original y despliega un '<foreignObject>' con clase '.custom-embedded-content'.
  * Estilo del contenedor modal: Fondo 'rgba(15, 15, 18, 0.6)' en modo oscuro ('rgba(255, 255, 255, 0.65)' en claro), 'backdrop-filter: blur(40px) saturate(250%)', bordes redondeados a '36px', borde cristalino sutil e iluminación interna 'inset 0 1px 1px rgba(255,255,255,0.2)'.
  * Encabezado del modal: Barra o píldora vertical de color, título (38px, font-weight 800) y subtítulo.
  * Lista de detalles técnicos: Viñetas personalizadas triangulares ('\25B8') con animación escalonada ('animation-delay: 0.15s + i*0.07s') que se desplazan levemente en hover.
  * Cierre: Al hacer clic fuera de la tarjeta o presionar la tecla 'Escape', la tarjeta regresa a su tamaño y posición original con una transición cúbica suave (ease-out).

=======================================================
6. FÍSICAS Y ANIMACIONES REACTIVAS
=======================================================
Implementa mediante JavaScript las siguientes físicas interactivas:
1. Parallax 360 Mouse-Repel:
   - Al mover el cursor, los nodos y tarjetas detectan la distancia al ratón.
   - En un radio de 250px a 300px, los elementos son repelidos en dirección opuesta al cursor proporcionalmente a la cercanía, regresando a su posición original con 'cubic-bezier(0.25, 0.8, 0.25, 1)' cuando el cursor se aleja.
2. Slime / Jelly 3D al hacer Scroll:
   - Calcular la velocidad del scroll ('velocity = currentScrollY - lastScrollY').
   - Aplicar transformación 3D elástica a los contenedores:
     * stretch = 1 + |v| * 0.003
     * squash = 1 - |v| * 0.0015
     * skew = v * -0.1deg
     * rotateX = v * -0.08deg con 'perspective(1200px)'
   - Al detener el scroll, desacelerar con fricción y restaurar la forma con rebote elástico 'cubic-bezier(0.25, 1.5, 0.5, 1)'.
3. 3D Tilt Hover:
   - Las tarjetas inferiores y paneles deben inclinarse en perspectiva 3D ('rotateX' y 'rotateY') siguiendo la posición del puntero del ratón con suavidad.
4. Scroll-Reveal (IntersectionObserver):
   - Los paneles y tarjetas inferiores aparecen gradualmente ('opacity: 0 -> 1', 'translateY(40px) -> translateY(0)') con retrasos escalonados conforme el usuario baja en la página.

=======================================================
7. PANEL INFERIOR Y CARDS DE METADATOS / DATOS
=======================================================
Debajo del diagrama SVG principal, coloca:
1. Banner interactivo "Exploración de Nodos / Estado de la Arquitectura":
   - Tarjeta alargada con efecto frosted glass que invite a interactuar con el diagrama.
2. Grid de Cards de Metadatos (flex-wrap centrado):
   - Tarjetas tipo cápsula con fondo translúcido 'rgba(255, 255, 255, 0.04)', blur de 30px, bordes de 20px.
   - Línea superior en degradado de acento que aparece al hacer hover.
   - Etiquetas superiores en mayúsculas pequeñas (11px, letter-spacing 1.5px) con colores temáticos independientes (rosa, naranja, morado, azul, verde).
   - Valores en tipografía 'Inter' 18px bold '#f5f5f7'.
   - Las últimas tarjetas deben distribuirse de manera equilibrada y centrada.

=======================================================
8. ROBUSTEZ Y ESTRUCTURA TÉCNICA
=======================================================
- El archivo debe ser completamente autocontenido en HTML con sus etiquetas '<style>' y '<script>'.
- Asegurar que las correcciones de layout impidan que los estilos de CSS Grid o flex colapsen el header o compriman los textos.
- Mantener la accesibilidad para atajos de teclado y navegadores modernos.
