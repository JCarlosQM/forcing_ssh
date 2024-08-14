# forcing_ssh

Este script en Bash está diseñado para realizar un ataque de diccionario sobre una clave SSH en formato RSA que esté protegida con una contraseña. Funciona en entornos Linux y se recomienda su uso en un contexto de pruebas de penetración autorizado.

El script toma una clave SSH RSA específica y prueba cada contraseña de un archivo de wordlist. Para evitar modificar la clave SSH original, el script crea un archivo temporal en `/tmp/temp_key.<PID>`, donde `<PID>` es el ID de proceso, que se elimina automáticamente al finalizar la prueba o si se encuentra la contraseña correcta.

## Uso

No se requiere una instalación específica para ejecutar el script. Solo necesitas tener el script en tu máquina y ejecutarlo con permisos de `sudo` si es necesario (por ejemplo, cuando la clave SSH tiene restricciones de permisos).

### Comando de Ejecución

```bash
sudo forcing_ssh.sh -w <archivo_wordlist> -d <archivo_clave_ssh>
