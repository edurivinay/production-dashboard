
Set sh = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
dir = fso.GetParentFolderName(WScript.ScriptFullName)
' Prefer pythonw silent
On Error Resume Next
sh.Run "pythonw --version", 0, True
If Err.Number = 0 Then
  sh.Run "pythonw """ & dir & "\server.py""", 0, False
Else
  Err.Clear
  sh.Run "powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & dir & "\Start-Dashboard.ps1""", 0, False
End If
