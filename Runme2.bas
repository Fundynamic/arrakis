'*****************************************************************
'*********** ARRAKIS RUNME FILE FOR RUNNING MENU/GAME ************
'*****************************************************************
'COPYRIGHTED BY STEFAN HENDRIKS
'DO NEVER CHANGE THE CODE WITHOUT PERMISSION
'DO NEVER CHANGE THE CODE UNLESS YOU KNOW WHAT YOU ARE DOING
'
'I'M NOT RESPONSIBLE FOR ANY DAMAGES THAT THIS PROGRAM CAN DO
'WETHER THERE HAS BEEN CHANGES MADE OR NOT.
'
'THIS PROGRAM SHOULD WORK PROPERLY, DO NOT SPREAD THIS OR PUT IT
'ON THE INTERNET WITHOUT MY PERMISSION
'
'THANK YOU
'E-MAIL: stefanhendriks@zonnet.nl
'*****************************************************************
'*********** ARRAKIS RUNME FILE FOR RUNNING MENU/GAME ************
'*****************************************************************

PRINT "- Arrakis Version 1.12 -"
t$ = COMMAND$
IF UCASE$(t$) = "/s" THEN nosound = 1 ELSE nosound = 0
nogeens:
SLEEP 1
PRINT "Loading..."
SHELL "MENU.EXE"
'Ok menu should quit, but what should WE do
OPEN "DATA\TEMPR.TMP" FOR INPUT AS #1
INPUT #1, v
CLOSE #1

IF v = 1 THEN
'We run ARRAKIS and go back to main menu
SLEEP 1
IF nosound = 0 THEN SHELL "GAME.EXE"
IF nosound = 1 THEN SHELL "GAME.EXE /s"
KILL "GAME.EXE"
GOTO nogeens
END IF

IF v = 2 THEN
finish:
KILL "DATA\TEMPR.TMP"
CLS
PRINT "Thanks for playing Arrakis"
PRINT
PRINT "Version : 1.12"
PRINT
END
END IF

'V = 4
IF v = 4 THEN
SLEEP 1
CLS
'New map file should be in RMGMAP.OUT
OPEN "DATA\MAPS\RMGMAP.OUT" FOR INPUT AS #1
INPUT #1, f$
CLOSE #1
'Now go back
'Ok, now we should rename playing house filename....
'To know which house is playing, open up ARRAKIS.INI
OPEN "DATA\ARRAKIS.INI" FOR INPUT AS #1
INPUT #1, hss$                  'Actually Not important
INPUT #1, hss2$                 'Actually Not important
INPUT #1, enemycolor            'Actually Not important
INPUT #1, mycolor               'Actually Not important
INPUT #1, skipframes            'Actually Not important
INPUT #1, penemyhouse           'Important
INPUT #1, playinghouse          'Important
CLOSE #1
IF playinghouse = 0 THEN f2$ = "arrakis.lvl"
IF playinghouse = 1 THEN f2$ = "arrakis.lv1"
IF playinghouse = 2 THEN f2$ = "arrakis.lv2"

NAME f2$ AS "ARRAKIS.SKR"
OPEN f2$ FOR OUTPUT AS #1
PRINT #1, f$
CLOSE #1

'Now finally play
SHELL "GAME.EXE"

'Now delete temp skr
KILL f2$
NAME "ARRAKIS.SKR" AS f2$
'Level file undone
'Go back
KILL "GAME.EXE"
GOTO nogeens:
END IF

'V = 3
IF v = 3 THEN
SLEEP 1
CLS
'New map file should be in RMGMAP.OUT
OPEN "DATA\MAPS\RMGMAP.OUT" FOR INPUT AS #1
INPUT #1, f$
CLOSE #1
'Now go back
'Ok, now we should rename playing house filename....
'To know which house is playing, open up ARRAKIS.INI
OPEN "DATA\ARRAKIS.INI" FOR INPUT AS #1
INPUT #1, hss$                  'Actually Not important
INPUT #1, hss2$                 'Actually Not important
INPUT #1, enemycolor            'Actually Not important
INPUT #1, mycolor               'Actually Not important
INPUT #1, skipframes            'Actually Not important
INPUT #1, penemyhouse           'Important
INPUT #1, playinghouse          'Important
CLOSE #1
IF playinghouse = 0 THEN f2$ = "arrakis.lvl"
IF playinghouse = 1 THEN f2$ = "arrakis.lv1"
IF playinghouse = 2 THEN f2$ = "arrakis.lv2"

NAME f2$ AS "ARRAKIS.SKR"
OPEN f2$ FOR OUTPUT AS #1
PRINT #1, f$
CLOSE #1

'Now finally play
SHELL "GAME.EXE"

'Now delete temp skr
KILL f2$
NAME "ARRAKIS.SKR" AS f2$
'Level file undone
'Go back
KILL "GAME.EXE"
GOTO nogeens:
END IF


IF v < 1 OR v > 4 THEN
GOTO finish
END IF

