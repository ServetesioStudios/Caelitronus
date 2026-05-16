import pygame
import Button
import UI_const
from pygame import Rect, mouse

pygame.init()
WIDTH, HEIGHT = (UI_const.WIDTH_screen, UI_const.HEIGHT_screen)
SCREEN = pygame.display.set_mode((WIDTH, HEIGHT))
clock = pygame.time.Clock()
clock.tick(30)

def draw_text(surface, text, color, rect, font, aa=False, bkg=None, scroll_offset=0):
    """
    Renderiza texto con ajuste automático dentro de un rectángulo, con soporte para desplazamiento.
    """
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

class Glosario:
    def __init__(self, screen):
        self.screen = screen
        self._ExitMode = False

    def runGlosario(self):
        screen = self.screen
        fondo = pygame.image.load("./Assets/BckGrnd/Nivel.png").convert()
        fondo = pygame.transform.scale(fondo, (WIDTH, HEIGHT))
        fondo_rect = fondo.get_rect()
        font = pygame.font.Font("./Assets/Fonts/Seagram_tfb.ttf", 35)
        text_titulo = font.render("\nGLOSARIO", True, '#000000')
        titulo_rect = text_titulo.get_rect(centerx=fondo_rect.centerx, top=fondo_rect.top)
        but_back = Button.Button('Atras', 100, 50, (25, 25))

        flechaizq = pygame.image.load("./Assets/Icons/izq.png")
        flechaizq_rect = pygame.Rect(0, 345, 50, 60)
        flechader = pygame.image.load("./Assets/Icons/der.png")
        flechader_rect = pygame.Rect(870, 345, 50, 60)

        # Botones con imágenes de la sección 1 (PERSONAJES)
        caelius = pygame.image.load("./Assets/ChArt/caelius de ira.png")
        but_caelius = Button.GlosarioButton(caelius, 'Caelius', 170, 260, (55, 150))

        papa = pygame.image.load("./Assets/ChArt/el papa.png")
        but_papa = Button.GlosarioButton(papa, 'Papa', 170, 260, (265, 150))

        monja = pygame.image.load("./Assets/ChArt/la monja.png")
        but_monja = Button.GlosarioButton(monja, 'Monja Roja', 170, 260, (475, 150))

        monaquillo = pygame.image.load("./Assets/ChArt/los monaquillo.png")
        but_monaquillo = Button.GlosarioButton(monaquillo, 'Monaquillo', 170, 260, (685, 150))

        espina = pygame.image.load("./Assets/ChArt/padre espina.png")
        but_espina = Button.GlosarioButton(espina, 'Padre Espina', 170, 260, (55, 450))

        serpico = pygame.image.load("./Assets/ChArt/Obispo Serpico.png")
        but_serpico = Button.GlosarioButton(serpico, 'Obispo Serpico', 170, 260, (265, 450))

        corvus = pygame.image.load("./Assets/ChArt/Fray Corvus.png")
        but_corvus = Button.GlosarioButton(corvus, 'Fray Corvus', 170, 260, (475, 450))

        galaad = pygame.image.load("./Assets/ChArt/galaad.png")
        but_galaad = Button.GlosarioButton(galaad, 'Galaad', 170, 260, (685, 450))

        kapparah = pygame.image.load("./Assets/ChArt/Kapparah.png")
        but_kapparah = Button.GlosarioButton(kapparah, 'Kapparah', 170, 260, (55, 750))

        run = True
        seccion = 1
        mouse_pos = pygame.mouse.get_pos()

        while run:
            events = pygame.event.get()
            for event in events:
                if event.type == pygame.QUIT:
                    pygame.quit()
                    run = False
                    quit()
                if event.type == pygame.MOUSEBUTTONUP:
                    if but_back.get_clicked():
                        self._ExitMode = True
                    if flechaizq_rect.collidepoint(mouse_pos) and seccion > 1:
                        seccion -= 1
                    if flechader_rect.collidepoint(mouse_pos) and seccion < 3:
                        seccion += 1
                    if but_caelius.get_clicked():
                        return but_caelius
                    if but_papa.get_clicked():
                        return but_papa
                    if but_monja.get_clicked():
                        return but_monja
                    if but_monaquillo.get_clicked():
                        return but_monaquillo
                    if but_espina.get_clicked():
                        return but_espina
                    if but_serpico.get_clicked():
                        return but_serpico
                    if but_corvus.get_clicked():
                        return but_corvus
                    if but_galaad.get_clicked():
                        return but_galaad
                    if but_kapparah.get_clicked():
                        return but_kapparah

            screen.blit(fondo, (0, 0))
            but_back.draw(screen, True, False)
            screen.blit(text_titulo, titulo_rect)

            mouse_pos = pygame.mouse.get_pos()
            if flechaizq_rect.collidepoint(mouse_pos) and seccion > 1:
                flechaizq = pygame.transform.scale(flechaizq, (55, 70))
            else:
                flechaizq = pygame.transform.scale(flechaizq, (50, 60))
            if flechader_rect.collidepoint(mouse_pos) and seccion < 3:
                flechader = pygame.transform.scale(flechader, (55, 70))
            else:
                flechader = pygame.transform.scale(flechader, (50, 60))
            screen.blit(flechader, flechader_rect)
            screen.blit(flechaizq, flechaizq_rect)

            font = pygame.font.Font("./Assets/Fonts/Seagram_tfb.ttf", 25)
            if seccion == 1:
                text_subtitulo = font.render("\n\n\nPERSONAJES", True, '#000000')
                but_caelius.draw(screen)
                but_papa.draw(screen)
                but_monja.draw(screen)
                but_monaquillo.draw(screen)
                but_espina.draw(screen)
                but_serpico.draw(screen)
                but_corvus.draw(screen)
                but_galaad.draw(screen)
                but_kapparah.draw(screen)
            elif seccion == 2:
                text_subtitulo = font.render("\n\n\nLUGARES", True, '#000000')
                # Mensaje de futuras actualizaciones
                future_updates_text = font.render("Futuras actualizaciones traerán más información.", True, '#000000')
                future_updates_rect = future_updates_text.get_rect(centerx=fondo_rect.centerx, centery=fondo_rect.centery + 100)
                screen.blit(future_updates_text, future_updates_rect)
            elif seccion == 3:
                text_subtitulo = font.render("\n\n\nCONCEPTOS", True, '#000000')
                # Mensaje de futuras actualizaciones
                future_updates_text = font.render("Futuras actualizaciones traerán más información.", True, '#000000')
                future_updates_rect = future_updates_text.get_rect(centerx=fondo_rect.centerx, centery=fondo_rect.centery + 100)
                screen.blit(future_updates_text, future_updates_rect)

            subtitulo_rect = text_subtitulo.get_rect(centerx=fondo_rect.centerx, top=fondo_rect.top)
            screen.blit(text_subtitulo, subtitulo_rect)

            if self._ExitMode:
                run = False

            pygame.display.update()
            clock.tick(30)

        return False

class Detalle:
    def __init__(self, screen):
        self.screen = screen
        self._ExitMode = False
        self.scroll_offset = 0
        self.max_scroll = 0
        self.show_religion = False  # Alterna entre descripción y religión
        self.show_stats_in_main_area = False # Nuevo estado para mostrar estadísticas en el área principal

    def cargaDetalle(self, screen, titulo, img, texto_principal, texto_religion, texto_estadisticas):
        fondo_rect = pygame.Rect(0, 0, screen.get_width(), screen.get_height())
        font_title = pygame.font.Font("./Assets/Fonts/Seagram_tfb.ttf", 25)
        text_titulo = font_title.render("\n" + titulo, True, '#000000')
        titulo_rect = text_titulo.get_rect(centerx=fondo_rect.centerx, top=fondo_rect.top)

        # Bloque superior (Imagen)
        background = pygame.image.load("./Assets/BckGrnd/paperallborder.png").convert_alpha()
        border_color = '#000000'
        border_rect = pygame.Rect(352, 75, 215, 291)
        background = pygame.transform.scale(background, (border_rect.width - 10, border_rect.height - 10))
        background_rect = background.get_rect(center=border_rect.center)
        img = pygame.transform.scale(img, (background_rect.width - 5, background_rect.height - 9))
        img_rect = img.get_rect(centerx=background_rect.centerx, top=background_rect.top + 4)

        # Bloque inferior (Texto)
        texto_border_rect = pygame.Rect(60, 375, 800, 350)
        texto_background = pygame.image.load("./Assets/BckGrnd/paper.png").convert_alpha()
        texto_background = pygame.transform.scale(texto_background, (texto_border_rect.width - 10, texto_border_rect.height - 10))
        texto_background_rect = texto_background.get_rect(center=texto_border_rect.center)

        font_text = pygame.font.Font("./Assets/Fonts/Seagram_tfb.ttf", 20)

        screen.blit(text_titulo, titulo_rect)

        pygame.draw.rect(screen, border_color, border_rect, 5)
        screen.blit(background, background_rect)
        screen.blit(img, img_rect)

        pygame.draw.rect(screen, border_color, texto_border_rect, 5)
        screen.blit(texto_background, texto_background_rect)

        padding = 10  # margen interno
        text_area = pygame.Rect(
            texto_background_rect.left + padding,
            texto_background_rect.top + padding,
            texto_background_rect.width - 2 * padding - 15,  # espacio para barra scroll
            texto_background_rect.height - 2 * padding
        )

        # Determinar qué contenido mostrar en el área principal
        if self.show_stats_in_main_area:
            current_text_content = texto_estadisticas
            font_to_use = pygame.font.Font("./Assets/Fonts/Seagram_tfb.ttf", 24) # Fuente más grande para estadísticas
        elif self.show_religion:
            current_text_content = texto_religion
            font_to_use = font_text
        else:
            current_text_content = texto_principal
            font_to_use = font_text

        temp_surface = pygame.Surface((text_area.width, 1), pygame.SRCALPHA)
        total_text_height = draw_text(temp_surface, current_text_content, (0, 0, 0), pygame.Rect(0, 0, text_area.width, 10000), font_to_use)

        self.max_scroll = max(0, total_text_height - text_area.height)

        draw_text(screen, current_text_content, (0, 0, 0), text_area, font_to_use, scroll_offset=self.scroll_offset)

        # Barra de scroll visual
        if self.max_scroll > 0:
            bar_width = 10
            bar_padding = 2
            bar_height = text_area.height * (text_area.height / total_text_height)
            bar_x = text_area.right + bar_padding
            scroll_ratio = -self.scroll_offset / self.max_scroll if self.max_scroll > 0 else 0
            bar_y = text_area.top + scroll_ratio * (text_area.height - bar_height)
            
            pygame.draw.rect(screen, (200, 200, 200), (bar_x, text_area.top, bar_width, text_area.height), border_radius=3)
            pygame.draw.rect(screen, (100, 100, 100), (bar_x, bar_y, bar_width, bar_height), border_radius=3)
            
        # Sección de estadísticas (solo se dibuja si no está en el área principal)
        if not self.show_stats_in_main_area:
            stats_border_rect = pygame.Rect(60, texto_border_rect.bottom + 20, 800, 120)
            stats_background = pygame.image.load("./Assets/BckGrnd/paper.png").convert_alpha()
            stats_background = pygame.transform.scale(stats_background, (stats_border_rect.width - 10, stats_border_rect.height - 10))
            stats_background_rect = stats_background.get_rect(center=stats_border_rect.center)

            stats_img = pygame.transform.scale(img, (100, 100))
            stats_img_rect = stats_img.get_rect(topleft=(stats_border_rect.left + padding, stats_border_rect.top + padding))

            pygame.draw.rect(screen, border_color, stats_border_rect, 5)
            screen.blit(stats_background, stats_background_rect)
            screen.blit(stats_img, stats_img_rect)

            stats_text_area = pygame.Rect(
                stats_img_rect.right + padding + 5,
                stats_border_rect.top + padding,
                stats_border_rect.width - stats_img_rect.width - 2 * padding - 5,
                stats_border_rect.height - 2 * padding
            )

            font_stats = pygame.font.Font("./Assets/Fonts/Seagram_tfb.ttf", 24) # Fuente más grande para estadísticas
            draw_text(screen, texto_estadisticas, (0, 0, 0), stats_text_area, font_stats)

    def runDetalle(self, boton):
        screen = self.screen
        fondo = pygame.image.load("./Assets/BckGrnd/Nivel.png").convert()
        fondo = pygame.transform.scale(fondo, (WIDTH, HEIGHT))
        fondo_rect = fondo.get_rect()
        but_back = Button.Button('Atras', 100, 50, (25, 25))
        but_religion_desc = Button.Button('Religión', 150, 50, (25, 85))
        but_stats_desc = Button.Button('Estadísticas', 150, 50, (25, 145)) # Nuevo botón para estadísticas

        flechaizq = pygame.image.load("./Assets/Icons/izq.png")
        flechaizq_rect = pygame.Rect(312, 195, 40, 50)
        flechader = pygame.image.load("./Assets/Icons/der.png")
        flechader_rect = pygame.Rect(567, 195, 40, 50)

        textoIra = ("Bendecido fue al nacer. Decían eso. Destinado a la pureza estaba, al servicio entregado debía ser. "
                   "Y él lo creyó. Privilegiado fue; cura lo hicieron, y más que los hombres caminó entre ellos. "
                   "Poder le dieron… devoró cuanto halló. Junto al Padre Espina permaneció hundido, vicios disfrazados de fe consumió."
                   "Pero precio el pecado siempre exige. Quebró la máscara, y sin dudar, Espina lo entregó. "
                   "Todo le vendieron: nombre, carne y alma. Espina fue absuelto, protegido por el obispo Sérpico. "
                   "A la fosa de la vergüenza fue arrojado. El Papa le arrancó el título, con lengua invertida lo maldijo, "
                   "condenado quedó a hablar en eco retorcido de sus palabras. Desde entonces, voz propia no tiene. "
                   "Es burla de Dios."
                   "Clavada en cada hueso la culpa lleva. Paz no existe. Absolución no hay. Solo vacío que devora su ser. "
                   "Pero en la ruina propósito halló: el trono papal. No lo desea por fe, redención tampoco. "
                   "Para acallar el grito de su miseria lo busca. Coronar debe, vestir al Santo Padre debe. "
                   "Con poder sofocará la voz de la culpa. Quizás entonces… lo escuchen.")

        imgego = pygame.image.load("./Assets/ChArt/caelius de ego.png")
        textoEgo = ("En su cuna recibió lo que llamaron bendición; otros vieron maldición. Lo hicieron cura y lo alzaron demasiado alto. "
                   "Decían que servía a Dios, pero sus actos hablaron distinto. El poder lo devoró, la carne de la fe se corrompió en sus manos. "
                   "A la sombra de Espina anduvo, y aquel mentor fue máscara de pecado. Vicios y secretos se convirtieron en su banquete."
                   "Cayó, mas en la caída creció; Espina le vendió: su nombre fue arrojado al fuego y su cuerpo entregado. "
                   "El obispo Sérpico lo absolvió a otros, dejándolo libre. Su voz quedó torcida, su lengua partida; habla palabras al revés, "
                   "pero aun así se alza. Es burla sagrada, eco de un poder que muchos temen."
                   "Reclama la noche como territorio propio. No pide perdón ni busca redención. Solo anhela trono y dominio. "
                   "Ansía ser Santo Padre, no por fe, sino por fuerza. Quiere poder absoluto para callar voces, arrasar débiles y devorar obstáculos. "
                   "Desea el trono; tomará lo que cree suyo. Nada escapará a su vacío. El narrador observa.")

        imgpena = pygame.image.load("./Assets/ChArt/caelius de pena.png")
        textoPena = ("No tuvo cuna sagrada: nació en silencio y sombras. Creció entre rezos vacíos y miradas que esquivaban su dolor. "
                    "Mientras otros aprendían a orar, él aprendió a contener el grito que nacía en sus huesos."
                    "El Padre Espina lo tomó bajo su manto; fue cruel enseñanza de olvido. Lo educó para convertir su sufrimiento en arma, "
                    "su pena en escudo y su corazon roto en coraza."
                    "Cuando la molestia de su incorruptibilidad quedó clara, fue vendido al obispo Sérpico. No fue entrega sino traición. "
                    "Dejó su nombre en aquel altar y con él el último vestigio de humanidad."
                    "Hoy camina erguido por el peso de cadenas, no por orgullo. Reza con labios sellados, adora con manos ensangrentadas y sirve con el alma vacía. "
                    "El dolor no lo redime: lo define. Cada cicatriz es un versículo, cada gemido un canto. No busca trono; su reino es el látigo y la corona de espinas. "
                    "Mientras otros sueñan con gobernar, él solo desea que el mundo sienta la pena infinita que lo mantiene en pie cuando debería yacer muerto.")

        textoPapa = ("El Papa no llegó al trono por gracia divina, sino por sangre. Derrocó a su predecesor con violencia y sobre el cadáver alzó su corona. "
                     "Desde aquel instante el mundo fue arcilla en sus manos: moldeó cuerpos y almas según su voluntad. "
                     "Fue señor del pecado y de lo profano, abusó de inocencias y convirtió la fe en alimento. "
                     "Su placer fue mandato, su poder, la única ley. "
                     "Entre cenizas celebró liturgia oscura, devorando hombres y mujeres, bebiendo sangre y esencia. "
                     "Como un Aghori, tomó lo prohibido y lo declaró verdad; se erigió dios en tierra, abismo encarnado. "
                     "Pero los muertos nunca callan. Los devorados regresaron como sombras, como voces. "
                     "No necesitaron armas: su sola presencia bastó para arrancarle el poder. "
                     "Fue todopoderoso, amo y verdugo; cayó no por hombres ni por Dios, sino por las víctimas que lo condenaron. "
                     "Ahora su nombre es maldición, su figura, ruina perpetua. El trono que arrebató se volvió su tumba, "
                     "y los espectros que lo persiguen no le permiten descanso. Es Papa eterno, no de gloria, sino de condena.")

        textoMonja = ("Hijos de nada, fieles del vacío: una figura eterna se presenta. Ni hombre ni mujer, ni carne ni hueso: su cuerpo refleja culpas y adopta la forma que conviene. "
                      "Es lo que desean verla ser: virgen o ramera, ángel o demonio, madre o verdugo."
                      "Creada para servir al Papa, no como esclava sino como cómplice, tejió maldiciones y urdió la condena de los monaquillos. "
                      "Besó y envenenó, acarició y pudrió; su sonrisa arrastra a las almas al abismo."
                      "Siempre estuvo y estará: vio papas nacer y morir, tronos manchados en sangre y fe devorada por gusanos. Espera, ansiosa, al nuevo Papa, "
                      "al nuevo mundo retorcido que su corona de huesos traerá."
                      "Contó con deleite la transgresión del primer monaquillo; celebró la daga imborrable contra sus amos. Venganza y fuego son melodía. "
                      "En sombras de plegarias y noches sudorosas persistirá: santa burlona, monja sin nombre, tentación eterna.")

        textoMonaquillo = ("Son los monaquillos: nacieron malditos, sin elección, sin destino. Su cuna fue cadena, su leche la esclavitud. "
                           "No son hombres ni mujeres, ni siquiera almas: son juguetes quebrados en manos de verdugos santos."
                           "No tienen nombre ni voz. Aunque la carne envejezca, ante los dominadores siguen siendo niños. Niños eternos, vacíos, sin identidad, sin futuro. "
                           "Un rebaño de cuerpos repetidos, un eco de dolor interminable."
                           "Nadie escapa. Ninguno respira libertad. Son carne ofrecida a deseos oscuros, sacrificio vivo para saciar un hambre perversa. "
                           "Abren su pecho para ser desgarrados, entregan su aliento para ser sofocados, ceden la piel para ser marcada y rota."
                           "Son juguetes en un juego cruel, gritos ahogados en piedra sagrada: un coro de lamento que ni la muerte silencia.")

        textoEspina = ("El hombre conocido como Padre Espina apareció para predicar salvación, pero su túnica fue máscara y la cruz, arma. "
                       "Mientras hablaba de redención, sus manos se hundían en la carne de quienes confiaban. Sus sermones fueron mentira; su fe, instrumento. "
                       "Los rezos cubrían los gemidos que él mismo arrancaba."
                       "Los niños eran su apetito: su miedo lo embriagaba, sus lágrimas eran vino, su resistencia, pan. Cuando temblaban bajo sus dedos, él sentía el pulso de un dios inexistente. "
                       "El “no” de sus bocas se quebraba hasta convertirse en silencio y rendición. Cuando se rompían, él respiraba eternidad."
                       "Abusó tanto que ya no llevaba cuentas. Cada rostro olvidado se mezcló con otro, cada grito se hizo coro en su interior. El obispo Sérpico conocía su hambre y compartía la podredumbre. "
                       "Cuando Caelius cayó, Espina lo ofreció: lo vendió y traicionó, arrojándolo a los lobos para cubrir su propia caída. Él ascendió mientras otros se hundían."
                       "Ahora mira el trono con deseo; lo reclama para sí. Con ese poder imagina cuerpos y almas sometidos: hombres, mujeres y niños bajo su sombra. "
                       "Su reino no tendrá leyes: no habrá Dios, ni cielo, solo placer, obediencia y dolor convertido en gloria.")

        textoSerpico = ("El Obispo Sérpico posee la lengua que bendice y a la vez calla. No fue su pecado el contacto carnal; fue mayor: el encubrimiento. "
                        "Fue velo sobre rostros llorosos y cruz que quebró familias. Cerró bocas de madres y apagó gritos de niños en nombre de la paz de la Iglesia."
                        "Se definió a sí mismo guardián: la unidad por encima del individuo justificó sus actos. Enterró a las víctimas en el olvido y así protegió la estructura clerical. "
                        "Con su voz consagró pactos oscuros; convirtió corderos en lobos, otorgó púlpitos a hombres ambiciosos y recibió asientos más altos a cambio."
                        "Brindó sombra a los placeres del clero: no necesitó tocar para ser más vil; fue amparo de perversión, absolución sin penitencia, altar donde el pecado se enalteció. "
                        "No reza al Dios común: su dios es el Silencio, su evangelio, el Encubrimiento. Mientras predique, los pecados no serán castigados sino bendecidos.")

        textoCorvus = ("Fue reconocido como exorcista prodigioso: expulsó ángeles falsos, demonios y espíritus corrompidos. Con habilidad parecía domar lo invisible. "
                       "Pero aquellos a quienes exorcizó volvieron y tomaron su cuerpo. Su alma y carne fueron invadidas; la monja y su bendición permitieron a su cuerpo soportar el embate, "
                       "pero ya no era el mismo."
                       "La mente y el espíritu se fracturaron: la locura y el arte del exorcismo se deshilachan en él. Cree que, si obtiene el poder papal, podrá curarse y terminar los exorcismos. "
                       "Planea un mundo donde él elimine a ángeles, demonios y espectros, un mundo donde solo él posea poder. Nadie más podrá ostentar el control."
                       "Desde su reclusión murmura visiones y juramentos: solo curando su herida alcanzará orden. Solo con poder absoluto imagina terminar con el caos que lo devora.")

        textoGalaad = ("Galaad se presenta como político cambiante y poderoso, convencido de su destino. Se ve como ideal y pretende obtener el poder papal para imponer su visión. "
                       "Se proclama superior y ambiciona erigir una hegemonía donde su nombre sea ley. Considera a la monja obstáculo que debe eliminar para concentrar todo el poder."
                       "Su retórica promete grandeza y control; desea restaurar lo que llama orden y, con la autoridad papal, alzará su propia divinidad. Los que se opongan serán convertidos en monaquillos. "
                       "Su discurso es ardor patriótico y ambición desmedida, con promesas de dominación y purga."
                       "Detrás del orador hay un guerrero dispuesto a usar la iglesia como instrumento para erigir un poder personal que trascienda naciones.")

        textoKapparah = ("Kapparah fue un monaquillo que, contra todo pronóstico, rompió la maldición. Conservó la fe cuando otros la perdieron y ascendió en dignidad. "
                         "Su deseo no es la venganza sino la reparación: anhela un mundo más justo, inclusivo, donde las maldiciones se desvanezcan para sus hermanos y hermanas. "
                         "Sueña con volver a memorias de antaño, a historias que hablaban de comunidades donde la bondad prevalecía."
                         "No busca poder para oprimir. Quiere sanar y restaurar: que aquellos que sufrieron recuperen nombre y voz. Aspira a una paz que no se imponga con violencia sino que brote del cariño. "
                         "Su lucha es por cariño, no por sangre; por reconstrucción, no por ruina.")

        religionCaelius = "Caelius pertenece al Catolicismo. los católicos se muestran profundamente dependientes de sus emociones; cada alegría, cada miedo o cada remordimiento parece moldear su ser. Sus almas, frágiles y cambiantes, se balancean entre la esperanza y la culpa, incapaces de encontrar un equilibrio duradero."
        religionPapa = "El Papa, pertenece a los Aghori. Estos seres repugnantes veneran la carne ajena y se alimentan de otros para aumentar su poder. Cuanto más consumen, más crece su fuerza, convirtiéndose en criaturas cuya maldad y apetito no conocen límites."
        religionMonja = "La Monja no pertenece a ninguna religión. Es un ser inmortal, creada con un propósito único: observar, narrar y dirigir. Su existencia trasciende las creencias humanas; está allí para guiar, para ayudar, y para mantener el orden en un mundo que los mortales apenas comprenden."
        religionMonaquillo = "Los monaquillos pertenecen a la Devotio Aeterna. Desde el momento de su nacimiento, están condenados a este destino: una vida marcada por la devoción estricta y la obediencia absoluta. No conocen otra existencia; su camino está trazado desde antes de que puedan comprenderlo, y su voluntad se encuentra siempre subordinada a la orden que los reclama."
        religionEspina = "El Padre Espina pertenece al Hinduismo. En esta religión, la moral es lo más importante: cuanto más se apega una persona a sus principios, mayor es el poder que obtiene. Sin embargo, la moral es un concepto abstracto y ambiguo, que depende en gran medida de cada individuo; lo que para uno es correcto, para otro puede ser cuestionable, y aun así, su fuerza se mide por la rectitud de su propia interpretación."
        religionSerpico = "El Obispo Serpico pertenece al Zoroastrismo. En esta religión, la fuerza de un individuo crece al alcanzar la edad adulta, pero depende de la cantidad de conocimiento que haya acumulado a lo largo de su vida. Quienes llegan a la adultez sin información suficiente corren un destino terrible: su propia alma los consume."
        religionCorvus = "Fray Curvus pertenece al cristianismo africano, una tradición en la que se destacan como expertos en exorcismos. A través de rituales complejos, buscan obtener bendiciones de los Eternos, y cada tatuaje en su cuerpo es una manifestación tangible de su poder y de las fuerzas que han invocado. Su dominio no proviene solo de la fe, sino de la habilidad para canalizar lo sobrenatural en cada gesto y marca sobre su piel."
        religionGalaad = "Galad pertenece al sincretismo del protestantismo estadounidense. las personas nacen con un destino de liderazgo; su poder no reside en ellos mismos, sino en la cantidad de seguidores que logran atraer. Sin creyentes a su alrededor, carecen de fuerza. Muchos de ellos terminan convirtiéndose en políticos o líderes de cultos, canalizando su influencia sobre quienes dependen de su guía."
        religionKapparah = "El Kappara pertenecía al Devotio Aeterna, pero ascendió y se convirtió en judío. En esta religión, sus miembros son personas puras, sin maldad, con un enorme poder espiritual. El Kappara es el único judío, pues solo mediante la ascensión se puede pertenecer a esta tradición, y él fue el único capaz de lograrlo, convirtiéndose en un ser de poder excepcional y singular."

        statsCaelius = "PV: 150\n\nATK: 20   DAN: 10   VLC: 10\n\nDEF: 0   ESQ: 10   SRT: 5"
        statsPapa = "PV: 3000\n\nATK: 2002   DAN: 902   VLC: 99\n\nDEF: 300   ESQ: 110   SRT: 5000"
        statsMonja = "PV: 3000\n\nATK: 2002   DAN: 902   VLC: 99\n\nDEF: 300   ESQ: 110   SRT: 5000"
        statsMonaquillo = "PV: 125\n\nATK: 5   DAN: 0   VLC: 0\n\nDEF: 5   ESQ: 15   SRT: 10"
        statsEspina = "PV: 200\n\nATK: 15   DAN: 25   VLC: 5\n\nDEF: 5   ESQ: 10   SRT: 15"
        statsSerpico = "PV: 275\n\nATK: 15   DAN: 10   VLC: 10\n\nDEF: 5   ESQ: 10   SRT: 10"
        statsCorvus = "PV: 127\n\nATK: 25   DAN: 10   VLC: 25\n\nDEF: 0   ESQ: 10   SRT: 10"
        statsGalaad = "PV: 500\n\nATK: 32   DAN: 20   VLC: 20\n\nDEF: 15   ESQ: 25   SRT: 20"
        statsKapparah = "PV: 559\n\nATK: 15   DAN: 35   VLC: 25\n\nDEF: 100   ESQ: 120   SRT: 10"

        opc = 1
        run = True
        mouse_pos = pygame.mouse.get_pos()

        while run:
            events = pygame.event.get()
            for event in events:
                if event.type == pygame.QUIT:
                    pygame.quit()
                    run = False
                    quit()
                if event.type == pygame.MOUSEBUTTONUP:
                    if but_back.get_clicked():
                        self._ExitMode = True
                    if flechaizq_rect.collidepoint(mouse_pos) and opc > 1:
                        opc -= 1
                        self.scroll_offset = 0
                        self.show_religion = False # Resetear vista al cambiar de opción
                        self.show_stats_in_main_area = False # Resetear vista al cambiar de opción
                        but_religion_desc.text_text = but_religion_desc.font.render('Religión', True, '#000000')
                        but_religion_desc.text_rect = but_religion_desc.text_text.get_rect(center = but_religion_desc.background_rect.center)
                        but_stats_desc.text_text = but_stats_desc.font.render('Estadísticas', True, '#000000')
                        but_stats_desc.text_rect = but_stats_desc.text_text.get_rect(center = but_stats_desc.background_rect.center)
                    if flechader_rect.collidepoint(mouse_pos) and opc < 3:
                        opc += 1
                        self.scroll_offset = 0
                        self.show_religion = False # Resetear vista al cambiar de opción
                        self.show_stats_in_main_area = False # Resetear vista al cambiar de opción
                        but_religion_desc.text_text = but_religion_desc.font.render('Religión', True, '#000000')
                        but_religion_desc.text_rect = but_religion_desc.text_text.get_rect(center = but_religion_desc.background_rect.center)
                        but_stats_desc.text_text = but_stats_desc.font.render('Estadísticas', True, '#000000')
                        but_stats_desc.text_rect = but_stats_desc.text_text.get_rect(center = but_stats_desc.background_rect.center)
                    if but_religion_desc.get_clicked():
                        self.show_religion = not self.show_religion
                        self.show_stats_in_main_area = False # Asegurarse de que no se muestren estadísticas
                        but_religion_desc.text_text = but_religion_desc.font.render('Descripción' if self.show_religion else 'Religión', True, '#000000')
                        but_religion_desc.text_rect = but_religion_desc.text_text.get_rect(center = but_religion_desc.background_rect.center)
                        but_stats_desc.text_text = but_stats_desc.font.render('Estadísticas', True, '#000000') # Resetear texto del botón de estadísticas
                        but_stats_desc.text_rect = but_stats_desc.text_text.get_rect(center = but_stats_desc.background_rect.center)
                        self.scroll_offset = 0
                        but_religion_desc.clicked = False
                    if but_stats_desc.get_clicked(): # Manejar clic en el nuevo botón de estadísticas
                        self.show_stats_in_main_area = not self.show_stats_in_main_area
                        self.show_religion = False # Asegurarse de que no se muestre religión
                        but_stats_desc.text_text = but_stats_desc.font.render('Descripción' if self.show_stats_in_main_area else 'Estadísticas', True, '#000000')
                        but_stats_desc.text_rect = but_stats_desc.text_text.get_rect(center = but_stats_desc.background_rect.center)
                        but_religion_desc.text_text = but_religion_desc.font.render('Religión', True, '#000000') # Resetear texto del botón de religión
                        but_religion_desc.text_rect = but_religion_desc.text_text.get_rect(center = but_religion_desc.background_rect.center)
                        self.scroll_offset = 0
                        but_stats_desc.clicked = False
                if event.type == pygame.MOUSEWHEEL:
                    self.scroll_offset += event.y * 10
                    self.scroll_offset = max(-self.max_scroll, min(0, self.scroll_offset))
                if event.type == pygame.QUIT:
                    pygame.quit()

            screen.blit(fondo, (0, 0))
            but_back.draw(screen, True, False)
            but_religion_desc.draw(screen, True, False)
            but_stats_desc.draw(screen, True, False) # Dibujar el nuevo botón de estadísticas

            mouse_pos = pygame.mouse.get_pos()

            if flechaizq_rect.collidepoint(mouse_pos) and opc > 1:
                flechaizq = pygame.transform.scale(flechaizq, (45, 60))
            else:
                flechaizq = pygame.transform.scale(flechaizq, (40, 50))
            if flechader_rect.collidepoint(mouse_pos) and opc < 3:
                flechader = pygame.transform.scale(flechader, (45, 60))
            else:
                flechader = pygame.transform.scale(flechader, (40, 50))
            screen.blit(flechader, flechader_rect)
            screen.blit(flechaizq, flechaizq_rect)

            # Determinar qué contenido mostrar según el botón y la opción seleccionada
            if (boton.text == 'Caelius'):
                if (opc == 1):
                    self.cargaDetalle(screen, boton.text, boton.img, textoIra, religionCaelius, statsCaelius)
                elif (opc == 2):
                    self.cargaDetalle(screen, boton.text, imgego, textoEgo, religionCaelius, statsCaelius)
                elif (opc == 3):
                    self.cargaDetalle(screen, boton.text, imgpena, textoPena, religionCaelius, statsCaelius)
            elif (boton.text == 'Papa'):
                self.cargaDetalle(screen, boton.text, boton.img, textoPapa, religionPapa, statsPapa)
            elif (boton.text == 'Monja Roja'):
                self.cargaDetalle(screen, boton.text, boton.img, textoMonja, religionMonja, statsMonja)
            elif (boton.text == 'Monaquillo'):
                self.cargaDetalle(screen, boton.text, boton.img, textoMonaquillo, religionMonaquillo, statsMonaquillo)
            elif (boton.text == 'Padre Espina'):
                self.cargaDetalle(screen, boton.text, boton.img, textoEspina, religionEspina, statsEspina)
            elif (boton.text == 'Obispo Serpico'):
                self.cargaDetalle(screen, boton.text, boton.img, textoSerpico, religionSerpico, statsSerpico)
            elif (boton.text == 'Fray Corvus'):
                self.cargaDetalle(screen, boton.text, boton.img, textoCorvus, religionCorvus, statsCorvus)
            elif (boton.text == 'Galaad'):
                self.cargaDetalle(screen, boton.text, boton.img, textoGalaad, religionGalaad, statsGalaad)
            elif (boton.text == 'Kapparah'):
                self.cargaDetalle(screen, boton.text, boton.img, textoKapparah, religionKapparah, statsKapparah)

            if self._ExitMode:
                run = False

            pygame.display.update()
            clock.tick(30)
