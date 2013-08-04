@echo off
:: By d4n13 < https://github.com/d4n13 >.  Don't forget to tip!
::   Ripple credit TipJar: rEXJQNj9frFgG3Wk3smqGFVdMUX53c7Fw4
::
setlocal
path=%path%;C:\Windows\Microsoft.NET\Framework\v4.0.30319
MSBuild ripple_cmd.csproj 
endlocal

