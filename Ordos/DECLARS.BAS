'$INCLUDE: 'directqb.bi'
'$DYNAMIC
DECLARE SUB readbriefingit ()

COMMON SHARED mapsight(), maptile(), mapunit(), mapstruct(), foundothergoal, musthavecredits, fouttekenen, harvested
COMMON SHARED mx, my, mousecell, white, x1, y1, x2, y2, checkunits, mousec, checkstr, credits
COMMON SHARED bar1, bar2, bar1t, bar2t, pro1, pro2, pro1c, pro2c, bouwdie1, bouwdie2
COMMON SHARED prijs1, prijs2, ready1, ready2, die1, die2, checkplace, hoogte, breedte, mousex, mousey, checkresults
COMMON SHARED power, spice, haveconst, haverefinery, haveradar, havetent, havewind, havewar, haverepair, haveradara
COMMON SHARED maxx, maxy, minx, miny, tijd, n$, e$, frame, showframe, frme, friendfound, enemyfound, enemies
COMMON SHARED magchecken, minutes, hours, seconds, showtime, aihavetent, aihavewar, aihaveconst, message$, messagetijd, wachten, soortai, attacktime
COMMON SHARED spelennr, messagenr, nr1, nr2, nr3, afspelen, Offset&, dontplay2, kills, losts
COMMON SHARED showtip, skipframe, nosound, aihaverepair, lvl, readbriefing, nu, mustquit, settimer, aihaveradar, techlevel, resetten

COMMON SHARED aitime(), aitime2(), aitype(), aicell(), aidead()
COMMON SHARED bulld(), bullc(), bullc3(), bullc2(), bullx(), bully(), bullx2(), bully2(), bullt(), bulld2(), bullf()
COMMON SHARED deadd(), deadc(), deadt(), deadc2(), deadx(), deady(), deadf()
COMMON SHARED structc2(), structc(), structt(), structt2(), structp(), structs(), structd(), structa()
COMMON SHARED unitfi2(), unitfi(), units3(), unitsp(), unitd(), unita(), unitc(), unitwc(), unitmc(), unitx(), unity(), unitcap(), unitp(), units2(), unitf(), unitt(), unitt2(), units(), unitc6(), unitc5(), unitc4(), unitc3(), unitc2(), unitfac(),  _
unitf3(), unitc7(), unitg()

COMMON SHARED level$(), able2play, enemyhousename$, myhousename$, enemycolor, mycolor
soortai = -1
mousec = 0
DIM SHARED textu(35)                    'For textured text
DIM SHARED level$(30)                   'MAX Levels 30
DIM SHARED pal AS STRING * 786         'Dimension PALette
DIM SHARED mapsight(4095)               'cells that are exposed
DIM SHARED maptile(4095)                '4095 Map tiles, 64X64 Map
DIM SHARED mapunit(4095)                'For unit collision,also id info
DIM SHARED mapstruct(4095)              'For unit collision,also id info
x1 = -1: y1 = -1                        'For multi-selection code
'AI
DIM SHARED aitime2(50)                  'Time in seconds to add
DIM SHARED aitime(50)                   'Time in seconds
DIM SHARED aitype(50)                   'Type
DIM SHARED aicell(50)                   'Cell to place ai structure on
DIM SHARED aidead(50)                   'AI dead flag

'BULLETS, ROCKETS etc
DIM SHARED bulld(100)                   'Bullet Dead flag
DIM SHARED bullc(100)                   'Bullet Cell
DIM SHARED bullc2(100)                  'Bullet Destenation Cell
DIM SHARED bullc3(100)                  'Bullet Correction
DIM SHARED bullx(100)                   'Bullet X
DIM SHARED bully(100)                   'Bullet Y
DIM SHARED bullx2(100)                  'Bullet to increase X
DIM SHARED bully2(100)                  'Bullet to increase Y
DIM SHARED bullt(100)                   'Bullet Type
DIM SHARED bulld2(100)                  'Bullet Damage
DIM SHARED bullf(100)                   'Bullet Facing  (for rockets)

'DEAD UNITS
DIM SHARED deadd(100)                    'Dead object dead flag
DIM SHARED deadc(100)                    'Dead cell
DIM SHARED deadt(100)                    'Dead type
DIM SHARED deadc2(100)                   'Dead counter
DIM SHARED deadx(100)                    'Dead X
DIM SHARED deady(100)                    'Dead Y
DIM SHARED deadf(100)                    'Dead Frame

'STRUCTURES
DIM SHARED structc2(100)                'Structure Count
DIM SHARED structc(100)                 'Structure CELL
DIM SHARED structt(100)                 'Structure TYPE
DIM SHARED structt2(100)                'Structure TEAM
DIM SHARED structp(100)                 'Structure POWER
DIM SHARED structs(100)                 'Structure SELECT flag
DIM SHARED structd(100)                 'Structure death flag
DIM SHARED structa(100)                 'Structure ACTION (<>0 =REPAIR)
'UNITS
DIM SHARED unitfi2(100)                  'Structure follow number
DIM SHARED unitfi(100)                  'Unit follow number
DIM SHARED units3(100)                  'Unit animation for soldiers
DIM SHARED unitsp(100)                  'Unit Spiced cell
DIM SHARED unitd(100)                   'Unit death flag, <> 0 is live.
DIM SHARED unita(100)                   'Unit Action! (0=MOVE,1=ATTACK,2=HARVEST)
DIM SHARED unitc(100)                   'Unit CELL
DIM SHARED unitwc(100)                  'Unit WAS-CELL
DIM SHARED unitmc(100)                  'Unit MOVE-CELL
DIM SHARED unitx(100)                   'Unit Graphical X
DIM SHARED unity(100)                   'Unit Graphical Y
DIM SHARED unitcap(100)                 'Unit Capacity
DIM SHARED unitp(100)                   'Unit Power
DIM SHARED units2(100)                   'Unit Speed
DIM SHARED unitf(100)                   'Unit FRAME
DIM SHARED unitt(100)                   'Unit Type
DIM SHARED unitt2(100)                  'Unit TEAM
DIM SHARED units(100)                   'Unit Selected?
DIM SHARED unitc6(100)                  'Unit COUNT function, for attacking..
DIM SHARED unitc5(100)                  'Unit COUNT function, for turning etc..
DIM SHARED unitc4(100)                  'Unit COUNT function, for turning etc..
DIM SHARED unitc3(100)                  'Unit COUNT function, for turning etc..
DIM SHARED unitc2(100)                  'Unit COUNT function, for turning etc..
DIM SHARED unitfac(100)                 'Unit FACING:
                                        '0 = UP
                                        '1 = UP-RIGHT
                                        '2 = RIGHT
                                        '3 = DOWN-RIGHT
                                        '4 = DOWN
                                        '5 = DOWN-LEFT
                                        '6 = LEFT
                                        '7 = UP-LEFT

DIM SHARED unitf3(100)
DIM SHARED unitc7(100)
DIM SHARED unitg(100)                   'Unit GROUP number


 

