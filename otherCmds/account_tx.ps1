## By d4n13 < https://github.com/d4n13 >.  Don't forget to tip!
##   Ripple credit TipJar: rEXJQNj9frFgG3Wk3smqGFVdMUX53c7Fw4 
##
## Git:  https://github.com/d4n13/ripple-ps-websocket.git
## Ref1: https://ripple.com/wiki/RPC_API#account_tx
##
$MyAccount = Read-Host -Prompt "Enter your gnarly ripple account"
$SnapSwap = "rMwjYedjc7qqtKYVLiAccJSmCwih4LnE2q"                                                    
$BitStamp = "rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B"
$command = @'
{
  "command": "account_tx",
  "account": "~ACCOUNT~",
  "ledger_index_min": "-1",
  "ledger_index_max": "-1"
}
'@
$command = $command.Replace("~ACCOUNT~", $MyAccount)

$st = ""
$size = 1024

$l = @(); $command.ToCharArray() | % {$l += [byte] $_}
$cm = New-Object System.ArraySegment[byte]  -ArgumentList @(,$l)
$l = [byte[]] @(,0) * $size
$rc = New-Object System.ArraySegment[byte]  -ArgumentList @(,$l)

$w = new-object System.Net.WebSockets.ClientWebSocket   
$c = New-Object System.Threading.CancellationToken 

$t = $w.ConnectAsync("wss://s1.ripple.com:443", $c)
    do { Start-Sleep -Milliseconds 100 }
    until ($t.IsCompleted)
  
$t = $w.SendAsync($cm, [System.Net.WebSockets.WebSocketMessageType]::Text, [System.Boolean]::TrueString, $c)
    do { Start-Sleep -Milliseconds 100 }
    until ($t.IsCompleted)

do {

   $t = $w.ReceiveAsync($rc, $c)
   do { Start-Sleep -Milliseconds 1 }
   until ($t.IsCompleted)

   $rc.Array[0..($t.Result.Count - 1)] | % { $st += [char]$_ }

} until ($t.Result.Count -lt $size)

$cs = new-object System.Net.WebSockets.WebSocketCloseStatus  
$t = $w.CloseAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, "NormalClosure", $c) 
do { Start-Sleep -Milliseconds 100 }
until ($t.IsCompleted)

$w | Select-Object *
$x = ConvertFrom-Json $st
if($x.result.transactions.tx)
{
    $x.result.transactions.tx
    $x.status
}
else { Write-Error "No tx found" }
