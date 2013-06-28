'****************************************************************
'*****  ARRAKIS MAIN MENU FILE, AND RMG INCLUDED AS S12.BAS *****
'****************************************************************
'COPYRIGHTED BY STEFAN HENDRIKS
'****************************************************************
'*****  ARRAKIS MAIN MENU FILE, AND RMG INCLUDED AS S12.BAS *****
'****************************************************************

CLS
PRINT "ADDING RANDOM MAP..."
'INPUT "Size rocks     :", zr
'INPUT "How many rocks :", r
'INPUT "Size Spice     :", zs
'INPUT "How many Spice :", s
again3:
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
'IF a$ = "A" THEN clearmap: GOTO again3

writefile

OPEN "DATA\MAPS\" + filename$ + ".BRF" FOR OUTPUT AS #1
PRINT #1, "SKIRMISH MISSION"
PRINT #1, ""
PRINT #1, "THE ENEMY MUST BE DESTROYED"
PRINT #1, "THAT IS THE MISSION."
PRINT #1, ""
PRINT #1, "GOOD LUCK!    "
CLOSE #1

OPEN "DATA\MAPS\RMGMAP.OUT" FOR OUTPUT AS #1
PRINT #1, filename$
CLOSE #1

