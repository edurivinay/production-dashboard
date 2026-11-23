
param([int]$Port = 8765)
$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $Root) { $Root = (Get-Location).Path }
Set-Location $Root

function Get-LanIPs {
  $list = @()
  try {
    Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
      Where-Object { $_.IPAddress -notlike '127.*' -and $_.PrefixOrigin -ne 'WellKnown' } |
      ForEach-Object { $list += $_.IPAddress }
  } catch {}
  if (-not $list.Count) {
    try {
      $list += (Test-Connection -ComputerName (hostname) -Count 1 -ErrorAction SilentlyContinue).IPV4Address.IPAddressToString
    } catch {}
  }
  return $list
}

$listener = $null
$started = $false
foreach ($p in ($Port..($Port+20))) {
  try {
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://+:$p/")
    $listener.Start()
    $Port = $p
    $started = $true
    break
  } catch {
    try {
      $listener = New-Object System.Net.HttpListener
      $listener.Prefixes.Add("http://127.0.0.1:$p/")
      $listener.Start()
      $Port = $p
      $started = $true
      break
    } catch { $listener = $null }
  }
}
if (-not $started) { throw "Cannot bind port. Run as Admin or close other MISO windows." }

$ips = Get-LanIPs
Write-Host "========================================================"
Write-Host " MISO Ribbon Dashboard — LIVE SHARED HOST"
Write-Host " This PC:     http://127.0.0.1:$Port/"
foreach ($ip in $ips) { Write-Host " Other users: http://${ip}:$Port/" }
Write-Host " Auto Sync:   http://127.0.0.1:$Port/data.json"
Write-Host " Data folder: $Root"
Write-Host "========================================================"
Start-Process "http://127.0.0.1:$Port/"

$mime = @{
  '.html'='text/html; charset=utf-8'; '.htm'='text/html; charset=utf-8'
  '.js'='application/javascript'; '.css'='text/css'; '.json'='application/json; charset=utf-8'
  '.png'='image/png'; '.jpg'='image/jpeg'; '.jpeg'='image/jpeg'; '.gif'='image/gif'
  '.svg'='image/svg+xml'; '.ico'='image/x-icon'; '.woff'='font/woff'; '.woff2'='font/woff2'
}

while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  $req = $ctx.Request
  $res = $ctx.Response
  try {
    $res.AddHeader('Access-Control-Allow-Origin', '*')
    $res.AddHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
    $res.AddHeader('Access-Control-Allow-Headers', 'Content-Type')
    $res.AddHeader('Cache-Control', 'no-cache, no-store, must-revalidate')

    if ($req.HttpMethod -eq 'OPTIONS') {
      $res.StatusCode = 204
      continue
    }

    $local = [Uri]::UnescapeDataString($req.Url.LocalPath)
    if ($local -eq '/data.json' -or $local -eq '/api/data') {
      if ($req.HttpMethod -eq 'POST') {
        $reader = New-Object System.IO.StreamReader($req.InputStream, $req.ContentEncoding)
        $body = $reader.ReadToEnd()
        $reader.Close()
        $null = $body | ConvertFrom-Json  # validate
        $path = Join-Path $Root 'data.json'
        [System.IO.File]::WriteAllText($path, $body, [System.Text.UTF8Encoding]::new($false))
        try { [System.IO.File]::WriteAllText((Join-Path $Root 'data_last.json'), $body, [System.Text.UTF8Encoding]::new($false)) } catch {}
        $out = [Text.Encoding]::UTF8.GetBytes('{"ok":true,"saved":"data.json"}')
        $res.StatusCode = 200
        $res.ContentType = 'application/json'
        $res.ContentLength64 = $out.Length
        $res.OutputStream.Write($out, 0, $out.Length)
        Write-Host "[SAVE] data.json updated"
      } else {
        $path = Join-Path $Root 'data.json'
        if (Test-Path -LiteralPath $path) {
          $bytes = [System.IO.File]::ReadAllBytes($path)
        } else {
          $bytes = [Text.Encoding]::UTF8.GetBytes('{"executive":null,"message":"No report uploaded yet"}')
        }
        $res.StatusCode = 200
        $res.ContentType = 'application/json; charset=utf-8'
        $res.ContentLength64 = $bytes.Length
        $res.OutputStream.Write($bytes, 0, $bytes.Length)
      }
      continue
    }

    if ($req.HttpMethod -ne 'GET') {
      $res.StatusCode = 405
      continue
    }

    $path = $local.TrimStart('/')
    if ([string]::IsNullOrWhiteSpace($path)) { $path = 'index.html' }
    $full = [System.IO.Path]::GetFullPath((Join-Path $Root $path))
    $rootFull = [System.IO.Path]::GetFullPath($Root)
    if (-not $full.StartsWith($rootFull)) {
      $res.StatusCode = 403
    } elseif (-not (Test-Path -LiteralPath $full -PathType Leaf)) {
      $res.StatusCode = 404
      $buf = [Text.Encoding]::UTF8.GetBytes('Not found')
      $res.OutputStream.Write($buf, 0, $buf.Length)
    } else {
      $ext = [System.IO.Path]::GetExtension($full).ToLowerInvariant()
      $res.ContentType = $(if ($mime.ContainsKey($ext)) { $mime[$ext] } else { 'application/octet-stream' })
      $bytes = [System.IO.File]::ReadAllBytes($full)
      $res.ContentLength64 = $bytes.Length
      $res.OutputStream.Write($bytes, 0, $bytes.Length)
    }
  } catch {
    try {
      $res.StatusCode = 500
      $buf = [Text.Encoding]::UTF8.GetBytes($_.Exception.Message)
      $res.OutputStream.Write($buf, 0, $buf.Length)
    } catch {}
  } finally {
    try { $res.OutputStream.Close() } catch {}
  }
}
