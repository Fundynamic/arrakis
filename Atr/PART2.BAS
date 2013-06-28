DECLARE SUB clearspot (cell%, h%, b%)
DECLARE SUB dropnuke (cll%)
DECLARE SUB playmusic ()
DECLARE SUB loadgame (file$)
DECLARE SUB savegame (file$)
DECLARE SUB drawwindow (breedte%)
DECLARE SUB resetall ()
DECLARE SUB loadmap (map$)
DECLARE SUB center (y%, tekst$, kleur%)
DECLARE SUB addunit (team%, tpe%, cll%, movecell%, actie%)
DECLARE SUB addbuilding (team%, typ%, cell%)
'$INCLUDE: 'declars.bas'

'NO MORE
SUB adddead (tpe, frame, cell, x, y)
FOR k = 1 TO 100
IF deadd(k) = 0 THEN new = k: EXIT FOR
NEXT k
IF k > 100 THEN EXIT SUB

deadd(new) = 1
deadc(new) = cell
kansop = INT(RND * 15)
IF kansop = 0 THEN
IF maptile(cell) = 5 OR maptile(cell) = 6 THEN maptile(cell) = 34 + INT(RND * 4)
IF maptile(cell) = 3 OR maptile(cell) = 4 THEN maptile(cell) = 38 + INT(RND * 3)
END IF

deadx(new) = x
deady(new) = y
deadt(new) = tpe
deadf(new) = frame
deadc2(new) = 0
END SUB

REM $DYNAMIC
SUB AIthink
'If no const yard, then we dont use the FOR-NEXT, because the FOR-NEXT
'is only for BUILDING A BASE!
'NEW: WE DO THE FOR-NEXT ANYWAY, FOR TRIGGERS..
FOR i = 1 TO 30

IF aidead(i) = 2 THEN

'TRIGGER with TIME events,
        triggersoort = aitype(i)
        triggercell = aicell(i)

        IF tijd = aitime(i) THEN
 
                IF triggersoort = 0 THEN
                'Trigger = 0
                'DROP A NUKE ON THE CELL!
                dropnuke triggercell
                DQBsetPal pal
                aidead(i) = 0           'Trigger dies
                END IF

                IF triggersoort = 1 THEN
                'TRIGGER = 1, WILL SET TIMER ON SPECIFIC SECONDS.
                'WILL DISCOUNT..
                settimer = triggercell
                aidead(i) = 0           'Trigger dies
                END IF

                IF triggersoort = 5 THEN
                'TRIGGER = 2,WILL SEND REINFORCEMENTS FROM CLOSEST POSITION
                'TO DESTENATION. THE UNIT IS A RANDOM UNIT, BUT IS NEVER A SOLDIER
                cll = triggercell
                y11 = INT(cll / 64)
                x11 = cll - INT(y11 * 64)
              
                IF x11 >= 32 THEN begnx = 63
                IF x11 < 32 THEN begnx = 0
                IF y11 >= 32 THEN begny = 63
                IF y11 < 32 THEN begny = 0
                begincll = begny * 64 + begnx
                IF begincll = 0 THEN begincll = 1
nogeens54:
                IF mapunit(begincll) <> 0 OR mapstruct(begincll) <> 0 THEN
                IF (begincll - 1) > 0 THEN begincll = begincll - 1: GOTO nogeens54
                IF (begincll + 1) < 4095 THEN begincll = begincll + 1: GOTO nogeens54
                END IF
                IF techlevel = 0 THEN srt = 5
                IF techlevel = 1 THEN srt = 4 + INT(RND * 2)
                IF techlevel = 2 OR techlevel = 3 THEN
                la = INT(RND * 2)
                IF la = 0 THEN srt = 4 + INT(RND * 2)
                IF la = 1 THEN srt = 0
                END IF
                IF techlevel > 3 THEN
                la = INT(RND * 2)
                IF la = 0 THEN srt = 4 + INT(RND * 2)
                IF la = 1 THEN srt = 0 + INT(RND * 2)
                END IF

                addunit 0, srt, begincll, aicell(i), 0
                message$ = "REINFORCEMENTS HAVE ARRIVED"
                messagetijd = 25
                aidead(i) = 0           'Trigger dies
                END IF

                IF triggersoort = 7 THEN
                'TRIGGER, AI will pick 5 units and send them to
                'the cell
                aidead(i) = 2           'Trigger re-lives
                aitime(i) = aitime(i) + aitime2(i)   'New movement in 20 seconds
                coun = 0
                FOR si = 1 + INT(RND * 50) TO 100
                IF unitt2(si) <> 0 AND unitt(si) <> 2 THEN unitmc(si) = triggercell: unita(si) = 0: coun = coun + 1
                IF coun > 4 THEN EXIT FOR
                NEXT si
                aidead(i) = 0           'Trigger dies
                END IF
              
              
                END IF
      
  
'TRIGGERS WHO DONT USE TIME!!!!!!!!!

                IF triggersoort = 2 THEN
                'PLAYER WILL WIN WHEN AI DOESNT HAVE ANY RADAR
                IF aihaveradar <= 0 THEN enemyfound = 0
                END IF

                IF triggersoort = 3 THEN
                'CLEAR SPOT
                        IF mapunit(aitime(i)) > 0 THEN
                                nr = mapunit(aitime(i))
                                IF unitt2(nr) = 0 THEN clearspot aicell(i), 0, 0: aidead(i) = 0
                        END IF
                END IF
               
                IF triggersoort = 4 THEN
                'PLAYER WILL WIN WHEN HE OR SHE HAS CELL AMOUNT OF CREDITS
                musthavecredits = aicell(i)
                IF credits >= musthavecredits THEN enemyfound = 0
                END IF

                IF triggersoort = 6 THEN
                'IF AI doesnt have any CONSTYARDS, TENTS, WARFACTORYS
                'YOU WIN
                IF aihaveconst <= 0 AND aihavetent <= 0 AND aihavewar <= 0 THEN enemyfound = 0
                END IF
        END IF


'IF ITS A BUILD STRUCTURE COMMAND AND AI HAVES 1 or more constyards...
IF aidead(i) = 1 AND aihaveconst > 0 THEN
IF tijd = aitime(i) THEN
aitime(i) = aitime(i) + aitime2(i)
IF mapstruct(aicell(i)) = 0 AND mapstruct(aicell(i) + 1) = 0 AND mapstruct(aicell(i) + 64) = 0 AND mapstruct(aicell(i) + 65) = 0 THEN fase = 1
IF fase = 1 AND mapunit(aicell(i)) = 0 AND mapunit(aicell(i) + 1) = 0 AND mapunit(aicell(i) + 64) = 0 AND mapunit(aicell(i) + 65) = 0 THEN fase = 2
IF fase = 2 THEN addbuilding 1, aitype(i), aicell(i)
END IF
END IF
NEXT i

unitai:
'AI thinking for use of units...
FOR i = 1 TO 100
IF unitd(i) <> 0 AND unitt2(i) <> 0 THEN
'Only computer units in this BLOCK
IF unitt(i) = 2 AND unitmc(i) = unitc(i) AND unitcap(i) < 25 THEN
'There is a harvester that is not harvesting,
'seek for closest harvest
dichtstbij = 0
FOR cll = 1 TO 4095
IF maptile(cll) >= 25 OR maptile < 28 THEN
IF unitc(i) > cll THEN dichtsbij = unitc(i) - cll: manier = 0
IF cll > unitc(i) THEN dichtsbij = cll - unitc(i): manier = 1
END IF
NEXT cll
IF manier = 0 THEN unitmc(i) = unitc(i) + dichtsbij
IF manier = 1 THEN unitmc(i) = unitc(i) - dichtsbij
END IF

IF tijd >= attacktime THEN
attacktime = attacktime + 40 + INT(RND * 40)
discovered = 1          'AI Knows at start where you are (yep thats cheating)

'Ok to advance the AI, we make different ai strategies
'Can only attack when discovered enemy
'0=Attack units, doesnt matter with what
'1=Attack enemy harvesters
'2=Attack structures, and attack units when interfering.
'3=Attack units, with best units it has
IF discovered <> 0 THEN
'Found you!, gna gna, now you DIE!
typeattack = INT(RND * 4)

'Logically you dont attack with all your units, so lets say for 65% of all
'the AI's units he will attack, that is 0.65*total
'dm = INT(enemies / 2) + INT(RND * (INT(enemies / 2)))   'Amount to attack with
dm = INT(.65 * enemies)

helemaal:
'*******************ATTACK TYPE 0***************
IF typeattack = 0 THEN
'First check if there are any units, if not then we switch to attack type 3
found = 0
FOR su = 1 TO 100
IF unitd(su) <> 0 AND unitt2(su) = 0 AND unitt(su) <> 2 THEN found = unitc(su): EXIT FOR
NEXT su
IF found = 0 THEN typeattack = 1: GOTO dontdothis

f = 0
FOR si = 1 TO 100

IF unitd(si) <> 0 AND unitt2(si) <> 0 AND unitt(si) <> 2 AND unitt(si) <> 3 THEN
f = f + 1
unitmc(si) = unitc(su)
unitfi2(si) = 0
unitfi(si) = su
unita(si) = 0
END IF
IF f >= dm THEN EXIT FOR
NEXT si
'TYPE ATTACK 0
END IF
dontdothis:

'*******************ATTACK TYPE 1***************
IF typeattack = 1 THEN
'First check if there are any units, if not then we switch to attack type 3
found = 0
FOR su = 1 TO 100
IF unitd(su) <> 0 AND unitt2(su) = 0 AND unitt(su) = 2 THEN found = unitc(su): EXIT FOR
NEXT su
IF found = 0 THEN typeattack = 3: GOTO dontdothis

f = 0
FOR si = 1 TO 100

IF unitd(si) <> 0 AND unitt2(si) <> 0 AND unitt(si) <> 2 AND unitt(si) <> 3 THEN
f = f + 1
unitmc(si) = unitc(su)
unitfi2(si) = 0
unitfi(si) = su
unita(si) = 0
END IF
IF f >= dm THEN EXIT FOR
NEXT si
'TYPE ATTACK 0
END IF

'*******************ATTACK TYPE 2***************
IF typeattack = 2 THEN
'First check if there are any structures, if not then we switch to attack type 3
found = 0
FOR su = 1 TO 100
IF structd(su) <> 0 AND structt2(su) = 0 THEN found = structc(su): EXIT FOR
NEXT su
IF found = 0 THEN typeattack = 0: GOTO helemaal

f = 0
FOR si = 1 TO 100

IF unitd(si) <> 0 AND unitt2(si) <> 0 AND unitt(si) <> 2 AND unitt(si) <> 3 THEN
f = f + 1
unitmc(si) = structc(su)
unitfi(si) = 0
unitfi2(si) = su
unita(si) = 0
END IF
IF f >= dm THEN EXIT FOR
NEXT si
'TYPE ATTACK 0
END IF
 

'ATTACK CODE
END IF



END IF
notthistime:

'Lets say that his target is destroyed, and the tank is on guard mode
'and the random figure is 0 then we say attack, so it is more dune 2 like
gok1 = INT(RND * 10)
gok2 = INT(RND * 20)
gok3 = INT(RND * 10)
gok = gok1 + gok2 + gok3
IF unitt(i) <= 1 AND unitc(i) = unitmc(i) AND unitfi(i) = 0 AND unitfi2(i) = 0 AND gok = 0 THEN GOTO diezelfde
IF unitt(i) >= 4 AND unitc(i) = unitmc(i) AND unitfi(i) = 0 AND unitfi2(i) = 0 AND gok = 0 THEN
diezelfde:
number = 0
FOR su = 1 TO 100
IF unitd(su) <> 0 AND unitt2(su) = 0 THEN number = su
NEXT su

IF number <> 0 THEN unitmc(i) = unitc(number): unita(i) = 4: unitfi(i) = number

IF number = 0 THEN
FOR su = 1 TO 100
IF structd(su) <> 0 AND structt2(su) = 0 THEN number = su
NEXT su
IF number <> 0 THEN unita(i) = 4: unitmc(i) = structc(number): unitfi2(i) = number
END IF

END IF




'DEAD END IF
END IF
NEXT i

'BUILD CODE
'Ofcourse build units when you can...

IF wachten = 0 AND soortai <> -1 THEN
IF aihavewar > 0 AND soortai <> 5 THEN addunit 1, soortai, 0, 0, 0
IF aihavetent > 0 AND soortai = 5 THEN addunit 1, soortai, 0, 0, 0
soortai = -1
END IF

IF wachten = 0 AND soortai = -1 THEN
gok = INT(RND * 5)
IF aihavewar > 0 THEN
IF gok = 0 THEN soortai = INT(RND * 2)  'Build a random unit (LIGHT/HEAVY TANK)
IF gok = 1 THEN soortai = 4     'Build a trike
IF gok = 2 THEN soortai = 0     'Will build a heavy tank
IF gok = 3 THEN soortai = 3     'Will build a grenade launcher
IF gok = 4 THEN soortai = 0     'Will build a heavy tank
END IF
IF aihavetent > 0 THEN
IF gok = 2 THEN soortai = 5: wachten = 3    'Build a soldier
END IF
'Waiting time for LIGHT TANK
IF soortai = 0 AND techlevel > 1 THEN wachten = 6
IF soortai = 0 AND techlevel <= 1 THEN soortai = -1
'Waiting time for HEAVY TANK
IF soortai = 1 AND techlevel > 3 THEN wachten = 7
IF soortai = 1 AND techlevel <= 3 THEN soortai = -1
'Waiting time for TRIKE
IF soortai = 4 AND techlevel > 0 THEN wachten = 4
IF soortai = 4 AND techlevel <= 0 THEN soortai = -1
'Waiting time for SOLDIER
IF soortai = 5 THEN wachten = 3
'Waiting time for GRENADE TANK
IF soortai = 3 AND techlevel > 4 THEN wachten = 10
IF soortai = 3 AND techlevel <= 4 THEN soortai = -1
END IF

END SUB
 

REM $STATIC
SUB center (y, tekst$, kleur)
tekst$ = UCASE$(tekst$)
l = LEN(tekst$)
l = l * 8 'Real size in pixels
xplaats = 320 / 2 - (l / 2)
y = y * 8
DQBprint 1, tekst$, xplaats, y, kleur
END SUB

SUB controleerfout
IF fouttekenen <> 0 THEN
PRINT
PRINT "A fatal error occured."
PRINT "To prevent crashing your system Arrakis has quit."
PRINT
PRINT "Please report any actions that where taken before this happened"
PRINT "You can send crash reports, but also questions/feedback to:"
PRINT
PRINT "stefan@flash.a2000.nl"
PRINT
PRINT "(You have to press a key to quit, this is to prevent auto-close in Windows)"
PRINT
PRINT "Error code:"; ERR
WHILE INKEY$ = "": WEND
END IF

END SUB

REM $DYNAMIC
'NO MORE
SUB drawdies
FOR i = 1 TO 100
IF deadd(i) <> 0 THEN

l = deadc(i)
y = INT(l / 64): x = l - (y * 64)
t = (deadt(i) * 18) + deadf(i)


IF deadt(i) = 0 AND mapunit(deadc(i)) <> 0 THEN GOTO niettekenen

'Put unit on map...
'but first calculate the x and y...
l = 0
l = INT(t / 18): t = t - (l * 18)
'Draw unit from layer to the game
IF mapsight(deadc(i)) <> 0 THEN DQBxPut 30, (t * 16) + t, (l * 16) + l, (t * 16) + t + 15, 15 + (l * 16) + l, 1, (x - mx) * 16 + deadx(i), (y - my) * 16 + deady(i)
niettekenen:

IF deadt(i) = 0 THEN
deadc2(i) = deadc2(i) + 1 + skipframe
IF deadc2(i) >= 10 THEN deadf(i) = deadf(i) + 1: deadc2(i) = 0
IF deadf(i) > 5 THEN deadd(i) = 0
END IF

IF deadt(i) = 1 THEN
deadc2(i) = deadc2(i) + 1
IF deadc2(i) >= 3 THEN deadf(i) = deadf(i) + 1: deadc2(i) = 0
IF deadf(i) > 5 THEN deadd(i) = 0
END IF

IF deadt(i) = 2 THEN
deadc2(i) = deadc2(i) + 1
IF deadc2(i) >= 3 THEN deadf(i) = deadf(i) + 1: deadc2(i) = 0
IF deadf(i) > 6 THEN deadd(i) = 0
END IF

IF deadt(i) = 3 THEN
deadc2(i) = deadc2(i) + 1
IF deadc2(i) >= 2 THEN deadf(i) = deadf(i) + 1: deadc2(i) = 0
IF deadf(i) > 5 THEN deadd(i) = 0
END IF

IF deadt(i) = 4 THEN
deadc2(i) = deadc2(i) + 1
IF deadc2(i) >= 3 THEN deadf(i) = deadf(i) + 1: deadc2(i) = 0
IF deadf(i) > 5 THEN deadd(i) = 0
END IF

IF deadt(i) = 5 THEN
deadc2(i) = deadc2(i) + 1
IF deadc2(i) >= 5 THEN deadf(i) = deadf(i) + 1: deadc2(i) = 0
IF deadf(i) > 5 THEN deadd(i) = 0
END IF

END IF
NEXT i

END SUB

REM $STATIC
SUB drawwindow (breedte)
beginnen = INT(160 - (breedte / 2))
DQBboxf 1, beginnen, 14, beginnen + breedte, 185, 159
FOR dil = -2 TO 172 STEP 2
DQBline 1, beginnen, 14 + dil + 2, beginnen + breedte, 14 + dil + 2, 160
NEXT dil
DQBbox 1, beginnen - 1, 13, beginnen + breedte + 1, 185 + 2, 158
DQBbox 1, beginnen - 2, 12, beginnen + breedte + 2, 185 + 3, 157
DQBbox 1, beginnen - 3, 11, beginnen + breedte + 3, 185 + 3, 158
DQBcopyLayer 1, 0
END SUB

SUB loadgame (file$)
'Load game...
OPEN "SAVE\" + file$ + ".sav" FOR INPUT AS #1
INPUT #1, lvl                   'Save level number
INPUT #1, friendfound, enemyfound
INPUT #1, haverepair, havewind, haveradar
INPUT #1, haverefinery, havewar, havetent
INPUT #1, haveconst, aihaverepair, aihavetent
INPUT #1, aihavewar, aihaveconst, minx, aihaveradar
INPUT #1, miny, maxx
INPUT #1, maxy, magchecken
INPUT #1, bouwdie1, bouwdie2
INPUT #1, prijs1, prijs2
INPUT #1, credits, musthavecredits
INPUT #1, die1, die2
INPUT #1, mx, my
INPUT #1, power, spice, harvested
INPUT #1, pro1, pro2
INPUT #1, tijd, nu, seconds, minutes, hours
INPUT #1, mousec, readbriefing, settimer, losts, kills, techlevel, foundothergoal
'That where the common variablen.
'Now print the MAP information, AND sight information
FOR i = 0 TO 4095
INPUT #1, maptile(i), mapsight(i)
IF maptile(i) > 41 THEN mapstruct(i) = -1
IF maptile(i) >= 5 THEN c = 123 ELSE c = 118
IF maptile(i) >= 25 AND maptile(i) < 28 THEN c = 238
IF maptile(i) > 41 THEN c = 159
yd = INT(i / 64): xd = i - (yd * 64)
IF mapsight(i) <> 0 THEN DQBpset 20, 249 + xd, 21 + yd, 0
DQBpset 2, 249 + xd, 21 + yd, c
NEXT i
'Now print all the UNIT information
FOR i = 1 TO 100
INPUT #1, unitfi2(i), unitfi(i), units3(i), unitsp(i), unitd(i), unita(i), unitc(i), unitwc(i), unitmc(i), unitx(i), unity(i), unitcap(i), unitp(i), units2(i), unitf(i), unitt(i), unitt2(i), units(i), units(i), unitc6(i), unitc5(i), unitc4(i),  _
unitc3(i), unitc2(i), unitfac(i), unitf3(i), unitc7(i), unitg(i)
NEXT i
'Phew, wow, now the structures
FOR i = 2 TO 100
INPUT #1, structc2(i), structc(i), structt(i), structt2(i), structp(i), structs(i), structd(i), structa(i)
 
NEXT i
'Bullets and rockets...
FOR i = 1 TO 100
INPUT #1, bulld(i), bullc(i), bullc2(i), bullc3(i), bullx(i), bully(i), bullx2(i), bully2(i), bullt(i), bulld2(i), bullf(i)
NEXT i
'Dead things
FOR i = 1 TO 100
INPUT #1, deadd(i), deadc(i), deadt(i), deadc2(i), deadx(i), deady(i), deadf(i)
NEXT i
FOR i = 1 TO 50
INPUT #1, aitime2(i), aitime(i), aitype(i), aicell(i), aidead(i)
NEXT i
CLOSE #1
END SUB

REM $DYNAMIC
SUB loadgraphics
IF DQBloadLayer(3, "DATA\GRAPHICS\COMMON\TERRAIN1.PCX", pal) <> 0 THEN DQBclose: END
 
'Layer 4: UNIT, Atreides Light Tank
IF DQBloadLayer(4, "DATA\GRAPHICS\ATR\LTANK.PCX", pal) <> 0 THEN DQBclose: END
 
'Layer 5: UNIT, Atreides Heavy Tank
IF DQBloadLayer(5, "DATA\GRAPHICS\ATR\HTANK.PCX", pal) <> 0 THEN DQBclose: END

'Layer 6: UNIT, Atreides Harvester
IF DQBloadLayer(6, "DATA\GRAPHICS\ATR\HARV.PCX", pal) <> 0 THEN DQBclose: END

'Layer 7: UNIT, Atreides Mine Layer
IF DQBloadLayer(7, "DATA\GRAPHICS\ATR\MINER.PCX", pal) <> 0 THEN DQBclose: END

'Layer 8: UNIT, Atreides Explorer unit, TRIKE
IF DQBloadLayer(8, "DATA\GRAPHICS\ATR\EXPL.PCX", pal) <> 0 THEN DQBclose: END

'Layer 9: UNIT, Atreides Infantry unit
IF DQBloadLayer(9, "DATA\GRAPHICS\ATR\INF.PCX", pal) <> 0 THEN DQBclose: END

'Layer 16: STRUCTURES
IF DQBloadLayer(16, "DATA\GRAPHICS\COMMON\BUILDING.PCX", pal) <> 0 THEN DQBclose: END

'Layer 17: ICONS
IF DQBloadLayer(17, "DATA\GRAPHICS\COMMON\ICONS.PCX", pal) <> 0 THEN DQBclose: END

'Layer 21: RADAR ANIMATION, ALSO WHEN YOU HAVE NO RADAR!
IF DQBloadLayer(21, "DATA\GRAPHICS\RADAR\RADAR1.PCX", pal) <> 0 THEN DQBclose: END

'Layer 22: RADAR ANIMATION
IF DQBloadLayer(22, "DATA\GRAPHICS\RADAR\RADAR2.PCX", pal) <> 0 THEN DQBclose: END
'Layer 23: RADAR ANIMATION
IF DQBloadLayer(23, "DATA\GRAPHICS\RADAR\RADAR3.PCX", pal) <> 0 THEN DQBclose: END
'Layer 24: RADAR ANIMATION
IF DQBloadLayer(24, "DATA\GRAPHICS\RADAR\RADAR4.PCX", pal) <> 0 THEN DQBclose: END
'Layer 25: RADAR ANIMATION
IF DQBloadLayer(25, "DATA\GRAPHICS\RADAR\RADAR5.PCX", pal) <> 0 THEN DQBclose: END
'Layer 26: RADAR ANIMATION
IF DQBloadLayer(26, "DATA\GRAPHICS\RADAR\RADAR6.PCX", pal) <> 0 THEN DQBclose: END
'Layer 27: RADAR ANIMATION
IF DQBloadLayer(27, "DATA\GRAPHICS\RADAR\RADAR7.PCX", pal) <> 0 THEN DQBclose: END
'Layer 28: RADAR ANIMATION
IF DQBloadLayer(28, "DATA\GRAPHICS\RADAR\RADAR8.PCX", pal) <> 0 THEN DQBclose: END
'Layer 29: RADAR ANIMATION
IF DQBloadLayer(29, "DATA\GRAPHICS\RADAR\RADAR9.PCX", pal) <> 0 THEN DQBclose: END

'Layer 30: DEAD ANIMATIONS
IF DQBloadLayer(30, "DATA\GRAPHICS\COMMON\DIES.PCX", pal) <> 0 THEN DQBclose: END

'Layer 31: BULLETS, ROCKETS
IF DQBloadLayer(31, "DATA\GRAPHICS\COMMON\BULLETS.PCX", pal) <> 0 THEN DQBclose: END

'Layer 32: UNIT, Harkonnen Light Tank
IF DQBloadLayer(32, "DATA\GRAPHICS\HARK\HLTANK.PCX", pal) <> 0 THEN DQBclose: END

'Layer 33: UNIT, Harkonnen Heavy Tank
IF DQBloadLayer(33, "DATA\GRAPHICS\HARK\HHTANK.PCX", pal) <> 0 THEN DQBclose: END

'Layer 34: UNIT, Harkonnen Harvester
IF DQBloadLayer(34, "DATA\GRAPHICS\HARK\HHARV.PCX", pal) <> 0 THEN DQBclose: END

'Layer 35: UNIT, Harkonnen Mine Layer
IF DQBloadLayer(35, "DATA\GRAPHICS\HARK\HMINER.PCX", pal) <> 0 THEN DQBclose: END

'Layer 36: UNIT, Harkonnen Explorer unit, TRIKE
IF DQBloadLayer(36, "DATA\GRAPHICS\HARK\HEXPL.PCX", pal) <> 0 THEN DQBclose: END

'Layer 37: UNIT, Harkonnen Infantry unit
IF DQBloadLayer(37, "DATA\GRAPHICS\HARK\HINF.PCX", pal) <> 0 THEN DQBclose: END

'Layer 43: SMOKE
IF DQBloadLayer(43, "DATA\GRAPHICS\COMMON\SMOKE.PCX", pal) <> 0 THEN DQBclose: END

END SUB

REM $STATIC
SUB loadsounds
'COMMON STUFF FIRST
'1=ATREIDES
test% = DQBloadSound%(1, "DATA\SOUND\COMMON\ATREIDES.WAV")
'2=HARKONNEN
test% = DQBloadSound%(2, "DATA\SOUND\COMMON\HARK.WAV")
'3=UNIT
test% = DQBloadSound%(3, "DATA\SOUND\COMMON\UNIT.WAV")
'4=DESTROYED
test% = DQBloadSound%(4, "DATA\SOUND\COMMON\DESTROYD.WAV")
'5=CONSTRUCTION COMPLETE
test% = DQBloadSound%(5, "DATA\SOUND\COMMON\COMPLETE.WAV")
'6=ACTIVATED
test% = DQBloadSound%(6, "DATA\SOUND\COMMON\ON.WAV")
'7=DEACTIVATED
test% = DQBloadSound%(7, "DATA\SOUND\COMMON\OFF.WAV")
'8=RADAR
test% = DQBloadSound%(8, "DATA\SOUND\COMMON\RADAR.WAV")
'9=STRUCTURE
test% = DQBloadSound%(9, "DATA\SOUND\COMMON\STRUCTR.WAV")
'10=PLACE(BOOM WHEN PLACING)
test% = DQBloadSound%(10, "DATA\SOUND\COMMON\PLACE.WAV")
'11=STATICAL SOUND WHEN RADAR ACTIVATES
test% = DQBloadSound%(11, "DATA\SOUND\COMMON\STATIC.WAV")
'12=CREDIT IN
test% = DQBloadSound%(12, "DATA\SOUND\COMMON\IN.WAV")
'13=CREDIT OUT
test% = DQBloadSound%(13, "DATA\SOUND\COMMON\OUT.WAV")

'UNITS!

'SHOOTING.
'14=SOLDIER SHOOTS
test% = DQBloadSound%(14, "DATA\SOUND\INF\GUN.WAV")
'15=TRIKE SHOOTS
test% = DQBloadSound%(15, "DATA\SOUND\TRIKE\GUN.WAV")
'16=TANK SHOOTS
test% = DQBloadSound%(16, "DATA\SOUND\TANK\GUN.WAV")

'EXPLOSIONS
'17=EXPLOSION 1, FOR BUILDINGS
test% = DQBloadSound%(17, "DATA\SOUND\EXPL\EXPL1.WAV")
'18=EXPLOSION 2, FOR UNITS
test% = DQBloadSound%(18, "DATA\SOUND\EXPL\EXPL2.WAV")
'19=EXPLOSION 3, FOR UNITS
test% = DQBloadSound%(19, "DATA\SOUND\EXPL\EXPL3.WAV")

'REPORTINGS
'20=REPORT1.WAV-> YES SIR?
test% = DQBloadSound%(20, "DATA\SOUND\REPORTS\REPORT1.WAV")
'21=REPORT2.WAV-> REPORTING...
test% = DQBloadSound%(21, "DATA\SOUND\REPORTS\REPORT2.WAV")

'22=MOVING OUT!
test% = DQBloadSound%(22, "DATA\SOUND\REPORTS\MOVEOUT.WAV")
'23=AFFIRMATIVE
test% = DQBloadSound%(23, "DATA\SOUND\REPORTS\AFFIRM.WAV")
'24=ACKNOWLEDGE!
test% = DQBloadSound%(24, "DATA\SOUND\REPORTS\KNOWLEDG.WAV")

'25=INFANTRY DIE 1
test% = DQBloadSound%(25, "DATA\SOUND\INF\DIE1.WAV")
'26=INFANTRY DIE 2
test% = DQBloadSound%(26, "DATA\SOUND\INF\DIE2.WAV")
'27=INFANTRY DIE 3
test% = DQBloadSound%(27, "DATA\SOUND\INF\DIE3.WAV")
'28=INFANTRY DIE 4
test% = DQBloadSound%(28, "DATA\SOUND\INF\DIE4.WAV")
'29=INFANTRY DIE 5
test% = DQBloadSound%(29, "DATA\SOUND\INF\DIE5.WAV")

'30=INFANTRY DIE when get squised!
test% = DQBloadSound%(30, "DATA\SOUND\INF\SQUISE.WAV")

END SUB

SUB options
DIM savenaam$(25), savepath$(25)
FOR la = 0 TO 9
savenaam$(la) = ""
savepath$(la) = ""
NEXT la
effeopnieuw:
'drawwindow
FOR l = 1 TO 160 STEP 2
drawwindow 5 + l
NEXT l
DQBcopyLayer 1, 44

DO
DQBcopyLayer 44, 1
IF nosound = 0 THEN flag$ = "ON" ELSE flag$ = "OFF"
center 2, "OPTIONS", white
center 5, "Save Game", white
center 7, "Load Game", white
center 9, "Restart Game", white
center 11, "Read Briefing", white
center 13, "Resume Game", white
center 15, "Sound:" + flag$, white
center 17, "Exit Game", white
center 21, "Version 1.12", 144
dieinfo = 0
FOR la = 5 TO 17 STEP 2
IF DQBmouseX >= 100 AND DQBmouseX <= 220 AND DQBmouseY >= (la * 8) AND DQBmouseY <= (la * 8) + 8 THEN
dieinfo = la
DQBbox 1, 100, (la * 8), 220, (la * 8) + 9, white
END IF

NEXT la
 

IF DQBmouseLB = -1 THEN
IF dieinfo = 5 OR dieinfo = 7 THEN
FOR l = 1 TO 160 STEP 2
drawwindow 5 + l
NEXT l
DQBcopyLayer 1, 44
OPEN "SAVE\SAVES.DAT" FOR INPUT AS #3
FOR nrs = 0 TO 9
INPUT #3, savenaam$(nrs), savepath$(nrs)
IF savenaam$(nrs) = "" THEN savenaam$(nrs) = "-----EMPTY SLOT-----"
NEXT nrs
CLOSE #3
na$ = ""
nummer = 0
DO
IF dontplay2 = 0 THEN playmusic
d$ = DQBinkey$
DQBcopyLayer 44, 1

IF dieinfo = 5 THEN
center 2, "SAVE YOUR GAME", white
center 19, "SAVE GAME AS:", white
END IF
IF dieinfo = 7 THEN center 2, "LOAD YOUR GAME", white
 
FOR sas = 0 TO 9
c = white
IF sas = nummer THEN c = 33
IF DQBmouseX >= 80 AND DQBmouseX <= 240 AND DQBmouseY > ((sas + 4) * 8) AND DQBmouseY <= ((sas + 4) * 8) + 8 THEN
IF DQBmouseLB = -1 THEN
IF dieinfo = 5 THEN
nummer = sas: na$ = savenaam$(sas)
IF na$ = "-----EMPTY SLOT-----" THEN na$ = ""
END IF

IF dieinfo = 7 THEN
'Load that game
nummer = sas
file$ = savepath$(nummer)
IF file$ = "" THEN GOTO nietdoen
IF savenaam$(number) = "" THEN GOTO nietdoen
resetall
loadgame file$
EXIT SUB
nietdoen:
END IF

END IF

DQBbox 1, 81, ((sas + 4) * 8), 239, ((sas + 4) * 8) + 8, white
c = 170
END IF
center 4 + sas, savenaam$(sas), c
NEXT sas

 
DQBbox 1, 80, 167, 240, 178, white
DQBbox 1, 80, 31, 240, 150, 156
DQBxPut 3, 308, 190, 319, 199, 1, DQBmouseX, DQBmouseY       'Draw MOUSE
IF d$ <> "" THEN
IF d$ = CHR$(8) AND LEN(na$) > 0 THEN na$ = LEFT$(na$, LEN(na$) - 1)
IF d$ = CHR$(27) THEN EXIT DO

IF d$ = CHR$(13) AND dieinfo = 5 THEN
file$ = "SAVE" + LTRIM$(RTRIM$(STR$(nummer)))
savegame file$
savenaam$(nummer) = na$
savepath$(nummer) = file$

OPEN "SAVE\SAVES.DAT" FOR OUTPUT AS #3
FOR ks = 0 TO 9
IF savenaam$(ks) = "-----EMPTY SLOT-----" THEN savenaam$(ks) = ""
PRINT #3, savenaam$(ks) + "," + savepath$(ks)
NEXT ks
CLOSE #3

EXIT DO
END IF

IF d$ <> CHR$(13) AND d$ <> CHR$(8) AND d$ <> CHR$(27) AND LEN(na$) < 20 THEN na$ = na$ + d$
na$ = UCASE$(na$)
END IF

IF dieinfo = 5 THEN center 21, na$, white
DQBcopyLayer 1, 0
LOOP
 
GOTO effeopnieuw
END IF

IF dieinfo = 9 THEN resetten = 1: EXIT DO
IF dieinfo = 11 THEN readbriefingit
IF dieinfo = 13 THEN EXIT DO
IF dieinfo = 15 THEN
IF nosound = 1 AND able2play = 0 THEN
nosound = 0
DQBplaySound 6, 1, 22050, 0
GOTO donethat
END IF
IF nosound = 0 THEN
IF able2play = 0 THEN DQBplaySound 7, 1, 22050, 0
nosound = 1
END IF

donethat:
DQBwait 10
END IF
IF dieinfo = 17 THEN mustquit = 1: EXIT DO
END IF
 

DQBxPut 3, 308, 190, 319, 199, 1, DQBmouseX, DQBmouseY       'Draw MOUSE
DQBcopyLayer 1, 0
IF dontplay2 = 0 AND nosound = 0 THEN playmusic
LOOP

END SUB

SUB quitanimation
d2 = 0
FOR d = 0 TO 159 STEP 2
DQBline 1, d, 0, d, 199, 0
DQBline 1, 319 - d, 0, 319 - d, 199, 0
DQBline 1, 0, d2, 319, d2, 0
DQBline 1, 0, 199 - d2, 319, 199 - d2, 0
DQBwait 1
IF d2 < 97 THEN d2 = d2 + 2
DQBcopyLayer 1, 0
NEXT d
DQBfadeTo 0, 0, 0
SLEEP 1
END SUB

DEFSNG A-Z
SUB readbriefingit
DEFINT A-Z
keer = 0
bestand$ = "DATA\MAPS\" + level$(lvl) + ".BRF"
FOR l = 1 TO 290 STEP 2
drawwindow 5 + l
NEXT l
wy = (wy * 8) + wy
maxl = (maxl * 8)
IF wy > 178 THEN wy = 178
 
OPEN bestand$ FOR INPUT AS #1
DO WHILE NOT EOF(1)
LINE INPUT #1, regel$
regel$ = UCASE$(regel$)
IF regel$ <> "#NEXT#" AND regel$ <> "#IMAGE#" THEN DQBprint 1, regel$, 16, 16 + (keer * 8) + keer, white
keer = keer + 1
IF regel$ = "#IMAGE#" THEN
INPUT #1, x1, y1, x2, y2, l
DQBxPut l, x1, y1, x2, y2, 1, 16, 16 + (keer * 8) + keer
vy = y2 - y1
keer = keer + INT(vy / 8) + 1
END IF

IF (keer * 8) + keer > 178 OR regel$ = "#NEXT#" THEN
DQBprint 1, "PRESS A KEY FOR NEXT PAGE...", 16, 179, white
DQBcopyLayer 1, 0
DO
k$ = DQBinkey$
IF k$ <> CHR$(27) AND k$ <> "" THEN EXIT DO
IF k$ = CHR$(27) THEN GOTO stopbriefing
LOOP
FOR l = 1 TO 290 STEP 2
drawwindow 5 + l
NEXT l
keer = 0
END IF

DQBwait 1
DQBcopyLayer 1, 0
LOOP
CLOSE #1
DQBprint 1, "PRESS A KEY...", 16, 187, white
DQBcopyLayer 1, 0
'WHILE INKEY$ = "": WEND
DO
ke$ = DQBinkey$
IF ke$ <> "" THEN EXIT DO
IF dontplay2 = 0 THEN playmusic
LOOP
stopbriefing:
readbriefing = 1
CLOSE
END SUB

SUB savegame (file$)
'Save game...
OPEN "SAVE\" + file$ + ".sav" FOR OUTPUT AS #1
PRINT #1, lvl                   'Save level number
PRINT #1, friendfound, enemyfound
PRINT #1, haverepair, havewind, haveradar
PRINT #1, haverefinery, havewar, havetent
PRINT #1, haveconst, aihaverepair, aihavetent
PRINT #1, aihavewar, aihaveconst, minx, aihaveradar
PRINT #1, miny, maxx
PRINT #1, maxy, magchecken
PRINT #1, bouwdie1, bouwdie2
PRINT #1, prijs1, prijs2
PRINT #1, credits, musthavecredits
PRINT #1, die1, die2
PRINT #1, mx, my
PRINT #1, power, spice, harvested
PRINT #1, pro1, pro2
PRINT #1, tijd, nu, seconds, minutes, hours
PRINT #1, mousec, readbriefing, settimer, losts, kills, techlevel, foundothergoal
'That where the common variablen.
'Now print the MAP information, AND sight information
FOR i = 0 TO 4095
PRINT #1, maptile(i), mapsight(i)
NEXT i
'Now print all the UNIT information
FOR i = 1 TO 100
PRINT #1, unitfi2(i), unitfi(i), units3(i), unitsp(i), unitd(i), unita(i), unitc(i), unitwc(i), unitmc(i), unitx(i), unity(i), unitcap(i), unitp(i), units2(i), unitf(i), unitt(i), unitt2(i), units(i), units(i), unitc6(i), unitc5(i), unitc4(i),  _
unitc3(i), unitc2(i), unitfac(i), unitf3(i), unitc7(i), unitg(i)
NEXT i
'Phew, wow, now the structures
FOR i = 2 TO 100
PRINT #1, structc2(i), structc(i), structt(i), structt2(i), structp(i), structs(i), structd(i), structa(i)
NEXT i
'Bullets and rockets...
FOR i = 1 TO 100
PRINT #1, bulld(i), bullc(i), bullc2(i), bullc3(i), bullx(i), bully(i), bullx2(i), bully2(i), bullt(i), bulld2(i), bullf(i)
NEXT i
'Dead things
FOR i = 1 TO 100
PRINT #1, deadd(i), deadc(i), deadt(i), deadc2(i), deadx(i), deady(i), deadf(i)
NEXT i
FOR i = 1 TO 50
PRINT #1, aitime2(i), aitime(i), aitype(i), aicell(i), aidead(i)
NEXT i
CLOSE #1
END SUB

