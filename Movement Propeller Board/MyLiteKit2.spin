{
  PROJECT: MyLiteKit2
  PLATFORM: Parallax Project USB Board
  REVISION: 3
  AUTHOR: Clement Low
  DATE: 170222
  LOG:
        170222 Updatee OBJ with new OBJ names
        230222 Added in Transmitter, Receiver and Mecanum
        240222 Updated new logic for function
        050322 Adding sensor condition before/after movement
        250322 Modified sensor condition for new movement
}


CON
        _clkmode = xtal1 + pll16x                             'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000
        _ConClkFreq = ((_clkmode - xtal1) >> 6 ) * _xinfreq
        _Ms_001 = _ConClkFreq / 1_000

        UltraSafe = 300
        TOFSafe   = 250
VAR

  long ToF[2], Ultra[4]
  long motorValue, motorSpeed
  long commValue, commSpeed
  long CogCheck, cogstack[8]

OBJ

  Term   : "FullDuplexSerial.spin"
  Trans  : "Transmitter.spin"
  Sen    : "MUXControl.spin"
  Mot    : "MecanumControl.spin"
  Comm   : "Comm2Control.spin"

PUB Main| i
'Main runs on Cog#0
'Start Serial Terminal
  'Term.Start (31, 30, 0, 230400)

'Start Receiver       on Cog#1&#2
  Comm.Start(_Ms_001, @commValue, @commSpeed)

'Start MecanumControl on Cog#3&#4
  Mot.Start(_Ms_001, @motorValue, @motorSpeed)

'Start MUX on            Cog#5
  Sen.Start(_Ms_001, @ToF, @Ultra)
'

{
'Used to check amount of cogs used
  'sCogCheck := cognew(Pause(1), @cogstack[64])
  'Term.Dec(CogCheck)
}

'Send command to MecanumControl depending on
'value received from Receiver
  repeat
    {Term.Dec(commValue)
    Term.Tx(13)
    Term.Dec(commSpeed)
    Term.Tx(13)
    }
'    commvalue := 11
'    commSpeed := 16
    case commValue
      1:'Forward
        if UltraFront AND ToFFront
          motorValue := commValue
          motorSpeed := commSpeed
        elseif !UltraFront OR !ToFFront
          motorValue := 11
      2:'Reverse
        if UltraBack AND ToFBack
          motorValue := commValue
          motorSpeed := commSpeed
        elseif !UltraBack OR !ToFBack
          motorValue := 11
      3:'Left
        if UltraLeft
          motorValue := commValue
          motorSpeed := commSpeed
        elseif !UltraLeft
          motorValue := 11
      4:'Right
        if UltraRight
          motorValue := commValue
          motorSpeed := commSpeed
        elseif !UltraRight
          motorValue := 11
      5:'TurnLeft
          motorValue := commValue
          motorSpeed := commSpeed
      6:'TurnRight
          motorValue := commValue
          motorSpeed := commSpeed
      7:'Topleft
        if UltraLeft AND UltraFront AND ToFFront
          motorValue := commValue
          motorSpeed := commSpeed
        elseif !UltraLeft OR !UltraFront OR !ToFFront
          motorValue := 11
      8:'TopRight
        if UltraRight AND UltraFront AND ToFFront
          motorValue := commValue
          motorSpeed := commSpeed
        elseif !UltraRight OR !UltraFront OR !ToFFront
          motorValue := 11
      9:'BtmLeft
        if UltraLeft AND UltraBack AND ToFBack
          motorValue := commValue
          motorSpeed := commSpeed
        elseif !UltraLeft OR !UltraBack OR !ToFBack
          motorValue := 11
      10:'BtmRight
        if UltraRight AND UltraBack AND ToFBack
          motorValue := commValue
          motorSpeed := commSpeed
        elseif !UltraRight OR !UltraBack OR !ToFBack
          motorValue := 11
      11:'Stop
        motorValue := commValue
        motorSpeed := commSpeed

   Pause(20)
PUB UltraFront
    return Ultra[0] > UltraSafe - 50

PUB UltraBack

    return Ultra[1] > UltraSafe

PUB UltraLeft

    return Ultra[2] > UltraSafe

PUB UltraRight

    return Ultra[3] > UltraSafe

PUB ToFFront

    return ToF[0] < 250

PUB ToFBack

    return ToF[1] < 250

PRI Pause(ms) | t
  t := cnt - 1088
  repeat (ms#>0)
    waitcnt(t+=_MS_001)
return