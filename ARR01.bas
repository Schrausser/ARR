!!
                 AudioRapidRecord
                  Audiorecorder
       © 2020-23 by Dietmar Gerald Schrausser
!!
_name$="ARR"
_ver$="v1.2.0"
INCLUDE strg.inc
cc=255
CONSOLE.TITLE _name$
! %Einstellungen
FILE.EXISTS fx, "arr.ini"
IF fx
 TEXT.OPEN r, arr, "arr.ini"
 TEXT.READLN arr, ini$:s00=VAL(ini$)
 TEXT.READLN arr, ini$:s01=VAL(ini$)
 TEXT.READLN arr, ini$:s02=VAL(ini$)
 TEXT.READLN arr, ini$:s03=VAL(ini$)
 TEXT.READLN arr, ini$:swc=VAL(ini$)
 TEXT.READLN arr, ini$:fp$=ini$
 TEXT.CLOSE arr
ELSE
 s00=-1
 s01=-1
 s02=1
 s03=1
 swc=1
 fp$="Light"
ENDIF
!
pat$="../../ARR/"
swad=0
sec1=0
min1=0
h1=0
dlg=1
inf=1
fs=1
!
IF s01=-1 
 rn=1
ELSE
 rn=0
ENDIF
!
SENSORS.OPEN 8
st0:
!
IF swc=0 THEN GR.OPEN 240,cc,cc,cc,0,1
IF swc=1 THEN GR.OPEN cc,0,0,0,0,1
!
GR.SCREEN sx,sy
mx=sx/2:my=sy/2
!
IF s00=-1
 IF dlg=1 THEN  GOSUB dialog
ENDIF
!
IF dlg=0
 dlg=1
 GR.CLOSE
 GOTO st0
ENDIF
fs=0
!
st:
GR.CLS 
!
IF s03=1
 TONE 2000,90
 PAUSE 200
ENDIF
!
GOSUB time
fn$="ARR"+Y$+M$+D$+h$+min$+sec$
af$=pat$+fn$+".mp3"
!
AUDIO.RECORD.START af$
!
sec0=sec
DO
 GR.CLS
 IF swc=0 THEN GR.COLOR cc/2,0,0,0,1
 IF swc=1 THEN GR.COLOR cc/3,cc,cc,cc,1
 GOSUB time
 IF sec<>sec0
  sec0=sec
  sec1=sec1+1
  IF sec1=60 
   sec1=0
   min1=min1+1
   IF min1=60
    min1=0
    h1=h1+1
   ENDIF
  ENDIF
 ENDIF
 GOSUB text
 GR.TEXT.ALIGN 2
 GR.TEXT.SIZE sx/10
 GR.TEXT.BOLD 1
 rtim$= FORMAT$("%%",h1)+FORMAT$("%%",min1)+FORMAT$("%%",sec1)
 GR.TEXT.DRAW tx,mx,my+sx/6,"["+rtim$+" ]"
 GR.TEXT.DRAW tx,mx,my,"REC... ["+INT$(rn)+"]"
 GR.COLOR cc,cc,0,0,1
 GR.CIRCLE cl,sx/20,sy/15,sx/25
 GR.RENDER
 SENSORS.READ 8,dx,dx,bwg
 GOSUB tc_
UNTIL bwg=1
sec1=0
min1=0
h1=0
!
AUDIO.RECORD.STOP
!
IF s03=1 THEN TONE 1000,80
IF s01=1 %Auto delete
 FILE.DELETE dl,af$
ENDIF
!
DO
 SENSORS.READ 8,dx,dx,bwg
UNTIL bwg=0
!
DO
 GR.CLS
 IF swc=0 THEN GR.COLOR cc/2,0,0,0,1
 IF swc=1 THEN GR.COLOR cc/3,cc,cc,cc,1
 GOSUB time
 GOSUB text
 GR.TEXT.ALIGN 2
 GR.TEXT.SIZE sx/8
 GR.TEXT.BOLD 1
 GR.TEXT.DRAW tx,mx,my+sx/6,"Stop"
 GR.COLOR cc,0,cc,0,1
 GR.CIRCLE cl,sx/20,sy/15,sx/25
 GR.RENDER
 SENSORS.READ 8,dx,dx,bwg
 GOSUB tc_
UNTIL bwg=1
!
DO
 SENSORS.READ 8,dx,dx,bwg
UNTIL bwg=0
!
IF s01=-1
 rn=rn+1
ENDIF
!
IF dlg=1 
 GOTO st
ELSE
 dlg=1
 GR.CLOSE
 GOTO st0
ENDIF
!
ONMENUKEY:
GOSUB dialog
MENUKEY.RESUME
ONBACKKEY:
GOSUB fin
END
!
TIME:
TIME Y$, M$, D$, h$, min$, sec$
yr=VAL(Y$)
sec=VAL(sec$)
nt=VAL(D$)
nm=VAL(M$)
st=VAL(h$)
min=VAL(min$)
RETURN
!
tc_:
GR.TOUCH tc,tx,ty
IF tc THEN GOSUB dialog
RETURN
!
text:
GR.TEXT.ALIGN 3
GR.TEXT.SIZE sx/20
GR.TEXT.BOLD 1
GR.TEXT.DRAW tx,sx,sy/35,D$+"."+M$+"."+Y$
GR.TEXT.ALIGN 1
GR.TEXT.DRAW tx,sx/500,sy/35,h$+":"+min$+"."+sec$
RETURN
!
dialog:
smb$=CHR$(9989)
smq$=CHR$(9654)
GOSUB menu
std:
ARRAY.LOAD sel$[],o00$,o01$,o02$,o03$,"Ok","exit" %,o03$,o04$,o05$,o06$,o08$,o09$,o07$,o10$,"Ok"
DIALOG.SELECT sel, sel$[],"ARR AudioRapidRecord "+_ver$+" - Options:"
IF sel=1:s00=s00*-1:ENDIF
IF sel=2
 rn0=rn0+rn
 s01=s01*-1
 IF s01=1
  rn=0
 ELSE 
  rn=rn0
  IF rn=0 THEN rn=1
 ENDIF
ENDIF
IF sel=3 & fs=1
 GOSUB dialogf
 inf=0:dlg=0
ENDIF
IF sel=4:s03=s03*-1: ENDIF
IF sel=5:RETURN    : ENDIF
IF sel=6:GOSUB fin: END: ENDIF
GOSUB menu
GOTO std
RETURN
!
menu:
IF s00=1:o00$=smb$+"  Auto Start":ENDIF
IF s00=-1: o00$="     Auto Start off":  ENDIF
IF s01=1:o01$=smb$+"  Auto Delete":ENDIF
IF s01=-1: o01$="     Auto Delete off":  ENDIF
o02$=smq$+"  Scheme: "+fp$
IF s03=1:o03$=smb$+"  Signal":ENDIF
IF s03=-1: o03$="     Signal off":  ENDIF
RETURN
!
dialogf:
f01$="Light"
f02$="Dark"
ARRAY.LOAD sel1$[],f01$,f02$
DIALOG.SELECT sel1, sel1$[],"Color Scheme:"
IF sel1=1:swc=0:fp$="Light":ENDIF
IF sel1=2:swc=1:fp$="Dark":ENDIF
RETURN
!
fin:
AUDIO.RECORD.STOP
AUDIO.STOP
IF s03=1 THEN TONE 1000,80
FILE.EXISTS fa,af$
IF fa & s01=1
 FILE.DELETE dl,af$
ENDIF
! %Einstellungen
TEXT.OPEN w, arr, "arr.ini"
TEXT.WRITELN arr, s00
TEXT.WRITELN arr, s01
TEXT.WRITELN arr, s02
TEXT.WRITELN arr, s03
TEXT.WRITELN arr, swc
TEXT.WRITELN arr, fp$
TEXT.CLOSE arr
PRINT _name$+" AudioRapidRecord "+_ver$         
PRINT "Copyright "+_cr$+" 2023 by Dietmar Gerald SCHRAUSSER"
PRINT "https://github.com/Schrausser/ARR"
RETURN
! // END //
! //
