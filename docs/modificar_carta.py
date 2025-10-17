import re
import base64

# Leer el archivo HTML
with open('240_landing_v1760456517.html', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Eliminar todos los precios (divs con clase precio-productos)
content = re.sub(r'<div class="precio-productos"[^>]*>.*?</div>', '', content)

# 2. Expandir descripciones truncadas
# Función para decodificar base64
def decode_description(encoded):
    try:
        decoded = base64.b64decode(encoded).decode('utf-8')
        return decoded
    except:
        return ""

# Buscar todos los bloques de productos y expandir las descripciones
def expand_description(match):
    full_block = match.group(0)
    
    # Buscar la descripción codificada en el onclick de showImage
    onclick_match = re.search(r'onclick="showImage\([^,]+,\s*[^,]+,\s*decodeURIComponent\(escape\(atob\(\'([^\']+)\'\)\)\)', full_block)
    
    if onclick_match:
        # Decodificar la descripción completa
        encoded_desc = onclick_match.group(1)
        full_description = decode_description(encoded_desc)
        
        # Buscar y reemplazar la descripción truncada
        full_block = re.sub(
            r'(<div class="descripcion-productos"[^>]*>)([^<]+\.\.\.)(<\/div>)',
            r'\1' + full_description + r'\3',
            full_block
        )
    
    return full_block

# Aplicar la expansión a todos los bloques de producto
content = re.sub(
    r'<div class="bloque_producto"[^>]*>.*?</div>\s*</div>\s*</div>',
    expand_description,
    content,
    flags=re.DOTALL
)

# Guardar el archivo modificado
with open('240_landing_v1760456517.html', 'w', encoding='utf-8') as f:
    f.write(content)

print("Modificaciones completadas exitosamente:")
print("✓ Todos los precios eliminados")
print("✓ Descripciones expandidas a su versión completa")
