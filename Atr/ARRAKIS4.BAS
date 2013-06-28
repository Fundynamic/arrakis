'ARRAKIS EXE / DAT FILE
'Copyrighted by Stefan Hendriks
'ATREIDES

DECLARE SUB clearspot (cell%, h%, b%)
DECLARE SUB checkarea (cell%, nr%, tpe%)
DECLARE SUB resetall ()
DECLARE SUB quitanimation ()
DECLARE SUB drawwindow (breedte%)
DECLARE SUB loadgraphics ()
DECLARE SUB addai (tijd%, tpe%, cell%, soort%)
DECLARE SUB center (y%, tekst$, kleur%)
DECLARE SUB dropnuke (cell%)
DECLARE SUB options ()
DECLARE SUB loadsounds ()
DECLARE SUB resetall ()
DECLARE SUB playmusic ()
DECLARE SUB playmessage ()
DECLARE SUB AIthink ()
DECLARE SUB addunit (team%, tpe%, cll%, movecell%, actie%)
DECLARE SUB changetime ()
DECLARE SUB addbullet (begin%, einde%, damage%, tpe%, testmode%)
DECLARE SUB drawbullets ()
DECLARE SUB adddead (tpe%, frame%, cell%, x%, y%)
DECLARE SUB drawdies ()
DECLARE SUB drawpower ()
DECLARE SUB addbuilding (team%, typ%, cell%)
DECLARE SUB checkplacecells (hoog%, breed%, placeresults%)
DECLARE SUB Sidebarcode ()
DECLARE SUB drawustructures ()
DECLARE SUB checkspice (cell%, i%)
DECLARE SUB checkunitturn (a%, b%, c%, d%, to2%)
DECLARE SUB turnunit (to2%, i%)
DECLARE SUB moveunit (i%)
DECLARE SUB drawunits ()
DECLARE SUB loadmap (map$)
DECLARE SUB drawterrain ()
'*************************
'ARRAKIS, REWRITE VERSION!
'*************************
'Graphics: Stefan
'Code    : Stefan
'Library : Enhanced Creations, DIRECTQB 1.5 + 1.6 SPRITE.OBJ
'Fully commented!
'DECLARS.BAS contains all variable that are shared in the whole program!
'DIRECTQB Included:
'$INCLUDE: 'declars.bas'

'For speed...
'For enemyhousename$ and myhousename$
OPEN "DATA\ARRAKIS.INI" FOR INPUT AS #1
INPUT #1, bl$                   'Enemyhousename$
INPUT #1, bl2$                  'MyHousename$
INPUT #1, enemycolor            'Enemycolor in game (map)
INPUT #1, mycolor               'Mycolor in game (map)
INPUT #1, skipframe             'Speed in SKIPFRAME
CLOSE #1
enemyhousename$ = UCASE$(bl$)
myhousename$ = UCASE$(bl2$)

la$ = COMMAND$
IF UCASE$(la$) = "/S" THEN dontplay2 = 1: nosound = 1

RANDOMIZE TIMER           'Always handy
t = DQBinit(44, 31)       'Test if computer is capable
IF t <> 0 THEN DQBclose: END    'If not, quit game

DQBinstallKeyboard
c% = DQBloadFont("DATA\FONT\ARRAKIS.FNT")
 
loadsounds
IF nosound = 0 THEN
dummy& = SETMEM(-17000)
IF DQBinstallSB(16, 22050, AUTO, AUTO, AUTO) THEN
    ' Bad initialization
    'UPDATE: DO NOT CLOSE ARRAKIS,
        dummy& = SETMEM(17000)  'Free mem
        'OK NOW SET FLAG WE DONT PLAY ANY SOUNDS
        able2play = 1   '1 means NO
        nosound = 1     'PLAY NO SOUNDS
        dontplay2 = 1   'PLAY NO MUSIC
END IF
END IF



'CHANNELS:
'1=Messages, like Unit destroyed, struction complete
'2=radar sound
'3=Explosions
'4=Reporting
'5=Moving out
'6=Squise
'7=Argh! etc
'8=shooting

'MUSIC
c% = DQBloadRawSound%(31, "DATA\MUSIC\BUILDING.WAV", 45, 64000)
IF c% = 1 THEN dontplay2 = 1    'Could not find file, dont play music!
  
DQBinitVGA                      'Go VGA modus!
DQBresetMouse

'********************************************************
'LOADING:                                  GRAPHICS
'********************************************************
'Layer 2: Graphical User Interface
IF DQBloadLayer(2, "DATA\GRAPHICS\COMMON\GUI.PCX", pal) <> 0 THEN DQBclose: END
DQBsetPal pal           'Use current Palette
white = DQBfindCol(63, 63, 63)          'Search for WHITE color
FOR l = 5 TO 300
drawwindow l
NEXT l
center 2, "LOADING GRAPHICS AND SOUNDS...", white
center 3, "THIS MAY TAKE SOME MINUTES", white
center 4, "ON SLOWER MACHINES.", white
center 6, "- VERSION 1.12 -", white

 
DQBcopyLayer 1, 0

loadgraphics

DQBget 3, 57, 97, 64, 104, VARSEG(textu(0)), VARPTR(textu(0))
DQBsetFontTexture VARSEG(textu(0)), VARPTR(textu(0))
DQBsetTextStyle TEXTURED

'Layer 3: Terrain, file nr 1
'Layer 15: FOR UNIT MAP, IS IMPORTANT!
'Layer 20: FOR Sight MAP, IS IMPORTANT TOO!
'********************************************************
'END LOADING:                              GRAPHICS
'********************************************************
center 16, "READY, PRESS A KEY.", white
DQBcopyLayer 1, 0
DQBwaitKey KEYANY
DQBfadeTo 0, 0, 0
DQBsetPal pal
DQBclearLayer 0
attacktime = 110 + INT(RND * 60)        'First time the AI will attack
'********************************************************
'DEFINED ARRAYS AND SHARED VARIABLES, CONSTANTS
'********************************************************
power = 5             'In percent
spice = 1500             'amount of spice that can be stored
'Spice capacity is 1500 always at start.
'when you build silos then the capacity increases with 1000
'if you have more credits than you can store then you lose credits
'the spice bar gives in percent the amount of credits against the
'amount you can store, so when you reach 100% you can't store any more credits

OPEN "ARRAKIS.LVL" FOR INPUT AS #1
DO WHILE NOT EOF(1)
INPUT #1, level$(kl)
kl = kl + 1
LOOP
CLOSE #1
lvl = 0

'********************************************************
'END DEFINED ARRAYS AND SHARED VARIABLES, CONSTANTS
'********************************************************
loadmore:
resetall
bestand$ = level$(lvl)
IF bestand$ = "" THEN
DQBclearLayer 1
center 1, "! CONGRATULATIONS !", 2
center 3, "YOU HAVE COMPLETED ALL SCENARIOS", 2
center 4, "OR YOU HAVE FINISHED A SKIRMISH", 2
center 5, "MISSION. ", 2
center 9, "PRESS A KEY TO GO BACK TO MENU", 2
DQBcopyLayer 1, 0
DQBwaitKey KEYANY

DQBinitText
DQBclose
END
END IF

loadmap bestand$                          'LOAD MAP

'********************************************************
'GAME STARTS HERE
'********************************************************
IF dontplay2 = 0 AND nosound = 0 THEN DQBplaySound 31, 11, 22050, ONCE
DO
IF dontplay2 = 0 AND nosound = 0 THEN playmusic
IF messagetijd = 0 THEN message$ = ""
DQBclearLayer 1         'Clear Layer 1
DQBclearLayer 15        'Important layer

'Very important to change the mx and my if they are out of range.
'now there will be never a mistake


IF DQBkey(KEYUP) = TRUE THEN my = my - 1
IF DQBkey(KEYDOWN) = TRUE THEN my = my + 1
IF DQBkey(KEYLEFT) = TRUE THEN mx = mx - 1
IF DQBkey(KEYRIGHT) = TRUE THEN mx = mx + 1

IF mx > 48 THEN mx = 48
IF mx < 0 THEN mx = 0
IF my > 50 THEN my = 50
IF my < 0 THEN my = 0

 

IF mousecell < 0 THEN mousecell = 0
friendfound = 0: enemyfound = 0
drawterrain             'Draw terrain
drawustructures         'Draw structures
drawunits               'Draw units
drawdies                'Draw dead objects
drawbullets             'Draw bullets
changetime              'Change time
playmessage             'Play any messages if needed
AIthink                 'Ai thinks/Events happen/Triggers check...
DQBcopyTransLayer 2, 1  'Draw GUI transparant (Terrain)
DQBcopyTransLayer 20, 1  'Draw GUI transparant (Fog of War)
DQBcopyTransLayer 15, 1  'Copy layer 15, as transparant at the minimap
  
IF haveradar <= 0 THEN DQBcopyTransLayer 21, 1
IF haveradara = -10 THEN
DQBcopyTransLayer 21, 1
END IF

IF haveradara > 0 THEN
DQBcopyTransLayer 20 + haveradara, 1
haveradara = haveradara + 1
IF haveradara > 9 THEN haveradara = 0
END IF

 
IF power < 5 AND haveradara = 0 THEN haveradara = -1: IF haveradar = 0 THEN messagenr = 6: IF nosound = 0 THEN DQBplaySound 11, 12, 22050, 0
IF power > 5 AND haveradara = -10 THEN haveradara = 1: IF haveradar <> 0 THEN messagenr = 5: IF nosound = 0 THEN DQBplaySound 11, 12, 22050, 0

IF haveradara < 0 THEN
IF haveradara > -10 THEN
DQBcopyTransLayer 30 + haveradara, 1
haveradara = haveradara - 1
IF haveradara < -9 THEN haveradara = -10
END IF
END IF

'Draw the power here
drawpower
Sidebarcode             'Code for sidebar

'Draw the map box on the minimap, minimap starts from 249,21
'And the width = 15 and height = 13
'So:
DQBbox 1, 249 + mx, 21 + my, 249 + mx + 15 + 1, 21 + my + 13 + 1, 0
DQBbox 1, 249 + mx - 1, 21 + my - 1, 249 + mx + 15, 21 + my + 13, white

DQBprint 1, "$" + STR$(credits), 264, 7, white      'Print Credits
                                                        
 
'********************************************************
'MULTI SELECTION CODE
'********************************************************
'Multi Selection code, mouse will draw a box when mouse is hold and
'is moved:
IF DQBmouseLB = -1 AND tekenen = 0 THEN x1 = DQBmouseX: y1 = DQBmouseY
IF DQBmouseLB = -1 AND x1 <> -1 AND y1 <> -1 THEN x2 = DQBmouseX: y2 = DQBmouseY: tekenen = 1

IF tekenen = 1 THEN
'Maydraw now,
magscrollen = 1 'You may not scroll when you multi-select
IF x2 > 245 THEN x2 = 245        'Max for multiselect
IF x1 > 245 THEN x1 = 245
IF x2 > x1 AND y2 > y1 THEN DQBbox 1, x1, y1, x2, y2, white
IF x2 > x1 AND y2 < y1 THEN DQBbox 1, x1, y2, x2, y1, white
IF x2 < x1 AND y2 > y1 THEN DQBbox 1, x2, y1, x1, y2, white
IF x2 < x1 AND y2 < y1 THEN DQBbox 1, x2, y2, x1, y1, white
END IF

IF DQBmouseLB = 0 AND tekenen = 1 THEN tekenen = 0: magscrollen = 0: checkunits = 2  'reset all
'********************************************************
'END MULTI SELECTION CODE
'********************************************************

'********************************************************
'SCROLL CODE
'********************************************************
IF magscrollen = 0 THEN
IF DQBmouseX > 318 THEN mx = mx + 1 + (skipframe / 2)
IF DQBmouseX < 1 THEN mx = mx - 1 - (skipframe / 2)
IF DQBmouseY > 198 THEN my = my + 1 + (skipframe / 2)
IF DQBmouseY < 1 THEN my = my - 1 - (skipframe / 2)
END IF
'********************************************************
'END SCROLL CODE
'********************************************************
IF minx < 0 THEN minx = 0
IF miny < 0 THEN miny = 0
IF maxx > 63 THEN maxx = 63
IF maxy > 63 THEN maxy = 63


'checkplace cells!
IF checkplace <> 0 THEN checkplacecells hoogte, breedte, checkresults

'dqbprint 1, STR$(checkresults) + "," + STR$(checkplace), 100, 100, white


'********************************************************
'MOUSE CODE
'********************************************************
'Ok when you click...
IF DQBmouseLB = -1 THEN
'If the mouse is within the minimap, we scroll to the specific position...
'borders minimap: X1=245, Y1:21, X2=309 :Y2 = 85
IF DQBmouseX >= 245 AND DQBmouseX <= 309 AND DQBmouseY >= 21 AND DQBmouseY <= 85 THEN
'It is within the minimap.

IF mousec = 0 THEN
'We move with the screen to that spot
mx = DQBmouseX - 245 - 8
my = DQBmouseY - 21 - 6
END IF

IF mousec = 1 THEN
'Move selected units to that spot
FOR i = 1 TO 100
IF units(i) <> 0 AND unitt2(i) = 0 THEN
mx2 = DQBmouseX - 245 - 8
my2 = DQBmouseY - 21 - 6
unitmc(i) = (my2 * 64) + mx2
IF unitmc(i) < 0 THEN unitmc(i) = 0
IF unitmc(i) > 4095 THEN unitmc(i) = 4095
END IF
NEXT i
IF nosound = 0 THEN DQBplaySound 22 + INT(RND * 3), 7, 22050, 0
END IF

GOTO noplayfield
END IF
'It must be in the playfield, we check if there is a unit below the mouse
'so we can select it... Only ofcourse when not placing a structure
IF checkplace = 0 THEN checkunits = 1: checkstr = 1

'If in the playfield and attack cursor is active so it is on an enemy
'unit then attack it.

IF mousec = 2 THEN
'Attack cursor
'check the unit nr
IF mapunit(mousecell) <> 0 THEN
FOR i = 1 TO 100
IF units(i) <> 0 AND unitt2(i) = 0 THEN unita(i) = 3: unitmc(i) = mousecell: unitfi(i) = mapunit(mousecell)
NEXT i
END IF

IF mapstruct(mousecell) <> 0 THEN
FOR i = 1 TO 100
IF units(i) <> 0 AND unitt2(i) = 0 THEN unita(i) = 3: unitmc(i) = mousecell: unitfi2(i) = mapstruct(mousecell)
NEXT i
END IF
END IF
 
noplayfield:
END IF

IF checkplace <> 0 AND DQBmouseLB = -1 THEN
'Check if a structure  can be placed first
IF checkresults = 0 THEN
ready1 = 0: addbuilding 0, die1, mousecell
IF nosound = 0 THEN DQBplaySound 10, 1, 22050, 0
END IF

END IF

'This code deselectes all units
IF DQBmouseRB = -1 AND DQBmouseX < 245 THEN
FOR i = 1 TO 100
units(i) = 0
NEXT i
mousec = 0
END IF



'********************************************************
'END MOUSE CODE
'********************************************************

'SHOW TIPS
IF DQBmouseX < 245 AND showtip <> 0 THEN
IF mousecell < 0 THEN mousecell = 0
txt$ = ""
IF mousecell > 4095 THEN mousecell = 4095
IF mapsight(mousecell) = 0 THEN txt$ = "Unexplored Area."
IF mapsight(mousecell) <> 0 THEN
IF maptile(mousecell) >= 25 AND maptile(mousecell) < 28 THEN txt$ = "Spice"
IF maptile(mousecell) >= 0 AND maptile(mousecell) < 5 THEN txt$ = "Sand"
IF maptile(mousecell) >= 5 AND maptile(mousecell) < 25 THEN txt$ = "Rock"
IF mapunit(mousecell) <> 0 THEN
txt$ = ""
id = mapunit(mousecell)
IF unitt2(id) <> 0 THEN txt$ = enemyhousename$ + " " ELSE txt$ = myhousename$ + " "
IF unitt(id) = 0 THEN txt$ = txt$ + "LIGHT TANK"
IF unitt(id) = 1 THEN txt$ = txt$ + "HEAVY TANK"
IF unitt(id) = 2 THEN txt$ = txt$ + "HARVESTER"
IF unitt(id) = 3 THEN txt$ = txt$ + "GRENADE LAUNCHER"
IF unitt(id) = 4 THEN txt$ = txt$ + "TRIKE"
IF unitt(id) = 5 THEN txt$ = txt$ + "SOLDIER"
END IF
IF mapstruct(mousecell) <> 0 THEN
txt$ = ""
id = mapstruct(mousecell)
IF id > 0 THEN

IF structt2(id) > 0 THEN txt$ = enemyhousename$ + " " ELSE txt$ = myhousename$ + " "
IF structt(id) = 0 THEN txt$ = txt$ + "CONSTRUCTION YARD"
IF structt(id) = 1 THEN txt$ = txt$ + "WINDTRAP"
IF structt(id) = 2 THEN txt$ = txt$ + "REFINERY"
IF structt(id) = 3 THEN txt$ = txt$ + "BARRACKS"
IF structt(id) = 4 THEN txt$ = txt$ + "WAR FACTORY"
IF structt(id) = 5 THEN txt$ = txt$ + "RADAR"
IF structt(id) = 6 THEN txt$ = txt$ + "REPAIR PAD"
IF structt(id) = 7 THEN txt$ = txt$ + "SILO'S"

END IF
END IF
END IF


txt$ = UCASE$(txt$)
tada = LEN(txt$)
xb = tada * 8
erbij = 0
IF DQBmouseX - xb < 0 THEN erbij = ABS(DQBmouseX - xb)
xb = xb - erbij
IF txt$ <> "" THEN DQBprint 1, txt$, DQBmouseX - xb, DQBmouseY, white
END IF




'DRAW MESSAGES
 


 
'********************************************************
'Misc code
'********************************************************
'Mouse cursor
'Normal:
IF mousec = 0 THEN DQBxPut 3, 308, 190, 319, 199, 1, DQBmouseX, DQBmouseY       'Draw MOUSE
'Move:
IF mousec = 1 THEN DQBxPut 3, 292, 188, 307, 199, 1, DQBmouseX - 8, DQBmouseY - 6  'Draw MOUSE
'Attack:
IF mousec = 2 THEN DQBxPut 3, 274, 188, 288, 199, 1, DQBmouseX - 8, DQBmouseY - 6  'Draw MOUSE
'Sell:
IF mousec = 3 THEN DQBxPut 3, 259, 188, 264, 199, 1, DQBmouseX - 8, DQBmouseY - 6  'Draw MOUSE
'Repair:
IF mousec = 4 THEN DQBxPut 3, 242, 188, 249, 199, 1, DQBmouseX - 8, DQBmouseY - 6  'Draw MOUSE
'Stop Repair:
IF mousec = 5 THEN DQBxPut 3, 229, 188, 237, 199, 1, DQBmouseX - 8, DQBmouseY - 6  'Draw MOUSE


IF mousec = 1 THEN
'If we turn on the move cursor and we move over an enemy unit
'then we turn it into an attack cursor
id = 0
IF mapsight(mousecell) <> 0 THEN id = mapunit(mousecell)
IF id > 0 AND unitt2(id) <> 0 THEN mousec = 2
id = 0
IF mapsight(mousecell) <> 0 THEN id = mapstruct(mousecell)
IF id > 1 THEN IF structt2(id) <> 0 THEN mousec = 2
END IF
 
IF mousec = 2 THEN
'If we turn on the move cursor and we move over an enemy unit
'then we turn it into an attack cursor
id = -1
IF mapsight(mousecell) <> 0 AND id = -1 THEN
'In sight, id = -1
id = mapunit(mousecell) ' if there is a unit on this cell then
                        ' id = unit number
                        ' If no unit found, then id = 0
IF id = 0 THEN id = -1
END IF


IF mapsight(mousecell) <> 0 AND id = -1 THEN
'If we havent found a unit and the mouse is in a area which is
'explored then...
id = mapstruct(mousecell)       'If there is a structure on this cell
                                'then id = building number
                                'if no structure found then id = 0
IF id = 0 THEN id = -1
END IF

IF id = -1 THEN mousec = 1
END IF

'The MOUSECELL is VERY important, it is calculated here...
IF DQBmouseX <= 245 THEN
mousex = INT(DQBmouseX / 16): mousey = INT(DQBmouseY / 16)
mousecell = (mousey + my) * 64 + (mousex + mx)
IF mousecell < 0 THEN mousecell = 0
IF mousecell > 4095 THEN mousecell = 4095

yd = INT(mousecell / 64): xd = mousecell - (yd * 64)
END IF

'H pressed, will auto-center on const yard
IF DQBkey(35) = TRUE THEN
cell = 0
FOR i = 1 TO 100
IF structd(i) <> 0 AND structt2(i) = 0 AND structt(i) = 0 THEN cell = structc(i): EXIT FOR
NEXT i
IF cell = 0 THEN GOTO noco
my = INT(cell / 64)
mx = cell - INT(my * 64)
my = my - 5
mx = mx - 7
noco:
END IF


IF DQBkey(21) = TRUE THEN mousec = 3
IF DQBkey(20) = TRUE THEN mousec = 4
IF DQBkey(19) = TRUE THEN mousec = 5
 
'Done!
IF showframe <> 0 THEN DQBprint 1, "FPS:" + STR$(frame), 0, 9, white

IF foundothergoal = 1 THEN IF aihaveradar > 0 THEN enemyfound = 1
IF foundothergoal = 2 THEN IF credits < musthavecredits THEN enemyfound = 1

IF friendfound = 0 THEN DQBprint 1, "MISSION FAILED", 0, 0 + (showtime * 9) + (showframe * 9 + (9 * showtime)), 16
IF enemyfound = 0 THEN DQBprint 1, "MISSION ACCOMPLISHED", 0, 0 + (showtime * 9) + (showframe * 9 + (9 * showtime)), 12


IF settimer > 0 THEN
'sec = INT((60 / settimer))
FOR la = 0 TO settimer STEP 60
sec = settimer - la
IF sec < 60 THEN EXIT FOR
NEXT la
min = INT(settimer / 60)
hours = INT(min / 60)
tijd$ = STR$(hours) + ":" + STR$(min) + ":" + STR$(sec)
DQBprint 1, tijd$, 0, 189, white
END IF

IF seconds > 59 THEN seconds = seconds - 60: minutes = minutes + 1
IF minutes > 59 THEN minutes = minutes - 60: hours = hours + 1
IF showtime <> 0 THEN DQBprint 1, "TIME:" + STR$(hours) + "HR," + STR$(minutes) + "M," + STR$(seconds) + "SEC", 0, 0, white
 

 
IF message$ <> "" THEN
IF UCASE$(message$) <> "REINFORCEMENTS HAVE ARRIVED" AND dontplay2 = 0 AND nosound = 0 THEN GOTO nietnodigh

lengte = (LEN(message$) * 8)
beginx = 123 - (lengte / 2)

DQBprint 1, message$, beginx, 95, white
nietnodigh:
messagetijd = messagetijd - 1
END IF

IF DQBkey(1) = TRUE AND nu <> 0 THEN
options
IF resetten <> 0 THEN GOTO loadmore
IF mustquit <> 0 THEN GOTO quitgame
END IF

IF readbriefing = 0 AND nu <> 0 THEN readbriefingit

DQBcopyLayer 1, 0                                       'Draw all on the screen

 
IF friendfound = 0 OR enemyfound = 0 THEN
FOR l = 1 TO 170
drawwindow 5 + l
NEXT l
center 3, "LEVEL:" + STR$(lvl + 1), white
center 5, "KILLS:" + STR$(kills), white
center 7, "LOSTS:" + STR$(losts), white
score = INT(kills - losts + INT(credits / 100))
t$ = STR$(hours) + ":" + STR$(minutes) + ":" + STR$(seconds)
center 16, "ELAPSED TIME:" + t$, white
center 9, "SPICE HARVESTED:" + STR$(harvested), white
center 12, "SCORE:" + STR$(score), white
center 18, "PRESS A KEY...", white
DQBcopyLayer 1, 0
DQBwaitKey KEYANY
IF friendfound = 0 THEN
options
IF resetten <> 0 THEN GOTO loadmore
IF mustquit <> 0 THEN EXIT DO
END IF

IF enemyfound = 0 THEN lvl = lvl + 1: GOTO loadmore
END IF


'When you press S then all selected units will stop moving.
IF DQBkey(31) = TRUE THEN
'Check for selected units
speelaf = 0
FOR i = 1 TO 100
IF units(i) <> 0 AND unitt2(i) = 0 THEN unitmc(i) = unitc(i): unita(i) = 0: speelaf = 1
NEXT i
IF nosound = 0 AND speelaf <> 0 THEN DQBplaySound 22 + INT(RND * 3), 7, 22050, 0
END IF

IF DQBkey(18) = TRUE THEN
'Check for selected units
'GUARD UNITS
FOR i = 1 TO 100
IF units(i) <> 0 AND unitt2(i) = 0 THEN unitmc(i) = unitc(i): unita(i) = 6: speelaf = 1
NEXT i
END IF

IF DQBkey(34) = TRUE THEN
'Check for enemy units
speelaf = 0
FOR i = 1 TO 100
IF units(i) <> 0 AND unitt2(i) = 0 THEN unita(i) = 5: speelaf = 1
NEXT i
END IF


 
IF DQBkey(53) = TRUE AND showtip = 1 THEN showtip = 0: GOTO lalala3
IF DQBkey(53) = TRUE AND showtip = 0 THEN showtip = 1
lalala3:
IF DQBkey(33) = TRUE AND showframe = 1 THEN showframe = 0: GOTO lalala
IF DQBkey(33) = TRUE AND showframe = 0 THEN showframe = 1
lalala:
IF DQBkey(16) = TRUE AND showtime = 1 THEN showtime = 0: GOTO lalala2
IF DQBkey(16) = TRUE AND showtime = 0 THEN showtime = 1
lalala2:
 
 

nummertje = 0
FOR t = 1 TO 5
'PRESSED CRTL and NR 1 to 5
IF DQBkey(29) = TRUE AND DQBkey(1 + t) = TRUE THEN nummertje = t
NEXT t

IF nummertje > 0 THEN
'CREATE GROUP
FOR i = 1 TO 100
IF unitd(i) <> 0 AND units(i) <> 0 THEN unitg(i) = nummertje
IF unitd(i) <> 0 AND units(i) = 0 AND unitg(i) = nummertje THEN unitg(i) = 0
NEXT i
END IF

nummertje = 0
altpressed = 0
FOR t = 1 TO 5
IF DQBkey(56) = TRUE THEN altpressed = 1
IF DQBkey(1 + t) = TRUE THEN nummertje = t
NEXT t

 

IF nummertje > 0 THEN
'SELECT GROUP
FOR i = 1 TO 100
'Select units of specific group
IF unitd(i) <> 0 AND unitg(i) = nummertje THEN units(i) = 1: mousec = 1
'Deselect all other units
IF unitd(i) <> 0 AND units(i) <> 0 AND unitg(i) <> nummertje THEN units(i) = 0
'CENTER ON FIRST UNIT OF THE GROUP WHEN ALT IS PRESSED
IF altpressed <> 0 AND unitg(i) = nummertje THEN
cell = unitc(i)

my = INT(cell / 64)
mx = cell - INT(my * 64)
my = my - 5
mx = mx - 7
altpressed = 0
END IF
NEXT i
END IF


nu = 1
frme = frme + 1
LOOP
quitgame:
quitanimation
dummy& = SETMEM(17000)  'FREE MEM
DQBresetMouse
DQBremoveSB
DQBinitText
DQBclose
CLS
SYSTEM

REM $DYNAMIC
SUB addai (tjd, tpe, cell, soort)
FOR k = 1 TO 30
IF aidead(k) = 0 THEN new = k: EXIT FOR
NEXT k
IF k > 30 THEN EXIT SUB
IF tpe = 4 THEN

END IF
aidead(new) = soort
aitype(new) = tpe
aicell(new) = cell
aitime(new) = tjd
aitime2(new) = tjd
END SUB

'NO MORE
SUB addbuilding (team, typ, cell)
FOR k = 2 TO 100
IF structd(k) = 0 THEN new = k: EXIT FOR
NEXT k

IF team = 0 THEN
'WINDTRAP
IF typ = 0 THEN
y11 = INT(cell / 64)
x11 = cell - INT(y11 * 64)
IF x11 - 3 < minx THEN minx = minx - 3
IF y11 - 3 < miny THEN miny = miny - 3
IF x11 + 4 > maxx THEN maxx = maxx + 4
IF y11 + 4 > maxy THEN maxy = maxy + 4

havewind = havewind + 1: power = power + 75
END IF

'REFINERY
IF typ = 1 THEN haverefinery = haverefinery + 1: power = power - 40: spice = spice + 500
'BARRACK
IF typ = 2 THEN havetent = havetent + 1: power = power - 15
'WAR-FACTORY
IF typ = 3 THEN havewar = havewar + 1: power = power - 60
'RADAR
IF typ = 4 AND haveradar = 0 THEN haveradara = 1
IF typ = 4 THEN haveradar = haveradar + 1: power = power - 40
'REPAIR PAD
IF typ = 5 THEN haverepair = haverepair + 1: power = power - 70
'SPICE SILOS
IF typ = 6 THEN power = power - 15: spice = spice + 1000
'CONST YARD
IF typ = -1 THEN
y11 = INT(cell / 64)
x11 = cell - INT(y11 * 64)
miny = y11 - 4
minx = x11 - 4
maxx = x11 + 5
maxy = y11 + 5
haveconst = haveconst + 1
END IF
END IF

IF team = 1 THEN
'WINDTRAP
'REFINERY
'BARRACK
IF typ = 2 THEN aihavetent = aihavetent + 1
IF typ = 3 THEN aihavewar = aihavewar + 1
IF typ = 4 THEN aihaveradar = aihaveradar + 1
IF typ = 5 THEN aihaverepair = aihaverepair + 1
IF typ = -1 THEN aihaveconst = aihaveconst + 1
END IF

structt(new) = (typ + 1)
structc(new) = cell
structt2(new) = team
structp(new) = 100
structa(new) = 0
structd(new) = 1
IF structt2(new) = 0 THEN checkplace = 0
IF (typ + 1) = 2 THEN
addunit team, 2, structc(new) + 128, 0, 0
END IF

END SUB

'NO MORE
SUB addbullet (begin, einde, damage, tpe, testmode)

FOR k = 1 TO 100
IF bulld(k) = 0 THEN new = k: EXIT FOR
NEXT k
IF k > 100 THEN EXIT SUB

IF testmode <> -1 THEN
bulld(new) = 1  'Lives
bullc(new) = begin
bullc2(new) = einde
bulld2(new) = damage
bullt(new) = tpe

'Play sounds for specific bullets
IF tpe = -1 THEN playnr = 14
IF tpe = 0 THEN playnr = 15
IF tpe = 1 THEN playnr = 16
IF tpe = 2 THEN playnr = 16

IF tpe <= 0 THEN IF nosound = 0 THEN DQBplaySound playnr, 4, 22050, 0
IF tpe > 0 THEN IF nosound = 0 THEN DQBplaySound playnr, 8, 22050, 0

bullx(new) = 0
bully(new) = 0
END IF

niet = 0
y11 = INT(begin / 64)                   'Y coordinaat BEGIN
x11 = begin - INT(y11 * 64)             'X coordinaat BEGIN
y22 = INT(einde / 64)                   'Y coordinaat EINDE
x22 = einde - INT(y22 * 64)             'X coordinaat EINDE

verschilx = x11 - x22
verschily = y11 - y22

IF verschilx < -4 OR verschilx > 4 THEN bulld(new) = 0: niet = 1
IF verschily < -4 OR verschily > 4 THEN bulld(new) = 0: niet = 1

la2 = 0
id = mapunit(begin)
'IF id <= 0 THEN id = mapstruct(begin)

IF niet = 1 AND id > 0 THEN
'Move closer
unitmc(id) = einde
unita(id) = 4: testmode = 0
END IF

IF niet = 0 AND id > 0 THEN
'Move closer
unitmc(id) = einde
unita(id) = 3: testmode = 0
END IF

bullx2(new) = incx
bully2(new) = incy

END SUB

'NO MORE
SUB addunit (team, tpe, cll, movecell, actie)
IF movecell = cll THEN movecell = 0

 
FOR k = 1 TO 100
IF unitd(k) = 0 THEN new = k: EXIT FOR
NEXT k
IF k > 100 THEN new = 100
unitd(new) = 1  'Live
'Search for a spot to get out from

unitfac(new) = INT(RND * 8)

IF cll = 0 THEN
unitfac(new) = 4
IF tpe <> 5 THEN soort = 4               'Search for? 4=WARFACTOY, 3=BARRACK
IF tpe = 5 THEN soort = 3               'Search for? 4=WARFACTOY, 3=BARRACK
FOR j = 1 TO 100
IF structd(j) <> 0 AND structt(j) = soort AND structt2(j) = team THEN
cell = 0
theone = j
'FIX: BUG was it only checked for units, now it does check for structures too.
'so units cant get out of structure when it is blocked by another structure.
IF mapunit(structc(theone) + 128) = 0 AND mapstruct(structc(theone) + 128) = 0 THEN cell = structc(theone) + 128
IF mapunit(structc(theone) + 129) = 0 AND mapstruct(structc(theone) + 129) = 0 THEN cell = structc(theone) + 129
IF cell <> 0 THEN EXIT FOR
END IF

NEXT j
IF j > 100 THEN unitd(new) = 0: EXIT SUB 'No structure found, unit dies

IF cell = 0 THEN unitd(new) = 0: EXIT SUB
END IF

IF cll = 0 THEN unitc(new) = cell
IF cll <> 0 THEN unitc(new) = cll

unitt(new) = tpe
unitp(new) = 100
 
unitfi(new) = 0
unitfi2(new) = 0
IF actie = 3 THEN
IF mapunit(movecell) <> 0 THEN unitfi(new) = mapunit(movecell)
IF mapstruct(movecell) <> 0 THEN unitfi2(new) = mapstruct(movecell)
END IF

unita(new) = actie
unitcap(new) = 0
unitf(new) = 0
IF cll = 0 THEN unitmc(new) = cell + 128 ELSE unitmc(new) = unitc(new)
IF movecell <> 0 THEN unitmc(new) = movecell
 
unitx(new) = 0
unity(new) = 0

IF unitmc(new) > 4095 THEN unitmc(new) = 4095
unitt2(new) = team
IF tpe = 0 THEN units2(new) = 2
IF tpe = 1 THEN units2(new) = 1
IF tpe = 2 THEN units2(new) = 2
IF tpe = 3 THEN units2(new) = 1
IF tpe = 4 THEN units2(new) = 3
IF tpe = 5 THEN units2(new) = 1

IF unitt2(new) <> 0 AND unitt(new) = 4 THEN
IF INT(RND * 4) = 0 THEN unitmc(new) = INT(RND * 4095): unita(new) = 0
END IF

units(new) = 0
unitg(new) = 0
END SUB

SUB changetime
'will give time units in seconds,

F$ = TIME$              'Put current time in f$
k$ = MID$(F$, 8, 8)     'Read the last figure (that is a second)

IF k$ = n$ THEN
'When this figure is the same figure as one
tijd = tijd + 1:  frame = frme: frme = 1: seconds = seconds + 1
IF settimer > 0 THEN settimer = settimer - 1
IF wachten > 0 THEN wachten = wachten - 1
END IF

                                'second before, decrease time
k = VAL(k$)                     'last figure is now an integer
k = k + 1                       'increase it (so we can check the comming sec)
IF k > 9 THEN k = 0             'And a check... (cause you only have till 9)
e$ = STR$(k)                    'Now make it a string again
e$ = LTRIM$(e$)                 'Remove spaces at the left
e$ = RTRIM$(e$)                 'And at the right (just in case)
n$ = e$                         'And give n$ our e$ value to check like above
F$ = LEFT$(F$, LEN(F$) - 1)     'Delete the second at the current time
F$ = F$ + e$                    'And place the future second instead of it

END SUB

'NO MORE
SUB checkarea (cell, nr, tpe)

'Will check area from specific cell,
y11 = INT(cell / 64)                   'Y coordinaat BEGIN
x11 = cell - INT(y11 * 64)             'X coordinaat BEGIN

xb1 = x11 - 5
xb2 = x11 + 5
yb1 = y11 - 5
yb2 = y11 + 5
IF xb1 < 0 THEN xb1 = 0
IF xb2 > 63 THEN xb2 = 63
IF yb1 < 0 THEN yb1 = 0
IF yb2 > 63 THEN yb2 = 63

FOR cx = xb1 TO xb2
FOR cy = yb1 TO yb2
cll = cy * 64 + cx
id = mapunit(cll)
 
        IF id > 0 AND unitt2(id) <> unitt2(nr) THEN
                unitmc(nr) = unitc(id): unita(nr) = 3: unitfi(nr) = id
                EXIT SUB
        END IF
NEXT cy
NEXT cx

IF unitt2(nr) <> 0 THEN
FOR cx = xb1 TO xb2
FOR cy = yb1 TO yb2
cll = cy * 64 + cx
id = mapstruct(cll)
IF id > 1 THEN
IF structt2(id) = 0 THEN
unitmc(nr) = structc(id): unita(nr) = 3: unitfi2(nr) = id
EXIT SUB
END IF
END IF

NEXT cy
NEXT cx
END IF

  
END SUB

'NO MORE
SUB checkplacecells (hoog, breed, placeresults)

IF DQBmouseX > 244 THEN checkresults = 1: EXIT SUB

DQBsetClipBox 0, 0, 244, 199

checkresults = 0
FOR cy = mousey TO mousey + hoog
FOR cx = mousex TO mousex + breed
tile = 0
IF (cx + mx) > (mx + 15) THEN checkresults = 1
IF (cx + mx) > maxx THEN checkresults = 1: tile = 1
IF (cx + mx) < minx THEN checkresults = 1: tile = 1
IF (cy + my) > maxy THEN checkresults = 1: tile = 1
IF (cy + my) < miny THEN checkresults = 1: tile = 1
checkcell = (cy + my) * 64 + (cx + mx)
IF checkcell < 0 THEN checkcell = 0
IF checkcell > 4095 THEN checkcell = 4095
IF maptile(checkcell) < 5 OR (maptile(checkcell) >= 25 AND (maptile(checkcell) < 28) OR maptile(checkcell) > 33) THEN checkresults = 1: tile = 1
IF mapsight(checkcell) = 0 THEN tile = 1: checkresults = 1
IF mapunit(checkcell) <> 0 THEN tile = 1:  checkresults = 1
IF mapstruct(checkcell) <> 0 THEN tile = 1: checkresults = 1
IF tile = 0 THEN DQBxPut 3, 0, 116, 15, 131, 1, (cx * 16), (cy * 16)
IF tile = 1 THEN DQBxPut 3, 0, 99, 15, 114, 1, (cx * 16), (cy * 16)
NEXT cx
NEXT cy

IF DQBmouseRB = -1 THEN checkplace = 0

DQBsetClipBox 0, 0, 319, 199

END SUB

'NO MORE
SUB checkspice (cell, i)
'Will check for spice around CELL, using I for UNIT NR
'It will check in a medium range
y11 = INT(cell / 64)
x11 = cell - INT(y11 * 64)

x11 = x11 - 3
IF x11 < 0 THEN x11 = 0
x22 = x11 + 6
IF x22 > 63 THEN x22 = 63
y11 = y11 - 3
IF y11 < 0 THEN y11 = 0
y22 = y11 + 6
IF y22 > 63 THEN y22 = 63

FOR checky = y11 TO y22
FOR checkx = x11 TO x22
cll = (checky * 64) + checkx
IF maptile(cll) >= 25 AND maptile(cll) < 28 AND mapunit(cll) = 0 AND INT(RND * 3) = 0 THEN
IF unitcap(i) < 100 THEN unitmc(i) = cll
IF unitcap(i) >= 100 THEN unitsp(i) = cll
EXIT SUB
END IF

NEXT checkx
NEXT checky

END SUB

'NO MORE
SUB checkunitturn (a, b, c, d, to2)
IF a = 1 AND b = 0 AND c = 0 AND d = 0 THEN to2 = 0
IF a = 1 AND b = 1 AND c = 0 AND d = 0 THEN to2 = 7
IF a = 1 AND b = 0 AND c = 1 AND d = 0 THEN to2 = 1
IF a = 0 AND b = 1 AND c = 0 AND d = 0 THEN to2 = 6
IF a = 0 AND b = 0 AND c = 1 AND d = 0 THEN to2 = 2
IF a = 0 AND b = 0 AND c = 0 AND d = 1 THEN to2 = 4
IF a = 0 AND b = 0 AND c = 1 AND d = 1 THEN to2 = 3
IF a = 0 AND b = 1 AND c = 0 AND d = 1 THEN to2 = 5
END SUB

'NO MORE
SUB clearspot (cell, h, b)
'will "drop"  a nuke on the specific spot.
'Very easy
'The CELL is the center of the explosion
IF h = 0 THEN h = 7
IF b = 0 THEN b = 7
y11 = INT(cell / 64)
x11 = cell - INT(y11 * 64)
x11 = x11 - b
y11 = y11 - h
x22 = x11 + b + b
y22 = y11 + h + h

IF x11 < 0 THEN x11 = 0
IF y11 < 0 THEN y11 = 0
IF y22 > 63 THEN y22 = 63
IF x22 > 63 THEN x22 = 63
FOR cy = y11 TO y22
FOR cx = x11 TO x22
cll = cy * 64 + cx
tekenenja = 0
IF mapsight(cll) = 0 THEN mapsight(cll) = 1: tekenenja = 1

IF tekenenja = 1 THEN
IF maptile(cll) >= 5 THEN c = 123 ELSE c = 118
IF maptile(cll) >= 25 AND maptile(cll) < 28 THEN c = 238
IF maptile(cll) > 41 THEN c = 159
DQBpset 2, 249 + cx, 21 + cy, c
DQBpset 20, 249 + cx, 21 + cy, 0
END IF

NEXT cx
NEXT cy


END SUB

'NO MORE
SUB drawbullets
FOR i = 1 TO 100
IF bulld(i) <> 0 THEN
y11 = INT(bullc(i) / 64)
x11 = bullc(i) - INT(y11 * 64)
x = x11
y = y11
t = (bullt(i) * 18) + bullf(i)

'Put bullet on map...
'but first calculate the x and y...
l = 0
l = INT(t / 18): t = t - (l * 18)
'Draw unit from layer to the game
IF bullc(i) < 0 THEN bullc(i) = 0: bulld(i) = 0
IF mapsight(bullc(i)) <> 0 AND bullt(i) >= 0 THEN DQBxPut 31, (t * 16) + t, (l * 16) + l, (t * 16) + t + 15, 15 + (l * 16) + l, 1, (x - mx) * 16 + bullx(i), (y - my) * 16 + bully(i)

IF bullc(i) <> bullc2(i) THEN
begin = bullc(i)
einde = bullc2(i)
y11 = INT(begin / 64)
x11 = begin - INT(y11 * 64)
y22 = INT(einde / 64)
x22 = einde - INT(y22 * 64)

IF x22 < x11 THEN bullc(i) = bullc(i) - 1
IF x22 > x11 THEN bullc(i) = bullc(i) + 1
IF y22 < y11 THEN bullc(i) = bullc(i) - 64
IF y22 > y11 THEN bullc(i) = bullc(i) + 64
END IF


IF bullc(i) = bullc2(i) THEN
bulld(i) = 0
IF bullt(i) = 1 THEN adddead 2, 0, bullc(i), 0 + INT(RND * 10), 0 + INT(RND * 10)
IF bullt(i) = 2 THEN adddead 2, 0, bullc(i), 0 + INT(RND * 10), 0 + INT(RND * 10)
IF bullt(i) = 0 THEN
adddead 3, 0, bullc(i), 0 + INT(RND * 10), 0 + INT(RND * 10)
adddead 3, 0, bullc(i), 0 + INT(RND * 10), 0 + INT(RND * 10)
END IF
IF bullt(i) = -1 THEN adddead 3, 0, bullc(i), 0 + INT(RND * 8), 0 + INT(RND * 8)
id = mapunit(bullc(i))
IF id > 0 THEN
IF unitt(id) = 5 THEN unitp(id) = unitp(id) - (bulld2(i) * 5)
IF unitt(id) = 4 THEN unitp(id) = unitp(id) - (bulld2(i) * 4)
IF unitt(id) = 3 THEN unitp(id) = unitp(id) - (bulld2(i) * 3)
IF unitt(id) = 2 THEN unitp(id) = unitp(id) - (bulld2(i) * 2)
IF unitt(id) = 1 THEN unitp(id) = unitp(id) - (bulld2(i) * 1)
IF unitt(id) = 0 THEN unitp(id) = unitp(id) - (bulld2(i) * 2)
'When under attack fire back at unit who is attacking you (AI)
IF unitt2(id) <> 0 THEN unita(id) = 5: unitmc(id) = unitc(id)
'NEW: (for player units)
'IF YOU DO NOTHING AND YOU ARE UNDER ATTACK THEN FIRE BACK
'And you are not a harvester ofcourse
IF unitt2(id) = 0 AND unitt(id) <> 2 AND unita(id) = 0 THEN unita(id) = 5: unitmc(id) = unitc(id)
END IF
id = 0
id = mapstruct(bullc(i))
IF id > 0 THEN
IF structt(id) = 7 THEN structp(id) = structp(id) - (bulld2(i) * 4)
IF structt(id) = 6 THEN structp(id) = structp(id) - (bulld2(i) * 2)
IF structt(id) = 5 THEN structp(id) = structp(id) - (bulld2(i) * 3)
IF structt(id) = 4 THEN structp(id) = structp(id) - (bulld2(i) * 2)
IF structt(id) = 3 THEN structp(id) = structp(id) - (bulld2(i) * 1)
IF structt(id) = 2 THEN structp(id) = structp(id) - (bulld2(i) * 2)
IF structt(id) = 1 THEN structp(id) = structp(id) - (bulld2(i) * 3)
IF structt(id) = 0 THEN structp(id) = structp(id) - (bulld2(i) * 1)
END IF


END IF

DQBpset 15, 249 + x, 21 + y, 149

END IF
NEXT i

END SUB

'NO MORE
SUB drawpower
'Draws power
p = power
IF p > 100 THEN p = 100
IF p < 0 THEN p = 0
DQBline 1, 248, 194 - p, 248, 195, 181
DQBline 1, 249, 194 - p, 249, 195, 183
DQBline 1, 250, 194 - p, 250, 195, 182
DQBline 1, 251, 194 - p, 251, 195, 181
DQBline 1, 252, 194 - p, 252, 195, 180
DQBline 1, 253, 194 - p, 253, 195, 179
 
'Spice left
'ok, credits=100%
'spice you can hold = the percent
p1 = INT(spice / 100)
sp = INT((spice - credits) / p1)
sp2 = sp
IF sp2 > 100 THEN sp2 = 100 ELSE sp2 = sp
IF sp2 < 0 THEN sp2 = 0
DQBline 1, 255, 194 - sp2, 255, 195, 242
DQBline 1, 256, 194 - sp2, 256, 195, 244
DQBline 1, 257, 194 - sp2, 257, 195, 245
DQBline 1, 258, 194 - sp2, 258, 195, 246
DQBline 1, 259, 194 - sp2, 259, 195, 247
DQBline 1, 260, 194 - sp2, 260, 195, 248


IF DQBmouseX >= 255 AND DQBmouseX <= 260 AND DQBmouseY >= 99 AND DQBmouseY <= 199 THEN txt$ = "%" + (LTRIM$(RTRIM$(STR$(sp)))) + " SPICE(" + (LTRIM$(RTRIM$(STR$(spice - credits)))) + ")": ja = 1
IF DQBmouseX >= 248 AND DQBmouseX <= 253 AND DQBmouseY >= 99 AND DQBmouseY <= 199 THEN txt$ = "%" + (LTRIM$(RTRIM$(STR$(power)))) + " POWER": ja = 1
td = LEN(txt$)
xb = td * 8
IF ja = 1 THEN DQBprint 1, txt$, DQBmouseX - xb, DQBmouseY, white
END SUB

'NO MORE
SUB drawterrain
'draws terrain, easy
'instead of calculating the X and Y
'we calculate the CELL,
'CELL=Y*64+X
'Start drawing from MX and MY to the borders,
'this makes it REALLY FAST and easy
FOR y = my TO my + 13
 
FOR x = mx TO mx + 15
 
t = maptile(y * 64 + x)
l = 0
l = INT(t / 18): t = t - (l * 18)
k = y * 64 + x
IF mapsight(k) <> 0 THEN
DQBxPut 3, (t * 16) + t, (l * 16) + l, (t * 16) + t + 15, 15 + (l * 16) + l, 1, (x - mx) * 16, (y - my) * 16
IF k - 1 > 0 THEN IF mapsight(k - 1) = 0 THEN DQBxPut 3, 0, 144, 25, 173, 1, (x - mx - 1) * 16 - 4, (y - my) * 16 - 4

IF k - 65 > 0 THEN IF mapsight(k - 65) = 0 THEN DQBxPut 3, 0, 144, 25, 173, 1, (x - mx - 1) * 16 - 4, (y - my - 1) * 16 - 4
IF k - 64 > 0 THEN IF mapsight(k - 64) = 0 THEN DQBxPut 3, 0, 144, 25, 173, 1, (x - mx) * 16 - 4, (y - my - 1) * 16 - 4
IF k - 63 > 0 THEN IF mapsight(k - 63) = 0 THEN DQBxPut 3, 0, 144, 25, 173, 1, (x - mx + 1) * 16 - 4, (y - my - 1) * 16 - 4

IF k + 1 < 4095 THEN IF mapsight(k + 1) = 0 THEN DQBxPut 3, 0, 144, 25, 173, 1, (x - mx + 1) * 16 - 4, (y - my) * 16 - 4

IF k + 65 < 4095 THEN IF mapsight(k + 65) = 0 THEN DQBxPut 3, 0, 144, 25, 173, 1, (x - mx + 1) * 16 - 4, (y - my + 1) * 16 - 4
IF k + 64 < 4095 THEN IF mapsight(k + 64) = 0 THEN DQBxPut 3, 0, 144, 25, 173, 1, (x - mx) * 16 - 4, (y - my + 1) * 16 - 4
IF k + 63 < 4095 THEN IF mapsight(k + 63) = 0 THEN DQBxPut 3, 0, 144, 25, 173, 1, (x - mx - 1) * 16 - 4, (y - my + 1) * 16 - 4
END IF


NEXT x
NEXT y
  
 
END SUB

'NO MORE
SUB drawunits
'This sub is very small,
'like in all unit files
'the facing is in unitfac()
'The TYPE of unit is from layer 4+ unittype
'Since a harvester is unit type 0, it will draw from layer 4
'so it will draw the harvester. Simple folume but very affectif
'So a lot of units can be added!
muisword = 0
enemies = 0
FOR i = 1 TO 100
 
'if unit is not dead then....

IF unitd(i) <> 0 THEN
uns = uns + 1
IF unitt2(i) = 0 THEN friendfound = 1
IF unitt2(i) <> 0 THEN enemyfound = 1: enemies = enemies + 1

IF unitt(i) = 5 AND unita(i) < 3 AND unitf(i) = 4 THEN unitf(i) = 0
IF unitt(i) = 2 AND (unita(i) = 5 OR unita(i) = 3 OR unita(i) = 4) THEN unita(i) = 0
'For collision...
mapunit(unitc(i)) = i
'It lives!
IF unita(i) = 0 AND unitf(i) <> 0 AND unitt(i) <> 5 AND unitt(i) <> 2 THEN unitf(i) = 0
 
IF unitt2(i) = 0 THEN
l = unitc(i)
yd = INT(l / 64): xd = l - (yd * 64)
mapsight(unitc(i)) = 1: DQBpset 20, 249 + xd, 21 + yd, 0
IF unitc(i) - 1 >= 0 THEN mapsight(unitc(i) - 1) = 1: DQBpset 20, 249 + xd - 1, 21 + yd, 0
IF unitc(i) - 65 >= 0 THEN mapsight(unitc(i) - 65) = 1: DQBpset 20, 249 + xd - 1, 21 + yd - 1, 0
IF unitc(i) - 64 >= 0 THEN mapsight(unitc(i) - 64) = 1: DQBpset 20, 249 + xd, 21 + yd - 1, 0
IF unitc(i) - 63 >= 0 THEN mapsight(unitc(i) - 63) = 1: DQBpset 20, 249 + xd + 1, 21 + yd - 1, 0
IF unitc(i) + 1 <= 4095 THEN mapsight(unitc(i) + 1) = 1: DQBpset 20, 249 + xd + 1, 21 + yd, 0
IF unitc(i) + 65 <= 4095 THEN mapsight(unitc(i) + 65) = 1: DQBpset 20, 249 + xd + 1, 21 + yd + 1, 0
IF unitc(i) + 64 <= 4095 THEN mapsight(unitc(i) + 64) = 1: DQBpset 20, 249 + xd, 21 + yd + 1, 0
IF unitc(i) + 63 <= 4095 THEN mapsight(unitc(i) + 63) = 1: DQBpset 20, 249 + xd - 1, 21 + yd + 1, 0
END IF

y = INT(unitc(i) / 64)
x = unitc(i) - (y * 64)
IF unitf(i) > 0 THEN t = unitfac(i) + (unitf(i) * 8) ELSE t = unitfac(i)

'Put unit on map...
'but first calculate the x and y...
uselayer = unitt(i) + 4 + unitt2(i) * 28

l = 0
l = INT(t / 18): t = t - (l * 18)
'Draw unit from layer to the game
IF mapsight(unitc(i)) <> 0 AND x >= (mx - 1) AND x <= mx + 16 AND y >= (my - 1) AND y <= my + 15 THEN
DQBxPut uselayer, (t * 16) + t, (l * 16) + l, (t * 16) + t + 15, 15 + (l * 16) + l, 1, (x - mx) * 16 + unitx(i), (y - my) * 16 + unity(i)

IF unitp(i) < 50 AND unitt(i) <> 5 THEN
t = unitf3(i)
l = 0
l = INT(t / 18): t = t - (l * 18)
'1 Smoke thing on a unit when damage < 50
DQBxPut 43, (t * 16) + t, 0, (t * 16) + t + 15, 15, 1, (x - mx) * 16 + unitx(i) + 7, (y - my) * 16 + unity(i) - 7
unitc7(i) = unitc7(i) + 1
IF unitc7(i) >= (6 - (skipframe / 2)) THEN
unitf3(i) = unitf3(i) + 1
IF unitf3(i) > 3 THEN unitf3(i) = 0
unitc7(i) = 0
END IF

END IF
END IF

'if we have to check for select code...
'then check it...
'we create 2 variables.. (the x2,y2 are +16 so we save 2 variables)
x3 = ((x - mx) * 16) + unitx(i)
y3 = ((y - my) * 16) + unity(i)

IF checkunits <> 0 AND DQBmouseX <= 245 THEN
'Select a unit, NOT using the Multi-select box...

IF checkunits = 1 THEN IF x1 >= x3 AND x1 <= (x3 + 16) AND y1 >= y3 AND y1 <= (y3 + 16) AND unitt2(i) = 0 THEN units(i) = 1: muisword = 1: IF nosound = 0 THEN DQBplaySound 20 + INT(RND * 2), 6, 22050, 0
'Deselect any structure
'Select units in multi-box
IF checkunits = 2 THEN
'Ok we check now the multi-box, but because X1 can be < X2 we have to
'swap them, so we have the right values to check
IF x2 < x1 THEN SWAP x2, x1: IF y2 < y1 THEN SWAP y2, y1
IF x3 >= x1 AND x3 <= x2 AND y3 >= y1 AND y3 <= y2 AND unitt2(i) = 0 THEN units(i) = 1: muisword = 1: IF nosound = 0 THEN DQBplaySound 20 + INT(RND * 2), 6, 22050, 0
END IF

END IF

'If a unit is selected we draw the selected bar...
IF units(i) <> 0 THEN
DQBxPut 3, 0, 184, 15, 199, 1, ((x - mx) * 16) + unitx(i), ((y - my) * 16) + unity(i)
'And power
DQBxPut 3, 0, 181, 0 + (INT(unitp(i) * .16)), 182, 1, ((x - mx) * 16) + unitx(i), ((y - my) * 16) + unity(i) - 3

'Capacity too, only when harvester...
IF unitt(i) = 2 THEN
DQBxPut 3, 0, 178, 0 + (INT(unitcap(i) * .16)), 179, 1, ((x - mx) * 16) + unitx(i), ((y - my) * 16) + unity(i) - 6
END IF

IF unitg(i) > 0 THEN
IF unitg(i) = 1 THEN teken$ = "a"
IF unitg(i) = 2 THEN teken$ = "b"
IF unitg(i) = 3 THEN teken$ = "c"
IF unitg(i) = 4 THEN teken$ = "d"
IF unitg(i) = 5 THEN teken$ = "e"
DQBprint 1, teken$, ((x - mx) * 16) + unitx(i), ((y - my) * 16) + unity(i), white
END IF
END IF


'MOVE CODE!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
'MOVE CODE!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
'MOVE CODE!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
IF unitc(i) <> unitmc(i) AND (unita(i) = 0 OR unita(i) = 4 OR unita(i) = 6) THEN moveunit i

'If a unit doesnt have to move but is not on the correct position X,Y then
'then it will move back
IF unitc(i) = unitmc(i) THEN
IF unitx(i) < 0 THEN unitx(i) = unitx(i) + 1 + skipframe
IF unitx(i) > 0 THEN unitx(i) = unitx(i) - 1 - skipframe
IF unity(i) < 0 THEN unity(i) = unity(i) + 1 + skipframe
IF unity(i) > 0 THEN unity(i) = unity(i) - 1 - skipframe
END IF

'MOVE CODE!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
'MOVE CODE!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
'MOVE CODE!!!!!!!!!!!!!!!!!!!!!!!!!!!!1

'IF DQBmouseLB = -1 AND mousec = 1 AND units(i) = 1 AND unitt2(i) = 0 THEN unitmc(i) = mousecell: unita(i) = 0
IF DQBmouseLB = -1 AND mousec = 1 AND units(i) = 1 AND unitt2(i) = 0 AND unitc(i) <> mousecell THEN unitmc(i) = mousecell: unita(i) = 0: afspelen = 10
 
'If a harvester is on spice, 25 > < 36 maptile, dan komt er langzamer hand
'spice in...
IF unitt(i) = 2 AND unitcap(i) < 101 THEN
'Is een harvester en heeft nog niet 100 procent
IF unitmc(i) < 0 THEN unitmc(i) = 0
IF unitmc(i) > 4095 THEN unitmc(i) = 4095

IF maptile(unitc(i)) <= 5 AND unitcap(i) < 100 AND unitmc(i) = unitc(i) THEN checkspice unitc(i), i

        IF maptile(unitc(i)) >= 25 AND maptile(unitc(i)) < 28 THEN
        'Op spice
        unitc2(i) = unitc2(i) + 1
                IF unitc2(i) > 3 THEN
                'Give capacity
                unitc2(i) = 0
                unitcap(i) = unitcap(i) + (1 * (skipframe + 2))        '20 percent per cell, you
                unitc3(i) = unitc3(i) + 1
                'Ofcourse the tile will change
                IF unitc3(i) > 17 THEN
                maptile(unitc(i)) = INT(RND * 5): unitc3(i) = 0
                'But look for borders too, or else we have holes
                checkspice unitc(i), i
                yd = INT(unitc(i) / 64): xd = unitc(i) - (yd * 64)
                DQBpset 2, 249 + xd, 21 + yd, 118
                END IF

                'need 10 cells to get 100 percent
                IF unitcap(i) > 100 THEN unitcap(i) = 100
        END IF

IF unitcap(i) = 100 THEN unitsp(i) = unitc(i)

END IF

'Als een harvester vol is, zoek dan voor een gebouw zodat je kunt dumpen
'We checken alleen waneer de harvester niet beweegt...
IF unitc(i) = unitmc(i) AND unitt(i) = 2 AND unitcap(i) >= 100 THEN
'Zoek voor een refinery
        FOR j = 1 TO 100
                IF structd(j) <> 0 AND structt(j) = 2 AND structt2(j) = unitt2(i) THEN
                IF mapunit(structc(j) + 128) = 0 THEN unitmc(i) = structc(j) + 128: EXIT FOR
                unitmc(i) = structc(j) + 129
                END IF
        NEXT j
END IF

'Als een harvester onder een refinery is dan dumpen we de spice
'tada
IF unitc(i) - 64 > 0 THEN
        IF mapstruct(unitc(i) - 64) <> 0 THEN
        id = mapstruct(unitc(i) - 64)
                IF id > 1 THEN
                IF structt2(id) = unitt2(i) AND structt(id) = 2 AND unitcap(i) > 0 THEN
                'IT is a structure of the same team

                unitcap(i) = unitcap(i) - 1
                IF harvested > 31994 THEN harvested = 31994
                IF (spice - credits) >= 6 AND unitt2(i) = 0 THEN credits = credits + 6: IF nosound = 0 THEN DQBplaySound 12, 3, 22050, 0: harvested = harvested + 6

                IF unitcap(i) <= 0 THEN unitmc(i) = unitsp(i): unitf(i) = 0

                END IF
                END IF

        END IF
END IF


 
IF unitcap(i) > 25 THEN unitf(i) = 1
IF unitcap(i) > 50 THEN unitf(i) = 2
IF unitcap(i) > 75 THEN unitf(i) = 3

END IF

'******************************
'If a unit stands still for a while it will turn around, like in dune 2
IF unitc(i) = unitmc(i) THEN
unitc4(i) = unitc4(i) + 1
IF unitc4(i) > INT(RND * 100) + 90 THEN unitc4(i) = 0: turnunit INT(RND * 8), i
END IF



'And draw it on the minimap
'Ok Colors are:
'40  = ATREIDES
'170 = HARKONNEN
'201 = ORDOS
IF unitt2(i) = 0 THEN c = mycolor ELSE c = enemycolor
IF units(i) <> 0 THEN c = 14
IF mapsight(unitc(i)) <> 0 THEN DQBpset 15, 249 + x, 21 + y, c


'If it is a Infantry unit, type number 5 then
IF unitt(i) = 5 THEN

IF unitmc(i) <> unitc(i) AND unita(i) <> 5 THEN
unitc5(i) = unitc5(i) + 1
IF unitc5(i) > 5 THEN unitf(i) = unitf(i) + 1: unitc5(i) = 0
IF unitf(i) > 3 THEN unitf(i) = 0
END IF

IF unitmc(i) <> unitc(i) AND unita(i) = 3 AND units3(i) > 0 THEN
die = units3(i) / (INT(RND * 4) + 1)
unitf(i) = INT(RND * 4)
plus = INT(RND * 3) + 1
FOR a = 1 TO units3(i) STEP plus
IF a = die THEN unitf(i) = 4: EXIT FOR
IF a > units3(i) THEN EXIT FOR
NEXT a
units3(i) = units3(i) - 1
END IF

END IF
'****************************************
'****************************************
'ATTACK CODE
'****************************************
'****************************************
IF unita(i) = 3 OR unita(i) = 4 THEN
'First check if inrange, if not, then we don't turn the unit!
begin = unitc(i)
einde = unitmc(i)
y11 = INT(begin / 64)
x11 = begin - INT(y11 * 64)
y22 = INT(einde / 64)
x22 = einde - INT(y22 * 64)
'If in range then change the facing

washere = 0
IF unitd(unitfi(i)) <> 0 AND unitfi(i) > 0 THEN
         
'Unit target lives, check if it is an ENEMY unit, if so then that is the target
                IF unitt2(unitfi(i)) <> unitt2(i) THEN check = unitc(unitfi(i)): washere = 1: GOTO nobuilding
        END IF

'If it gets to here then there is NOT an enemy unit
IF structd(unitfi2(i)) <> 0 AND unitfi2(i) > 0 THEN
'Structure lives
IF structt2(unitfi2(i)) <> unitt2(i) THEN check = structc(unitfi2(i)): washere = 2
END IF

nobuilding:
 

'To check if we still have to move
addbullet begin, check, 0, 0, -1

IF unita(i) = 3 THEN
links = 0: rechts = 0: omhoog = 0: omlaag = 0
IF x22 < x11 THEN links = 1
IF x22 > x11 THEN rechts = 1
IF y22 < y11 THEN omhoog = 1
IF y22 > y11 THEN omlaag = 1
checkunitturn omhoog, links, rechts, omlaag, to2        'Calculate facing
IF to2 <> unitfac(i) THEN turnunit to2, i: unita(i) = 3
END IF

'BUT if the target is a soldier and the current unit is a TANK
'then over-ride it, only when a computer unit
IF unitt2(i) <> 0 AND unitt(i) <= 2 THEN
'Computer unit
id = mapunit(unitmc(i))
                IF id > 0 THEN
                        IF unitt(id) = 5 THEN unitmc(i) = unitc(id): unita(i) = 0: GOTO nounit
                END IF
END IF

IF unitf(i) <> 0 AND unita(i) <> 3 AND unitt(i) <> 5 THEN unitf(i) = 0

IF unitfac(i) = to2 AND unita(i) = 3 THEN
'Check target, if it lives then attack it
'First check UNITs
IF unitf(i) <> 0 AND unitc6(i) = 0 AND unita(i) = 3 THEN unitf(i) = 0
  

IF washere = 1 THEN unitfi2(i) = 0: unitmc(i) = unitc(i)
IF washere = 2 THEN unitfi(i) = 0: unitmc(i) = unitc(i)
IF washere = 0 THEN unitfi(i) = 0: unitfi2(i) = 0: unita(i) = 5: unitmc(i) = unitc(i): GOTO nounit

IF unita(i) = 3 THEN
'First before you fire a bullet, check if we are in range
addbullet unitc(i), check, 0, 0, -1
unitc6(i) = unitc6(i) + 1
END IF


IF unitt(i) = 0 THEN extraw = 2
IF unitt(i) = 1 THEN extraw = 3
IF unitt(i) = 3 THEN extraw = 4
IF unitt(i) = 4 THEN extraw = 1
IF unitt(i) = 5 THEN extraw = 0

IF unitc6(i) > (13 + extraw) THEN
IF unitt(i) = 5 THEN units3(i) = 25
IF unitt(i) <> 5 AND unitf(i) = 0 THEN unitf(i) = 1
IF unitt(i) = 0 THEN strength = 3: sort = 1
IF unitt(i) = 1 THEN strength = 5: sort = 1
IF unitt(i) = 3 THEN strength = 7: sort = 2
IF unitt(i) = 4 THEN strength = 2: sort = 0
IF unitt(i) = 5 THEN strength = 1: sort = -1
addbullet unitc(i), check, strength, sort, 0: unitc6(i) = 0
unitc6(i) = 0
mapsight(unitc(i)) = 1
'IF gebouw = 1 THEN addbullet unitc(i), structc(check), strength, sort, 0: unitc6(i) = 0
END IF

END IF
nounit:
END IF

IF unitp(i) <= 0 THEN
IF unitt2(i) = 0 THEN huis$ = myhousename$: losts = losts + 1:  ELSE huis$ = enemyhousename$: kills = kills + 1
message$ = huis$ + " UNIT DESTROYED"
messagetijd = 25
IF unitt2(i) = 0 THEN messagenr = 1 ELSE messagenr = 2

IF unitt(i) <= 4 THEN IF nosound = 0 THEN DQBplaySound 18 + INT(RND * 2), 5, 22050, 0
IF unitt(i) = 5 THEN IF nosound = 0 THEN DQBplaySound 25 + INT(RND * 5), 9, 22050, 0

unitd(i) = 0
FOR si = 1 TO 100
IF unitfi(si) = i THEN unitfi(si) = 0
NEXT si

IF unitt(i) <> 5 THEN
gok = INT(RND * 2)
IF gok = 0 THEN adddead 1, 0, unitc(i), unitx(i), unity(i)
IF gok = 1 THEN adddead 4, 0, unitc(i), unitx(i), unity(i)
END IF

IF unitt(i) = 5 THEN
gok = INT(RND * 2)
IF gok = 0 THEN adddead 0, 0, unitc(i), unitx(i), unity(i)
IF gok = 1 THEN adddead 5, 0, unitc(i), unitx(i), unity(i)
END IF

mapunit(unitc(i)) = 0
END IF

IF unitc(i) = unitmc(i) AND unitt2(i) <> 0 AND unita(i) <> 5 THEN unita(i) = 5
IF unita(i) = 5 THEN checkarea unitc(i), i, 1


'To prevent, rare movements, when target number is 0 and action
'of unit is attack or follow (3 or 4) then we change the unitmovecell
'and the action. since there is nothing to follow ...
IF (unitfi(i) <= 0 AND unitfi2(i) <= 0) AND (unita(i) = 3 OR unita(i) = 4) THEN unita(i) = 5: unitmc(i) = unitc(i): unitf(i) = 0


IF unita(i) = 6 THEN
IF unitmc(i) = unitc(i) THEN
la = INT(RND * 4)
IF la = 0 THEN unitmc(i) = unitmc(i) - INT(RND * 3) - 1
IF la = 1 THEN unitmc(i) = unitmc(i) - INT(RND * 3) - 1 - (INT(RND * 3) * 64) - 64
IF la = 2 THEN unitmc(i) = unitmc(i) + INT(RND * 3) + 1
IF la = 3 THEN unitmc(i) = unitmc(i) + INT(RND * 3) + 1 + (INT(RND * 3) * 64) + 64
END IF
END IF

IF unitmc(i) < 0 THEN unitmc(i) = 0
IF unitmc(i) > 4095 THEN unitmc(i) = 4095


IF x1 >= x3 AND x1 <= (x3 + 16) AND y1 >= y3 AND y1 <= (y3 + 16) AND unitt2(i) <> 0 AND mousec = 1 THEN mousec = 2



'AI STUFF
IF unitp(i) < 50 AND aihaverepair <> 0 AND unitmc(i) = unitc(i) AND unitt2(i) <> 0 THEN
'Repair unit
FOR fr = 1 TO 100
IF structd(fr) <> 0 AND structt2(fr) <> 0 AND structt(fr) = 6 THEN
iets = 0
IF mapunit(structc(fr) + 128) <> 0 THEN iets = 1
IF mapstruct(structc(fr) + 128) <> 0 THEN iets = 1

IF mapunit(structc(fr) + 129) <> 0 THEN GOTO kanniet
IF mapstruct(structc(fr) + 129) <> 0 THEN GOTO kanniet

unitmc(i) = structc(fr) + 128 + iets: unita(i) = 0

END IF
kanniet:

NEXT fr
END IF

IF unitt2(i) = 0 THEN clearspot unitc(i), 4, 4
IF unita(i) = 0 THEN unitfi(i) = 0: unitfi2(i) = 0

 
'END OF DEAD IF -END IF
END IF


NEXT i

'Ok now search for any selected units, so we change the mouse cursor.
'With purpose this loop because when i put it in the loop above you cannot
'multiselect....
'Another function is that the units will move to the current mousecell..
'FOR i = 1 TO 100
'IF units(i) <> 0 AND unitd(i) <> 0 THEN mousec = 1
'NEXT i
checkunits = 0
IF muisword <> 0 THEN mousec = muisword
IF afspelen > 0 THEN afspelen = afspelen - 1
IF afspelen = 8 THEN IF nosound = 0 THEN DQBplaySound 22 + INT(RND * 3), 7, 22050, 0
END SUB

'NO MORE
SUB drawustructures
'Draw structures
IF checkstr <> 0 THEN
 
FOR j = 2 TO 100
structs(j) = 0
NEXT j
END IF
str = 0
FOR i = 2 TO 100
 'If a structure is NOT dead

IF structd(i) <> 0 THEN

IF structt2(i) = 0 THEN friendfound = 1
IF structt2(i) <> 0 THEN enemyfound = 1

mapstruct(structc(i)) = i
mapstruct(structc(i) + 1) = i
mapstruct(structc(i) + 64) = i
mapstruct(structc(i) + 65) = i

IF structp(i) <= 0 THEN
'Ok, first seek for any unit that wanted to attack this structure
'if found, set them on GUARD mode and leave them on the cell
IF structt2(i) = 0 THEN huis$ = myhousename$: losts = losts + 5 ELSE huis$ = enemyhousename$: kills = kills + 5
message$ = huis$ + " STRUCTURE DESTROYED"
messagetijd = 25
IF structt2(i) = 0 THEN messagenr = 3 ELSE messagenr = 4

FOR si = 1 TO 100
IF unitfi2(si) = i THEN
unitfi2(si) = 0
unitmc(si) = unitc(si)
unita(si) = 5
END IF
NEXT si

IF nosound = 0 THEN DQBplaySound 17, 6, 22050, 0

IF structt2(i) = 0 THEN
IF structt(i) = 0 THEN haveconst = haveconst - 1
IF structt(i) = 1 THEN havewind = havewind - 1: power = power - 75
IF structt(i) = 2 THEN haverefinery = haverefinery - 1: power = power + 40: spice = spice - 500
IF structt(i) = 3 THEN havetent = havetent - 1: power = power + 15
IF structt(i) = 4 THEN havewar = havewar - 1: power = power + 70
IF structt(i) = 5 THEN haveradar = haveradar - 1: power = power + 40
IF structt(i) = 6 THEN haverepair = haverepair - 1: power = power + 70
IF structt(i) = 7 THEN power = power + 15: spice = spice - 1000
END IF

IF structt2(i) <> 0 THEN
IF structt(i) = 0 THEN aihaveconst = aihaveconst - 1
IF structt(i) = 3 THEN aihavetent = aihavetent - 1
IF structt(i) = 4 THEN aihavewar = aihavewar - 1
IF structt(i) = 5 THEN aihaveradar = aihaveradar - 1
IF structt(i) = 6 THEN aihaverepair = aihaverepair - 1
END IF

'Geef soldaatjes op de cells, random, max 2 soldaten
IF INT(RND * 2) = 0 THEN addunit structt2(i), 5, structc(i), 0, 5
IF INT(RND * 2) = 0 THEN addunit structt2(i), 5, structc(i) + 65, 0, 5

structd(i) = 0
mapstruct(structc(i)) = 0
mapstruct(structc(i) + 1) = 0
mapstruct(structc(i) + 64) = 0
mapstruct(structc(i) + 65) = 0
adddead 1, 0, structc(i), 0, 0
adddead 1, 0, structc(i) + 1, 0, 0
adddead 1, 0, structc(i) + 64, 0, 0
adddead 1, 0, structc(i) + 65, 0, 0

extra = INT(RND * 4) + 1
FOR la = 1 TO extra
adddead 4, 0, structc(i), -5 + INT(RND * 13), -5 + INT(RND * 15)
NEXT la

END IF


 

'If a human structure
IF structt2(i) = 0 THEN
mapsight(structc(i)) = 1
mapsight(structc(i) + 1) = 1
mapsight(structc(i) + 64) = 1
mapsight(structc(i) + 65) = 1

'Around the structure too
IF structc(i) - 1 >= 0 THEN mapsight(structc(i) - 1) = 1
IF structc(i) - 65 >= 0 THEN mapsight(structc(i) - 65) = 1
IF structc(i) - 64 >= 0 THEN mapsight(structc(i) - 64) = 1
IF structc(i) - 63 >= 0 THEN mapsight(structc(i) - 63) = 1
IF structc(i) - 62 >= 0 THEN mapsight(structc(i) - 62) = 1

IF structc(i) + 2 <= 4095 THEN mapsight(structc(i) + 2) = 1
IF structc(i) + 63 <= 4095 THEN mapsight(structc(i) + 63) = 1
IF structc(i) + 66 <= 4095 THEN mapsight(structc(i) + 66) = 1

IF structc(i) + 127 <= 4095 THEN mapsight(structc(i) + 127) = 1
IF structc(i) + 128 <= 4095 THEN mapsight(structc(i) + 128) = 1
IF structc(i) + 129 <= 4095 THEN mapsight(structc(i) + 129) = 1
IF structc(i) + 130 <= 4095 THEN mapsight(structc(i) + 130) = 1
END IF

y = INT(structc(i) / 64)
x = structc(i) - (y * 64)

 

x3 = ((x - mx) * 16)
y3 = ((y - my) * 16)
 
'IF unitf(i) > 0 THEN t = unitfac(i) + (unitf(i) * 8) ELSE t = unitfac(i)

t = structt(i)
'Put unit on map...
'but first calculate the x and y...
l = 0
l = INT(t / 9): t = t - (l * 9)

'Draw unit from layer to the game
IF structt2(i) = 0 THEN
DQBxPut 16, (t * 32) + t, (l * 32) + l, (t * 32) + 31 + t, (l * 32) + 31 + l, 1, (x - mx) * 16, (y - my) * 16
DQBxPut 3, 5, 86, 9, 92, 1, (x - mx) * 16, (y - my) * 16
END IF

IF structt2(i) <> 0 THEN
IF mapsight(structc(i)) <> 0 THEN
DQBxPut 16, (t * 32) + t, (l * 32) + l, (t * 32) + 15 + t, (l * 32) + 15 + l, 1, (x - mx) * 16, (y - my) * 16
DQBxPut 3, 0, 85, 3, 92, 1, (x - mx) * 16, (y - my) * 16
END IF
IF mapsight(structc(i) + 1) <> 0 THEN
DQBxPut 16, (t * 32) + t + 16, (l * 32) + l, (t * 32) + 31 + t, (l * 32) + 15 + l, 1, (x - mx) * 16 + 16, (y - my) * 16
END IF
IF mapsight(structc(i) + 64) <> 0 THEN
DQBxPut 16, (t * 32) + t, (l * 32) + l + 16, (t * 32) + 15 + t, (l * 32) + 31 + l, 1, (x - mx) * 16, (y - my) * 16 + 16
END IF
IF mapsight(structc(i) + 65) <> 0 THEN
DQBxPut 16, (t * 32) + t + 16, (l * 32) + l + 16, (t * 32) + 31 + t, (l * 32) + 31 + l, 1, (x - mx) * 16 + 16, (y - my) * 16 + 16
END IF

END IF

IF structa(i) = 1 THEN
IF mapsight(structc(i)) <> 0 THEN DQBxPut 3, 217, 188, 225, 199, 1, (x - mx) * 16, (y - my) * 16
IF credits > (4 + structt(i)) AND structt2(i) = 0 AND structp(i) < 100 THEN structc2(i) = structc2(i) + 1
IF structc2(i) > 2 + (structt(i)) THEN structp(i) = structp(i) + 1: credits = credits - (4 + structt(i)): structc2(i) = 0: IF nosound = 0 THEN DQBplaySound 13, 3, 22050, 0
IF structt2(i) <> 0 THEN structc2(i) = structc2(i) - 1
IF structc2(i) < -2 - (structt(i)) THEN structp(i) = structp(i) + 1: structc2(i) = 0
IF structp(i) >= 100 THEN structa(i) = 0
END IF


IF checkstr <> 0 THEN
'Select a unit, NOT using the Multi-select box...
IF mousec = 0 AND mapsight(structc(i)) <> 0 AND x1 >= x3 AND x1 <= (x3 + 32) AND y1 >= y3 AND y1 <= (y3 + 32) THEN structs(i) = 1

IF mapsight(structc(i)) <> 0 AND x1 >= x3 AND x1 <= (x3 + 32) AND y1 >= y3 AND y1 <= (y3 + 32) AND structt2(i) = 0 AND mousec = 4 THEN structa(i) = 1: structs(i) = 1
IF mapsight(structc(i)) <> 0 AND x1 >= x3 AND x1 <= (x3 + 32) AND y1 >= y3 AND y1 <= (y3 + 32) AND structt2(i) = 0 AND mousec = 5 THEN structa(i) = 0: structs(i) = 1

IF mapsight(structc(i)) <> 0 AND x1 >= x3 AND x1 <= (x3 + 32) AND y1 >= y3 AND y1 <= (y3 + 32) AND structt2(i) = 0 AND mousec = 3 THEN
structd(i) = 0
'Sell
IF structt(i) = 0 THEN haveconst = haveconst - 1: credits = credits + 500
IF structt(i) = 1 THEN havewind = havewind - 1: power = power - 75: credits = credits + 250
IF structt(i) = 2 THEN haverefinery = haverefinery - 1: credits = credits + 300: power = power + 40: spice = spice - 500
IF structt(i) = 3 THEN havetent = havetent - 1: credits = credits + 150: power = power + 15
IF structt(i) = 4 THEN havewar = havewar - 1: credits = credits + 400: power = power + 70
IF structt(i) = 5 THEN haveradar = haveradar - 1: credits = credits + 250: power = power + 40
IF structt(i) = 6 THEN haverepair = haverepair - 1: credits = credits + 400: power = power + 70
IF structt(i) = 7 THEN credits = credits + 75: power = power + 15: spice = spice - 1000

'Geef soldaatjes op de cells, random, max 2 soldaten
IF INT(RND * 2) = 0 THEN addunit structt2(i), 5, structc(i), 0, 5
IF INT(RND * 2) = 0 THEN addunit structt2(i), 5, structc(i) + 64, 0, 5


mapstruct(structc(i)) = 0
mapstruct(structc(i) + 1) = 0
mapstruct(structc(i) + 64) = 0
mapstruct(structc(i) + 65) = 0
END IF

'Select units in multi-box
END IF


IF structs(i) <> 0 THEN
'Show selected box
DQBxPut 16, 0, 168, 31, 199, 1, (x - mx) * 16, (y - my) * 16
DQBxPut 16, 0, 164, INT(structp(i) * .32), 165, 1, (x - mx) * 16, (y - my) * 16 - 3
END IF




'Draw structure on the minimap
'Same here:
'170 = Harkonnen
'40 = Atreides
'201 = Ordos
IF structt2(i) = 0 THEN c = mycolor ELSE c = enemycolor
IF structs(i) <> 0 THEN c = 14

IF mapsight(structc(i)) <> 0 THEN DQBpset 15, 249 + x, 21 + y, c
IF mapsight(structc(i) + 1) <> 0 THEN DQBpset 15, 249 + x + 1, 21 + y, c
IF mapsight(structc(i) + 64) <> 0 THEN DQBpset 15, 249 + x, 21 + y + 1, c
IF mapsight(structc(i) + 65) <> 0 THEN DQBpset 15, 249 + x + 1, 21 + y + 1, c




'if a unit is beneath a repair pad then we repair it, when damaged
IF structt(i) = 6 THEN
id = 0: id2 = 0
IF mapunit(structc(i) + 128) > 0 THEN id = mapunit(structc(i) + 128)
IF mapunit(structc(i) + 129) > 0 THEN id2 = mapunit(structc(i) + 129)
IF id > 0 AND unitt(id) <> 5 AND unitt2(id) = structt2(i) AND unitp(id) < 100 AND credits > (4 + unitt(id)) THEN credits = credits - (4 + unitt(id)): unitp(id) = unitp(id) + 1: IF nosound = 0 THEN DQBplaySound 13, 3, 22050, 0
IF id2 > 0 AND unitt(id2) <> 5 AND unitt2(id2) = structt2(i) AND unitp(id2) < 100 AND credits > (4 + unitt(id2)) THEN credits = credits - (4 + unitt(id2)): unitp(id2) = unitp(id2) + 1: IF nosound = 0 THEN DQBplaySound 13, 3, 22050, 0
END IF

'END OF DEAD IF-END IF
END IF


IF structp(i) < 60 AND structt2(i) <> 0 THEN structa(i) = 1

NEXT i
checkstr = 0
END SUB

'NO MORE
SUB dropnuke (cll)
'will "drop"  a nuke on the specific spot.
'Very easy
'The CELL is the center of the explosion
y11 = INT(cll / 64)
x11 = cll - INT(y11 * 64)
x11 = x11 - 7
y11 = y11 - 7
x22 = x11 + 14
y22 = y11 + 14

IF x11 < 0 THEN x11 = 0
IF y11 < 0 THEN y11 = 0
IF y22 > 63 THEN y22 = 63
IF x22 > 63 THEN x22 = 63
DQBfadeTo 63, 63, 63


FOR cy = y11 TO y22
FOR cx = x11 TO x22
cll = cy * 64 + cx
id1 = mapunit(cll)
id2 = mapstruct(cll)

IF id1 > 0 THEN unitp(id1) = -1
IF id2 > 0 THEN structp(id2) = -1
 
gok = INT(RND * 3)
IF gok = 0 THEN
adddead 1, 0, cll, 0, 0
IF nosound = 0 THEN
datnr = 13 + INT(RND * 4)
IF DQBinUse(datnr) = FALSE THEN DQBplaySound 18 + INT(RND * 2), datnr, 22050, 0
END IF
END IF

NEXT cx
NEXT cy

END SUB

'NO MORE
SUB loadmap (map$)
FOR i = 0 TO 4095                       'Make a lot a sand, randomly!
maptile(i) = INT(RND * 5)
NEXT i
'Now open data, and retrieve info about changed maptiles
OPEN "DATA\MAPS\" + map$ + ".map" FOR INPUT AS #1
INPUT #1, mx, my
DO WHILE NOT EOF(1)
INPUT #1, nr, soort
IF nr < 0 THEN EXIT DO
maptile(nr) = soort
IF soort > 41 THEN mapstruct(nr) = -1
LOOP
DO WHILE NOT EOF(1)
INPUT #1, team, tpe, cll
IF team < 0 THEN EXIT DO
addbuilding team, tpe, cll
LOOP
DO WHILE NOT EOF(1)
INPUT #1, team, tpe, cll, movecell, actie
IF team < 0 THEN EXIT DO
addunit team, tpe, cll, movecell, actie
LOOP
DO WHILE NOT EOF(1)
INPUT #1, tid, tpe, cll, soort
IF tid < 0 THEN EXIT DO
IF tid = 0 THEN addbuilding 1, tpe, cll
IF tid > 0 THEN
IF soort <= 0 THEN soort = 1
IF tpe = 2 THEN foundothergoal = 1
IF tpe = 4 THEN foundothergoal = 2
addai tid, tpe, cll, soort
END IF

LOOP
INPUT #1, credits, techlevel
CLOSE #1

FOR i = 0 TO 4095                       'Draw now the map for map window
IF maptile(i) >= 5 THEN c = 123 ELSE c = 118
IF maptile(i) >= 25 AND maptile(i) < 28 THEN c = 238
IF maptile(i) > 41 THEN c = 159
yd = INT(i / 64): xd = i - (yd * 64)
DQBpset 2, 249 + xd, 21 + yd, c
DQBpset 20, 249 + xd, 21 + yd, 160
NEXT i

END SUB

'NO MORE
SUB moveunit (i)
'Nieuwe MOVE-CODE
y11 = INT(unitc(i) / 64)
x11 = unitc(i) - INT(y11 * 64)

y21 = INT(unitmc(i) / 64)
x21 = unitmc(i) - INT(y21 * 64)

omhoog = 0: omlaag = 0: links = 0: rechts = 0

IF x21 < x11 THEN links = -1
IF x21 > x11 THEN rechts = 1
IF y21 < y11 THEN omhoog = -64
IF y21 > y11 THEN omlaag = 64

volgendecell = ((((unitc(i) + links) + rechts) + omhoog) + omlaag)

'DO
'Deze loop gaat door totdat de volgendecell 0 is en dus geen unit is...

'Als de unit alleen naar LINKS moet gaan en er staat een unit dan
'controleer je BOVEN en ONDER de volgendecell, als deze posities
'ook bezet zijn dan controleer je of je naar beneden kunt of naarboven..

'Bezet,
'Voordat de check wordt uitgevoerd wordt er gecheckt of de obstakel nog
'moet bewegen, als dat niet het geval is, dan stoppen we de unit gewoon.
IF volgendecell < 0 THEN volgendecell = 0
IF volgendecell > 4095 THEN volgendecell = 4095
IF unitmc(i) < 0 THEN unitmc(i) = 0
IF unitmc(i) > 4095 THEN unitmc(i) = 4095

IF mapunit(volgendecell) <> 0 AND volgendecell = unitmc(i) THEN
id = mapunit(unitmc(i))
IF unitc(id) = unitmc(id) THEN unitmc(i) = unitc(i)
GOTO doei
END IF

IF unitmc(i) < 0 THEN unitmc(i) = 0
IF unitmc(i) > 4095 THEN unitmc(i) = 4095

'Als de movecell al bezet is dan kiest hij er een plek vlakbij dat vrij is
IF mapunit(unitmc(i)) <> 0 AND unitt(i) <> 2 THEN
'Not for harvesters, they must move to that specific point
IF unita(i) <> 4 THEN
la = INT(RND * 4)
IF la = 0 THEN unitmc(i) = unitmc(i) - INT(RND * 2)
IF la = 1 THEN unitmc(i) = unitmc(i) - INT(RND * 2) - (INT(RND * 3) * 64)
IF la = 2 THEN unitmc(i) = unitmc(i) + INT(RND * 2)
IF la = 3 THEN unitmc(i) = unitmc(i) + INT(RND * 2) + (INT(RND * 3) * 64)
END IF

IF unita(i) = 4 THEN
begin = unitc(i)
'First check if it is a unit or a structure to follow
id = 0
IF unitd(unitfi(i)) <> 0 THEN id = mapunit(unitmc(i)): einde = unitc(id)
IF structd(unitfi2(i)) <> 0 THEN id = mapstruct(unitmc(i)): einde = structc(id)
'IF unitd(unitfi(i)) <> 0 THEN id = unitfi(i): einde = unitc(id)
'IF structd(unitfi2(i)) <> 0 THEN id = unitfi2(i): einde = structc(id)

y11 = INT(begin / 64)                   'Y coordinaat BEGIN
x11 = begin - INT(y11 * 64)             'X coordinaat BEGIN
y22 = INT(einde / 64)                   'Y coordinaat EINDE
x22 = einde - INT(y22 * 64)             'X coordinaat EINDE


verschilx = x11 - x22
verschily = y11 - y22

la = 0
IF verschilx < -4 OR verschilx > 4 THEN la = 1
IF verschily < -4 OR verschily > 4 THEN la = 1

IF la = 0 THEN unita(i) = 3: EXIT SUB
END IF

END IF

 
'check gewoon welke kant hij dan heen kan gaan..
t = -1
t2 = -1
nogeenkeer:
t = t + 1
t2 = t2 + 1
IF volgendecell < 0 THEN volgendecell = 0

hoeftniet = 0
id = mapunit(volgendecell)
IF unitt(id) = 5 AND unitt2(id) <> unitt2(i) AND unitt(i) <= 2 THEN hoeftniet = 1


IF volgendecell < 0 THEN volgendecell = 0
IF volgendecell > 4095 THEN volgendecell = 4095


IF mapunit(volgendecell) <> 0 AND hoeftniet = 0 THEN
IF unitc(i) - 1 > 0 THEN IF volgendecell = unitc(i) - 1 AND mapunit(unitc(i) - 1) <> 0 THEN volgendecell = unitc(i) - 65
IF unitc(i) - 65 > 0 THEN IF volgendecell = unitc(i) - 65 AND mapunit(unitc(i) - 65) <> 0 THEN volgendecell = unitc(i) - 64
IF unitc(i) - 64 > 0 THEN IF volgendecell = unitc(i) - 64 AND mapunit(unitc(i) - 64) <> 0 THEN volgendecell = unitc(i) - 63
IF unitc(i) - 63 > 0 THEN IF volgendecell = unitc(i) - 63 AND mapunit(unitc(i) - 63) <> 0 THEN volgendecell = unitc(i) + 1
IF unitc(i) + 1 < 4095 THEN IF volgendecell = unitc(i) + 1 AND mapunit(unitc(i) + 1) <> 0 THEN volgendecell = unitc(i) + 65
IF unitc(i) + 65 < 4095 THEN IF volgendecell = unitc(i) + 65 AND mapunit(unitc(i) + 65) <> 0 THEN volgendecell = unitc(i) + 64
IF unitc(i) + 64 < 4095 THEN IF volgendecell = unitc(i) + 64 AND mapunit(unitc(i) + 64) <> 0 THEN volgendecell = unitc(i) + 63
IF unitc(i) + 63 < 4095 THEN IF volgendecell = unitc(i) + 63 AND mapunit(unitc(i) + 63) <> 0 THEN volgendecell = unitc(i) - 1
END IF

IF volgendecell < 0 THEN volgendecell = 0
IF volgendecell > 4095 THEN volgendecell = 4095

'Check structures
IF mapstruct(volgendecell) <> 0 THEN
IF unitc(i) - 1 > 0 THEN IF volgendecell = unitc(i) - 1 AND mapstruct(unitc(i) - 1) <> 0 THEN volgendecell = unitc(i) - 65
IF unitc(i) - 65 > 0 THEN IF volgendecell = unitc(i) - 65 AND mapstruct(unitc(i) - 65) <> 0 THEN volgendecell = unitc(i) - 64
IF unitc(i) - 64 > 0 THEN IF volgendecell = unitc(i) - 64 AND mapstruct(unitc(i) - 64) <> 0 THEN volgendecell = unitc(i) - 63
IF unitc(i) - 63 > 0 THEN IF volgendecell = unitc(i) - 63 AND mapstruct(unitc(i) - 63) <> 0 THEN volgendecell = unitc(i) + 1
IF unitc(i) + 1 < 4095 THEN IF volgendecell = unitc(i) + 1 AND mapstruct(unitc(i) + 1) <> 0 THEN volgendecell = unitc(i) + 65
IF unitc(i) + 65 < 4095 THEN IF volgendecell = unitc(i) + 65 AND mapstruct(unitc(i) + 65) <> 0 THEN volgendecell = unitc(i) + 64
IF unitc(i) + 64 < 4095 THEN IF volgendecell = unitc(i) + 64 AND mapstruct(unitc(i) + 64) <> 0 THEN volgendecell = unitc(i) + 63
IF unitc(i) + 63 < 4095 THEN IF volgendecell = unitc(i) + 63 AND mapstruct(unitc(i) + 63) <> 0 THEN volgendecell = unitc(i) - 1
END IF

IF volgendecell < 0 THEN volgendecell = 0
IF volgendecell > 4095 THEN volgendecell = 4095

IF mapstruct(volgendecell) = 0 THEN t2 = 1
IF mapunit(volgendecell) = 0 THEN t = 1

IF unitmc(i) < 0 THEN unitmc(i) = 0
IF unitmc(i) > 4095 THEN unitmc(i) = 4095
IF mapstruct(unitmc(i)) <> 0 AND unita(i) <> 4 THEN
la = INT(RND * 4)
IF la = 0 THEN unitmc(i) = unitmc(i) - INT(RND * 2)
IF la = 1 THEN unitmc(i) = unitmc(i) - INT(RND * 2) - (INT(RND * 3) * 64)
IF la = 2 THEN unitmc(i) = unitmc(i) + INT(RND * 2)
IF la = 3 THEN unitmc(i) = unitmc(i) + INT(RND * 2) + (INT(RND * 3) * 64)
END IF

IF t = 0 THEN GOTO nogeenkeer
IF t2 = 0 THEN GOTO nogeenkeer
IF mapunit(volgendecell) <> 0 AND hoeftniet = 0 THEN volgendecell = unitc(i): unitx(i) = 0: unity(i) = 0
doei:
 

'Nu de nieuwe X2,Y2 berekenen.
y21 = INT(volgendecell / 64)
x21 = volgendecell - INT(y21 * 64)
'dqbprint 1, "X," + STR$(unitc(i)), (x21 - mx) * 16, (y21 - my) * 16, white

'En opnieuw de volgende checks maken
links = 0: rechts = 0: omhoog = 0: omlaag = 0
IF x21 < x11 THEN links = 1
IF x21 > x11 THEN rechts = 1
IF y21 < y11 THEN omhoog = 1
IF y21 > y11 THEN omlaag = 1


checkunitturn omhoog, links, rechts, omlaag, to2
turnunit to2, i


'Crate code
'Check for any crates
IF maptile(volgendecell) = 41 THEN
maptile(volgendecell) = INT(RND * 5)

niksaan:
soortje = INT(RND * 4)
IF soortje = 0 THEN addunit unitt2(i), INT(RND * 6), volgendecell, volgendecell - 1, 0
IF soortje = 1 THEN credits = credits + 1000
IF soortje = 2 AND unitp(i) < 100 THEN unitp(i) = 100
IF soortje = 2 AND unitp(i) = 100 THEN GOTO niksaan
IF soortje = 3 THEN units2(i) = units2(i) + 1

END IF
 




'Checken voor de facing...
'***********************CHECK FACING CODE************************
'En nu de unit naar de gegeven locatie bewegen..

IF unitfac(i) = to2 THEN
IF (maptile(unitc(i)) >= 5 AND maptile(unitc(i)) < 25) OR (maptile(unitc(i)) >= 28 AND maptile(unitc(i)) <= 33) THEN extra = 1 ELSE extra = 0
IF links = 1 THEN unitx(i) = unitx(i) - (units2(i) + extra) - skipframe
IF rechts = 1 THEN unitx(i) = unitx(i) + (units2(i) + extra) + skipframe
IF omhoog = 1 THEN unity(i) = unity(i) - (units2(i) + extra) - skipframe
IF omlaag = 1 THEN unity(i) = unity(i) + (units2(i) + extra) + skipframe

b = 0
IF (maptile(unitc(i))) <= 3 THEN b = INT(RND * 2)

IF links = 0 AND unitx(i) < 0 THEN unitx(i) = unitx(i) + (1 + b) + skipframe
IF rechts = 0 AND unitx(i) > 0 THEN unitx(i) = unitx(i) - (1 + b) + skipframe
IF omhoog = 0 AND unity(i) < 0 THEN unity(i) = unity(i) + (1 + b) + skipframe
IF omlaag = 0 AND unity(i) > 0 THEN unity(i) = unity(i) - (1 + b) + skipframe

IF unitx(i) > 15 THEN mapunit(unitc(i)) = 0: unitc(i) = unitc(i) + 1: unitx(i) = 0
IF unitx(i) < -15 THEN mapunit(unitc(i)) = 0: unitc(i) = unitc(i) - 1: unitx(i) = 0
IF unity(i) > 15 THEN mapunit(unitc(i)) = 0: unitc(i) = unitc(i) + 64: unity(i) = 0
IF unity(i) < -15 THEN mapunit(unitc(i)) = 0: unitc(i) = unitc(i) - 64: unity(i) = 0

'Now check if we have moved a tank over infantry
id = mapunit(unitc(i))
IF id > 0 THEN
IF unitt2(id) <> unitt2(i) AND unitt(i) <= 2 AND unitt(id) = 5 THEN
unitd(id) = 0: adddead 0, 2, unitc(i), unitx(i), unity(i)
IF unitt2(id) = 0 THEN huis$ = myhousename$ ELSE huis$ = enemyhousename$
message$ = huis$ + " INFANTRY SQUISED"
messagetijd = 25
IF nosound = 0 THEN DQBplaySound 30, 10, 22050, 0
END IF
END IF

END IF

END SUB

'NO MORE
SUB playmessage
IF messagenr <> 0 THEN
'Now we dont play ATREIDES UNIT DESTROYED, BUT UNIT DESTROYED!
'ATREIDES UNIT DESTROYED
IF messagenr = 1 THEN nr1 = 3: nr2 = 4: nr3 = 0: spelennr = 1: messagenr = 0
'HARKONNEN UNIT DESTROYED
IF messagenr = 2 THEN nr1 = 3: nr2 = 4: nr3 = 0: spelennr = 1: messagenr = 0
'ATREIDES STRUCTURE DESTROYED
IF messagenr = 3 THEN nr1 = 1: nr2 = 9: nr3 = 4: spelennr = 1: messagenr = 0
'HARKONNEN STRUCTURE DESTROYED
IF messagenr = 4 THEN nr1 = 2: nr2 = 9: nr3 = 4: spelennr = 1: messagenr = 0
'RADAR ACTIVATED
IF messagenr = 5 THEN nr1 = 8: nr2 = 6: nr3 = 0: spelennr = 1: messagenr = 0
'RADAR DEACTIVATED
IF messagenr = 6 THEN nr1 = 8: nr2 = 7: nr3 = 0: spelennr = 1: messagenr = 0
END IF

IF DQBinUse(1) = FALSE AND spelennr > 0 THEN
IF spelennr = 1 THEN nummertje = nr1
IF spelennr = 2 THEN nummertje = nr2
IF spelennr = 3 THEN nummertje = nr3
spelennr = spelennr + 1
IF nummertje = 0 THEN spelennr = 0: EXIT SUB
IF nosound = 0 THEN DQBplaySound nummertje, 1, 22050, 0
END IF

END SUB

'NO MORE
SUB playmusic
again:
IF DQBinUse(11) = FALSE THEN
        Offset& = Offset& + 64000
        c% = DQBloadRawSound%(31, "DATA\MUSIC\BUILDING.WAV", 45 + Offset&, 64000)
        IF c% = 1 THEN dontplay2 = 1    'Could not find data file, dont play music
        IF c% > 1 THEN Offset& = -64000: GOTO again
        DQBplaySound 31, 11, 22050, ONCE
END IF

END SUB

'NO MORE
SUB resetall
musthavecredits = 0
foundothergoal = 0
resetten = 0
friendfound = 0
enemyfound = 0
haverepair = 0
havewind = 0
haveradar = 0
haverefinery = 0
havewar = 0
havetent = 0
haveconst = 0

aihaveradar = 0
aihaverepair = 0
aihavetent = 0
aihavewar = 0
aihaveconst = 0

minx = 0
miny = 0
maxx = 0
maxy = 0

magchecken = 300
bouwdie1 = -1
bouwdie2 = -1
prijs1 = -1
prijs2 = -1

credits = 0
die1 = 0
die2 = 0

mx = 0
my = 0

FOR k = 1 TO 100
structd(k) = 0
unitd(k) = 0
units(k) = 0
unitg(k) = 0
deadd(k) = 0
bulld(k) = 0
IF k < 31 THEN aidead(k) = 0
NEXT k

FOR k = 0 TO 4095
mapsight(k) = 0
maptile(k) = 0
mapunit(k) = 0
mapstruct(k) = 0
yd = INT(k / 64): xd = k - (yd * 64)
DQBpset 2, 249 + xd, 21 + yd, 0
DQBpset 20, 249 + xd, 21 + yd, 160
NEXT k


DQBclearLayer 15

harvested = 0
mousec = 0
kills = 0
losts = 0
minx = 0
maxx = 0
miny = 0
maxy = 0
power = 5
spice = 1500
readbriefing = 0
tijd = 0
nu = 0
END SUB

'NO MORE
SUB Sidebarcode
'Checks on which button is pressed
FOR b = 0 TO 3          'ICONS VERTICAL
FOR c = 0 TO 1          'HORIZONTAL
x11 = 264 + (c * 20) + c * 4
x22 = x11 + 20
y11 = 91 + ((b) * 20) + (b)
y22 = y11 + 20
IF c = 0 THEN t = bar1 + b ELSE t = bar2 + b + (c * 15)

'Place icon in icon bar
l = 0
l = INT(t / 15): t = t - (l * 15)

DQBxPut 17, (t * 20) + t, (l * 20) + l, (t * 20) + t + 19, 19 + (l * 20) + l, 1, x11 + 1 + (c * 2), y11 + 2 + (b * 2)



'When something is building then you cannot see the specific buildings..
'only an another icon..
IF (c = 0 AND (b + bar1) <> bouwdie1 AND bouwdie1 > -1) OR (c = 1 AND (b + bar2) <> bouwdie2 AND bouwdie2 > -1) THEN DQBxPut 17, 252, 42, 271, 61, 1, x11 + 1 + (c * 2), y11 + 2 + (b * 2)
IF c = 0 THEN
'Check for structures who cannot be build yet...
soort = (b + bar1)
teken = 0
IF haveconst <= 0 THEN teken = 1

IF techlevel = 0 THEN
'TECHLEVEL 0, MAY NOT BUILD
IF soort = 3 THEN teken = 1     'WARFACTORY
IF soort = 5 THEN teken = 1     'REPAIR PAD
IF soort = 4 THEN teken = 1     'RADAR
END IF

IF techlevel > 0 AND techlevel < 5 THEN
'TECHLEVEL 0, MAY NOT BUILD
IF soort = 5 THEN teken = 1     'REPAIR PAD
END IF

IF soort >= 1 AND havewind = 0 THEN teken = 1
IF soort >= 2 AND haverefinery = 0 THEN teken = 1
IF soort = 3 AND (haveradar = 0 OR havetent = 0) THEN teken = 1
IF teken = 1 THEN DQBxPut 17, 252, 42, 271, 61, 1, x11 + 1 + (c * 2), y11 + 2 + (b * 2)
END IF

IF c = 1 THEN
'Check for UNITS who cannot be build yet...
soort = (b + bar2)
teken = 0

IF techlevel = 1 THEN
'ON TECHLEVEL 1, YOU CAN'T BUILD FROM A WARFACTORY
IF soort = 0 THEN teken = 1             'LIGHT TANK
IF soort = 1 THEN teken = 1             'HEAVY TANK
IF soort = 2 THEN teken = 1             'HARVESTER
IF soort = 3 THEN teken = 1             'GRENADE TANK
END IF

IF techlevel = 2 THEN
'ON TECHLEVEL 2, YOU CAN'T BUILD FROM A WARFACTORY
IF soort = 1 THEN teken = 1             'HEAVY TANK
IF soort = 2 THEN teken = 1             'HARVESTER
IF soort = 3 THEN teken = 1             'GRENADE TANK
END IF

IF techlevel = 3 THEN
'ON TECHLEVEL 3, YOU CAN'T BUILD FROM A WARFACTORY
IF soort = 1 THEN teken = 1             'HEAVY TANK
IF soort = 3 THEN teken = 1             'GRENADE TANK
END IF

IF techlevel = 4 THEN
'ON TECHLEVEL 4, YOU CAN'T BUILD FROM A WARFACTORY
IF soort = 3 THEN teken = 1             'GRENADE TANK
END IF

IF havewar = 0 AND soort < 5 THEN teken = 1
IF havetent = 0 AND soort = 5 THEN teken = 1
IF soort = 3 AND haverepair = 0 THEN teken = 1
IF teken = 1 THEN DQBxPut 17, 252, 42, 271, 61, 1, x11 + 1 + (c * 2), y11 + 2 + (b * 2)
END IF

IF (ready1 <> 0 AND c = 0 AND (b + bar1) <> die1) THEN DQBxPut 17, 252, 42, 271, 61, 1, x11 + 1 + (c * 2), y11 + 2 + (b * 2)

IF (ready1 = 1 AND c = 0 AND (b + bar1) = die1) THEN DQBxPut 17, 0, 70, 18, 75, 1, x11 + 1 + (c * 2), y11 + 2 + (b * 2)



'Procent gebouwd
'To calculate the time to scroll we must know what the price is
IF bouwdie1 <> -1 AND credits > 0 THEN
tot1 = INT(prijs1 / 10)
sk = skipframe
IF sk <= 0 THEN sk = 1
pro1c = pro1c + 1: credits = credits - (1 * sk): IF nosound = 0 THEN DQBplaySound 13, 3, 22050, 0
IF pro1 > 10 THEN
pro1 = 0: die1 = bouwdie1: bouwdie1 = -1: ready1 = 1
IF nosound = 0 THEN DQBplaySound 5, 1, 22050, 0
END IF
IF pro1c > (tot1 / sk) THEN pro1c = 0: pro1 = pro1 + 1
END IF

IF bouwdie2 <> -1 AND credits > 0 THEN
tot2 = INT(prijs2 / 10)
IF bouwdie2 < 5 THEN
pro2c = pro2c + 1: credits = credits - (1 * (havewar + skipframe)): IF nosound = 0 THEN DQBplaySound 13, 3, 22050, 0
IF pro2 > 10 THEN
pro2 = 0: die2 = bouwdie2: bouwdie2 = -1: ready2 = 1
IF nosound = 0 THEN DQBplaySound 5, 1, 22050, 0
END IF
IF pro2c > (tot2 / (havewar + skipframe)) THEN pro2c = 0: pro2 = pro2 + 1
END IF

IF bouwdie2 = 5 THEN
pro2c = pro2c + 1: credits = credits - (1 * havetent): IF nosound = 0 THEN DQBplaySound 13, 3, 22050, 0
IF pro2 > 10 THEN pro2 = 0: die2 = bouwdie2: bouwdie2 = -1: ready2 = 1
IF pro2c > (tot2 / havetent) THEN pro2c = 0: pro2 = pro2 + 1
END IF
END IF

IF c = 0 THEN t = pro1 ELSE t = pro2

'Laat de bouwschijf zien op de BUILDING bar
IF (b + bar1) = bouwdie1 AND c = 0 THEN DQBxPut 17, (t * 20) + t, 42, (t * 20) + t + 19, 61, 1, x11 + 1 + (c * 2), y11 + 2 + (b * 2)
'Laat de bouwschijf zien op de UNIT bar
IF (b + bar2) = bouwdie2 AND c = 1 THEN DQBxPut 17, (t * 20) + t, 42, (t * 20) + t + 19, 61, 1, x11 + 1 + (c * 2), y11 + 2 + (b * 2)

IF DQBmouseX >= x11 AND DQBmouseX <= x22 AND DQBmouseY >= (y11 + (b * 2)) AND DQBmouseY <= (y22 + (b * 2)) THEN
'BUILDING SIDE
IF (b + bar1) = 0 AND c = 0 THEN txt$ = "Windtrap $350": p1 = 350
IF (b + bar1) = 1 AND c = 0 THEN txt$ = "Refinery $600": p1 = 600
IF (b + bar1) = 2 AND c = 0 THEN txt$ = "Barracks $300": p1 = 300
IF (b + bar1) = 3 AND c = 0 THEN txt$ = "War Factory $800": p1 = 800
IF (b + bar1) = 4 AND c = 0 THEN txt$ = "Radar    $500": p1 = 500
IF (b + bar1) = 5 AND c = 0 THEN txt$ = "Repair Pad  $800": p1 = 800
IF (b + bar1) = 6 AND c = 0 THEN txt$ = "Silo's   $300": p1 = 300

'UNITS SIDE
IF (b + bar2) = 0 AND c = 1 THEN txt$ = "Light Tank $550": p2 = 550
IF (b + bar2) = 1 AND c = 1 THEN txt$ = "Heavy Tank $800": p2 = 800
IF (b + bar2) = 2 AND c = 1 THEN txt$ = "Harvester  $700": p2 = 700
IF (b + bar2) = 3 AND c = 1 THEN txt$ = "Grenade Tank $1000": p2 = 1000
IF (b + bar2) = 4 AND c = 1 THEN txt$ = "Raider Trike $250": p2 = 250
IF (b + bar2) = 5 AND c = 1 THEN txt$ = "Infantry $100": p2 = 100

txt$ = UCASE$(txt$)
tada = LEN(txt$)
xb = tada * 8

IF DQBmouseLB = -1 THEN
'Left button pressed, build it... when not already building
IF c = 0 AND bouwdie1 = -1 AND ready1 <> 1 THEN
soort = (b + bar1)

IF techlevel = 0 THEN
'TECHLEVEL 0, MAY NOT BUILD
IF soort = 3 THEN GOTO mn2
IF soort = 5 THEN GOTO mn2
IF soort = 4 THEN GOTO mn2
END IF

IF techlevel > 0 AND techlevel < 5 THEN
'TECHLEVEL 0, MAY NOT BUILD
IF soort = 5 THEN GOTO mn2
END IF

IF haveconst <= 0 THEN GOTO mn2
IF havewind = 0 AND soort >= 1 THEN GOTO mn2
IF haverefinery = 0 AND soort >= 2 THEN GOTO mn2
IF (haveradar = 0 OR havetent = 0) AND soort = 3 THEN GOTO mn2
bouwdie1 = (b + bar1): prijs1 = p1
mn2:
END IF

IF c = 1 AND bouwdie2 = -1 AND ready2 <> 1 THEN
soort = (b + bar2)

IF techlevel = 1 THEN
'ON TECHLEVEL 1, YOU CAN'T BUILD FROM A WARFACTORY
IF soort = 0 THEN GOTO mon2
IF soort = 1 THEN GOTO mon2
IF soort = 2 THEN GOTO mon2
IF soort = 3 THEN GOTO mon2
END IF

IF techlevel = 2 THEN
'ON TECHLEVEL 1, YOU CAN'T BUILD FROM A WARFACTORY
IF soort = 1 THEN GOTO mon2
IF soort = 2 THEN GOTO mon2
IF soort = 3 THEN GOTO mon2
END IF

IF techlevel = 3 THEN
'ON TECHLEVEL 1, YOU CAN'T BUILD FROM A WARFACTORY
IF soort = 1 THEN GOTO mon2
IF soort = 3 THEN GOTO mon2
END IF

IF techlevel = 4 THEN
'ON TECHLEVEL 1, YOU CAN'T BUILD FROM A WARFACTORY
IF soort = 3 THEN GOTO mon2
END IF



IF soort < 5 AND havewar <= 0 THEN GOTO mon2
IF soort = 5 AND havetent <= 0 THEN GOTO mon2
IF haverepair = 0 AND soort = 3 THEN GOTO mon2
bouwdie2 = (b + bar2): prijs2 = p2
mon2:
END IF

'If pressed and when it is ready to place then we should get a place check
IF c = 0 AND bouwdie1 = -1 AND ready1 = 1 THEN
IF die1 = 0 THEN hoogte = 1: breedte = 1
IF die1 = 1 THEN hoogte = 2: breedte = 1
IF die1 = 2 THEN hoogte = 2: breedte = 1
IF die1 = 3 THEN hoogte = 2: breedte = 1
IF die1 = 4 THEN hoogte = 1: breedte = 1
IF die1 = 5 THEN hoogte = 2: breedte = 1
IF die1 = 6 THEN hoogte = 1: breedte = 1
checkplace = 1
END IF

IF c = 1 AND bouwdie2 = -1 AND ready2 = 1 THEN la = 0

END IF



END IF

IF c = 1 AND bouwdie2 = -1 AND ready2 = 1 THEN
addunit 0, die2, 0, 0, 0
ready2 = 0
END IF

NEXT c

IF txt$ <> "" THEN DQBprint 1, txt$, DQBmouseX - xb, DQBmouseY, white: mouse = 0
 
NEXT b

'Down button in BUILDING bar
IF DQBmouseLB = -1 AND DQBmouseX >= 275 AND DQBmouseX <= 287 AND DQBmouseY >= 192 AND DQBmouseY <= 199 AND bar1t < 5 THEN bar1t = bar1t + 1
IF DQBmouseLB = -1 AND DQBmouseX >= 275 AND DQBmouseX <= 287 AND DQBmouseY >= 192 AND DQBmouseY <= 199 AND bar1t >= 5 THEN bar1 = bar1 + 1: bar1t = 0
'Up button in BUILDING bar
IF DQBmouseLB = -1 AND DQBmouseX >= 263 AND DQBmouseX <= 274 AND DQBmouseY >= 192 AND DQBmouseY <= 199 AND bar1t < 5 THEN bar1t = bar1t + 1
IF DQBmouseLB = -1 AND DQBmouseX >= 263 AND DQBmouseX <= 274 AND DQBmouseY >= 192 AND DQBmouseY <= 199 AND bar1t >= 5 THEN bar1 = bar1 - 1: bar1t = 0
IF bar1 < 0 THEN bar1 = 0
IF bar1 > 3 THEN bar1 = 3

'Down button in UNITS bar
IF DQBmouseLB = -1 AND DQBmouseX >= 301 AND DQBmouseX <= 311 AND DQBmouseY >= 192 AND DQBmouseY <= 199 AND bar2t < 5 THEN bar2t = bar2t + 1
IF DQBmouseLB = -1 AND DQBmouseX >= 301 AND DQBmouseX <= 311 AND DQBmouseY >= 192 AND DQBmouseY <= 199 AND bar2t >= 5 THEN bar2 = bar2 + 1: bar2t = 0
'Up button in BUILDING bar
IF DQBmouseLB = -1 AND DQBmouseX >= 290 AND DQBmouseX <= 300 AND DQBmouseY >= 192 AND DQBmouseY <= 199 AND bar2t < 5 THEN bar2t = bar2t + 1
IF DQBmouseLB = -1 AND DQBmouseX >= 290 AND DQBmouseX <= 300 AND DQBmouseY >= 192 AND DQBmouseY <= 199 AND bar2t >= 5 THEN bar2 = bar2 - 1: bar2t = 0
IF bar2 < 0 THEN bar2 = 0
IF bar2 > 2 THEN bar2 = 2

 
END SUB

'NO MORE
SUB turnunit (to2, i)
'Will turn a unit to facing nr...
unitc2(i) = unitc2(i) + 1
IF unitc2(i) > 2 AND unitfac(i) <> to2 THEN
unitc2(i) = 0
'Simple, when the current facing is lower than the facing it should be
'then we increase the facing...
erbij = 0

linksom = (unitfac(i) + 8) - to2
IF linksom > 7 THEN linksom = linksom - 8
rechtsom = ABS(linksom - 8)
IF linksom = rechtsom AND INT(RND * 2) = 0 THEN erbij = 1
IF linksom = rechtsom AND INT(RND * 2) = 1 THEN erbij = -1
IF linksom > rechtsom THEN erbij = 1
IF linksom < rechtsom THEN erbij = -1

unitfac(i) = unitfac(i) + erbij
IF unitfac(i) < 0 THEN unitfac(i) = unitfac(i) + 8
IF unitfac(i) > 7 THEN unitfac(i) = unitfac(i) - 8
END IF
END SUB

