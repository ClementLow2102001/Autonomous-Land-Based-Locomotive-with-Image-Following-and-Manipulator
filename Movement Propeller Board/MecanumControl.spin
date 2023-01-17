{
  PROJECT: MecanumControl
  PLATFORM: Parallax Project USB Board
  REVISION: 4
  AUTHOR: Clement Low
  DATE: 160222
  LOG:
        160222 Added Basic Movement in all 8 direction & Turning functionalities
        200222 Encapsulated the function to integrate with MyliteKit
        220222 Duty Cycle for some movement added
        240222 Added SpeedLimit(VAR), need to make it work with Pointer
}

CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000
        '_ConClkFreq = ((_clkmode - xtal1) >> 6 ) * _xinfreq
        '_Ms_001 = _ConClkFreq / 1_000

        'Motor pin allocation
         R1S1 = 3
         R1S2 = 2
         R2S1 = 5
         R2S2 = 4

        'BaudRate
         SSBaud = 57_600

        'Movement
        ShutDown     =  0
        FullReverse1 =  1
        FullForward1 =  127
        FullReverse2 = -127
        FullForward2 = -1

        'RightWheels
        Forward1     =  72
        Reverse1     =  56

        'LeftWheels
        Forward2     = -56
        Reverse2     = -72

        'Stop/-Stop for wheels
        Stop         =  64

        'SpeedLimit   =  16
VAR

  long cogNumID, cogStack[128]
  long _Ms_001
  long SpeedLimit

OBJ
  MD[2]    : "FullDuplexSerial.spin"
  Term     : "FullDuplexSerial.spin"
PUB Start(MSVal, Dir, speed)

  SpeedLimit := speed
  _Ms_001    := MSVal
  cogNumID   := cognew(Movement(Dir, speed), @cogStack)
PUB Movement(Dir, speed)

'  Term.Start (31, 30, 0, 115200)

'Start communication with RoboClaw
  Init
'Movement base on instruction received
  repeat
    case long[Dir]
      1:
        Forward
      2:
        Reverse
      3:
        Left
      4:
        Right
      5:
        TurnLeft
      6:
        TurnRight
      7:
        TopLeft
      8:
        TopRight
      9:
        BtmLeft
      10:
        BtmRight
      11:
        StopWheels

PUB StopWheels 'Stops all movement

MD[0].Tx(64)
MD[0].Tx(-64)
MD[1].Tx(64)
MD[1].Tx(-64)
PUB Init

MD[0].Start(R1S2,R1S1,0,SSBaud)
MD[1].Start(R2S2,R2S1,0,SSBaud)

PUB Forward

  MD[0].Tx(Stop   + long[SpeedLimit])
  MD[0].Tx(-Stop  + long[SpeedLimit])
  MD[1].Tx(Stop   + long[SpeedLimit])
  MD[1].Tx(-Stop  + long[SpeedLimit])
PUB Reverse

  MD[0].Tx(Stop   - long[SpeedLimit])
  MD[0].Tx(-Stop  - long[SpeedLimit])
  MD[1].Tx(Stop   - long[SpeedLimit])
  MD[1].Tx(-Stop  - long[SpeedLimit])
PUB Left

  MD[0].Tx(Stop  + long[SpeedLimit])
  MD[0].Tx(-Stop - long[SpeedLimit])
  MD[1].Tx(Stop  - long[SpeedLimit])
  MD[1].Tx(-Stop + long[SpeedLimit])
PUB Right

  MD[0].Tx(Stop  - long[SpeedLimit])
  MD[0].Tx(-Stop + long[SpeedLimit])
  MD[1].Tx(Stop  + long[SpeedLimit])
  MD[1].Tx(-Stop - long[SpeedLimit])
PUB TurnLeft

  MD[0].Tx(Stop  + long[SpeedLimit])
  MD[0].Tx(-Stop - long[SpeedLimit])
  MD[1].Tx(Stop  + long[SpeedLimit])
  MD[1].Tx(-Stop - long[SpeedLimit])
PUB TurnRight

  MD[0].Tx(Stop  - long[SpeedLimit])
  MD[0].Tx(-Stop + long[SpeedLimit])
  MD[1].Tx(Stop  - long[SpeedLimit])
  MD[1].Tx(-Stop + long[SpeedLimit])
PUB CornerLeft

  MD[0].Tx(Forward1)
  MD[1].Tx(Forward1)
  MD[0].Tx(-Stop)
  MD[1].Tx(-Stop)
PUB CornerRight

  MD[0].Tx(Forward2)
  MD[1].Tx(Forward2)
  MD[0].Tx(Stop)
  MD[1].Tx(Stop)
PUB CornerReverseLeft

  MD[0].Tx(Reverse1)
  MD[1].Tx(Reverse1)
  MD[0].Tx(-Stop)
  MD[1].Tx(-Stop)
PUB CornerReverseRight

  MD[0].Tx(Reverse2)
  MD[1].Tx(Reverse2)
  MD[0].Tx(Stop)
  MD[1].Tx(Stop)
PUB TopRight
  MD[0].Tx(Stop)
  MD[0].Tx(-Stop + long[SpeedLimit])
  MD[1].Tx(Stop  + long[SpeedLimit])
  MD[1].Tx(-Stop)

PUB TopLeft
  MD[0].Tx(Stop  + long[SpeedLimit])
  MD[0].Tx(-Stop)
  MD[1].Tx(Stop)
  MD[1].Tx(-Stop + long[SpeedLimit])

PUB BtmRight
  MD[0].Tx(Stop  - long[SpeedLimit])
  MD[0].Tx(-Stop)
  MD[1].Tx(Stop)
  MD[1].Tx(-Stop - long[SpeedLimit])

PUB BtmLeft
  MD[0].Tx(Stop)
  MD[0].Tx(-Stop - long[SpeedLimit])
  MD[1].Tx(Stop  - long[SpeedLimit])
  MD[1].Tx(-Stop)

PUB FlipCW

  MD[0].Tx(Reverse1)
  MD[0].Tx(Forward2)
  MD[1].Tx(Stop)
  MD[1].Tx(Stop)
PUB FlipACW

  MD[0].Tx(Forward1)
  MD[0].Tx(Reverse2)
  MD[1].Tx(Stop)
  MD[1].Tx(Stop)
PRI Pause(ms) | t
  t := cnt - 1088
  repeat (ms#>0)
    waitcnt(t+=_MS_001)
return{Object_Title_and_Purpose}