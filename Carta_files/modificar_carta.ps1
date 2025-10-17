# Script PowerShell para modificar la carta
$inputFile = "240_landing_v1760456517.html"
$outputFile = "240_landing_v1760456517.html"

# Leer todo el contenido del archivo
$content = Get-Content $inputFile -Raw -Encoding UTF8

# 1. ELIMINAR TODOS LOS PRECIOS
# Eliminar divs con clase precio-productos
$content = $content -replace '<div class="precio-productos"[^>]*>.*?</div>', ''

# 2. EXPANDIR DESCRIPCIONES TRUNCADAS
# Buscar y reemplazar descripciones que terminan con "..."
# Patrón: buscar descripción truncada y reemplazar con la completa del atob

# Función auxiliar para decodificar base64
function Decode-Base64 {
    param([string]$encoded)
    try {
        $bytes = [System.Convert]::FromBase64String($encoded)
        return [System.Text.Encoding]::UTF8.GetString($bytes)
    }
    catch {
        return ""
    }
}

# Procesar cada producto
$pattern = '(<div class="descripcion-productos"[^>]*>)([^<]+\.\.\.)(<\/div><\/a><div[^>]*><button[^>]*onclick="addToCart[^>]*><\/button>)(<\/div><\/div><\/div><div[^>]*><a[^>]*onclick="showImage[^,]+,\s*[^,]+,\s*decodeURIComponent\(escape\(atob\(''([^'']+)''\)\)\))'

$matches = [regex]::Matches($content, $pattern)

foreach ($match in $matches) {
    if ($match.Groups.Count -ge 6) {
        $encodedDesc = $match.Groups[5].Value
        $fullDesc = Decode-Base64 $encodedDesc
        if ($fullDesc) {
            $oldText = $match.Groups[0].Value
            $newText = $oldText -replace [regex]::Escape($match.Groups[2].Value), $fullDesc
            $content = $content.Replace($oldText, $newText)
        }
    }
}

# Guardar el archivo modificado
$content | Out-File -FilePath $outputFile -Encoding UTF8 -NoNewline

Write-Host "✓ Modificaciones completadas exitosamente"
Write-Host "✓ Todos los precios eliminados"
Write-Host "✓ Descripciones expandidas"
