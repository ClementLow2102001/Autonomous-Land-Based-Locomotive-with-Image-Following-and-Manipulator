 {
  PROJECT: Comm2Control
  PLATFORM: Parallax Project USB Board
  REVISION: 2
  AUTHOR: Clement Low
  DATE: 170222
  LOG:
        170222 Created logic for receiving and checksum
        240322 Added commSpeed as a parameter
        050322 Edited to suit Cortex as a receiver
}



CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000
        '_ConClkFreq = ((_clkmode - xtal1) >> 6 ) * _xinfreq
        '_Ms_001 = _ConClkFreq / 1_000

        commStart     = $7A
        commForward   = $01
        commReverse   = $02
        commLeft      = $03
        commRight     = $04
        commTurnLeft  = $05
        commTurnRight = $06
        commTopLeft   = $07
        commTopRight  = $08
        commBtmLeft   = $09
        commBtmRight  = $0A
        commStopAll   = $0B
        commEndByte   = $7B
        commChecksum  = $7F


VAR

  long _Ms_001
  long cogCommID, rxValue
  long cogStack[128]
  long array[4]

OBJ
  RTX      : "FullDuplexSerial.spin"
  Comm     : "FullDuplexSerial.spin"

PUB Start(MSVal, commValue, commSpeed)

  _Ms_001   := MSVal
  cogCommID := cognew(Rx(commValue, commSpeed), @cogStack)

PUB Rx(commValue, commSpeed)|i

'Start Receiving Terminal
  RTX.Start(27, 26, 0, 115200)

'Start Serial Terminal
  Comm.Start(31, 30, 0, 230400)

'Checking for a input
  repeat
    'Comm.Str(String(13, "CommValue: "))
    'Comm.Dec(long[commValue])
    'Comm.Tx(13)
    i := 0
    array[0] := 0
    rxValue := RTX.Rx

    'Comm.Hex(rxValue,2)
    'Comm.Tx(13)

    if rxValue == commStart

      'Comm.Str(String(13, "Array:"))
      'Comm.Tx(13)

      repeat while rxValue <>= commEndByte
        rxValue := RTX.Rx
        'if rxValue > $00
          array[i] := rxValue
          'Comm.Hex(array[i],2)
          'Comm.Tx(13)
          i++
      if array[0] ^ array[1] == array[2] ^ commChecksum
        'Comm.Str(String(13, "Checks: "))
        'Comm.Hex(array[0],2)
        case array[0]
          1:
            Comm.Str(String(13, "Forward"))
          2:
            Comm.Str(String(13, "Reverse"))
          3:
            Comm.Str(String(13, "Left"))
          4:
            Comm.Str(String(13, "Right"))
          7:
            Comm.Str(String(13, "TopLeft"))
          8:
            Comm.Str(String(13, "TopRight"))
          9:
            Comm.Str(String(13, "BtmLeft"))
          10:
            Comm.Str(String(13, "BtmRight"))
          11:
            Comm.Str(String(13, "Stop"))
          other:
            Comm.Str(String(13, "Default"))

        long[commValue] := array[0]
        long[commSpeed] := array[1]
  return

PRI Pause(ms) | t
  t := cnt - 1088
  repeat (ms#>0)
    waitcnt(t+=_MS_001)
return