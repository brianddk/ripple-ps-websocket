$SnapSwap = "rMwjYedjc7qqtKYVLiAccJSmCwih4LnE2q"                                                    
$BitStamp = "rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B"
$create = @'
{
  "command": "path_find",
  "subcommand": "create",
  "source_account": "~FROM~",
  "destination_account": "~TO~",
  "destination_amount": "~AMOUNT~/USD/~TO~",
  "source_currencies": [{"currency":"USD","issuer":"~FROM~"}]
}
'@

$create = $create.Replace("~AMOUNT~", "5000")
$create = $create.Replace("~TO~", $SnapSwap)
$create = $create.Replace("~FROM~", $BitStamp)

$status = @'
{
  "command": "path_find",
  "subcommand": "status"
}
'@

$close = @'
{
  "command": "path_find",
  "subcommand": "close"
}
'@

$st = ""
$size = 1024

$l = @(); $create.ToCharArray() | % {$l += [byte] $_}          
$cr = New-Object System.ArraySegment[byte]  -ArgumentList @(,$l)
$l = @(); $status.ToCharArray() | % {$l += [byte] $_}          
$st = New-Object System.ArraySegment[byte]  -ArgumentList @(,$l)
$l = @(); $close.ToCharArray() | % {$l += [byte] $_}          
$cl = New-Object System.ArraySegment[byte]  -ArgumentList @(,$l)
$l = [byte[]] @(,0) * $size
$rc = New-Object System.ArraySegment[byte]  -ArgumentList @(,$l)

$w = new-object System.Net.WebSockets.ClientWebSocket                                                
$c = New-Object System.Threading.CancellationToken                                                   

$t = $w.ConnectAsync("wss://s1.ripple.com:443", $c)                                                  
    do { Start-Sleep -Milliseconds 100 }
    until ($t.IsCompleted)
                                                                                       
$t = $w.SendAsync($cr, [System.Net.WebSockets.WebSocketMessageType]::Text, [System.Boolean]::TrueString, $c)
    do { Start-Sleep -Milliseconds 100 }
    until ($t.IsCompleted)

$t = $w.SendAsync($st, [System.Net.WebSockets.WebSocketMessageType]::Text, [System.Boolean]::TrueString, $c)
    do { Start-Sleep -Milliseconds 100 }
    until ($t.IsCompleted)


do {

    $t = $w.ReceiveAsync($rc, $c)
        do { Start-Sleep -Milliseconds 100 }
        until ($t.IsCompleted)

    $rc.Array[0..($t.Result.Count - 1)] | % { $st += [char]$_ }

} until ($t.Result.Count -lt $size)

$t = $w.SendAsync($cl, [System.Net.WebSockets.WebSocketMessageType]::Text, [System.Boolean]::TrueString, $c)
    do { Start-Sleep -Milliseconds 100 }
    until ($t.IsCompleted)

$cs = new-object System.Net.WebSockets.WebSocketCloseStatus                                          
$t = $w.CloseAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, "NormalClosure", $c) 
do { Start-Sleep -Milliseconds 100 }
until ($t.IsCompleted)

$w | Select-Object *
$x = ConvertFrom-Json $st
if($x.result.alternatives)
{
    $x.result.alternatives.source_amount
    $x.result.alternatives.paths_computed
    $x.status
}
else { Write-Error "No Path Found" }
