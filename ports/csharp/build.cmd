@echo off
::By d4n13 < https://github.com/d4n13 >.  Don't forget to tip!
::  Ripple credit TipJar: rEXJQNj9frFgG3Wk3smqGFVdMUX53c7Fw4
::
::Git:  https://github.com/d4n13/ripple-ps-websocket.git
::Note: See otherCmds directory for other commands.
::Reqs: Requires .NET 4.5 (aka 4.0.30319.18010; see Ref2)
::Erta: Warning MSB3644, benign, working to suppress
::Ref1: https://ripple.com/wiki/RPC_API#path_find
::Ref2: http://www.microsoft.com/en-us/download/details.aspx?id=30653
::Ref3: http://mutelight.org/using-the-little-known-built-in-net-json-parser
::Ref4: http://stackoverflow.com/a/9546397
::
setlocal
path=%path%;C:\Windows\Microsoft.NET\Framework\v4.0.30319
if exist "C:\Windows\Microsoft.NET\Framework\v4.0.30319\Microsoft.Internal.Tasks.Dataflow.dll" (
   MSBuild ripple_cmd.csproj 
) else (
   echo You have .Net 4.0, you NEED .Net 4.5
   echo http://www.microsoft.com/en-us/download/details.aspx?id=30653
)
endlocal

