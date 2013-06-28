'****************************************************************
'*****  ARRAKIS MAIN MENU FILE, AND RMG INCLUDED AS S12.BAS *****
'****************************************************************
'COPYRIGHTED BY STEFAN HENDRIKS
'****************************************************************
'*****  ARRAKIS MAIN MENU FILE, AND RMG INCLUDED AS S12.BAS *****
'****************************************************************

DECLARE SUB setatreidesfont ()
DECLARE SUB setharkonnenfont ()
DECLARE SUB setordosfont ()
DECLARE SUB setnormalfont ()
DECLARE SUB center (y%, tekst$, kleur%)
DECLARE SUB setselectedfont ()
DECLARE FUNCTION checkcenter% (y%, txt$)
DECLARE SUB menucode ()
DECLARE SUB processhouses ()
DECLARE SUB getskirmaps ()
DECLARE SUB makespot (cll%, duration%, tp%)
DECLARE SUB fillgaps (sort%)
DECLARE SUB checkais ()
DECLARE SUB clearspice ()
DECLARE SUB makeborders ()
DECLARE SUB writefile ()
DECLARE FUNCTION checkspot% (cl%)
DEFINT A-Z
'$INCLUDE: 'directqb.bi'
COMMON SHARED playinghouse, menuitem, speed, penemyhouse, maxskirmaps, mlist, skirmish
COMMON SHARED playmap$, sizerock, sizespice, amountrock, amountspice
COMMON SHARED dif, keer, cl, afstand, startcell1, startcell2, mx, my, filename$
RANDOMIZE TIMER
DIM SHARED posities(50)
DIM SHARED map(4095)
DIM SHARED mapstr(4095)
t = DQBinit(2, 0)
IF t <> 0 THEN DQBclose: END
DIM SHARED mapfile$(200)
'penemyhouse = INT(RND * 3)
OPEN "DATA\ARRAKIS.INI" FOR INPUT AS #1
INPUT #1, hss$                  'Actually Not important
INPUT #1, hss2$                 'Actually Not important
INPUT #1, enemycolor            'Actually Not important
INPUT #1, mycolor               'Actually Not important
INPUT #1, skipframes            'Importans
INPUT #1, penemyhouse           'Important
INPUT #1, playinghouse          'Important
INPUT #1, amountspice           'Important
INPUT #1, amountrock           'Important
INPUT #1, sizespice           'Important
INPUT #1, sizerock           'Important
CLOSE #1
IF skipframes = 0 THEN speed = 0
IF skipframes = 1 THEN speed = 1
IF skipframes = 2 THEN speed = 2
IF skipframes = 4 THEN speed = 3
IF skipframes = 8 THEN speed = 4
 

DIM SHARED textu(50)
DIM SHARED Pal AS STRING * 786
getskirmaps
DQBinitVGA
c% = DQBloadLayer(2, "DATA\MENU\MEN.PCX", Pal)
DQBsetPal Pal

DQBsetTextStyle TEXTURED
c% = DQBloadFont("DATA\FONT\ARRAKIS.FNT")

DO
k$ = INKEY$
DQBclearLayer 1
DQBcopyLayer 2, 1

menucode                ' Here the menu code

DQBxPut 2, 1, 45, 8, 58, 1, DQBmouseX, DQBmouseY

DQBcopyLayer 1, 0
LOOP


 
DQBclose
END

REM $DYNAMIC
SUB center (y, tekst$, kleur)
tekst$ = UCASE$(tekst$)
l = LEN(tekst$)
l = l * 8 'Real size in pixels
xplaats = 320 / 2 - (l / 2)
y = y * 8
DQBprint 1, tekst$, xplaats, y, kleur
END SUB

SUB checkais
'This sub checks on startcell1 and startcell2 if there is enough room
'for building, it will automaticly fill up sand.
basetype = INT(RND * 2)         '2 base types

keer1 = 0
weer:
IF keer1 = 0 THEN c = startcell1
IF keer1 = 1 THEN c = startcell2
IF keer1 > 1 THEN EXIT SUB
y11 = INT(c / 64)
x11 = c - INT(y11 * 64)

map(c) = 5
IF c + 1 < 64 THEN map(c + 1) = 5
IF c + 64 < 64 THEN map(c + 64) = 5
IF c + 65 < 64 THEN map(c + 65) = 5

x1 = x11 - 6
x2 = x11 + 7
y1 = y11 - 6
y2 = y11 + 7


IF x1 < 0 THEN x1 = 0
IF y1 < 0 THEN y1 = 0
IF x2 > 63 THEN x2 = 63
IF y2 > 63 THEN y2 = 63

IF keer1 = 0 THEN
cell = c
my = INT(cell / 64)
mx = cell - INT(my * 64)
my = my - 5
mx = mx - 7
IF mx > 48 THEN mx = 48
IF mx < 0 THEN mx = 0
IF my > 50 THEN my = 50
IF my < 0 THEN my = 0
END IF

nogeens3:
ja = 0: nee = 0
FOR cx = x1 TO x2
FOR cy = y1 TO y2
c = cy * 64 + cx
IF extra > 10 THEN extra = 0: GOTO neenietnogeens
IF map(c) <> 5 THEN
IF extra > 0 THEN makespot c, (40 * extra), 5
END IF
IF map(c) = 5 THEN ja = ja + 1
IF map(c) <> 5 THEN nee = nee + 1
NEXT cy
NEXT cx
LOCATE 10, 1: 'PRINT proc
proc = INT((ja / 169) * 100)
IF proc < 60 THEN extra = extra + 1: GOTO nogeens3

neenietnogeens:

'Ok if keer = 1 then place ai structures variables
IF keer1 = 1 THEN
'Ok add ai
cell = startcell2
OPEN "DATA\MAPS\ADDAI.NON" FOR OUTPUT AS #1
PRINT #1, "-1,-1"
PRINT #1, "0 , -1 ,"; startcell1
PRINT #1, "1 , -1 ,"; startcell2
PRINT #1, "-1 , -1 , -1"
'Starting units
c1 = startcell1 - 2
c2 = startcell1 + 3
IF c1 < 0 THEN c1 = 0
IF c2 > 3967 THEN c1 = 3967

PRINT #1, "0 , 4 ,"; c1; ","; c1; ",0"
PRINT #1, "0 , 4 ,"; c2; ","; c2; ",0"
PRINT #1, "-1 , -1 , -1 , -1 , -1"
'Now for AI to add structures
'First a windtrap

addbuilding:
building = building + 1
t = 0
GOTO zoekdir
nogeens1:
IF checkspot(cell) = 0 THEN
c = cell
LOCATE 11, 1: 'PRINT building

'Base type = 1
IF basetype = 0 THEN
IF building = 1 THEN PRINT #1, "4 , 0,"; c; ", 1"
IF building = 2 THEN PRINT #1, "12 , 1,"; c; ", 1"
IF building = 3 THEN PRINT #1, "22 , 2,"; c; ", 1"
IF building = 4 THEN PRINT #1, "30 , 0,"; c; ", 1"
IF building = 5 THEN PRINT #1, "35 , 0,"; c; ", 1"
IF building = 6 THEN PRINT #1, "42 , 4,"; c; ", 1"
IF building = 7 THEN PRINT #1, "52 , 3,"; c; ", 1"
IF building = 8 THEN PRINT #1, "62 , 6,"; c; ", 1"
IF building = 9 THEN PRINT #1, "82 , 5,"; c; ", 1"
IF building = 3 OR building = 2 OR building = 7 OR building = 8 THEN
IF c + 128 <= 4095 THEN mapstr(c + 128) = 1
IF c + 129 <= 4095 THEN mapstr(c + 129) = 1
END IF
END IF

'Other base type
IF basetype = 1 THEN
IF building = 1 THEN PRINT #1, "4 , 0,"; c; ", 1"
IF building = 2 THEN PRINT #1, "12 , 1,"; c; ", 1"
IF building = 3 THEN PRINT #1, "22 , 0,"; c; ", 1"
IF building = 4 THEN PRINT #1, "30 , 2,"; c; ", 1"
IF building = 5 THEN PRINT #1, "35 , 6,"; c; ", 1"
IF building = 6 THEN PRINT #1, "42 , 4,"; c; ", 1"
IF building = 7 THEN PRINT #1, "52 , 3,"; c; ", 1"
IF building = 8 THEN PRINT #1, "62 , 5,"; c; ", 1"
IF building = 9 THEN PRINT #1, "82 , 6,"; c; ", 1"
IF building = 2 OR building = 4 OR building = 7 OR building = 8 THEN
IF c + 128 <= 4095 THEN mapstr(c + 128) = 1
IF c + 129 <= 4095 THEN mapstr(c + 129) = 1
END IF
END IF

mapstr(c) = 1
mapstr(c + 1) = 1
mapstr(c + 64) = 1
mapstr(c + 65) = 1


ELSE
zoekdir:
a = INT(RND * 50)
IF a < 25 THEN cell = cell - (INT(RND * 3) * 64) - INT(RND * 6)
IF a >= 25 THEN cell = cell + (INT(RND * 3) * 64) + INT(RND * 6)
IF cell > 3967 THEN cell = 3967
IF cell < 0 THEN cell = 0
GOTO nogeens1
END IF

IF building < 10 THEN GOTO addbuilding
PRINT #1, c1; " , 3,"; startcell1; ", 2"
rein = INT(RND * 5)
t = INT(RND * 30)
IF rein > 0 THEN
FOR r = 1 TO rein
PRINT #1, t; " , 5,"; startcell1; ", 2"
NEXT r
PRINT #1, "1 , 1,"; (t - 1); ", 2"
END IF

PRINT #1, "-1, -1, -1, -1"
PRINT #1, "3500 , 6"
CLOSE #1


END IF







keer1 = keer1 + 1
GOTO weer




END SUB

FUNCTION checkcenter (y, txt$)
y1 = (y * 8)
y2 = y1 + 7
tekst$ = UCASE$(tekst$)
l = LEN(txt$)
l = l * 8 'Real size in pixels
x1 = 320 / 2 - (l / 2)
x2 = x1 + l
IF DQBmouseX >= x1 AND DQBmouseX <= x2 AND DQBmouseY >= y1 AND DQBmouseY <= y2 THEN checkcenter = -1

END FUNCTION

FUNCTION checkspot (cl)
checkspot = 0
my1 = INT(cl / 64)
mx1 = cl - INT(my1 * 64)
my2 = INT(startcell2 / 64)
mx2 = startcell2 - INT(my2 * 64)
IF cl > 4095 THEN checkspot = 1: cl = 4095
IF cl < 0 THEN checkspot = 1: cl = 0

IF mx1 > mx2 THEN vx = mx1 - mx2
IF mx2 > mx1 THEN vx = mx2 - mx1
IF my1 > my2 THEN vy = my1 - my2
IF my2 > my1 THEN vy = my2 - my1

IF vx > 6 THEN checkspot = 1
IF vy > 6 THEN checkspot = 1

IF mx1 + 1 >= 62 THEN checkspot = 1
IF my1 + 1 >= 62 THEN checkspot = 1

IF mapstr(cl) <> 0 THEN checkspot = 1
IF mapstr(cl + 1) <> 0 THEN checkspot = 1
IF mapstr(cl + 64) <> 0 THEN checkspot = 1
IF mapstr(cl + 65) <> 0 THEN checkspot = 1

END FUNCTION

SUB clearmap
FOR i = 0 TO 4095
map(i) = 0
mapstr(i) = 0
NEXT i
END SUB

SUB clearspice
'no spice attached to rock
FOR i = 0 TO 4095
IF map(i) = 5 THEN
links = i - 1
rechts = i + 1
boven = i - 64
onder = i + 64

IF links < 0 THEN links = 0
IF rechts < 0 THEN rechts = 0
IF boven < 0 THEN boven = 0
IF onder < 0 THEN onder = 0

IF links > 4095 THEN links = 4095
IF rechts > 4095 THEN rechts = 4095
IF boven > 4095 THEN boven = 4095
IF onder > 4095 THEN onder = 4095

tekenlinks = map(links)
tekenrechts = map(rechts)
tekenboven = map(boven)
tekenonder = map(onder)

IF tekenlinks = 25 THEN map(links) = 0
IF tekenrechts = 25 THEN map(rechts) = 0
IF tekenboven = 25 THEN map(boven) = 0
IF tekenonder = 25 THEN map(onder) = 0


END IF

NEXT i


END SUB

SUB drawmap
FOR i = 0 TO 4095
begin = i
y11 = INT(begin / 64)
x11 = begin - INT(y11 * 64)
c = 25          'sand
IF map(i) >= 5 THEN c = 22
IF map(i) >= 25 AND map(i) <= 27 THEN c = 29
IF i = startcell1 THEN c = 15
IF i = startcell2 THEN c = 14
PSET (x11, 100 + y11), c
NEXT i
LINE (mx, 100 + my)-(mx + 15, 100 + my + 13), 15, B
END SUB

SUB fillgaps (sort)
'Fill gaps
'1 = ROCK
'2 = SPICE

IF sort = 1 THEN
FOR i = 0 TO 4095
IF map(i) = 0 THEN
links = i - 1
rechts = i + 1
boven = i - 64
onder = i + 64

IF links < 0 THEN links = 0
IF rechts < 0 THEN rechts = 0
IF boven < 0 THEN boven = 0
IF onder < 0 THEN onder = 0

IF links > 4095 THEN links = 4095
IF rechts > 4095 THEN rechts = 4095
IF boven > 4095 THEN boven = 4095
IF onder > 4095 THEN onder = 4095

tekenlinks = map(links)
tekenrechts = map(rechts)
tekenboven = map(boven)
tekenonder = map(onder)

IF tekenlinks = 25 THEN tekenlinks = 0
IF tekenrechts = 25 THEN tekenrechts = 0
IF tekenboven = 25 THEN tekenboven = 0
IF tekenonder = 25 THEN tekenonder = 0

IF tekenlinks <> 5 THEN tekenlinks = 0
IF tekenrechts <> 5 THEN tekenrechts = 0
IF tekenboven <> 5 THEN tekenboven = 0
IF tekenonder <> 5 THEN tekenonder = 0

som = tekenlinks + tekenrechts + tekenboven + tekenonder
IF som > 10 THEN map(i) = 5
IF som = 10 THEN
keer = INT(RND * 100)
IF keer < 50 THEN
map(i) = 5
END IF
IF keer >= 50 THEN
map(i) = 0
END IF
END IF

END IF

NEXT i

END IF




IF sort = 2 THEN
FOR i = 0 TO 4095
IF map(i) = 0 THEN
links = i - 1
rechts = i + 1
boven = i - 64
onder = i + 64

IF links < 0 THEN links = 0
IF rechts < 0 THEN rechts = 0
IF boven < 0 THEN boven = 0
IF onder < 0 THEN onder = 0

IF links > 4095 THEN links = 4095
IF rechts > 4095 THEN rechts = 4095
IF boven > 4095 THEN boven = 4095
IF onder > 4095 THEN onder = 4095

tekenlinks = map(links)
tekenrechts = map(rechts)
tekenboven = map(boven)
tekenonder = map(onder)

IF tekenlinks = 25 THEN tekenlinks = 5
IF tekenrechts = 25 THEN tekenrechts = 5
IF tekenboven = 25 THEN tekenboven = 5
IF tekenonder = 25 THEN tekenonder = 5

IF tekenlinks <> 25 THEN tekenlinks = 0
IF tekenrechts <> 25 THEN tekenrechts = 0
IF tekenboven <> 25 THEN tekenboven = 0
IF tekenonder <> 25 THEN tekenonder = 0

som = tekenlinks + tekenrechts + tekenboven + tekenonder
IF som > 10 THEN map(i) = 25
IF som = 10 THEN
keer = INT(RND * 100)
IF keer < 50 THEN
map(i) = 25
END IF
IF keer >= 50 THEN
map(i) = 0
END IF
END IF

END IF

NEXT i

END IF

END SUB

SUB getskirmaps
'First clear all
playmap$ = ""
maxskirmaps = -1
DIM temp$(200)
FOR m = 0 TO 200
mapfile$(m) = ""
NEXT m
SHELL "DIR DATA\MAPS\*.MAP > TEMP.SKR"
OPEN "TEMP.SKR" FOR INPUT AS #1
regel = 0
DO WHILE NOT EOF(1)
regel = regel + 1
LINE INPUT #1, dat$
IF regel > 5 THEN
temp$(l) = MID$(dat$, 1, 8)
l = l + 1
END IF
LOOP
CLOSE #1
OPEN "TEMP.OUT" FOR OUTPUT AS #2
FOR w = 0 TO (l - 3)
PRINT #2, temp$(w)
NEXT w
CLOSE #2

'Now read all
OPEN "TEMP.OUT" FOR INPUT AS #1
DO WHILE NOT EOF(1)
IF f <= 200 THEN INPUT #1, mapfile$(f)
IF f > 200 THEN EXIT DO
f = f + 1
LOOP
CLOSE #1
IF f = 1 AND mapfile$(0) = "" THEN
maxskirmaps = -1
ELSE
maxskirmaps = (f - 1)
nr$ = MID$(mapfile$(f - 1), 4, 8)
nrr = VAL(nr$)
END IF
'Now delete temp files
KILL "TEMP.SKR"
KILL "TEMP.OUT"
OPEN "DATA\MAPS\RMG.INI" FOR OUTPUT AS #1
PRINT #1, nrr
CLOSE #1

END SUB

SUB makeborders
'smooth map
DIM newmap(4095)
FOR i = 0 TO 4095
newmap(i) = 0
NEXT i

FOR i = 0 TO 4095
IF map(i) = 5 THEN
'change borders
links = i - 1
rechts = i + 1
boven = i - 64
onder = i + 64

IF links < 0 THEN links = 0
IF rechts < 0 THEN rechts = 0
IF boven < 0 THEN boven = 0
IF onder < 0 THEN onder = 0

IF links > 4095 THEN links = 4095
IF rechts > 4095 THEN rechts = 4095
IF boven > 4095 THEN boven = 4095
IF onder > 4095 THEN onder = 4095

tekenlinks = 0: tekenrechts = 0: tekenonder = 0: tekenboven = 0
tekenlinks = map(links)
tekenrechts = map(rechts)
tekenboven = map(boven)
tekenonder = map(onder)
links2 = 0: rechts2 = 0: boven2 = 0: onder2 = 0
IF tekenlinks = 5 THEN links2 = 1
IF tekenrechts = 5 THEN rechts2 = 1
IF tekenboven = 5 THEN boven2 = 1
IF tekenonder = 5 THEN onder2 = 1

'Nothing around it
IF links2 = 0 AND rechts2 = 0 AND boven2 = 0 AND onder2 = 0 THEN newmap(i) = 23

'Everything around it
IF links2 = 1 AND rechts2 = 1 AND boven2 = 1 AND onder2 = 1 THEN newmap(i) = 5 + INT(RND * 2)

'Only at the left rock
IF links2 = 1 AND rechts2 = 0 AND boven2 = 0 AND onder2 = 0 THEN newmap(i) = 28

'Only at the right rock
IF links2 = 0 AND rechts2 = 1 AND boven2 = 0 AND onder2 = 0 THEN newmap(i) = 29

'Only at the up rock
IF links2 = 0 AND rechts2 = 0 AND boven2 = 1 AND onder2 = 0 THEN newmap(i) = 30

'Only at the down rock
IF links2 = 0 AND rechts2 = 0 AND boven2 = 0 AND onder2 = 1 THEN newmap(i) = 31

'Only at the left and right rock
IF links2 = 1 AND rechts2 = 1 AND boven2 = 0 AND onder2 = 0 THEN newmap(i) = 33

'Only at the up and down
IF links2 = 0 AND rechts2 = 0 AND boven2 = 1 AND onder2 = 1 THEN newmap(i) = 32

'Only at the left up
IF links2 = 1 AND rechts2 = 0 AND boven2 = 1 AND onder2 = 0 THEN newmap(i) = 18

'Only at the left down
IF links2 = 1 AND rechts2 = 0 AND boven2 = 0 AND onder2 = 1 THEN newmap(i) = 16

'Only at the right down
IF links2 = 0 AND rechts2 = 1 AND boven2 = 0 AND onder2 = 1 THEN newmap(i) = 15

'Only at the right up
IF links2 = 0 AND rechts2 = 1 AND boven2 = 1 AND onder2 = 0 THEN newmap(i) = 17

'Only at the right up
IF links2 = 1 AND rechts2 = 1 AND boven2 = 1 AND onder2 = 0 THEN newmap(i) = 11 + INT(RND * 2)

'Only at the right down
IF links2 = 1 AND rechts2 = 1 AND boven2 = 0 AND onder2 = 1 THEN newmap(i) = 13 + INT(RND * 2)

'Only at the right
IF links2 = 1 AND rechts2 = 0 AND boven2 = 1 AND onder2 = 1 THEN newmap(i) = 9 + INT(RND * 2)

'Only at the left
IF links2 = 0 AND rechts2 = 1 AND boven2 = 1 AND onder2 = 1 THEN newmap(i) = 7 + INT(RND * 2)


END IF
NEXT i


'Ok now change all rocks
FOR i = 0 TO 4095
IF map(i) = 5 THEN map(i) = newmap(i)
IF map(i) = 25 THEN map(i) = map(i) + INT(RND * 3)
NEXT i







END SUB

SUB makespot (cll, duration, tp)
'create a random spot of tpe on cell, at duration
c = cll
cl = cll
FOR i = 0 TO duration
dir = INT(RND * 4)
IF dir = 0 THEN c2 = -1
IF dir = 1 THEN c2 = 1
IF dir = 2 THEN c2 = -64
IF dir = 3 THEN c2 = 64
c = c + c2
IF c > 4095 THEN c = 0
IF c < 0 THEN c = 4095
IF map(c) = 0 THEN map(c) = tp
NEXT i
END SUB

SUB menucode

dqbboxf 1, 0, 0, 8, 60, 35
skirmish = 0
IF menuitem = 0 THEN
setnormalfont
'MAIN MENU
center 7, "- MAIN MENU -", 2

 
IF checkcenter(11, "PLAY ARRAKIS") <> 0 THEN pulldown = 1
IF checkcenter(13, "SELECT HOUSE") <> 0 THEN pulldown = 2
IF checkcenter(15, "SETTINGS") <> 0 THEN pulldown = 3
IF checkcenter(17, "PLAY SKIRMISH") <> 0 THEN pulldown = 4
IF checkcenter(19, "EXIT GAME") <> 0 THEN pulldown = 5

setnormalfont
IF pulldown = 1 THEN setselectedfont
center 11, "PLAY ARRAKIS", 2
setnormalfont
IF pulldown = 2 THEN setselectedfont
center 13, "SET HOUSES", 2
setnormalfont
IF pulldown = 3 THEN setselectedfont
center 15, "SETTINGS", 2
setnormalfont
IF pulldown = 4 THEN setselectedfont
center 17, "PLAY SKIRMISH", 2
setnormalfont
IF pulldown = 5 THEN setselectedfont
center 19, "EXIT GAME", 2
             

'Mouse clicked
IF DQBmouseLB = -1 THEN
IF pulldown = 1 THEN spelen = TRUE
IF pulldown = 2 THEN menuitem = 1               'Select house
IF pulldown = 3 THEN menuitem = 2               'Settings
IF pulldown = 4 THEN menuitem = 3               'Play Skirmish
IF pulldown = 5 THEN
DQBclose
CLS
PRINT "Thanks for Playing Arrakis"
PRINT
PRINT "Version : 1.12"
PRINT
OPEN "DATA\TEMPR.TMP" FOR OUTPUT AS #1
PRINT #1, "2"
CLOSE #1
'Save last settings


END
END IF

END IF

END IF



IF spelen = TRUE THEN
playgame:
processhouses
spelen = FALSE
END IF



' SELECT  HOUSE!!!!!!!!!!!!!!!
IF menuitem = 1 THEN
setnormalfont
'SELECT HOUSE
center 7, "- SET HOUSES -", 2
setselectedfont
center 8, "CHOOSE YOUR HOUSE HERE", 2
setnormalfont
center 10, "PLAY AS:", 2
IF playinghouse = 0 THEN h$ = "ATREIDES": setatreidesfont
IF playinghouse = 1 THEN h$ = "HARKONNEN": setharkonnenfont
IF playinghouse = 2 THEN h$ = "ORDOS": setordosfont
IF checkcenter(11, "HARKONNEN") <> 0 THEN
setselectedfont
otherenemy = 0
IF DQBmouseLB = TRUE THEN playinghouse = playinghouse + 1: dqbwait 10: otherenemy = 1
IF DQBmouseRB = TRUE THEN playinghouse = playinghouse - 1: dqbwait 10: otherenemy = 1
IF playinghouse < 0 THEN playinghouse = 2
IF playinghouse > 2 THEN playinghouse = 0
END IF
center 11, UCASE$(h$), 2
setnormalfont
center 13, "PLAY AGAINST:", 2
IF otherenemy <> 0 THEN
again:
penemyhouse = INT(RND * 3)
IF penemyhouse = playinghouse THEN GOTO again
END IF
IF penemyhouse = 0 THEN h$ = "ATREIDES": setatreidesfont
IF penemyhouse = 1 THEN h$ = "HARKONNEN": setharkonnenfont
IF penemyhouse = 2 THEN h$ = "ORDOS": setordosfont
center 14, UCASE$(h$), 2
setnormalfont
IF checkcenter(18, "BACK") <> 0 THEN
setselectedfont
IF DQBmouseLB = TRUE THEN menuitem = 0
END IF

center 18, "BACK", 2
setnormalfont
END IF

' SETTINGS
IF menuitem = 2 THEN
setnormalfont
center 7, "- SETTINGS MENU -", 2
setnormalfont
center 10, "GAME SPEED:", 2
setharkonnenfont
IF speed = 0 THEN h$ = "PENTIUM II OR BETTER"
IF speed = 1 THEN h$ = "PENTIUM I 200MHZ"
IF speed = 2 THEN h$ = "PENTIUM I 166MHZ"
IF speed = 3 THEN h$ = "PENTIUM I 75MHZ"
IF speed = 4 THEN h$ = "486 PC"
IF checkcenter(11, "PENTIUM II OR BETTER") <> 0 THEN
setselectedfont
IF DQBmouseLB = TRUE THEN speed = speed + 1: dqbwait 10
IF DQBmouseRB = TRUE THEN speed = speed - 1: dqbwait 10
IF speed < 0 THEN speed = 4
IF speed > 4 THEN speed = 0
END IF
center 11, UCASE$(h$), 2
setnormalfont

s$ = STR$(amountspice)
r$ = STR$(amountrock)
zs$ = STR$(sizespice)
ZR$ = STR$(sizerock)


setatreidesfont
center 15, "RANDOM MAP GENERATOR", 2
setnormalfont
IF checkcenter(16, "ROCK PLATES:" + UCASE$(r$)) <> 0 THEN
setselectedfont
IF DQBmouseLB = TRUE THEN amountrock = amountrock + 1: dqbwait 10
IF DQBmouseRB = TRUE THEN amountrock = amountrock - 1: dqbwait 10
END IF
center 16, "ROCK PLATES:" + UCASE$(r$), 2

setnormalfont
IF checkcenter(17, "SPICE FIELDS:" + UCASE$(s$)) <> 0 THEN
setselectedfont
IF DQBmouseLB = TRUE THEN amountspice = amountspice + 1: dqbwait 10
IF DQBmouseRB = TRUE THEN amountspice = amountspice - 1: dqbwait 10
END IF
center 17, "SPICE FIELDS:" + UCASE$(s$), 2

setnormalfont
IF checkcenter(18, "SIZE ROCK PLATES:" + UCASE$(ZR$)) <> 0 THEN
setselectedfont
IF DQBmouseLB = TRUE THEN sizerock = sizerock + 10: dqbwait 10
IF DQBmouseRB = TRUE THEN sizerock = sizerock - 10: dqbwait 10
END IF
center 18, "SIZE ROCK PLATES:" + UCASE$(ZR$), 2

setnormalfont
IF checkcenter(19, "SIZE SPICE FIELDS:" + UCASE$(zs$)) <> 0 THEN
setselectedfont
IF DQBmouseLB = TRUE THEN sizespice = sizespice + 10: dqbwait 10
IF DQBmouseRB = TRUE THEN sizespice = sizespice - 10: dqbwait 10
END IF
center 19, "SIZE SPICE FIELDS:" + UCASE$(zs$), 2

IF amountspice < 1 THEN amountspice = 1
IF amountrock < 1 THEN amountrock = 1
IF sizespice < 50 THEN sizespice = 50
IF sizerock < 50 THEN sizerock = 50

IF amountspice > 25 THEN amountspice = 25
IF amountrock > 25 THEN amountrock = 25
IF sizespice > 500 THEN sizespice = 500
IF sizerock > 500 THEN sizerock = 500

som = (amountspice * sizespice) + (amountrock * sizerock)

s = amountspice
zs = sizespice
r = amountrock
ZR = sizerock
IF som >= 15000 THEN
setharkonnenfont
center 13, "HIGH AMOUNTS WILL TAKE LONG TIME TO", 2
center 14, "CREATE A MAP. KEEP IT REASONABLE...", 2
setnormalfont
END IF

setnormalfont
IF checkcenter(21, "BACK") <> 0 THEN
setselectedfont
IF DQBmouseLB = TRUE THEN menuitem = 0
END IF

center 21, "BACK", 2
setnormalfont
END IF


'SKIRMISH
IF menuitem = 3 THEN
setnormalfont
center 7, "- PLAY SKIRMISH -", 2
setselectedfont
center 8, "PLAY RANDOM GENERATED MAPS", 2

IF maxskirmaps >= 0 THEN setharkonnenfont ELSE setnormalfont
IF checkcenter(9, " PREVIOUS ") <> 0 AND maxskirmaps >= 0 THEN
setselectedfont
IF DQBmouseLB = TRUE THEN
'previous mission
mlist = mlist - 1
dqbwait 10
IF mlist < 0 THEN mlist = 0
END IF

END IF
center 9, " PREVIOUS ", 2
IF maxskirmaps >= 0 THEN
FOR lm = mlist TO maxskirmaps
t = t + 1

IF t = 1 THEN setselectedfont: playmap$ = mapfile$(lm):  ELSE setnormalfont
center 10 + t, mapfile$(lm), 2

IF t > 4 THEN EXIT FOR
NEXT lm
dqbbox 1, 200, 80, 210, 134, 100
groottey = (52 / (maxskirmaps + 1))
posy = (groottey * (mlist))
IF DQBmouseX >= 200 AND DQBmouseX <= 210 AND DQBmouseY >= 80 AND DQBmouseY <= 134 THEN
dqbbox 1, 200, 80, 210, 134, 200
pos1 = DQBmouseY - 80
IF DQBmouseLB = TRUE THEN
IF pos1 < posy THEN mlist = mlist - 1
IF pos1 > posy THEN mlist = mlist + 1
IF mlist < 0 THEN mlist = 0
IF mlist > maxskirmaps THEN mlist = maxskirmaps
END IF
END IF


dqbboxf 1, 201, 81 + posy, 209, 81 + posy + groottey, 150

ELSE
setordosfont
center 12, "NO MAPS AVAILABLE", 2
END IF


IF maxskirmaps >= 0 THEN setharkonnenfont ELSE setnormalfont
IF checkcenter(17, " NEXT ") <> 0 AND maxskirmaps >= 0 THEN
setselectedfont
IF DQBmouseLB = TRUE THEN
'previous mission
mlist = mlist + 1
dqbwait 10
IF mlist > maxskirmaps THEN mlist = maxskirmaps
END IF

END IF
center 17, " NEXT ", 2



setnormalfont
IF checkcenter(18, "PLAY NEW MISSION") <> 0 THEN
setselectedfont
IF DQBmouseLB = TRUE THEN
'Play a new mission, random generate it, set flag SKIRMIS
skirmish = 2     'Create new map
GOTO playgame
END IF

END IF
center 18, "PLAY NEW MISSION", 2
 
setnormalfont
IF checkcenter(19, "PLAY MAP<" + UCASE$(playmap$) + ">") <> 0 AND maxskirmaps >= 0 THEN
setselectedfont
IF DQBmouseLB = TRUE THEN
'Play a selected mission, random generate it, set flag SKIRMIS
skirmish = 1     'Dont create new map
GOTO playgame
END IF

END IF
center 19, "PLAY MAP<" + UCASE$(playmap$) + ">", 2

  
setnormalfont
IF checkcenter(21, "BACK") <> 0 THEN
setselectedfont
IF DQBmouseLB = TRUE THEN menuitem = 0
END IF
center 21, "BACK", 2
setnormalfont

END IF

END SUB

SUB processhouses
'This will copy the house you want to play with to the specific dir
'DATA\GRAPHICS\ATR
'DATA\GRAPHICS\COMMON
'Also the ARRAKIS.DAT from that house will be copied as ARRAKIS.EXE
'Into the ARRAKIS dir , and we can play!

'Ok, now convert variables
currenthouse = playinghouse + 1
enemyhouse = penemyhouse + 1
'If arrakis locks up, the program FIX.EXE will check the Arrakis dir
'and then fix any errors.

'Ok
'the dir we should copy from is...
IF currenthouse = 1 THEN dir$ = "DATA\HOUSES\ATREIDES\": mycolor = 40 'Atreides
IF currenthouse = 2 THEN dir$ = "DATA\HOUSES\HARKONN\": mycolor = 170'Harkonnen
IF currenthouse = 3 THEN dir$ = "DATA\HOUSES\ORDOS\": mycolor = 201   'Ordos
'Ok
'the dir we copy TO is DATA\GRAPHICS\ATR, and ...\COMMON

'These dir names are also in the house dirs.
'We also have an enemy, SO, we need an enemy, well that is a house
'but NOT our house!

 
'Ok, now we have enemy houses
'the dir we should copy from for enemy
'House colors:
'170 = Hark
'40 = Atr
'201 = Ord
IF enemyhouse = 1 THEN dir2$ = "DATA\HOUSES\ATREIDES\" 'Atreides
IF enemyhouse = 2 THEN dir2$ = "DATA\HOUSES\HARKONN\"  'Harkonnen
IF enemyhouse = 3 THEN dir2$ = "DATA\HOUSES\ORDOS\"    'Ordos

'Ok string for HSS file
IF enemyhouse = 1 THEN hss$ = "ATREIDES": enemycolor = 40
IF enemyhouse = 2 THEN hss$ = "HARKONNEN": enemycolor = 170
IF enemyhouse = 3 THEN hss$ = "ORDOS": enemycolor = 201
'For myhouse too
IF currenthouse = 1 THEN hss2$ = "ATREIDES"
IF currenthouse = 2 THEN hss2$ = "HARKONNEN"
IF currenthouse = 3 THEN hss2$ = "ORDOS"
'We copy the files with an H extra at start to the HARK dir

'Ok we have
'DIR$ = Contains Player HOUSE dir
'DIR2$ = Contains Enemy HOUSE dir (AI)
'DIR$ = Contains also EXE file for Arrakis as a DAT file


IF speed = 0 THEN skipframes = 0
IF speed = 1 THEN skipframes = 1
IF speed = 2 THEN skipframes = 2
IF speed = 3 THEN skipframes = 4
IF speed = 4 THEN skipframes = 8


'We have to do:
'CREATE a ARRAKIS.HSS so ARRAKIS.EXE knows what the ENEMY name is!
'COPY GRAPHICS TO specific dirs
OPEN "DATA\ARRAKIS.INI" FOR OUTPUT AS #1
PRINT #1, hss$
PRINT #1, hss2$
PRINT #1, enemycolor
PRINT #1, mycolor
PRINT #1, skipframes
PRINT #1, penemyhouse           'Important
PRINT #1, playinghouse          'Important
PRINT #1, amountspice           'Important
PRINT #1, amountrock           'Important
PRINT #1, sizespice           'Important
PRINT #1, sizerock           'Important
CLOSE #1

DQBfadeTo 0, 0, 0

'Ok now copy specific files..
'HOUSE files, are not other file names than in HOUSE dir, so we can
'copy with *.*
commandline$ = "COPY " + dir$ + "ATR\*.* DATA\GRAPHICS\ATR"
SHELL commandline$
commandline$ = "COPY " + dir$ + "COMMON\*.* DATA\GRAPHICS\COMMON"
SHELL commandline$
'EXPLOSION FILE
commandline$ = "COPY " + dir2$ + "ATR\EXPL.PCX DATA\GRAPHICS\HARK\HEXPL.PCX"
SHELL commandline$
'HARVESTER
commandline$ = "COPY " + dir2$ + "ATR\HARV.PCX DATA\GRAPHICS\HARK\HHARV.PCX"
SHELL commandline$
'HEAVY TANK
commandline$ = "COPY " + dir2$ + "ATR\HTANK.PCX DATA\GRAPHICS\HARK\HHTANK.PCX"
SHELL commandline$
'LIGHT TANK
commandline$ = "COPY " + dir2$ + "ATR\LTANK.PCX DATA\GRAPHICS\HARK\HLTANK.PCX"
SHELL commandline$
'INFANTRY
commandline$ = "COPY " + dir2$ + "ATR\INF.PCX DATA\GRAPHICS\HARK\HINF.PCX"
SHELL commandline$
'MINER(GRENADE TANK)
commandline$ = "COPY " + dir2$ + "ATR\MINER.PCX DATA\GRAPHICS\HARK\HMINER.PCX"
SHELL commandline$
'EXE FILE
'Skill EASY
IF difficulty = 0 THEN commandline$ = "COPY " + dir$ + "ARRAKIS.DAT GAME.EXE"
SHELL commandline$
'START GAME
'Hopes it will not crash because running an another DIRECTQB...
DQBclearLayer 0
SLEEP 1
DQBsetPal Pal
DQBinitText
DQBresetMouse
'Ok, now this program will end, and we process a variable to the ARRAKIS.EXE
'which is actually a small run the programs program, ok we pass a variable
OPEN "DATA\TEMPR.TMP" FOR OUTPUT AS #1
IF skirmish = 0 THEN PRINT #1, "1"
IF skirmish = 1 THEN PRINT #1, "3"
IF skirmish = 2 THEN
PRINT #1, "4"
END IF

CLOSE #1

IF skirmish > 0 THEN
OPEN "DATA\MAPS\RMGMAP.OUT" FOR OUTPUT AS #1
PRINT #1, playmap$
CLOSE #1
END IF

'1 = RUN GAME.EXE
'2 = QUIT
'3 = PLAY SKIRMISH
'4 = PLAY SKIRMISH , CREATE NEW MAP
DQBclose
IF skirmish = 2 THEN
ZR = sizerock
r = amountrock
zs = sizespice
s = amountspice
'$INCLUDE: 's12.bas'
END IF



END
END SUB

SUB setatreidesfont
DQBget 2, 0, 0, 7, 7, VARSEG(textu(0)), VARPTR(textu(0))
DQBsetFontTexture VARSEG(textu(0)), VARPTR(textu(0))
END SUB

SUB setharkonnenfont
DQBget 2, 0, 9, 7, 16, VARSEG(textu(0)), VARPTR(textu(0))
DQBsetFontTexture VARSEG(textu(0)), VARPTR(textu(0))
END SUB

SUB setnormalfont
DQBget 2, 0, 27, 7, 34, VARSEG(textu(0)), VARPTR(textu(0))
DQBsetFontTexture VARSEG(textu(0)), VARPTR(textu(0))
END SUB

SUB setordosfont
DQBget 2, 0, 18, 7, 25, VARSEG(textu(0)), VARPTR(textu(0))
DQBsetFontTexture VARSEG(textu(0)), VARPTR(textu(0))
END SUB

SUB setselectedfont
DQBget 2, 0, 36, 7, 43, VARSEG(textu(0)), VARPTR(textu(0))
DQBsetFontTexture VARSEG(textu(0)), VARPTR(textu(0))
END SUB

SUB writefile
OPEN "DATA\MAPS\RMG.INI" FOR INPUT AS #1
INPUT #1, teller
CLOSE #1
teller = teller + 1
teller$ = RTRIM$(LTRIM$(STR$(teller)))

leng = LEN(teller$)
over = 5 - leng
IF over < -1 THEN over = 0
s$ = "RMG"
FOR s = 1 TO over
s$ = s$ + "0"
NEXT s
s$ = s$ + teller$

filename$ = UCASE$(s$)

OPEN "DATA\MAPS\ADDAi.non" FOR INPUT AS #2
OPEN "DATA\MAPS\" + filename$ + ".MAP" FOR OUTPUT AS #1
PRINT #1, mx, my
FOR i = 0 TO 4095
IF map(i) > 0 THEN PRINT #1, i, map(i)
NEXT i
DO WHILE NOT EOF(2)
LINE INPUT #2, l$
PRINT #1, l$
LOOP
CLOSE #1
CLOSE #2
END SUB

