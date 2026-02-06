$f = Get-Content 'c:\workcube\prod\documents\report\5560605B-BA40-44A6-1E209FF687575FC2.cfm' -Raw
$tags = @('cfif','cfloop','cftry','cfoutput','cfswitch')
foreach($t in $tags) {
  $open = ([regex]::Matches($f, "<$t[\s>]")).Count
  $close = ([regex]::Matches($f, "</$t>")).Count
  Write-Host "$t : open=$open close=$close"
}
$f2 = Get-Content 'c:\workcube\prod\documents\report\5560605B-BA40-44A6-1E209FF687575FC2.cfm.working_20260206' -Raw
Write-Host "--- WORKING FILE ---"
foreach($t in $tags) {
  $open = ([regex]::Matches($f2, "<$t[\s>]")).Count
  $close = ([regex]::Matches($f2, "</$t>")).Count
  Write-Host "$t : open=$open close=$close"
}
