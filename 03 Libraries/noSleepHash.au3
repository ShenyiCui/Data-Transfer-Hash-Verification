While 1
   $pos = MouseGetPos()
   MouseMove(10,10,1)
   MouseMove($pos[0],$pos[1],1)
   Sleep(90000)
WEnd