
import pygame

clock = pygame.time.Clock()
clock.tick(30)

pygame.init()

import random

import Characters as Ch
import Battle as Btl
import Menus as Mns
import UI_const

WIDTH, HEIGHT = (UI_const.WIDTH_screen, UI_const.HEIGHT_screen)

#Angel Randomizer Chances
ANGRND = [["HealManifest",4],["DrainManifest",3], ["LazManifest",1]]

#Win State
WINSTATE = {"W":1,"L&Out":2,"L&Re":3,"GW":4}

class Level:

    def __init__(self, M1, diff, stage):

        self._M1 = M1
        self._diff = diff
        self._stage = stage

        self._winState = 0

    def runLvSq (self):

        #Cutscene de Inicio de Seccion

        screen = pygame.display.set_mode((WIDTH, HEIGHT))

        pygame.display.set_caption("Caelitronus")

        LvSq = [[self.AngeRand(), 1 + self._diff],[self.AngeRand(), 1 + self._diff], [self._stage + "BossManifest", 2 + self._diff]]

        for Enemy in LvSq:
            
            M2 = getattr(Ch,Enemy[0])(Enemy[1])
            self._M1.set_opp(M2)
            M2.set_opp(self._M1)

            # Creamos una nueva batalla
            battleScreen = Btl.Battle(self._M1, M2, screen)

            run = True

            ##print("Do Battle!!")

            self._M1.heal(self._M1.get_maxHp())

            self._M1.setUpBuff()

            if Enemy[0] == LvSq[-1][0]:
                pygame.mixer.music.load(r"Assets\\Music\\Duel.wav")
                pygame.mixer.music.play(-1) 
            else:
                pygame.mixer.music.load(r"Assets\\Music\\Adversus.wav")
                pygame.mixer.music.play(-1) 

            while run:

                
                run = battleScreen.doBattle()

                #pygame.display.flip()

                clock.tick(30)

            pygame.mixer.music.load(r"Assets\\Music\\Ruins.wav")
            pygame.mixer.music.play(-1) 

            self._winState = WINSTATE["GW"] if Enemy[0] == LvSq[-1][0] else WINSTATE["W"]

            if self._M1.get_hp() == 0:
                #Pantalla de Perdida
                LostMenu = Mns.LScreen(screen)
                self._winState = WINSTATE["L&Re"] if LostMenu.runMenu() == True else WINSTATE["L&Out"]
                break

            #Pantalla de Siguiente Batalla o Subida de Nivel

            screenState = pygame.display.get_surface().copy()

            if self._winState == WINSTATE["W"]:
                
                WinMenu = Mns.WScreen(screen,self._M1)
                run = WinMenu.runMenu()

                while run:
                    LvUpMenu = Mns.LvUpScreen(screen,self._M1)
                    LvUpMenu.runMenu()

                    screen.blit(screenState)

                    WinMenu = Mns.WScreen(screen,self._M1)
                    run = WinMenu.runMenu()

            elif self._winState == WINSTATE["GW"]:

                #Cutscene de Final de Seccion

                WinMenu = Mns.GWScreen(screen,self._M1)
                run = WinMenu.runMenu()

                while run:
                    LvUpMenu = Mns.LvUpScreen(screen,self._M1)
                    LvUpMenu.runMenu()

                    screen.blit(screenState)

                    WinMenu = Mns.GWScreen(screen,self._M1)
                    run = WinMenu.runMenu()
            
            battleScreen.textReset()

        return self._winState
        
    def AngeRand(self):

        AngL = []

        for Ang in ANGRND:
            for i in range(Ang[1]):
                AngL.append(Ang[0])

        random.shuffle(AngL)

        return AngL[0]
    
'''
##Prueba de Niveles##

MainC = Ch.AtkDmnManifest(1)

LV1 = Level(MainC,0,"Spn")

run = WINSTATE["L&Re"]

while run == WINSTATE["L&Re"]:
    run = LV1.runLvSq()
'''