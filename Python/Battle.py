from time import sleep

import pygame
import random as rnd
import UI_const

from PIL.ImageChops import offset

##from pygame.examples.go_over_there import MIN_SPEED

import Characters

battle1_path = "Sound/Music/Battle1.wav"
lifeGauge_path = "./Assets/ui/lifeGaugeAlpha.png"
lifeGauge = pygame.image.load(lifeGauge_path)

lifeGauge_offsetX = 18
lifeGauge_offsetY = 13
WIDTH, HEIGHT = (UI_const.WIDTH_screen, UI_const.HEIGHT_screen)
# screen = pygame.display.set_mode((WIDTH, HEIGHT))
# pygame.display.set_caption("Prueba de Ticks")
#fontPath = None
fontPath = "./Assets/Fonts/Seagram_tfb.ttf"
# clock = pygame.time.Clock()
font = pygame.font.Font(fontPath, 14)
fontStats = pygame.font.Font(fontPath, 16)
#textos = []

RED = (255, 0, 0)
GREEN = (0, 255, 0)
WHITE = (255, 255, 255)
BLACK = (0, 0, 0)
GREY = (127, 127, 127)
PURPLE = (127, 0, 127)
YELLOW = (255, 200, 0)
TOPY = 50

offset1 = 0
offset2 = 0
OFFSETPOWER = 15
OFFSETDURATION = 20
MIN_SPEED = 5


class Battle:
    def __init__(self, battler1: Characters, battler2: Characters, screen):

        #Recibe los combatientes
        self._battler1 = battler1
        self._battler2 = battler2

        self._screen = screen

        self._tiempoEvent1 = pygame.time.get_ticks()/1000
        self._tiempoEvent2 = pygame.time.get_ticks()/1000

        self._tiempoBuff1 = 0
        self._tiempoBuff2 = 0

        self._textos = []

        self._animations = []

        self._offset1 = 0
        self._offset2 = 0

        self._battleEnd = False

        #Se obtiene la imagen original del battler
        self._img1_imp = pygame.image.load(battler1.get_sprite())
        self._img2_imp = pygame.image.load(battler2.get_sprite())

        #Se resizea para que tenga el tamaño correcto
        self._imagen1 = pygame.transform.scale(self._img1_imp, (self._img1_imp.get_width(), self._img1_imp.get_height()))
        self._imagen2 = pygame.transform.scale(self._img2_imp, (self._img2_imp.get_width(), self._img2_imp.get_height()))

    def get_battler1(self):
        return self._battler1
    def get_battler2(self):
        return self._battler2
    
    def get_tiempoEvent1(self):
        return self._tiempoEvent1
    def get_tiempoEvent2(self):
        return self._tiempoEvent2
    
    def get_imagen1(self):
        return self._imagen1
    def get_imagen2(self):
        return self._imagen2
    
    def get_screen(self):
        return self._screen

    def get_tiempoBuff1(self):
        return self._tiempoBuff1
    def get_tiempoBuff2(self):
        return self._tiempoBuff2

    def set_tiempoEvent1(self, tiempoEvent1):
        self._tiempoEvent1 = tiempoEvent1
    def set_tiempoEvent2(self, tiempoEvent2):
        self._tiempoEvent2 = tiempoEvent2

    def set_tiempoBuff1(self, tiempoBuff1):
        self._tiempoBuff1 = tiempoBuff1
    def set_tiempoBuff2(self, tiempoBuff2):
        self._tiempoBuff2 = tiempoBuff2

    def addZero(self, stat):
        if stat < 10:
            return "0" + str(stat)
        else: return str(stat)

    def printStats(self, battler: Characters):
        att = self.addZero(battler.get_atk())
        dam = self.addZero(battler.get_atkDmg())
        arm = self.addZero(battler.get_defn())
        spd = self.addZero(battler.get_spd())
        lck = self.addZero(battler.get_luck())
        eva = self.addZero(battler.get_evd())


        stat = "ATQ: " + att + "  DAN: " + dam + "  VLC: " + spd
        stat += "\n DEF: " + arm + "  ESQ: " + eva + "  SRT: " + lck

        return stat

    def textReset(self):
        self._textos = []

    def colorCalculation(self, actualHp, maxHp):
        if actualHp > (maxHp / 2):
            return GREEN
        elif actualHp <= maxHp / 2 and actualHp > maxHp / 4:
            return YELLOW
        else:
            return RED

    def fractionCalculation(self, actualHp, maxHp):
        if actualHp == 0 or maxHp == 0:
            return 0
        return actualHp / maxHp

    def animationManager(self):

        pops = []

        for i in range(len(self._animations)):
            animation_path = "./Assets/Animations/" + self._animations[i][0] + "/" + self._animations[i][0] + str(self._animations[i][1]) + ".png"
            animationFrame = pygame.image.load(animation_path).convert_alpha()
            #animationFrame.set_colorkey(BLACK)
            animationFrame = pygame.transform.scale(animationFrame,(animationFrame.get_width() * 2, animationFrame.get_height() * 2))

            if self._animations[i][3] == 0:
                anim_x = self.get_screen().get_width() / 2 + (animationFrame.get_width() / 4)
            else:
                anim_x = 0 - (animationFrame.get_width() / 5)
            anim_y = (self.get_screen().get_height() / 2) - (animationFrame.get_height() / 2) - 50


            self.get_screen().blit(animationFrame, (anim_x, anim_y))
            self._animations[i][1] += 1
            if self._animations[i][1] >= self._animations[i][2]:
                pops.append(i)

        for i in range(len(pops)):
            self._animations.pop(pops[i]-i)



    def doBattle(self):


        actualTick = pygame.time.get_ticks() / 1000

        if not self._battleEnd:

            if actualTick >= self.get_tiempoEvent1() + (MIN_SPEED - (self.get_battler1().get_spd() * 0.5 * 0.1)):

                beforeBattleLife = self.get_battler2().get_hp()

                btlMsg1 = str(self.get_battler1().act())

                if beforeBattleLife > self.get_battler2().get_hp() and self.get_battler2().get_hp() > 0:
                    self._offset2 = OFFSETDURATION
                    pygame.mixer.Channel(1).play(pygame.mixer.Sound('Assets\Sounds\Fantasy_Game_Attack_Weapon_Impact.wav'), maxtime=2000)
                    # PRUEBA ANIMACION
                    self._animations.append(["Slash", 1, 13, 0])
                    # print("ANIMAR")

                #self._offset2 = 30

                self.set_tiempoEvent1(pygame.time.get_ticks() / 1000)

                print("Ataque de " + btlMsg1)

                # Prueba de checks

                print(str(actualTick) + " - " + str(self.get_tiempoEvent1()))

                #self._textos.append(font.render(f"{btlMsg1}", True, BLACK, None, 265))
                self._textos.append(btlMsg1)

                if self.get_battler2().get_hp() <= 0:
                    expGainMsg = self.get_battler1().xpUp(5 * self._battler2.get_lv())
                    #self._textos.append(font.render(f"{expGainMsg}", True, BLACK, None, 265))
                    self._textos.append(expGainMsg)

                # self._textos.append(font.render("PJ 1 ataca", True, BLACK))

            if actualTick >= self.get_tiempoEvent2() + (MIN_SPEED - (self.get_battler2().get_spd() * 0.5 * 0.1)) and self.get_battler2().get_hp() > 0:

                beforeBattleLife = self.get_battler1().get_hp()
                beforeBattleLifeHeal = self.get_battler2().get_hp()
                beforeAtk = self.get_battler2().get_atk()

                btlMsg2 = str(self.get_battler2().act())

                if beforeBattleLife > self.get_battler1().get_hp() and self.get_battler1().get_hp() > 0:
                    self._offset1 = OFFSETDURATION
                    pygame.mixer.Channel(2).play(pygame.mixer.Sound('Assets\Sounds\Fantasy_Game_Attack_Weapon_Impact.wav'), maxtime=2000)
                    self._animations.append(["Slash", 1, 13, 1])

                if beforeBattleLifeHeal < self.get_battler2().get_hp() and self.get_battler2().get_hp() > 0 and self.get_battler1().get_hp() > 0:
                    self._animations.append(["Cure", 1, 21, 0])

                if beforeAtk < self.get_battler2().get_atk() and self.get_battler2().get_actvBuff()[1] == False:
                    pygame.mixer.Channel(3).play(pygame.mixer.Sound('Assets\Sounds\Fantasy_Game_Magic_Light Magic_2_Blast_Holy_Priest_Spell.wav'), maxtime=2000)
                    self._animations.append(["BossBuff", 1, 26, 0])


                self.set_tiempoEvent2(actualTick)

                print("Ataque de " + btlMsg2)

                # self._textos.append(font.render(f"PJ 2 ataca con Daño {danioNuevo[0]} {danioNuevo[1]}", True, BLACK))

                #self._textos.append(font.render(f"{btlMsg2}", True, BLACK, None, 256))
                self._textos.append(btlMsg2)

                # self._textos.append(font.render("PJ 2 ataca", True, BLACK))

            if self.get_battler1().get_actvBuff()[1] and self.get_tiempoBuff1() == 0:

                self.set_tiempoBuff1(actualTick)

                pygame.mixer.Channel(4).play(pygame.mixer.Sound('Assets\Sounds\Fantasy_Game_Magic_Light Magic_2_Blast_Holy_Priest_Spell.wav'), maxtime=2000)

                self._animations.append(["Buff", 1, 29, 1])

                print("Ataque actual con buff: " + str(self.get_battler1().get_atk()) + "\n" + str(self.get_tiempoBuff1()) + " - " + str(self.get_tiempoBuff1() + self.get_battler1().get_actvBuff()[0]))

            if self.get_battler1().get_actvBuff()[1] and actualTick >= self.get_tiempoBuff1() + self.get_battler1().get_actvBuff()[0]:
                endBuffmsg = self.get_battler1().endBuff()
                #self._textos.append(font.render(f"{endBuffmsg}", True, BLACK, None, 256))
                self._textos.append(endBuffmsg)
                self.set_tiempoBuff1(0)

                self._animations.append(["Debuff", 1, 24, 1])

                print("Ataque actual sin buff: " + str(self.get_battler1().get_atk()))

            if self.get_battler2().get_actvBuff()[1] and self.get_tiempoBuff1() == 0:
                self.set_tiempoBuff2(actualTick)
                pygame.mixer.Channel(3).play(pygame.mixer.Sound('Assets\Sounds\Fantasy_Game_Magic_Light Magic_2_Blast_Holy_Priest_Spell.wav'), maxtime=2000)
                self._animations.append(["BossBuff", 1, 26, 0])
                print("Ataque actual con buff: " + str(self.get_battler1().get_atk()) + "\n" + str(self.get_tiempoBuff2()) + " - " + str(self.get_tiempoBuff2() + self.get_battler2().get_actvBuff()[0]))

            if self.get_battler2().get_actvBuff()[1] and actualTick >= self.get_tiempoBuff1() + self.get_battler2().get_actvBuff()[0]:
                endBuffmsg = self.get_battler2().endBuff()
                #self._textos.append(font.render(f"PJ 2: {endBuffmsg}", True, BLACK, None, 256))
                self._textos.append(f"PJ 2: {endBuffmsg}")
                self.set_tiempoBuff2(0)
                self._animations.append(["Debuff", 1, 24, 0])
                print("Ataque actual sin buff: " + str(self.get_battler2().get_atk()))

        ##############

        #Calcular offset

        if self._offset2 > 0:
            offset_x2 = rnd.randint(-OFFSETPOWER, OFFSETPOWER)
            offset_y2 = rnd.randint(-OFFSETPOWER, OFFSETPOWER)
            self._offset2 -= 1
        else:
            offset_x2 = 0
            offset_y2 = 0

        if self._offset1 > 0:
            offset_x1 = rnd.randint(-OFFSETPOWER, OFFSETPOWER)
            offset_y1 = rnd.randint(-OFFSETPOWER, OFFSETPOWER)
            self._offset1 -= 1
        else:
            offset_x1 = 0
            offset_y1 = 0
        ##############
        self.get_screen().fill(WHITE)

        ##############

        fondo_screen = pygame.image.load("./Assets/BckGrnd/Bonefield_mvt.png").convert()
        fondo_screen = pygame.transform.scale(fondo_screen, (self.get_screen().get_width(), self.get_screen().get_height()))
        self.get_screen().blit(fondo_screen, (0, 0))

        paperBorder = pygame.image.load("./Assets/BckGrnd/papersideborder.png").convert()
        paperBorder.set_alpha(200)
        paperBorder = pygame.transform.scale(paperBorder, (self.get_screen().get_width() / 3, self.get_screen().get_height()))
        self.get_screen().blit(paperBorder, (self.get_screen().get_width() / 2 - self.get_screen().get_width() / 6, 0))

        paperAllBorder = pygame.image.load("./Assets/BckGrnd/paperallborder.png").convert()
        #paperAllBorder.set_alpha(200)
        paperAllBorder = pygame.transform.scale(paperAllBorder, (self.get_screen().get_width() / 3, self.get_screen().get_height() / 7))
        self.get_screen().blit(paperAllBorder, (0, self.get_screen().get_height() - self.get_screen().get_height() / 4))
        self.get_screen().blit(paperAllBorder, (self.get_screen().get_width() / 3 * 2, self.get_screen().get_height() - self.get_screen().get_height() / 4))
        ##############


        #pygame.draw.rect(self.get_screen(), RED, pygame.Rect(self.get_screen().get_width() - 300, TOPY + 25, self.get_battler2().get_maxHp(), 15))
        #pygame.draw.rect(self.get_screen(), GREEN, pygame.Rect(self.get_screen().get_width() - 300, TOPY + 25, self.get_battler2().get_hp(), 15))
        pygame.draw.rect(self.get_screen(), self.colorCalculation(self.get_battler2().get_hp(), self.get_battler2().get_maxHp()), pygame.Rect(self.get_screen().get_width() - lifeGauge.get_width() - 25 + lifeGauge_offsetX, TOPY + 25 + lifeGauge_offsetY, 205 * self.fractionCalculation(self.get_battler2().get_hp(), self.get_battler2().get_maxHp()), 17))
        self.get_screen().blit(lifeGauge, (self.get_screen().get_width() - lifeGauge.get_width() - 25, TOPY + 25))

        #pygame.draw.rect(self.get_screen(), RED, pygame.Rect(25, TOPY + 25, self.get_battler1().get_maxHp(), 15))
        pygame.draw.rect(self.get_screen(), self.colorCalculation(self.get_battler1().get_hp(), self.get_battler1().get_maxHp()), pygame.Rect(25 + lifeGauge_offsetX, TOPY + 25 + lifeGauge_offsetY, 205 * self.fractionCalculation(self.get_battler1().get_hp(), self.get_battler1().get_maxHp()), 17))
        self.get_screen().blit(lifeGauge, (25, TOPY + 25))

        ##############
        ############## Dibujar Stats

        #HUD1
        self.draw_wrapped_text(
            self.get_screen(),
            self.printStats(self.get_battler1()),
            fontStats,
            BLACK,
            25,
            HEIGHT - 140,
            250)

        #HUD2
        self.draw_wrapped_text(
            self.get_screen(),
            self.printStats(self.get_battler2()),
            fontStats,
            BLACK,
            self.get_screen().get_width() - 280,
            HEIGHT - 140,
            250)
        
        #HUD1 = fontStats.render(self.printStats(self.get_battler1()), True, BLACK)
        #HUD2 = fontStats.render(self.printStats(self.get_battler2()), True, BLACK)

        LIFE1 = fontStats.render(str(self.get_battler1().get_hp()) + "/" + str(self.get_battler1().get_maxHp()), True, WHITE)
        LIFE2 = fontStats.render(str(self.get_battler2().get_hp()) + "/" + str(self.get_battler2().get_maxHp()), True, WHITE)
        NAME1 = fontStats.render(self.get_battler1().get_name() + " [" + str(self.get_battler1().get_lv()) + "]", True, WHITE)
        NAME2 = fontStats.render(self.get_battler2().get_name() + " [" + str(self.get_battler2().get_lv()) + "]", True, WHITE)
        # boton_rect1 = pygame.Rect(100, 600, 120, 120)
        # #boton_rect2 = pygame.Rect(430, 600, 120, 75)
        # #fuenteBoton = pygame.font.SysFont(None, 16)
        # #textoBoton = fuenteBoton.render("SUBIR DE NIVEL", True, WHITE, None, 120)  # Texto blanco
        # texto_rect = HUD1.get_rect(center=boton_rect1.center)
        # pygame.draw.rect(self.get_screen(), GREY, boton_rect1)
        # self.get_screen().blit(HUD1, texto_rect)
        #
        # #self.get_screen().blit(texto_rect, (25, 600))

        self.get_screen().blit(LIFE1, (25, TOPY))
        self.get_screen().blit(LIFE2, (self.get_screen().get_width() - LIFE2.get_width() - 25, TOPY))
        self.get_screen().blit(NAME1, (25, TOPY - 20))
        self.get_screen().blit(NAME2, (self.get_screen().get_width() - NAME2.get_width() - 25, TOPY - 20))

        #self.get_screen().blit(HUD1, (25, HEIGHT-120))
        #self.get_screen().blit(HUD2, (self.get_screen().get_width() - 280, HEIGHT-120))

        ################

        ################
        while len(self._textos) > 5:
            self._textos.remove(self._textos[0])

        for i, texto in enumerate(self._textos):
            # if texto.get_alpha() > 1:
            #     self.get_screen().blit(texto, ((self.get_screen().get_width() / 3) + 10, TOPY + i * 125))
            self.draw_wrapped_text(
                self.get_screen(),
                texto,
                font,
                BLACK,
                (self.get_screen().get_width() / 3) + 10,
                TOPY + i * 100,
                300
            )

        self.get_screen().blit(self.get_imagen1(), (0 + offset_x1, TOPY + 100 + offset_y1))
        self.get_screen().blit(pygame.transform.flip(self.get_imagen2(), True, False), (self.get_screen().get_width() - (self.get_imagen2().get_width()) + offset_x2, TOPY + 100 + offset_y2))

        #PRUEBA ANINACIONES
        self.animationManager()

        # self.get_screen().blit(self.get_imagen1(), (0, TOPY + 75))
        # self.get_screen().blit(pygame.transform.flip(self.get_imagen2(), True, False), (self.get_screen().get_width() - (self.get_imagen2().get_width() + 20 + offset_x2), TOPY + 75 + offset_y2))

        if self.get_battler1().get_hp() <= 0 or self.get_battler2().get_hp() <= 0 and not self._battleEnd:
            pygame.mixer.music.fadeout(1000)
            self.get_battler1().endBuff()
            self.get_battler2().endBuff()
            return False
            sleep(1)
            self._battleEnd = True

        '''    
        if self._battleEnd:
            boton_rect1 = pygame.Rect(300, 600, 120, 75)
            boton_rect2 = pygame.Rect(430, 600, 120, 75)
            fuenteBoton = pygame.font.SysFont(None, 16)
            textoBoton = fuenteBoton.render("SUBIR DE NIVEL", True, WHITE, None, 120)  # Texto blanco
            texto_rect = textoBoton.get_rect(center=boton_rect1.center)
            if self.get_battler1().checkXp():
                pygame.draw.rect(self.get_screen(), GREY, boton_rect1)
            self.get_screen().blit(textoBoton, texto_rect)
            textoBoton2 = fuenteBoton.render("SIGUIENTE BATALLA", True, WHITE, None, 120)  # Texto blanco
            texto_rect2 = textoBoton2.get_rect(center=boton_rect2.center)
            pygame.draw.rect(self.get_screen(), GREY, boton_rect2)
            self.get_screen().blit(textoBoton2, texto_rect2)

            for evento in pygame.event.get():
                if evento.type == pygame.MOUSEBUTTONDOWN:
                    if self.get_battler1().checkXp():
                        if boton_rect1.collidepoint(evento.pos):
                            print("¡Botón Subir de Nivel!")
                    if boton_rect2.collidepoint(evento.pos):
                        print("¡Botón Continuar!")
        '''

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
        
        pygame.display.flip()
        return True
    
    def draw_wrapped_text(self, screen, texto, font, color, x, y, max_width):
        palabras = texto.split(' ')
        lineas = []
        linea_actual = ""

         # WRAP
        for palabra in palabras:

            prueba = linea_actual + palabra + " "

            if font.size(prueba)[0] <= max_width:
                linea_actual = prueba
            else:
                lineas.append(linea_actual)
                linea_actual = palabra + " "

        lineas.append(linea_actual)

        # DIBUJAR
        y_offset = y

        for linea in lineas:

            render = font.render(linea, True, color)

            screen.blit(render, (x, y_offset))

            y_offset += font.get_height() + 5



    