DECLARE SUB fillgaps ()
DECLARE SUB savelevel (map$)
DECLARE SUB drawusing (t%, x%, y%)
DECLARE SUB loadmap (map$)
'*************************
'ARRAKIS, REWRITE VERSION!
'*************************
'Graphics: Stefan
'Code    : Stefan
'Library : Enhanced Creations, DIRECTQB 1.5 + 1.6 SPRITE.OBJ
'
'Fully commented!
DECLARE SUB drawterrain ()
'DIRECTQB Included:
'$INCLUDE: 'directqb.bi'

'Shared variables.
'MX and MY are the MAP variables so scrolling is possible.
'MouseCELL, figure where mouse is on the map...
COMMON SHARED mx, my, mousecell, use, mapfile$, startsx, startsy
RANDOMIZE TIMER         'Always handy
mapfile$ = COMMAND$
IF mapfile$ = "" THEN
PRINT "You did not specify a filename"
PRINT
PRINT "Syntax:"
PRINT
PRINT "AEDIT.EXE filename"
PRINT
PRINT "When filename = NEWMAP then you can create a new map."
END
END IF

IF LEN(mapfile$) > 8 THEN
PRINT "Invalid length of filename, " + mapfile$ + ", does not excist"
END
END IF

IF LCASE$(mapfile$) = "newmap" THEN
PRINT "Create a new map:"
PRINT
nogmaals:
INPUT "Filename:", mapfile$
IF LEN(mapfile$) > 8 THEN
PRINT "not more than 8 characters long!"
GOTO nogmaals
END IF
dontload = 1
END IF

t = DQBinit(3, 0)       'Test if computer is capable
IF t <> 0 THEN dqbclose: END    'If not, quit game


'KEYS:
'A = NEXT TILE
'S = PREVIOUS TILE
'T = SMOOTH
'F = FILL UP ROCK PLATES A BIT
'LB = PLACE TILE
'RB = PLACE SAND
'Q = SAVE
'W = SET STARTSCREEN
'R = MAKE RANDOM SAND
'C = CLEAR MAP
'H = HELP






DIM Pal AS STRING * 786         'Dimension PALette
DQBinitVGA                      'Go VGA modus!

'********************************************************
'LOADING:                                  GRAPHICS
'********************************************************
'Layer 2: Graphical User Interface
'IF DQBloadLayer(2, "DATA\GRAPHICS\COMMON\GUI.PCX", Pal) <> 0 THEN dqbclose: END

'Layer 3: Terrain, file nr 1
IF DQBloadLayer(3, "DATA\GRAPHICS\COMMON\TERRAIN1.PCX", Pal) <> 0 THEN dqbclose: END
DQBsetPal Pal           'Use current Palette

'********************************************************
'END LOADING:                              GRAPHICS
'********************************************************

'********************************************************
'DEFINED ARRAYS AND SHARED VARIABLES, CONSTANTS
'********************************************************
white = DQBfindCol(63, 63, 63)          'Search for WHITE color
'Map:
DIM SHARED maptile(4095)                '4095 Map tiles, 64X64 Map


IF dontload = 0 THEN loadmap mapfile$
FOR i = 0 TO 4095                       'Draw now the map for map window
IF maptile(i) >= 5 THEN c = 157 ELSE c = 158
IF maptile(i) >= 25 AND maptile(i) < 28 THEN c = 156
yd = INT(i / 64): xd = i - (yd * 64)
dqbpset 2, 249 + xd, 21 + yd, c
NEXT i


'********************************************************
'END DEFINED ARRAYS AND SHARED VARIABLES, CONSTANTS
'********************************************************

'********************************************************
'GAME STARTS HERE
'********************************************************
DO
k$ = LCASE$(INKEY$)
DQBclearLayer 1         'Clear Layer 1
drawterrain             'Draw terrain
DQBcopyTransLayer 2, 1  'Draw GUI transparant
dqbprint 1, "Arrakis Terrain Editor:   CELL:" + STR$(mousecell), 0, 0, white      'Print Credits

IF k$ = "a" THEN use = use - 1
IF use < 0 THEN use = 0
IF k$ = "s" THEN use = use + 1
 
'********************************************************
'SCROLL CODE
'********************************************************
IF magscrollen = 0 THEN
IF DQBmouseX > 278 THEN mx = mx + 1
IF mx > 43 THEN mx = 43
IF DQBmouseX < 1 THEN mx = mx - 1
IF mx < 0 THEN mx = 0
IF DQBmouseY > 170 THEN my = my + 1
IF my > 49 THEN my = 49
IF DQBmouseY < 1 THEN my = my - 1
IF my < 0 THEN my = 0
END IF
'********************************************************
'END SCROLL CODE
'********************************************************

IF DQBmouseLB = -1 THEN
IF use = 5 THEN die = use + INT(RND * 2)
IF use = 6 THEN die = use - INT(RND * 2)
IF use = 7 THEN die = use + INT(RND * 2)
IF use = 8 THEN die = use - INT(RND * 2)
IF use = 9 THEN die = use + INT(RND * 2)
IF use = 10 THEN die = use - INT(RND * 2)
IF use = 11 THEN die = use + INT(RND * 2)
IF use = 12 THEN die = use - INT(RND * 2)
IF use = 13 THEN die = use + INT(RND * 2)
IF use = 14 THEN die = use - INT(RND * 2)
IF use = 25 THEN die = use + INT(RND * 3)
IF use > 14 AND use < 25 THEN die = use
IF use < 5 THEN die = use
IF use >= 28 THEN die = use
maptile(mousecell) = die
IF maptile(mousecell) >= 5 THEN c = 157 ELSE c = 158
IF maptile(mousecell) >= 25 AND maptile(mousecell) < 28 THEN c = 156
yd = INT(mousecell / 64): xd = mousecell - (yd * 64)
dqbpset 2, 249 + xd, 21 + yd, c
END IF

IF DQBmouseRB = -1 THEN
maptile(mousecell) = INT(RND * 5)
yd = INT(mousecell / 64): xd = mousecell - (yd * 64)
dqbpset 2, 249 + xd, 21 + yd, 158
END IF




IF k$ = "r" THEN
'Make random sand
'deny any rock types
FOR i = 0 TO 4095
IF maptile(i) < 5 THEN maptile(i) = INT(RND * 5)
NEXT i
END IF

DQBxPut 3, 308, 190, 319, 199, 1, DQBmouseX, DQBmouseY       'Draw MOUSE
dqbprint 1, STR$(use), DQBmouseX + 9, DQBmouseY - 8, white
'The MOUSECELL is VERY important, it is calculated here...
mousex = INT(DQBmouseX / 16)
mousey = INT(DQBmouseY / 16)
mousecell = (mousey + my) * 64 + (mousex + mx)
IF mousecell < 0 THEN mousecell = 0
IF mousecell > 4095 THEN mousecel = 4095

'Done!
IF DQBmouseX + 32 <= 320 AND DQBmouseY + 32 <= 200 THEN
dqbbox 1, DQBmouseX + 8, DQBmouseY + 8, DQBmouseX + 25, DQBmouseY + 25, white
drawusing use, DQBmouseX + 9, DQBmouseY + 9
END IF

dqbprint 1, "MX:" + STR$(mx) + ",MY:" + STR$(my), 0, 8, 14


dqbbox 1, 249 + startsx, 21 + startsy, 249 + startsx + 15, 21 + startsy + 13, 10
dqbbox 1, 249 + mx, 21 + my, 249 + mx + 20, 21 + my + 13, white



dqbcopylayer 1, 0                                       'Draw all on the screen

drawusing 18, 0, 0

IF k$ = "c" THEN
FOR i = 0 TO 4095
maptile(i) = INT(RND * 5)
'dqbpset 2, 249 + xd, 21 + yd, c
NEXT i
dqbboxf 2, 249, 21, 249 + 64, 21 + 64, 158
END IF

IF k$ = "t" THEN
'Make all undone rocky terrain
FOR j = 0 TO 4095
IF (maptile(j) >= 5 AND maptile(j) <= 24) OR (maptile(j) >= 28 AND maptile(j) <= 37) THEN
maptile(j) = 5
END IF
NEXT j

FOR i = 0 TO 4095


IF maptile(i) = 5 OR maptile(i) = 6 THEN

boven = 0: onder = 0: links = 0: rechts = 0
links2 = 0: onder2 = 0: boven2 = 0: rechts2 = 0
'IF i - 64 >= 0 THEN IF maptile(i - 64) >= 5 AND maptile(i - 64) < 28 THEN boven = 1
'IF i + 64 <= 4095 THEN IF maptile(i + 64) >= 5 AND maptile(i + 64) < 28 THEN onder = 1
'IF i - 1 >= 0 THEN IF maptile(i - 1) >= 5 AND maptile(i - 1) < 28 THEN links = 1
'IF i + 1 <= 4095 THEN IF maptile(i + 1) >= 5 AND maptile(i + 1) < 28 THEN rechts = 1

IF i - 64 >= 0 THEN IF maptile(i - 64) >= 5 THEN boven = 1
IF i + 64 <= 4095 THEN IF maptile(i + 64) >= 5 THEN onder = 1
IF i - 1 >= 0 THEN IF maptile(i - 1) >= 5 THEN links = 1
IF i + 1 <= 4095 THEN IF maptile(i + 1) >= 5 THEN rechts = 1

nr = 5 + INT(RND * 2)

links2 = links
rechts2 = rechts
boven2 = boven
onder2 = onder

'Nothing around it
IF links2 = 0 AND rechts2 = 0 AND boven2 = 0 AND onder2 = 0 THEN nr = 23

'Everything around it
IF links2 = 1 AND rechts2 = 1 AND boven2 = 1 AND onder2 = 1 THEN nr = 5 + INT(RND * 2)

'Only at the left rock
IF links2 = 1 AND rechts2 = 0 AND boven2 = 0 AND onder2 = 0 THEN nr = 28

'Only at the right rock
IF links2 = 0 AND rechts2 = 1 AND boven2 = 0 AND onder2 = 0 THEN nr = 29

'Only at the up rock
IF links2 = 0 AND rechts2 = 0 AND boven2 = 1 AND onder2 = 0 THEN nr = 30

'Only at the down rock
IF links2 = 0 AND rechts2 = 0 AND boven2 = 0 AND onder2 = 1 THEN nr = 31

'Only at the left and right rock
IF links2 = 1 AND rechts2 = 1 AND boven2 = 0 AND onder2 = 0 THEN nr = 33

'Only at the up and down
IF links2 = 0 AND rechts2 = 0 AND boven2 = 1 AND onder2 = 1 THEN nr = 32

'Only at the left up
IF links2 = 1 AND rechts2 = 0 AND boven2 = 1 AND onder2 = 0 THEN nr = 18

'Only at the left down
IF links2 = 1 AND rechts2 = 0 AND boven2 = 0 AND onder2 = 1 THEN nr = 16

'Only at the right down
IF links2 = 0 AND rechts2 = 1 AND boven2 = 0 AND onder2 = 1 THEN nr = 15

'Only at the right up
IF links2 = 0 AND rechts2 = 1 AND boven2 = 1 AND onder2 = 0 THEN nr = 17

'Only at the right up
IF links2 = 1 AND rechts2 = 1 AND boven2 = 1 AND onder2 = 0 THEN nr = 11 + INT(RND * 2)

'Only at the right down
IF links2 = 1 AND rechts2 = 1 AND boven2 = 0 AND onder2 = 1 THEN nr = 13 + INT(RND * 2)

'Only at the right
IF links2 = 1 AND rechts2 = 0 AND boven2 = 1 AND onder2 = 1 THEN nr = 9 + INT(RND * 2)

'Only at the left
IF links2 = 0 AND rechts2 = 1 AND boven2 = 1 AND onder2 = 1 THEN nr = 7 + INT(RND * 2)


maptile(i) = nr

END IF
NEXT i
END IF


IF k$ = "w" THEN
'startsx = mx
'startsy = my

'the mousecell is where the center of the screen should be.
yd = INT(mousecell / 64): xd = mousecell - (yd * 64)
startsx = xd - 7
startsy = yd - 7

END IF

IF k$ = "h" THEN
t% = DQBloadLayer(0, "DATA\GRAPHICS\AHELP.PCX", Pal)
dqbprint 0, "ARRAKIS TERRAIN EDITOR HELP", 0, 0, 14
dqbprint 0, "KEYS:", 0, 16, 14
dqbprint 0, "Q   - Save File", 0, 32, 14
dqbprint 0, "W   - Set Startscreen", 0, 40, 14
dqbprint 0, "F   - Fill gaps in Rock plates", 0, 48, 14
dqbprint 0, "C   - Clear map", 0, 56, 14
dqbprint 0, "T   - Smooth rock terrain", 0, 64, 14
dqbprint 0, "R   - Make Random Sand", 0, 72, 14
dqbprint 0, "A/S - Next/Previous Tile", 0, 80, 14
dqbprint 0, "H   - Help Screen", 0, 88, 14
dqbprint 0, "Press a key to go back.", 0, 170, 14
WHILE INKEY$ = "": WEND
END IF

IF k$ = "q" THEN savelevel mapfile$

IF k$ = "f" THEN
fillgaps
FOR i = 0 TO 4095                       'Draw now the map for map window
IF maptile(i) >= 5 THEN c = 157 ELSE c = 158
IF maptile(i) >= 25 AND maptile(i) < 28 THEN c = 156
yd = INT(i / 64): xd = i - (yd * 64)
dqbpset 2, 249 + xd, 21 + yd, c
NEXT i
END IF


IF k$ = CHR$(27) THEN EXIT DO       'Quit program when ESC pressed
LOOP





dqbinittext
dqbclose
END

REM $DYNAMIC
SUB drawterrain
'draws terrain, easy
'instead of calculating the X and Y
'we calculate the CELL,
'CELL=Y*64+X
'Start drawing from MX and MY to the borders,
'this makes it REALLY FAST and easy

FOR y = my TO my + 13
FOR x = mx TO mx + 20
t = maptile(y * 64 + x)

l = 0
'IF t > 17 THEN l = l + 1: t = t - 18
l = INT(t / 18): t = t - (l * 18)
DQBxPut 3, (t * 16) + t, (l * 16) + l, (t * 16) + t + 16, 15 + (l * 16) + l, 1, (x - mx) * 16, (y - my) * 16


IF x = (startsx + 7) AND y = (startsy + 7) THEN
dqbbox 1, (x - mx) * 16, (y - my) * 16, (x - mx) * 16 + 15, (y - my) * 16 + 15, 4
END IF

IF maptile(y * 64 + x) >= 42 THEN
IF (x - mx) * 16 + 16 > 319 THEN GOTO nodraw
IF (y - my) * 16 + 16 > 199 THEN GOTO nodraw
dqbbox 1, (x - mx) * 16, (y - my) * 16, (x - mx) * 16 + 15, (y - my) * 16 + 15, 2
nodraw:
END IF



NEXT x
NEXT y
END SUB

REM $STATIC
SUB drawusing (g, x, y)
laatzien = 0
t = g
l = 0
'IF t > 17 THEN l = l + 1: t = t - 18
l = INT(t / 18): t = t - (l * 18)
DQBxPut 3, (t * 16) + t, (l * 16 + l), (t * 16) + t + 16, 15 + (l * 16 + l), 1, x, y
'dqbprint 1, STR$(mousecell), DQBmouseX - 32, DQBmouseY - 32, 14

END SUB

SUB fillgaps
'Fill gaps
FOR i = 0 TO 4095
IF maptile(i) <= 4 THEN
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

tekenlinks = maptile(links)
tekenrechts = maptile(rechts)
tekenboven = maptile(boven)
tekenonder = maptile(onder)


IF tekenlinks <> 5 AND tekenlinks <> 6 THEN tekenlinks = 0
IF tekenrechts <> 5 AND tekenrechts <> 6 THEN tekenrechts = 0
IF tekenboven <> 5 AND tekenboven <> 6 THEN tekenboven = 0
IF tekenonder <> 5 AND tekenonder <> 6 THEN tekenonder = 0

IF tekenonder = 6 THEN tekenonder = 5
IF tekenboven = 6 THEN tekenboven = 5
IF tekenlinks = 6 THEN tekenlinks = 5
IF tekenrechts = 6 THEN tekenrechts = 5

som = tekenlinks + tekenrechts + tekenboven + tekenonder
IF som > 10 THEN maptile(i) = 5
IF som = 10 THEN
keer = INT(RND * 100)
IF keer < 50 THEN
maptile(i) = 5 + INT(RND * 2)
END IF
IF keer >= 50 THEN
maptile(i) = 0 + INT(RND * 5)
END IF
END IF

END IF

NEXT i
END SUB

SUB loadmap (map$)
FOR i = 0 TO 4095                       'Make a lot a sand, randomly!
maptile(i) = INT(RND * 5)
NEXT i
'Now open data, and retrieve info about changed maptiles
OPEN map$ + ".map" FOR INPUT AS #1
INPUT #1, startsx, startsy
DO WHILE NOT EOF(1)
INPUT #1, nr, soort
IF nr < 0 THEN EXIT DO
maptile(nr) = soort
LOOP
CLOSE #1

FOR i = 0 TO 4095                       'Draw now the map for map window
IF maptile(i) >= 5 THEN c = 157 ELSE c = 158
IF maptile(i) >= 25 AND maptile(i) < 28 THEN c = 156
yd = INT(i / 64): xd = i - (yd * 64)
dqbpset 2, 249 + xd, 21 + yd, c
NEXT i
mx = startsx
my = startsy
END SUB

SUB savelevel (map$)
OPEN map$ + ".map" FOR OUTPUT AS #1
PRINT #1, startsx, startsy
FOR i = 0 TO 4095
IF maptile(i) > 4 THEN PRINT #1, i, maptile(i)
NEXT i
CLOSE #1
END SUB

