{
  PROJECT: MUXControl
  PLATFORM: Parallax Project USB Board
  REVISION: 2
  AUTHOR: Clement Low
  DATE: 141121
  LOG:
        141121 Added UltraSensor & ToFSensor
        211121 Added Cognew functions and made program
               a sub-program for MyLiteKit
        070222 Added 2 UltraSensor to the Left&Right
}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000
        '_ConClkFreq = ((_clkmode - xtal1) >> 6 ) * _xinfreq
        '_Ms_001 = _ConClkFreq / 1_000

        'MUX pin allocation
        MUXSCL   = 8
        MUXSDA   = 9
        Reset    = 10

        'Ultra Address
        UltraAdd = $57

        'TOF Front RST pin
        Tofone  = 6
        'TOF Back RST pin
        Toftwo  = 7
        'TOF Address
        TofAdd   = $29

VAR

  long _Ms_001
  long cog1ID
  long cogStack[128]

OBJ
  MUX   : "TCA9548Av2.spin"
  Term  : "FullDuplexSerial.spin"
PUB Start(MSVal, ToF, Ultra)

  _Ms_001 := MSVal
  cog1ID := cognew(getReading(ToF, Ultra), @cogStack)

  return

PUB getReading(ToF, Ultra)| i

  Init
  repeat
    repeat i from 0 to 1
     'Tof Sensors
      MUX.PSelect(i,0)
      long[ToF][i] := MUX.GetSingleRange(TofAdd)
      Pause(10)

    repeat i from 2 to 5
      'Ultra Sensors
      MUX.PSelect(i,0)
      MUX.PWriteByte(i, UltraAdd, $01)
      Pause(30)
      long[Ultra][i-2] := MUX.readHCSR04(i, UltraAdd)*100/254
      Pause(10)
      MUX.resetHCSR04(i, UltraAdd)

PUB Init
'P1 Terminal
  'Term.Start (31, 30, 0, 115200)

'Init MUX
  MUX.PInit2
  Pause(100)

'Init TOF
  MUX.PSelect(0,0)
  tofInit(0)
  Pause(100)
  MUX.PSelect(1,0)
  tofInit(1)
  Pause(100)

  return

PUB Stop
  if cog1ID
    cogstop(cog1ID~)

PRI tofInit(x)

  case x
    0:
      MUX.initVL6180X(TofOne)
      MUX.ChipReset(1, TofOne)
      Pause(1000)
      MUX.FreshReset(TofAdd)
      MUX.MandatoryLoad(TofAdd)
      MUX.RecommendedLoad(TofAdd)
      MUX.FreshReset(TofAdd)
    1:
      MUX.initVL6180X(TofTwo)
      MUX.ChipReset(1, TofTwo)
      Pause(1000)
      MUX.FreshReset(TofAdd)
      MUX.MandatoryLoad(TofAdd)
      MUX.RecommendedLoad(TofAdd)
      MUX.FreshReset(TofAdd)

PRI Pause(ms) | t
  t := cnt - 1088
  repeat (ms#>0)
    waitcnt(t+=_MS_001)
return