'AI EDITOR
'COPYRIGHTED BY STEFAN HENDRIKS!

INPUT "File?:", file$
file$ = file$ + ".map"
OPEN file$ FOR APPEND AS #1
PRINT #1, "-1,-1"
weer1:
CLS
PRINT "Starting Structures"
PRINT "-------------------"
PRINT
INPUT "Team?:", team
INPUT "Cell :", cell
INPUT "Structure:", str
PRINT #1, team; ","; str; ","; cell
INPUT "Again? 0 YES, <> 0 NO", dummy
IF dummy = 0 THEN GOTO weer1
PRINT #1, "-1,-1,-1"
weer2:
CLS
PRINT "Starting Units"
PRINT "--------------"
INPUT "Team?:", team
INPUT "Cell :", cell
INPUT "Move-Cell:", mcell
IF mcell = 0 AND cell <> 0 THEN mcell = cell
INPUT "Unit Type:", tpe
INPUT "Action:", action
PRINT #1, team; ","; tpe; ","; cell; ","; mcell; ","; action
INPUT "Again? 0 YES, <> 0 NO", dummy
IF dummy = 0 THEN GOTO weer2
PRINT #1, "-1,-1,-1,-1,-1"
weer3:
CLS
PRINT "AI/TRIGGERS"
PRINT "-----------"
INPUT "Type? 1 = AI, 2 = TRIGGER:", tpe
IF tpe <= 0 THEN tpe = 1
IF tpe > 2 THEN tpe = 2
IF tpe = 1 THEN
INPUT "Time:", tme
INPUT "Building Type:", btpe
INPUT "Cell:", cell
PRINT #1, tme; ","; btpe; ","; cell; ","; tpe
INPUT "Again? 0 YES, <> 0 NO", dummy
IF dummy = 0 THEN GOTO weer3
GOTO nomore
END IF

IF tpe = 2 THEN
cell = 0
INPUT "Type Trigger:", trigger
IF trigger = 0 THEN INPUT "Cell to nuke:", cell
IF trigger = 1 THEN INPUT "Set time to :", cell
'TRIGGER2 = ALL RADARS DESTROYED, SO NOTHING ELSE TO FILL IN
IF trigger = 3 THEN INPUT "Cell to reveal:", cell
IF trigger = 4 THEN INPUT "Credits amount:", cell
IF trigger = 5 THEN INPUT "Cell to move Reinforcement to:", cell
'TRIGGER = 6 = ALL FACTORIES TO DESTROY, NOTHIN ELSE TO FILL IN
IF trigger = 7 THEN INPUT "Cell to send units to:", cell

IF trigger = 5 THEN INPUT "Time in seconds to send reinforcement:", time
IF trigger = 3 THEN INPUT "Cell to move over for revealing:", time
IF trigger <> 3 AND trigger <> 5 THEN INPUT "Time:", time
PRINT #1, time; ","; trigger; ","; cell; ","; tpe
INPUT "Again? 0 YES, <> 0 NO", dummy
IF dummy = 0 THEN GOTO weer3
GOTO nomore

END IF

nomore:

PRINT #1, "-1,-1,-1,-1"

INPUT "Starting Credits:", credits
INPUT "TechLevel:", tech
PRINT #1, credits; ","; tech
CLOSE #1
PRINT
PRINT "Thanks for using"
END

