'**************************
'**** ADD RANDOM MAP ******
'**************************
'TOOL: FOR ARRAKIS
'COPYRIGHTED BY STEFAN HENDRIKS

DECLARE SUB makespot (cll!, duration!, tp!)
DECLARE SUB fillgaps (sort!)
DECLARE FUNCTION checkspot! (cl!)
DECLARE SUB checkais ()
DECLARE SUB clearmap ()
DECLARE SUB drawmap ()
DECLARE SUB makeborders ()
DECLARE SUB clearspice ()
DECLARE SUB writefile ()
COMMON SHARED dif, keer, cl, afstand, startcell1, startcell2, mx, my, filename$
RANDOMIZE TIMER
DIM SHARED map(4095)
DIM SHARED mapstr(4095)
CLS
PRINT "ADDING RANDOM MAP..."
'INPUT "Size rocks     :", zr
'INPUT "How many rocks :", r
'INPUT "Size Spice     :", zs
'INPUT "How many Spice :", s
ZR = 150 + INT(RND * 100)
r = 5 + INT(RND * 8)
zs = 75 + INT(RND * 75)
s = 10 + INT(RND * 7)
DIM SHARED posities(r)
again:
keer = 0
afstand = 0
FOR i = 0 TO r
c = INT(RND * 3839)
posities(i) = c
IF (i - 1) >= 0 THEN
cell1 = c
cell2 = posities(i - 1)
IF cell2 < cell1 THEN SWAP cell1, cell2
vx = cell2 - cell1
IF vx > afstand THEN
afstand = vx
a = INT(RND * 100)
IF a < 50 THEN
startcell1 = cell1
startcell2 = cell2
ELSE
startcell1 = cell2
startcell2 = cell1
END IF

END IF


END IF
makespot c, ZR, 5
NEXT i

kleintjes = INT(RND * 30)
FOR i = 0 TO kleintjes
map(INT(RND * 3839)) = 5
NEXT i

fillgaps 1
checkais

FOR i = 0 TO s
makespot INT(RND * 3839), zs, 25
NEXT i

fillgaps 2
clearspice
makeborders
'drawmap
'LOCATE 8, 1: INPUT "Save file? Y/N/A:", a$
'a$ = UCASE$(a$)
'IF a$ = "Y" THEN writefile
'IF a$ = "N" THEN SCREEN 0: CLS : END
'IF a$ = "A" THEN clearmap: GOTO again

writefile

OPEN filename$ + ".BRF" FOR OUTPUT AS #1
PRINT #1, "SKIRMISH MISSION"
PRINT #1, ""
PRINT #1, "THE ENEMY MUST BE DESTROYED"
PRINT #1, "THAT IS THE MISSION."
PRINT #1, ""
PRINT #1, "GOOD LUCK!    "
CLOSE #1

OPEN "RMGMAP.OUT" FOR OUTPUT AS #1
PRINT #1, filename$
CLOSE #1

SUB checkais
'This sub checks on startcell1 and startcell2 if there is enough room
'for building, it will automaticly fill up sand.
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
OPEN "ADDAI.NON" FOR OUTPUT AS #1
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
IF building = 1 THEN PRINT #1, "4 , 0,"; c; ", 1"
IF building = 2 THEN PRINT #1, "12 , 1,"; c; ", 1"
IF building = 3 THEN PRINT #1, "22 , 2,"; c; ", 1"
IF building = 4 THEN PRINT #1, "30 , 0,"; c; ", 1"
IF building = 5 THEN PRINT #1, "35 , 0,"; c; ", 1"
IF building = 6 THEN PRINT #1, "42 , 4,"; c; ", 1"
IF building = 7 THEN PRINT #1, "52 , 3,"; c; ", 1"
IF building = 8 THEN PRINT #1, "62 , 6,"; c; ", 1"
IF building = 9 THEN PRINT #1, "82 , 5,"; c; ", 1"
mapstr(c) = 1
mapstr(c + 1) = 1
mapstr(c + 64) = 1
mapstr(c + 65) = 1
ELSE
zoekdir:
a = INT(RND * 50)
IF a < 25 THEN cell = cell - (INT(RND * 3) * 64) - INT(RND * 6)
IF a >= 25 THEN cell = cell + (INT(RND * 3) * 64) + INT(RND * 6)
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

IF mx1 + 1 > 63 THEN checkspot = 1
IF my1 + 1 > 63 THEN checkspot = 1

IF cl + 1 < 4095 THEN IF NOT (cl + 1 < 4095 AND mapstr(cl + 1) = 0) THEN checkspot = 1
IF cl + 64 < 4095 THEN IF NOT (cl + 64 < 4095 AND mapstr(cl + 64) = 0) THEN checkspot = 1
IF cl + 65 < 4095 THEN IF NOT (cl + 65 < 4095 AND mapstr(cl + 65) = 0) THEN checkspot = 1
IF NOT (cl < 4095 AND mapstr(cl) = 0) THEN checkspot = 1

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

SUB writefile
OPEN "RMG.INI" FOR INPUT AS #1
INPUT #1, teller
CLOSE #1
OPEN "RMG.INI" FOR OUTPUT AS #1
PRINT #1, teller + 1
CLOSE #1
teller = teller + 1
teller$ = LTRIM$(RTRIM$(STR$(teller)))

leng = LEN(teller$)
over = 5 - leng
IF over < -1 THEN over = 0
s$ = "RMG"
FOR s = 1 TO over
s$ = s$ + "0"
NEXT s
s$ = s$ + teller$

filename$ = UCASE$(s$)

OPEN "ADDAi.non" FOR INPUT AS #2
OPEN filename$ + ".MAP" FOR OUTPUT AS #1
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

