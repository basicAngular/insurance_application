On Error Resume Next

Const wbemFlagReturnImmediately = &h10
Const wbemFlagForwardOnly = &h20

arrComputers = Array(".")
For Each strComputer In arrComputers
   Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
   Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_ComputerSystem", "WQL", _
                                          wbemFlagReturnImmediately + wbemFlagForwardOnly)

   For Each objItem In colItems
      WScript.Echo objItem.Model
   Next
Next

