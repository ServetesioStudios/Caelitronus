import random
import numpy
import pygame
import pygame_widgets as pwidgets
from pygame_widgets.button import Button as WidButton

import Characters
import Button
import UI_const

pygame.init()

WIDTH, HEIGHT = (UI_const.WIDTH_screen, UI_const.HEIGHT_screen)
SCREEN = pygame.display.set_mode((WIDTH, HEIGHT))
font_Path = r"Assets\\Fonts\\Seagram_Tfb.ttf"
BTNIMAGE = r"Assets\\BckGrnd\\paperallborder.png"
MENUIMAGE = r"Assets\\BckGrnd\\paperallborder.png"

clock = pygame.time.Clock()
clock.tick(30)

class BinaryMenu:
    def __init__(self, screen):

        self._screen =  screen

        #Fonts
        self._BttnFont = pygame.font.Font(r"Assets\\Fonts\\Seagram_Tfb.ttf",16)
        self._TitleFont = pygame.font.Font(r"Assets\\Fonts\\Seagram_Tfb.ttf", 20)

        #Elements Text
        self._titleTxt = "Title"
        self._leftTxt = "Left"
        self._rightTxt= "Right"

        self._leftLg = ""
        self._rightLg = ""

        #Separator
        self._sprt = 20

        #Elements Size
        self._bttnSize = (140,40)
        self._titleSize = self._TitleFont.size(self._titleTxt)
        self._menuSize = self.caclMenuSize()

        #Elements Positions
        self._menuCenter = (WIDTH/2, 570)
        self._leftBttnPos = (self._menuCenter[0] - self._bttnSize[0] - self._sprt/2,self._menuCenter[1])
        self._rightBttnPos = (self._menuCenter[0] + self._sprt/2,self._menuCenter[1])
        self._titlePos = (self._menuCenter[0] - self._titleSize[0]/2,self._menuCenter[1] - self._bttnSize[1] - self._sprt)
        self._menuPos = (numpy.subtract(self._menuCenter,numpy.divide(self._menuSize,2)))

        #Elements Colors (yay!)
        self._titleTxtCol = (0,0,0)
        self._btnnTxtCol = (0,0,0)
    
        self._menuColor = (255,255,255,255)
        self._menuImage = pygame.image.load(r"Assets\\BckGrnd\\paperallborder.png")
        self._btnImage = pygame.image.load(r"Assets\\BckGrnd\\papersideborder.png")

        self._BtnCol = (0,0,0)
        self._hoverBtnnCol = (247,236,36)
        self._pressedBtnnCol = (247,236,36)

        #Buttons Enabling
        self._leftEn = True
        self._rightEn = True
         
        #Escape Clause
        self._ExitMode = False

        #Return Value
        self._ret = True   

    def runMenu(self):

        #self._screen.fill((255,255,255))
        
        #Creting Menu Box
        menu = self._menuImage.fill(self._menuColor, None, pygame.BLEND_RGBA_MULT)
        menu = pygame.transform.scale(self._menuImage,self._menuSize)

        self._screen.blit(menu,self._menuPos)

        #pygame.draw.rect(self._screen, self._menuCol, pygame.Rect(*self._menuPos,*self._menuSize))

        #Creating Tittle
        title = self._TitleFont.render(self._titleTxt,True,self._titleTxtCol)
        self._screen.blit(title,self._titlePos)
        
        #Creating Buttons
        self._btnImage = pygame.transform.scale(self._btnImage, numpy.subtract(self._bttnSize,(10,10)))

        leftBtn = WidButton(
            self._screen, *self._leftBttnPos, *self._bttnSize, text=self._leftTxt,
            font=self._BttnFont, margin=20,
            inactiveColour = self._BtnCol,
            pressedColour = self._pressedBtnnCol if self._leftEn == True else self._BtnCol,
            hoverColour = self._hoverBtnnCol if self._leftEn == True else self._BtnCol,
            image = self._btnImage,
            onClick = lambda: self.pressLeft() if self._leftEn == True else self.null(),
            textColour = self._btnnTxtCol)
        
        rightBtn = WidButton(
            self._screen, *self._rightBttnPos, *self._bttnSize, text=self._rightTxt,
            font=self._BttnFont, margin=20,
            inactiveColour = self._BtnCol,
            pressedColour = self._pressedBtnnCol if self._rightEn == True else self._BtnCol,
            hoverColour = self._hoverBtnnCol if self._rightEn == True else self._BtnCol,
            image = self._btnImage,
            onClick = lambda: self.pressRight() if self._rightEn == True else self.null(),
            textColour = self._btnnTxtCol)

        #Making Legends
        title = self._BttnFont.render(self._leftLg,True,self._titleTxtCol)
        self._screen.blit(title,numpy.subtract(self._leftBttnPos,(0,(self._bttnSize[1]/2))))

        title = self._BttnFont.render(self._rightLg,True,self._titleTxtCol)
        self._screen.blit(title,numpy.add(self._rightBttnPos,(0,(self._bttnSize[1]))))


        run = True
        self._ExitMode = False
        self._ret = False

        #screenState = pygame.display.get_surface().copy()

        while run:

            events = pygame.event.get()
            #print("Running Menu")
            for event in events:
                if event.type == pygame.QUIT:
                    pygame.quit()
                    run = False
                    quit()

            if self._ExitMode == True:
                run = False

            pwidgets.update(events)
            pygame.display.update()

        return self._ret
    
    def pressLeft(self):
        #print("Left")

        self._ret = False
        self._ExitMode = True
    
    def pressRight(self):
        #print("Right")

        self._ret = False
        self._ExitMode = True
    
    def null(self):
        pass

    def caclMenuSize(self):

        horBtnnSize = 2 * self._bttnSize[0] + 3 * self._sprt
        horTitleSize = self._titleSize[0] + 2 * self._sprt

        menuWidth = 0
        menuHeight = 2 * self._bttnSize[1] + self._titleSize[1] + 4 * self._sprt

        if horBtnnSize > horTitleSize:
            menuWidth = horBtnnSize
        else:
            menuWidth = horTitleSize
        
        return (menuWidth,menuHeight)

class WScreen (BinaryMenu):
    def __init__(self,screen,M1):
        super().__init__(screen)
        self._titleTxt = "Victoria"
        self._leftTxt = "Subir de Nivel"
        self._rightTxt= "Siguiente Batalla"

        self._titleSize = self._TitleFont.size(self._titleTxt)
        self._titlePos = (self._menuCenter[0] - self._titleSize[0]/2,self._menuCenter[1] - self._bttnSize[1] - self._sprt)

        self._M1 = M1

        self._leftLg = "XP: " + str(self._M1.get_xp()) + "/" + str(self._M1._xpBp[self._M1.get_lv() - 2] if self._M1.get_lv() == self._M1.get_lvBp()[0]["EndLv"] else self._M1._xpBp[self._M1.get_lv() - 1])

        self._leftEn = self._leftEn if self._M1.checkXp() == True else False

    def pressLeft(self):
        #print("We Level Up")
        if self._M1.checkXp() == True:
            self._ret = True
            self._ExitMode = True

            #print(self._ret)
        
class LScreen (BinaryMenu):
    def __init__(self, screen):
        super().__init__(screen)
        self._titleTxt = "Derrota"
        self._leftTxt = "Reintentar"
        self._rightTxt= "Seleccion de Nivel"

        self._titleSize = self._TitleFont.size(self._titleTxt)
        self._titlePos = (self._menuCenter[0] - self._titleSize[0]/2,self._menuCenter[1] - self._bttnSize[1] - self._sprt)

    def pressLeft(self):
        #We Try again
        self._ret = True
        self._ExitMode = True

class GWScreen (WScreen):
    def __init__(self,screen,M1):
        super().__init__(screen,M1)

        self._TitleFont = pygame.font.Font(font_Path, 26)

        self._titleTxt = "GRAN VICTORIA"
        self._leftTxt = "Subir de Nivel"
        self._rightTxt = "Continuar a la Seleccion de los Niveles"

        self._bttnSize = (300,55)

        self._titleSize = self._TitleFont.size(self._titleTxt)
        self._menuSize = (WIDTH,self.caclMenuSize()[1] + self._sprt)

        self._menuCenter = (WIDTH/2, 320)

        self._leftBttnPos = (self._menuCenter[0] - self._bttnSize[0]/2,self._menuCenter[1])
        self._rightBttnPos = (self._menuCenter[0] - self._bttnSize[0]/2,self._menuCenter[1] + self._bttnSize[1] + self._sprt)
        self._titlePos = (self._menuCenter[0] - self._titleSize[0]/2,self._menuCenter[1] - self._bttnSize[1] - self._sprt)
        self._menuPos = (self._menuCenter[0] - self._menuSize[0]/2,self._menuCenter[1] - 100)
        
        self._menuColor = (249,218,94,0)
        self._menuImage = pygame.image.load(r"Assets\\BckGrnd\\paper.png")
        
class LvUpScreen:
    def __init__(self,screen,M1):

        self._screen =  screen
        self._M1 = M1

        #Textos
        self._titleTxt = "Caelus sube de Nivel"
        self._untitleTxt = "Estadisticas Aumentadas"
        self._statTxt = self.gnrtStatTxt()
        self._bttnOverTxt = "Elige una mejora"

        #Fonts
        self._stageFont = pygame.font.Font(r"Assets\\Fonts\\Seagram_Tfb.ttf", 15)

        self._TitleFont = pygame.font.Font(r"Assets\\Fonts\\Seagram_Tfb.ttf", 50)

        self._subTitleFont = pygame.font.Font(r"Assets\\Fonts\\Seagram_Tfb.ttf", 25)

        self._statFont = pygame.font.Font(r"Assets\\Fonts\\Seagram_Tfb.ttf", 18)

        #Separator
        self._sprt = 50

        #Elements Size
        self._bttnSize = (180,80)
        self._titleSize = self._TitleFont.size("Caelus sube de Nivel")
        

        #Elements Positions
        self._menuCenter = (int(WIDTH/2), 320)

        self._bttmLeftBttnPos = (self._menuCenter[0] - self._bttnSize[0] * (1/2 + 1) - self._sprt, self._menuCenter[1] - self._bttnSize[1]/2 + self._titleSize[1]/2 + 5 * self._sprt)
        self._bttmMiddleBtnnPos = (self._menuCenter[0] - self._bttnSize[0]/2, self._menuCenter[1] - self._bttnSize[1]/2 + self._titleSize[1]/2 + 5 * self._sprt)
        self._bttmRightBtnnPos = (self._menuCenter[0] - self._bttnSize[0] * (1/2 - 1) + self._sprt, self._menuCenter[1] - self._bttnSize[1]/2 + self._titleSize[1]/2 + 5 * self._sprt)

        self._titlePos = (self._menuCenter[0] - self._titleSize[0]/2 , self._menuCenter[1] + - self._titleSize[1]/2 - 4 * self._sprt)

        #Elements Colors (yay!)
        self._titleTxtCol = (0,0,0)
        self._btnnTxtCol = (0,0,0)
    
        self._backCol = (226, 129, 99)
        self._backImage = pygame.image.load(r"Assets\\BckGrnd\\paper.png")
        self._btnImage = pygame.image.load(r"Assets\\BckGrnd\\papersideborder.png")

        self._BtnCol = (0,0,0)
        self._hoverBtnnCol = (247,236,36)
        self._pressedBtnnCol = (247,236,36)

        #Returns
        self._ExitMode = False

        pass

    def runMenu(self):
        self._screen.fill((137,137,137))

        #Creating Background
        back = self._backImage.fill((226, 114, 86), None, pygame.BLEND_RGBA_MULT)
        back = pygame.transform.scale(self._backImage,(WIDTH,HEIGHT))

        self._screen.blit(back,(0,0))
        
        #Creating Tittle
        title = self._TitleFont.render(self._titleTxt,True,self._titleTxtCol)
        self._screen.blit(title,self._titlePos)

        #Creating Stat Subtsection

        title = self._subTitleFont.render(self._untitleTxt,True,self._titleTxtCol)
        title_size = self._subTitleFont.size(self._untitleTxt)
        self._screen.blit(title,(self._menuCenter[0] - title_size[0]/2,self._titlePos[1] + self._titleSize[1] + self._sprt))

        i = 0
        for txt in self._statTxt:
            title = self._statFont.render(txt,True,self._titleTxtCol)
            title_size = self._statFont.size(txt)
            self._screen.blit(title,(self._menuCenter[0] - title_size[0]/2, self._titlePos[1] + self._titleSize[1] * (2/3) + (2 + i) * self._sprt + title_size[1]))
            i+=1


        #Generating Buttons 

        title = self._TitleFont.render(self._bttnOverTxt,True,self._titleTxtCol)
        title_size = self._TitleFont.size(self._bttnOverTxt)
        self._screen.blit(title,(self._menuCenter[0] - title_size[0]/2,self._bttmMiddleBtnnPos[1] - self._bttnSize[1] - self._sprt))

        statList =[self.gnrtRndStatUp(),self.gnrtRndStatUp(),self.gnrtRndStatUp()]

        self._btnImage = pygame.transform.scale(self._btnImage, numpy.subtract(self._bttnSize,(10,10)))

        bttomLeftTxt = "+" + str(statList[0][0][1])  + " " + str(statList[0][0][0]) + "\n" + "+" + str(statList[0][1][1])  + " " + str(statList[0][1][0])
        bttomMiddleTxt = "+" + str(statList[1][0][1])  + " " + str(statList[1][0][0]) + "\n" + "+" + str(statList[1][1][1])  + " " + str(statList[1][1][0])
        bttomRightTxt = "+" + str(statList[2][0][1])  + " " + str(statList[2][0][0]) + "\n" + "+" + str(statList[2][1][1])  + " " + str(statList[2][1][0])
       
        
        bttmLeftBtn = WidButton(
            self._screen, *self._bttmLeftBttnPos, *self._bttnSize, text=bttomLeftTxt,
            font=self._stageFont, margin=20,
            inactiveColour = self._BtnCol,
            pressedColour = self._pressedBtnnCol,
            hoverColour = self._hoverBtnnCol,
            image = self._btnImage,
            onClick = lambda: self.btnnStatUp(statList[0]),
            textColour = self._btnnTxtCol)
        
        bttmMiddleBtn = WidButton(
            self._screen, *self._bttmMiddleBtnnPos, *self._bttnSize,  text=bttomMiddleTxt,
            font=self._stageFont, margin=20,
            inactiveColour = self._BtnCol,
            pressedColour = self._pressedBtnnCol,
            hoverColour = self._hoverBtnnCol,
            image = self._btnImage,
            onClick = lambda: self.btnnStatUp(statList[1]),
            textColour = self._btnnTxtCol)
        
        bttmRightBtn = WidButton(
            self._screen, *self._bttmRightBtnnPos, *self._bttnSize,  text=bttomRightTxt,
            font=self._stageFont, margin=20,
            inactiveColour = self._BtnCol,
            pressedColour = self._pressedBtnnCol,
            hoverColour = self._hoverBtnnCol,
            image = self._btnImage,
            onClick = lambda: self.btnnStatUp(statList[2]),
            textColour = self._btnnTxtCol)

        run = True
        while run:
            events = pygame.event.get()
            for event in events:
                if event.type == pygame.QUIT:
                    pygame.quit()
                    run = False
                    quit()

            if self._ExitMode == True:
                run = False

            pwidgets.update(events)
            pygame.display.update()
    
    def gnrtStatTxt(self):
        TxtList = []
        M1Bp = self._M1.get_lvBp()
        M1Lv = self._M1.get_lv()

        lvOffset = M1Lv - M1Bp[0]['StartLv']  + 1

        i = 0
        Txt = ""
        for Stat in Characters.STATLIST:

            Txt += Stat + ": " + str(self._M1.get_bsStatByKey(Stat)) + " >>> " + (str(self._M1.get_bsStatByKey(Stat) + M1Bp[lvOffset+1][Stat]))
            
            if i == 0 or i == 3 or i == 6:
                TxtList.append(Txt)
                Txt = ""
            else:
               Txt += "    " 
            i+=1
        return TxtList
    
    def gnrtRndStatUp(self):
        pickList = []

        for i in range(0,2):
            statList = [[Characters.STATLIST[0],25],
                        [Characters.STATLIST[1],5],
                        [Characters.STATLIST[2],5],
                        [Characters.STATLIST[3],5],
                        [Characters.STATLIST[4],5],
                        [Characters.STATLIST[5],5],
                        [Characters.STATLIST[6],5]]
            random.shuffle(statList)
            pickList.append(statList[0])
        return pickList

    def btnnStatUp(self,stats):
        M1 = self._M1

        for stat in stats:
            IncrValue = M1.get_bsStatByKey(stat[0]) + stat[1]
            M1.set_bsStatByKey(stat[0],IncrValue)

        M1.lvUp()

        self._ExitMode = True

class LevelSelectScreen:

    def __init__(self,screen):

        self.screen = screen

        #Prueba. True si los jefes han sido derrotados (no me hago cargo si no respetan el orden de pelea)
        self.flag_serpico = False
        self.flag_espina = False
        self.flag_corvus = False
        self.flag_galaad = False
        self.flag_misionero = False
        self.jefesderrotados = 0

        self._ExitMode = False

        pass

    def runMenu(self):

        screen = self.screen

        stageSelec = None
        self.jefesderrotados = 0
        self._ExitMode = False
        

        #Trae y muestra los iconos de los jefes
        fondo = pygame.image.load("./Assets/BckGrnd/Nivel.png").convert()
        fondo = pygame.transform.scale(fondo, (WIDTH, HEIGHT))
        icon_back_color = '#000000'

        if(self.flag_serpico == False):
            icon_serpico = pygame.image.load("./Assets/Icons/Serpico.png")
        else:
            icon_serpico = pygame.image.load("./Assets/Icons/SerpicoDerrotado.png")
            self.jefesderrotados+=1

        icon_serpico = pygame.transform.scale(icon_serpico, (50, 50))
        posicion = pygame.Rect(155,HEIGHT-170,50,50)
        icon_serpico_rect = icon_serpico.get_rect(center = posicion.center)

        if(self.flag_espina == False):
            icon_espina = pygame.image.load("./Assets/Icons/Espina.png")
        else:
            icon_espina = pygame.image.load("./Assets/Icons/EspinaDerrotado.png")
            self.jefesderrotados+=1

        icon_espina = pygame.transform.scale(icon_espina, (50, 50))
        posicion = pygame.Rect(435,HEIGHT-170,50,50)
        icon_espina_rect = icon_espina.get_rect(center = posicion.center)

        if(self.flag_corvus == False):
            icon_corvus = pygame.image.load("./Assets/Icons/Corvus.png")
        else:
            icon_corvus = pygame.image.load("./Assets/Icons/CorvusDerrotado.png")
            self.jefesderrotados+=1

        icon_corvus = pygame.transform.scale(icon_corvus, (50, 50))
        posicion = pygame.Rect(715,HEIGHT-170,50,50)
        icon_corvus_rect = icon_corvus.get_rect(center = posicion.center)

        if(self.flag_galaad == False):
            icon_galaad = pygame.image.load("./Assets/Icons/Galaad.png")
        else:
            icon_galaad = pygame.image.load("./Assets/Icons/GalaadDerrotado.png")
            self.jefesderrotados+=1

        icon_galaad = pygame.transform.scale(icon_galaad, (50, 50))
        posicion = pygame.Rect(435,275,50,50)
        icon_galaad_rect = icon_galaad.get_rect(center = posicion.center)
        
        icon_misionero = pygame.image.load("./Assets/Icons/Misionero.png")

        icon_misionero = pygame.transform.scale(icon_misionero, (50, 50))
        posicion = pygame.Rect(435,50,50,50)
        icon_misionero_rect = icon_misionero.get_rect(center = posicion.center)

        #Botones de Seleccion de nivel (clase Button)
        but_serpico = Button.Button('Obispo Serpico',200,100,(80,HEIGHT-120))
        but_espina = Button.Button('Padre Espina',200,100,(360,HEIGHT-120))
        but_corvus = Button.Button('Fray Corvus',200,100,(640,HEIGHT-120))
        but_galaad = Button.Button('Galaad',200,100,(360,325))
        but_misionero = Button.Button('???',200,100,(360,100))
        but_menu = Button.Button('Salir al Menu Principal',280,50,(595,25))

        run = True
        

        while run:
            events = pygame.event.get()
            for event in events:
                if event.type == pygame.QUIT:
                    pygame.quit()
                    run = False
                    quit()
                if event.type == pygame.MOUSEBUTTONUP:
                    if(but_serpico.get_clicked() == True):
                        stageSelec = "Fn"
                        self._ExitMode = True
                    if(but_espina.get_clicked() == True):
                        stageSelec = "Spn"
                        self._ExitMode = True
                    if(but_corvus.get_clicked() == True):
                        stageSelec = "Pss"
                        self._ExitMode = True
                    if(but_galaad.get_clicked() == True):
                        stageSelec = "Fnl"
                        self._ExitMode = True
                    if(but_misionero.get_clicked() == True):
                        stageSelec = "Miss"
                        self._ExitMode = True 
                    if(but_menu.get_clicked() == True):
                        stageSelec = "Back"
                        self._ExitMode = True
                if event.type == pygame.QUIT:
                    pygame.quit()
            
            #Rect.Rect.Rect.Rect.Rect.Rect.Rect.Rect.Rect.Rect.Rect.Rect.Rect.Rect.Rect...
            #Dibuja las lineas entre los niveles, y sus variantes, segun cual y cuantos jefes se han derrotado
           
            screen.blit(fondo,(0,0))
            pygame.draw.rect(screen,'#000000',pygame.Rect(450,200,20,400))
            pygame.draw.rect(screen,'#000000',pygame.Rect(170,485,20,50))
            pygame.draw.rect(screen,'#000000',pygame.Rect(730,485,20,50))
            pygame.draw.rect(screen,'#000000',pygame.Rect(170,485,560,20))

            #Seccion de Serpico
            pygame.draw.rect(screen,'#000000',pygame.Rect(140,535,80,65))
            if(self.flag_serpico == True):
                pygame.draw.rect(screen,(255,0,0),pygame.Rect(145,540,70,65),5)
                pygame.draw.rect(screen,(255,0,0),pygame.Rect(175,535,10,5))
            else:
                 pygame.draw.rect(screen,(247,236,36),pygame.Rect(145,540,70,65),5)
            pygame.draw.rect(screen,icon_back_color,icon_serpico_rect)
            screen.blit(icon_serpico,icon_serpico_rect)

            #Seccion de Espina
            pygame.draw.rect(screen,'#000000',pygame.Rect(420,535,80,65))
            if(self.flag_espina == True):
                pygame.draw.rect(screen,(255,0,0),pygame.Rect(425,540,70,65),5)
                pygame.draw.rect(screen,(255,0,0),pygame.Rect(455,535,10,5))
            else:
                pygame.draw.rect(screen,(247,236,36),pygame.Rect(425,540,70,65),5)
            pygame.draw.rect(screen,icon_back_color,icon_espina_rect)
            screen.blit(icon_espina,icon_espina_rect)
            
            #Seccion de Corvus
            pygame.draw.rect(screen,'#000000',pygame.Rect(700,535,80,65))
            if(self.flag_corvus == True):
                pygame.draw.rect(screen,(255,0,0),pygame.Rect(705,540,70,65),5)
                pygame.draw.rect(screen,(255,0,0),pygame.Rect(735,535,10,5))
            else:
                pygame.draw.rect(screen,(247,236,36),pygame.Rect(705,540,70,65),5)
            pygame.draw.rect(screen,icon_back_color,icon_corvus_rect)
            screen.blit(icon_corvus,icon_corvus_rect)
            
            #Seccion de Galaad
            pygame.draw.rect(screen,'#000000',pygame.Rect(420,260,80,65))
            if(self.flag_galaad == True):
                pygame.draw.rect(screen,(255,0,0),pygame.Rect(425,265,70,65),5)
                pygame.draw.rect(screen,(255,0,0),pygame.Rect(455,200,10,65))
            else:
                pygame.draw.rect(screen,(247,236,36),pygame.Rect(425,265,70,65),5)
            pygame.draw.rect(screen,icon_back_color,icon_galaad_rect)
            screen.blit(icon_galaad,icon_galaad_rect)
            
            #Seccion del Misionero
            pygame.draw.rect(screen,'#000000',pygame.Rect(420,35,80,65))
            pygame.draw.rect(screen,(247,236,36),pygame.Rect(425,40,70,65),5)
            pygame.draw.rect(screen,icon_back_color,icon_misionero_rect)
            screen.blit(icon_misionero,icon_misionero_rect)
    
            if self.jefesderrotados == 1:
                pygame.draw.rect(screen,(255,0,0),pygame.Rect(175,497,10,38))
                pygame.draw.rect(screen,(255,0,0),pygame.Rect(735,497,10,38))
                pygame.draw.rect(screen,(255,0,0),pygame.Rect(455,497,10,38))
                pygame.draw.rect(screen,(255,0,0),pygame.Rect(175,497,560,3))
            elif self.jefesderrotados >= 2:
                pygame.draw.rect(screen,(255,0,0),pygame.Rect(175,490,10,45))
                pygame.draw.rect(screen,(255,0,0),pygame.Rect(735,490,10,45))
                pygame.draw.rect(screen,(255,0,0),pygame.Rect(455,480,10,55))
                pygame.draw.rect(screen,(255,0,0),pygame.Rect(175,490,560,10))
                if (self.jefesderrotados >= 3):
                    pygame.draw.rect(screen,(255,0,0),pygame.Rect(455,425,10,55))

            #Llamadas a la funcion draw de la clase Button
            but_serpico.draw(screen,True,self.flag_serpico)
            but_espina.draw(screen,True,self.flag_espina)
            but_corvus.draw(screen,True,self.flag_corvus)

            if(self.jefesderrotados >= 3):
                but_galaad.draw(screen,True,self.flag_galaad)
            else:
                but_galaad.draw(screen,False,self.flag_galaad)

            if(self.jefesderrotados >= 4):
                but_misionero.draw(screen,True,self.flag_misionero)
            else:
                but_misionero.draw(screen,False,self.flag_misionero)
            
            but_menu.draw(screen,True,False)

            if self._ExitMode == True:
                run = False

            pygame.display.update()
            clock.tick(30)
            
        print(self._ExitMode)
        return stageSelec

class CharSelectScreen:

    def __init__(self,screen):

        self.screen = screen
        self._ExitMode = False

        pass

    def drawThing(self,screen,rect,thing):

        fondo = pygame.image.load("./Assets/BckGrnd/paperallborder.png").convert()
        border_rect = rect
        border_color = '#000000'
        fondo = pygame.transform.scale(fondo, (border_rect.width - 10 , border_rect.height - 10))
        fondo_rect = fondo.get_rect(center = border_rect.center)

        if isinstance(thing, str):

            if(border_rect.left == 40):
                icon = pygame.image.load("./Assets/Icons/Espada.png")
                but_select = Button.Button('Seleccionar',150,40,(100, HEIGHT-50))
            if(border_rect.left == 325):
                icon = pygame.image.load("./Assets/Icons/Escudo.png")
                but_select = Button.Button('Seleccionar',150,40,(385, HEIGHT-50))
            if(border_rect.left == 610):
                icon = pygame.image.load("./Assets/Icons/Velocidad.png")
                but_select = Button.Button('Seleccionar',150,40,(670, HEIGHT-50))
            
            icon = pygame.transform.scale(icon, (32, 32))
            icon_rect = icon.get_rect(center = fondo_rect.center)
            icon_rect.top = border_rect.top + 15

            pygame.draw.rect(screen,border_color,border_rect,5)
            screen.blit(fondo,fondo_rect)
            screen.blit(icon,icon_rect)

            #TEXTO MULTILÍNEA
            font = pygame.font.Font("./Assets/Fonts/Seagram_tfb.ttf", 20)
            y_offset = 0
       
            lineas = thing.split('\n');
            for linea in lineas: 
               text = font.render(linea,True,'#000000')
               text_rect = text.get_rect(center=(fondo_rect.centerx, fondo_rect.top + 70 + y_offset))
               y_offset += 24;
               screen.blit(text,text_rect)
                
            
            return but_select

        else:

            img = thing
            img_rect = thing.get_rect(center = fondo_rect.center)

            pygame.draw.rect(screen,border_color,border_rect,5)
            screen.blit(fondo,fondo_rect)
            screen.blit(img,img_rect)

    def runMenu(self):

        screen = self.screen

        charType = None

        fondo_screen = pygame.image.load("./Assets/BckGrnd/Nivel.png").convert()
        fondo_screen = pygame.transform.scale(fondo_screen, (WIDTH, HEIGHT))      
        caelius1 = pygame.image.load("./Assets/ChArt/caelius de ira.png")
        caelius1 = pygame.transform.scale(caelius1, (200, 386))
        caelius2 = pygame.image.load("./Assets/ChArt/caelius de ego.png")
        caelius2 = pygame.transform.scale(caelius2, (200, 386))
        caelius3 = pygame.image.load("./Assets/ChArt/caelius de pena.png")
        caelius3 = pygame.transform.scale(caelius3, (200, 386))

        #Botones de Seleccion de Personajes (clase Button)

        but_select1 = Button.Button('Obispo Serpico',610,HEIGHT-250,(270,250))
        but_select2 = Button.Button('Obispo Serpico',325,HEIGHT-250,(270,250))
        but_select3 = Button.Button('Obispo Serpico',40,HEIGHT-250,(270,250))

        run = True
        while run:
            events = pygame.event.get()
            for event in events:
                if event.type == pygame.QUIT:
                    pygame.quit()
                    run = False
                    quit()
                if event.type == pygame.MOUSEBUTTONUP:
                    if(but_select1.get_clicked() == True):
                        charType = "Atk"
                        self._ExitMode = True
                    if(but_select2.get_clicked() == True):
                        charType = "Def"
                        self._ExitMode = True
                    if(but_select3.get_clicked() == True):
                        charType = "Lck"
                        self._ExitMode = True
                        

            screen.blit(fondo_screen,(0,0))

            self.drawThing(screen, pygame.Rect(65,15,220,425), caelius1)
            self.drawThing(screen, pygame.Rect(350,15,220,425), caelius2)
            self.drawThing(screen, pygame.Rect(635,15,220,425), caelius3)

            but_select1 = self.drawThing(screen, pygame.Rect(40,HEIGHT-250,270,250), "Fauste de Fe (Ira): \nIncrementa sus valores\nde ATK y DAN en un\n30% por 5 segundos ")
            but_select2 = self.drawThing(screen, pygame.Rect(325,HEIGHT-250,270,250), " Fauste de Fe (Ego):\nIncrementa su valor de DEF\nen un 40% por 5 segundos\ny se cura 10% de sus\nPV maximos")
            but_select3 = self.drawThing(screen, pygame.Rect(610,HEIGHT-250,270,250), " Fauste de Fe (Pena):\nIncrementa su valor de SRT\npor un 10% y sus valores\nde ESQ y VLC en 20%\npor 5 segundos")
           
            but_select1.draw(screen,True,False)
            but_select2.draw(screen,True,False)
            but_select3.draw(screen,True,False)            

            if self._ExitMode == True:
                run = False

            pygame.display.update()
            clock.tick(30)

        return charType

class Creditos:

    def __init__(self,screen):

        self.screen = screen
        self._ExitMode = False


    def runMenu(self):

        screen = self.screen

        creditos_fondo = pygame.image.load("./Assets/BckGrnd/papersideborder.png").convert()
        creditos_fondo = pygame.transform.scale(creditos_fondo, (WIDTH, HEIGHT))
        creditos_rect = creditos_fondo.get_rect()
        font = pygame.font.Font("./Assets/Fonts/Seagram_tfb.ttf", 25)
        text = font.render("\t\tGRUPO 6:  ESTUDIO SERVENTESIO\n\n\t\t\t\t\t\t\t\t\tDESARROLLADORES:\n\n" +
        "\t\t\t\t\t\t\t\t\t\tMaximiliano Andre Bograd\n\n\t\t\t\t\t\t\t\t\t\t\t\t\tJuarez Javier David\n\n\t\t\t\t\t\t\t\t\t\t\t\t\t Matias Daniel Diaz\n\n\t\t\t\t\t\t\t\t\t\t\tBriosso Adrian Roberto\n\n" +
        "\t\t\t\t\t\t\t\t\t\t\t\t\tPROFESORES:\n\n\t\t\t\t\t\t\t\t\t\t\t\t\t\tMariano Volker\n\n\t\t\t\t\t\t\t\t\t\t\t\t\t\tDario Hirschfeldt\n\n\n",True,'#000000')
        text_rect = text.get_rect(center = creditos_rect.center)
        but_mainmenu = Button.Button('Volver al Menu Principal',300,50,(310, 685))

        run = True
        while run:
            events = pygame.event.get()
            for event in events:
                if event.type == pygame.QUIT:
                    pygame.quit()
                    run = False
                    quit()
                if event.type == pygame.MOUSEBUTTONUP:
                    if(but_mainmenu.get_clicked() == True):
                        self._ExitMode = True

            screen.blit(creditos_fondo, (0,0))
            screen.blit(text,text_rect)
            but_mainmenu.draw(screen,True,False)

            if self._ExitMode == True:
                run = False

            pygame.display.update()
            clock.tick(30)

class Instruct:

    def __init__(self,screen):

        self.screen = screen
        self._ExitMode = False


    def runMenu(self):

        screen = self.screen

        creditos_fondo = pygame.image.load("./Assets/BckGrnd/papersideborder.png").convert()
        creditos_fondo = pygame.transform.scale(creditos_fondo, (WIDTH, HEIGHT))
        creditos_rect = creditos_fondo.get_rect()
        font = pygame.font.Font("./Assets/Fonts/Seagram_tfb.ttf", 25)
        text = font.render("\t\t\t\t\t\t\t\tLas batalllas en Caelitronus son automaticas\n\n\nCARACTERISTICAS:\n\nATQ: Determina la posibilidad de acertar un ataque\n\n" +
                           "DAN: Determina la potencia de cada ataque\n\nVLC: Determina la velocidad de ataque\n\nDEF: Reduce la potencia de cada ataque recibido\n\n" +
                           "ESQ: Reduce la posibilidad de acertar del enemigo\n\nSRT: Aumenta la posibilidad de criticos y la activacion de habilidades\n\n\n\n",True,'#000000')
        text_rect = text.get_rect(center = creditos_rect.center)
        but_mainmenu = Button.Button('Volver al Menu Principal',300,50,(310, 685))

        run = True
        while run:
            events = pygame.event.get()
            for event in events:
                if event.type == pygame.QUIT:
                    pygame.quit()
                    run = False
                    quit()
                if event.type == pygame.MOUSEBUTTONUP:
                    if(but_mainmenu.get_clicked() == True):
                        self._ExitMode = True

            screen.blit(creditos_fondo, (0,0))
            screen.blit(text,text_rect)
            but_mainmenu.draw(screen,True,False)

            if self._ExitMode == True:
                run = False

            pygame.display.update()
            clock.tick(30)
