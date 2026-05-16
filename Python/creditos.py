import pygame
import Button
import numpy
import UI_const

WIDTH, HEIGHT = (UI_const.WIDTH_screen, UI_const.HEIGHT_screen)
SCREEN = None

class CreditosScreen:
    def __init__(self, screen):
        global SCREEN
        SCREEN = screen
        self.screen = screen
        self._ExitMode = False
        self.scroll_offset = 0
        self.max_scroll = 0
        self.current_category = "Serventensio Studios"
        self.current_person_data = None
        self.show_detail = False

        # Fuentes
        self.font_title = pygame.font.Font(r"Assets\\Fonts\\Seagram_tfb.ttf", 35)
        self.font_subtitle = pygame.font.Font(r"Assets\\Fonts\\Seagram_tfb.ttf", 25)
        self.font_text = pygame.font.Font(r"Assets\\Fonts\\Seagram_tfb.ttf", 20)

        # Datos de los créditos
        self.credits_data = {
            "Serventensio Studios": {
                "name": "Serventensio Studios",
                "image": pygame.image.load(r"Assets\\credit\\logo.png"),
                "description": "Serventensio Studios somos un equipo indie de desarrollo de videojuegos, y este es nuestro primer proyecto: la demo de nuestro primer juego. Esperamos que disfruten esta versión inicial y que, en un futuro, puedan experimentar la versión final completa, tal como la hemos imaginado y trabajado con tanto esfuerzo.",
                "contact": ""
            },
            "Programadores": {
                "Juarez Javier": {
                    "name": "Juarez Javier",
                    "image": pygame.image.load(r"Assets\\credit\\javier.png"),
                    "description": "Es el programador encargado de diseñar y desarrollar las mecánicas centrales del juego, incluyendo la implementación de estadísticas, niveles y sistemas de progresión. Su trabajo consiste en asegurar que cada nivel funcione correctamente, que los desafíos y recompensas estén equilibrados, y que los datos de los personajes o jugadores se registren y actualicen de manera precisa. Además, se encarga de integrar todas las funciones necesarias para que el juego sea interactivo y dinámico, optimizando el rendimiento y solucionando posibles errores en la programación.",
                    "contact": ""
                },
                "Matias Diaz": {
                    "name": "Matias Diaz",
                    "image": pygame.image.load(r"Assets\\credit\\matias.png"),
                    "description": "Es el programador encargado de diseñar y desarrollar las mecánicas del sistema de combate del juego. Su trabajo incluye crear las reglas de interacción entre personajes, enemigos y objetos, así como implementar ataques, defensas, habilidades especiales y efectos visuales relacionados con la acción. Se asegura de que el sistema sea equilibrado, dinámico y desafiante, garantizando que cada enfrentamiento funcione de manera fluida y sin errores.",
                    "contact": ""
                },
                "Briosso Adrian": {
                    "name": "Briosso Adrian",
                    "image": pygame.image.load(r"Assets\\ChArt\\el papa.png"),
                    "description": "Se encargó de programar y desarrollar todas las interfaces del juego, abarcando tanto el diseño visual como la experiencia del usuario (IU/UX). Su trabajo incluye crear menús, paneles, botones, indicadores de estadísticas y cualquier elemento interactivo con el que el jugador interactúe. Además, se asegura de que la navegación sea intuitiva, fluida y atractiva, adaptando cada componente a las necesidades del juego y garantizando que la experiencia del usuario sea clara y agradable.",
                    "contact": ""
                },
                "Matute": {
                    "name": "Maxi Bograd",
                    "image": pygame.image.load(r"Assets\\credit\\matu.png"),
                    "description": "Se encargó de programar diversos detalles del juego y de brindar apoyo al resto del equipo de programación cuando alguno de sus integrantes lo necesitaba. Su labor incluye colaborar en la implementación de pequeñas funciones, solucionar problemas puntuales y asegurar que las distintas partes del código funcionen correctamente en conjunto. Además, actúa como un recurso de soporte dentro del equipo, facilitando la resolución de dudas y contribuyendo a que el desarrollo avance de manera más eficiente y coordinada.",
                    "contact": "@matute._.fk2"
                }
            },
            "Arte": {
                "Matute": {
                    "name": "Maxi Bograd",
                    "image": pygame.image.load(r"Assets\\credit\\matu.png"),
                    "description": "Se encargó de todo el diseño de personajes, cinemáticas y otros elementos visuales del juego. Su trabajo incluye conceptualizar y crear los modelos de los personajes, sus animaciones, expresiones y movimientos, así como planificar y producir las secuencias cinematográficas que cuentan la historia del juego. Su labor es fundamental para definir la identidad visual y estética del proyecto, asegurando que los personajes y escenas transmitan la narrativa de manera impactante y coherente.",
                    "contact": "@matute._.fk2"
                },
                "Matias Diaz": {
                    "name": "Matias Diaz",
                    "image": pygame.image.load(r"Assets\\credit\\matias.png"),
                    "description": "Se encargó del diseño y la creación de todos los fondos del juego. Su trabajo incluye conceptualizar, ilustrar y dar vida a los escenarios en los que se desarrollan las acciones, asegurando que cada ambiente refleje la atmósfera y el estilo visual del proyecto.",
                    "contact": ""
                },
            },
            "Guionista": {
                "Matute": {
                    "name": "Maxi Bograd",
                    "image": pygame.image.load(r"Assets\\credit\\matu.png"),
                    "description": "Se encargó de la creación de la narrativa, los diálogos y el lore del juego. Su labor incluye construir la historia principal, desarrollar las tramas secundarias y definir el trasfondo de los personajes y del mundo en el que se desarrolla el juego. Además, escribe los diálogos asegurándose de que sean coherentes con la personalidad de cada personaje y contribuyan al desarrollo de la historia, generando una experiencia inmersiva y emocional para los jugadores. Su trabajo es clave para dar profundidad, contexto y sentido a todo el universo del juego.",
                    "contact": "@matute._.fk2"
                }
            },
            "Sonido y Audio": {
                "Matute": {
                    "name": "Maxi Bograd",
                    "image": pygame.image.load(r"Assets\\credit\\matu.png"),
                    "description": "Se encargó de editar todas las voces del juego, asegurándose de que cada interpretación tuviera el tono, la claridad y el matiz adecuados. Su trabajo incluye ajustar volumen, ritmo, entonación y efectos sonoros para que cada personaje transmita la emoción correcta y se integre de manera coherente con la narrativa y la atmósfera del juego.",
                    "contact": "@matute._.fk2"
                },
                "Matias Diaz": {
                    "name": "Matias Daniel Diaz",
                    "image": pygame.image.load(r"Assets\\credit\\matias.png"),
                    "description": "Se encargó de seleccionar la banda sonora y los efectos de sonido del juego, asegurándose de que cada pista y efecto encajara con la atmósfera y la narrativa del proyecto. Debido a limitaciones de tiempo, no fue posible crear piezas originales, pero la selección realizada mantiene la coherencia y la inmersión del juego. A futuro, está previsto que se desarrollen composiciones y efectos propios para reforzar aún más la identidad sonora del proyecto.",
                    "contact": ""
                }
            },
            "Voces": {
                "Anto Fiori": {
                    "name": "Anto Fiori",
                    "image": pygame.image.load(r"Assets\\credit\\anto.png"),
                    "description": "Aportó vida al personaje de la monja con su destacada interpretación, logrando que el personaje transmitiera un drama teatral único que lo hace inolvidable. Su actuación se destacó por la calidad de la voz y la intensidad emocional, convirtiéndose en la mejor interpretación dentro del proyecto y aportando profundidad y carácter al personaje.",
                    "contact": "@_antofiori"
                },
                "Lucio Verdier": {
                    "name": "Lucio Verdier",
                    "image": pygame.image.load(r"Assets\\credit\\lucio.png"),
                    "description": "Lucio le dio vida al personaje de Fray Corvus con una interpretación que nos encantó. Capturó perfectamente la esencia del personaje, agregando un acento increíble que reforzó su personalidad y lo hizo aún más memorable. Su actuación aportó autenticidad, carácter y carisma.",
                    "contact": "@lucio.verdier"
                },
                "Thiago Ferraro": {
                    "name": "Voz Adicional 1",
                    "image": pygame.image.load(r"Assets\\credit\\thiago.png"),
                    "description": "Thiago le dio vida al personaje del Obispo Serpico con una interpretación que destacó por su calidad y expresividad. Su actuación fue una de las que más nos gustó, aportando profundidad y personalidad al personaje.",
                    "contact": "@thiafoferraro32"
                },
                "Joaquin Iglesias": {
                    "name": "Joaquin Iglesias",
                    "image": pygame.image.load(r"Assets\\credit\\juaco.png"),
                    "description": "Juaquín le dio vida al personaje del Padre Espina, convirtiéndose en nuestra segunda interpretación favorita. Su actuación nos encantó: casi no requirió edición y, además, modificó algunos diálogos y añadió elementos propios, logrando un resultado excelente que aportó autenticidad y fuerza al personaje.",
                    "contact": ""
                },
                "Matute": {
                    "name": "Matute",
                    "image": pygame.image.load(r"Assets\\credit\\matu.png"),
                    "description": "...",
                    "contact": "@matute._.fk2"
                },
            },
            "UI/UX": {
                "Briosso Adrian": {
                    "name": "Briosso Adrian",
                    "image": pygame.image.load(r"Assets\\ChArt\\Fray Corvus.png"),
                    "description": "Se encargó del diseño y la usabilidad de la interfaz de usuario, asegurándose de que cada elemento fuera claro, funcional y fácil de usar. Su trabajo hizo que la interacción con el juego fuera intuitiva, permitiendo que los jugadores navegaran de manera fluida y disfrutasen de una experiencia accesible y agradable.",
                    "contact": ""
                }
            }
        }
        self.categories_order = list(self.credits_data.keys())
        self.current_category_index = 0

        # Cargar fondo
        self.background_image = pygame.image.load(r"Assets\\BckGrnd\\Nivel.png").convert()
        self.background_image = pygame.transform.scale(self.background_image, (WIDTH, HEIGHT))

        # Botones de navegación
        self.flechaizq = pygame.image.load(r"Assets\\Icons\\izq.png")
        self.flechaizq_rect = pygame.Rect(0, HEIGHT // 2 - 30, 50, 60)
        self.flechader = pygame.image.load(r"Assets\\Icons\\der.png")
        self.flechader_rect = pygame.Rect(WIDTH - 50, HEIGHT // 2 - 30, 50, 60)

        self.but_back = Button.Button('Atras', 100, 50, (25, 25))
        self.person_buttons = []

    def draw_text(self, surface, text, color, rect, font, aa=False, bkg=None, scroll_offset=0):
        rect = pygame.Rect(rect)
        y = rect.top + scroll_offset
        line_spacing = -2

        font_height = font.size("Tg")[1]
        lines = []
        current_text = text
        while current_text:
            i = 1
            while font.size(current_text[:i])[0] < rect.width and i < len(current_text):
                i += 1
            if i < len(current_text):
                i = current_text.rfind(" ", 0, i) + 1
            lines.append(current_text[:i])
            current_text = current_text[i:]

        total_text_height = len(lines) * (font_height + line_spacing)

        for line in lines:
            if y + font_height > rect.top and y < rect.bottom:
                if bkg:
                    image = font.render(line, aa, color, bkg)
                    image.set_colorkey(bkg)
                else:
                    image = font.render(line, aa, color)
                surface.blit(image, (rect.left, y))
            y += font_height + line_spacing

        return total_text_height

    def runMenu(self):
        run = True
        while run:
            events = pygame.event.get()
            for event in events:
                if event.type == pygame.QUIT:
                    pygame.quit()
                    run = False
                    quit()
                if event.type == pygame.MOUSEBUTTONUP:
                    if self.but_back.get_clicked():
                        if self.show_detail:
                            self.show_detail = False
                            self.current_person_data = None
                            self.scroll_offset = 0
                            self.but_back.clicked = False
                        else:
                            self._ExitMode = True
                            self.but_back.clicked = False
                    
                    if not self.show_detail:
                        if self.flechaizq_rect.collidepoint(pygame.mouse.get_pos()):
                            self.current_category_index = (self.current_category_index - 1) % len(self.categories_order)
                            self.current_category = self.categories_order[self.current_category_index]
                            self.person_buttons = []
                            self.scroll_offset = 0
                        elif self.flechader_rect.collidepoint(pygame.mouse.get_pos()):
                            self.current_category_index = (self.current_category_index + 1) % len(self.categories_order)
                            self.current_category = self.categories_order[self.current_category_index]
                            self.person_buttons = []
                            self.scroll_offset = 0

                        for p_button in self.person_buttons:
                            if p_button.get_clicked():
                                self.current_person_data = self.credits_data[self.current_category][p_button.text]
                                self.show_detail = True
                                self.scroll_offset = 0
                                p_button.clicked = False
                                break
                if event.type == pygame.MOUSEWHEEL:
                    if self.show_detail:
                        self.scroll_offset += event.y * 10
                        self.scroll_offset = max(-self.max_scroll, min(0, self.scroll_offset))

            self.screen.blit(self.background_image, (0, 0))
            self.but_back.draw(self.screen, True, False)

            # Título CRÉDITOS siempre visible pero con posición ajustada
            text_titulo = self.font_title.render("CRÉDITOS", True, '#000000')
            if self.show_detail:
                # En vista detalle: título más arriba para dejar espacio
                titulo_rect = text_titulo.get_rect(centerx=self.screen.get_width() // 2, top=10)
            else:
                # En vista general: posición normal
                titulo_rect = text_titulo.get_rect(centerx=self.screen.get_width() // 2, top=20)
            self.screen.blit(text_titulo, titulo_rect)

            if self.show_detail:
                self._draw_person_detail()
            else:
                self._draw_category_view()

            if not self.show_detail:
                mouse_pos = pygame.mouse.get_pos()
                current_flechaizq = pygame.transform.scale(self.flechaizq, (55, 70)) if self.flechaizq_rect.collidepoint(mouse_pos) else pygame.transform.scale(self.flechaizq, (50, 60))
                current_flechader = pygame.transform.scale(self.flechader, (55, 70)) if self.flechader_rect.collidepoint(mouse_pos) else pygame.transform.scale(self.flechader, (50, 60))
                self.screen.blit(current_flechaizq, self.flechaizq_rect)
                self.screen.blit(current_flechader, self.flechader_rect)

            if self._ExitMode:
                run = False

            pygame.display.update()

        return "MENU"

    def _draw_category_view(self):
        text_category = self.font_subtitle.render(self.current_category, True, '#000000')
        category_rect = text_category.get_rect(centerx=self.screen.get_width() // 2, top=100)
        self.screen.blit(text_category, category_rect)

        category_content = self.credits_data[self.current_category]
        
        if self.current_category == "Serventensio Studios":
            studio_data = category_content
            img = studio_data["image"]
            description = studio_data["description"]
            contact = studio_data["contact"]

            img_rect_area = pygame.Rect(WIDTH // 2 - 150, 150, 300, 300)
            img = pygame.transform.scale(img, (img_rect_area.width, img_rect_area.height))
            self.screen.blit(img, img_rect_area.topleft)

            text_area_rect = pygame.Rect(WIDTH // 2 - 300, 470, 600, 250)
            text_background = pygame.image.load(r"Assets\\BckGrnd\\paper.png").convert_alpha()
            text_background = pygame.transform.scale(text_background, (text_area_rect.width - 10, text_area_rect.height - 10))
            text_background_rect = text_background.get_rect(center=text_area_rect.center)
            
            pygame.draw.rect(self.screen, '#000000', text_area_rect, 5)
            self.screen.blit(text_background, text_background_rect)

            full_text = description + "\n\n" + contact
            
            temp_surface = pygame.Surface((text_area_rect.width - 20, 1), pygame.SRCALPHA)
            total_text_height = self.draw_text(temp_surface, full_text, (0, 0, 0), pygame.Rect(0, 0, text_area_rect.width - 20, 10000), self.font_subtitle)
            self.max_scroll = max(0, total_text_height - (text_area_rect.height - 20))

            self.draw_text(self.screen, full_text, (0, 0, 0), pygame.Rect(text_area_rect.left + 10, text_area_rect.top + 10, text_area_rect.width - 20, text_area_rect.height - 20), self.font_subtitle, scroll_offset=self.scroll_offset)

            if self.max_scroll > 0:
                bar_width = 10
                bar_padding = 2
                bar_height = (text_area_rect.height - 20) * ((text_area_rect.height - 20) / total_text_height)
                bar_x = text_area_rect.right + bar_padding
                scroll_ratio = -self.scroll_offset / self.max_scroll if self.max_scroll > 0 else 0
                bar_y = text_area_rect.top + 10 + scroll_ratio * ((text_area_rect.height - 20) - bar_height)
                
                pygame.draw.rect(self.screen, (200, 200, 200), (bar_x, text_area_rect.top + 10, bar_width, text_area_rect.height - 20), border_radius=3)
                pygame.draw.rect(self.screen, (100, 100, 100), (bar_x, bar_y, bar_width, bar_height), border_radius=3)

        else:
            self.person_buttons.clear()
            button_width = 190
            button_height = 280
            col_count = 4
            total_button_width = col_count * button_width
            total_spacing_x = WIDTH - total_button_width
            spacing_x = total_spacing_x / (col_count + 1)
            y_start = 150
            spacing_y = button_height + 20

            for i, (person_name, data) in enumerate(category_content.items()):
                col = i % col_count
                row = i // col_count
                pos_x = int(spacing_x + col * (button_width + spacing_x))
                pos_y = y_start + row * spacing_y
                
                p_button = Button.GlosarioButton(data["image"], person_name, button_width, button_height, (pos_x, pos_y))
                self.person_buttons.append(p_button)
                p_button.draw(self.screen)

    def _draw_person_detail(self):
        # Renderizar el nombre de la persona primero para calcular su altura
        person_name_text = self.font_subtitle.render(self.current_person_data["name"], True, '#000000')
        person_name_rect = person_name_text.get_rect(centerx=WIDTH // 2, top=55)
        self.screen.blit(person_name_text, person_name_rect)

        # Calcular la posición y tamaño del bloque de imagen dinámicamente
        # La imagen debe empezar debajo del nombre con un pequeño margen
        image_top_y = person_name_rect.bottom + 5  # 5px de margen entre el nombre y la imagen
        image_width = 200  # Ancho fijo para la imagen
        image_height = 200 # Altura fija para la imagen (ajustar si es necesario)
        
        # Ajuste de imagen según tipo
        img = self.current_person_data["image"]
        try:
            image_path_str = str(self.current_person_data["image"])
        except Exception:
            image_path_str = ""

        # Cargar la imagen original para obtener sus dimensiones y luego escalarla
        original_img = self.current_person_data["image"]
        aspect_ratio = original_img.get_width() / original_img.get_height()

        # Ajustar el tamaño de la imagen manteniendo el aspecto ratio
        if aspect_ratio > 1: # Imagen más ancha que alta
            scaled_width = image_width
            scaled_height = int(image_width / aspect_ratio)
        else: # Imagen más alta que ancha o cuadrada
            scaled_height = image_height
            scaled_width = int(image_height * aspect_ratio)

        # Asegurarse de que la imagen no exceda las dimensiones máximas
        if scaled_width > image_width:
            scaled_width = image_width
            scaled_height = int(image_width / aspect_ratio)
        if scaled_height > image_height:
            scaled_height = image_height
            scaled_width = int(image_height * aspect_ratio)

        img = pygame.transform.scale(original_img, (scaled_width, scaled_height))

        # Calcular el rectángulo para la imagen centrada
        img_rect = img.get_rect(centerx=WIDTH // 2, top=image_top_y)

        # Calcular el rectángulo del fondo 'paperallborder.png' para que se ajuste a la imagen
        # con un margen de 5px
        border_padding = 5
        border_rect = pygame.Rect(
            img_rect.left - border_padding,
            img_rect.top - border_padding,
            img_rect.width + 2 * border_padding,
            img_rect.height + 2 * border_padding
        )
        
        background = pygame.image.load(r"Assets\\BckGrnd\\paperallborder.png").convert_alpha()
        background = pygame.transform.scale(background, (border_rect.width, border_rect.height))
        background_rect = background.get_rect(center=border_rect.center)
        
        border_color = '#000000'
        pygame.draw.rect(self.screen, border_color, border_rect, 5)
        self.screen.blit(background, background_rect)
        self.screen.blit(img, img_rect)

        # Bloque inferior (Texto)
        # El bloque de texto debe empezar debajo del bloque de imagen con un margen
        texto_top_y = border_rect.bottom + 15 # Margen entre el bloque de imagen y el bloque de texto
        texto_border_rect = pygame.Rect(60, texto_top_y, WIDTH - 120, HEIGHT - texto_top_y - 50)
        texto_background = pygame.image.load(r"Assets\\BckGrnd\\paper.png").convert_alpha()
        texto_background = pygame.transform.scale(texto_background, (texto_border_rect.width - 10, texto_border_rect.height - 10))
        texto_background_rect = texto_background.get_rect(center=texto_border_rect.center)

        pygame.draw.rect(self.screen, border_color, texto_border_rect, 5)
        self.screen.blit(texto_background, texto_background_rect)

        padding = 10
        text_area = pygame.Rect(
            texto_background_rect.left + padding,
            texto_background_rect.top + padding,
            texto_background_rect.width - 2 * padding - 15,
            texto_background_rect.height - 2 * padding
        )

        full_text = self.current_person_data["description"] + "\n\n" + self.current_person_data["contact"]
        
        temp_surface = pygame.Surface((text_area.width, 1), pygame.SRCALPHA)
        total_text_height = self.draw_text(temp_surface, full_text, (0, 0, 0), pygame.Rect(0, 0, text_area.width, 10000), self.font_text)
        self.max_scroll = max(0, total_text_height - text_area.height)

        self.draw_text(self.screen, full_text, (0, 0, 0), text_area, self.font_text, scroll_offset=self.scroll_offset)

        if self.max_scroll > 0:
            bar_width = 10
            bar_padding = 2
            bar_height = text_area.height * (text_area.height / total_text_height)
            bar_x = text_area.right + bar_padding
            scroll_ratio = -self.scroll_offset / self.max_scroll if self.max_scroll > 0 else 0
            bar_y = text_area.top + scroll_ratio * (text_area.height - bar_height)
            
            pygame.draw.rect(self.screen, (200, 200, 200), (bar_x, text_area.top, bar_width, text_area.height), border_radius=3)
            pygame.draw.rect(self.screen, (100, 100, 100), (bar_x, bar_y, bar_width, bar_height), border_radius=3)
