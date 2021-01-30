#!/usr/bin/env pwsh
param(
  [string]$payload
)

$ErrorActionPreference = "Stop"

function ParsePayload([string]$payload) {
  $json = ConvertFrom-Json $payload
  $guid = $json.guid
  if (!$guid) { 
    Write-Output "You have to pass the 'guid' parameter in query string"
    exit 1 
  }

  if (![guid]::TryParse($guid, $([ref][guid]::Empty))) {
    Write-Output "'$guid' does not appear to be a valid guid"
    exit 1 
  }

  $guid
}

$guid = ParsePayload $payload
$dns4meData  = curl -sS "$env:DNS4ME_URL/$guid"

$dns4meData = $dns4meData.replace("add name=","add regexp=")

# Trim too long regular expressions
[regex]$regex = '(?<head>add regexp=")(?<exp>[^"]*)(?<tail>".*)'
$dns4meData = $dns4meData -split "`n" | %{
  $m = $regex.Match($_)
  if ($m) {
    # strictly speaking this check is wrong since we need to check length after mikrotik string unescaping
    # but it would take more time to program and in most cases will work without
    $len = $m.Groups["exp"].Value.Length
    if ($len -gt 63) {
      $trimmed = $m.Groups["exp"].Value.Substring($len - 61,61).TrimStart(".\")
      $regex.Replace($_,"`${head}.*$trimmed`${tail}")
    } else {
      $_
    }
  } else {
    $_
  }
}

$dns4meData -join "`n"
