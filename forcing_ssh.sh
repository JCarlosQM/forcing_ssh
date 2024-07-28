#!/bin/bash

# Función para procesar cada contraseña en un archivo temporal
process_password() {
    local password="$1"
    local ssh_key_file="$2"
    local temp_file="/tmp/temp_key.$$"  # Nombre del archivo temporal usando el PID del proceso actual

    # Copiar la clave privada original a un archivo temporal
    if ! cp "$ssh_key_file" "$temp_file" >/dev/null 2>&1; then
        echo "Error: No se pudo copiar la clave privada al archivo temporal $temp_file"
        exit 1
    fi

    # Intentar autenticar con la contraseña usando ssh-keygen en el archivo temporal
    if ssh-keygen -p -P "$password" -N "" -f "$temp_file" >/dev/null 2>&1; then
        # Mostrar el comentario de la clave SSH (si existe)
        comment=$(ssh-keygen -l -f "$temp_file" | awk '{print $3}')
        echo -e "\n\e[91mContraseña correcta encontrada: $password\e[0m\n"
        rm "$temp_file" >/dev/null 2>&1 || true # Eliminar el archivo temporal después de encontrar la contraseña (sin mostrar mensaje de error)
        password_found=true  # Activar bandera de contraseña encontrada
        kill -SIGTERM 0  # Enviar señal de terminación a todos los subprocesos
        exit 0 # Terminar el script al encontrar la contraseña correcta
    else
        rm "$temp_file" >/dev/null 2>&1 || true # Eliminar el archivo temporal si la contraseña es incorrecta (sin mostrar mensaje de error)
    fi
}

# Procesar opciones
while getopts ":w:d:h" option; do
    case "$option" in
        w)
            wordlist_file=$OPTARG
            ;;
        d)
            ssh_key_file=$OPTARG
            ;;
        h)
            echo "Uso: $0 -w <archivo_wordlist> -d <archivo_clave_ssh>"
            echo "  -w <archivo_wordlist>   Especifica la ruta del archivo que contiene la lista de contraseñas."
            echo "  -d <archivo_clave_ssh>  Especifica la ruta del archivo de clave privada SSH."
            exit 0
            ;;
        :)
            echo "Opción -$OPTARG requiere un argumento."
            exit 1
            ;;
        \?)
            echo "Opción inválida: -$OPTARG"
            exit 1
            ;;
    esac
done

# Verificar que se hayan especificado ambos archivos
if [ -z "$wordlist_file" ] || [ -z "$ssh_key_file" ]; then
    echo "Error: Debe especificar la ruta del archivo de wordlist y del archivo de clave privada SSH."
    echo "Uso: $0 -w <archivo_wordlist> -d <archivo_clave_ssh>"
    exit 1
fi

# Verificar que el archivo de clave privada SSH exista y sea válido
if [ ! -f "$ssh_key_file" ]; then
    echo "Error: El archivo de clave privada SSH ($ssh_key_file) no existe."
    exit 1
fi

# Verificar que el archivo especificado con -d sea una clave SSH
if ! ssh-keygen -l -f "$ssh_key_file" >/dev/null 2>&1; then
    echo "Error: El archivo especificado ($ssh_key_file) no parece ser una clave SSH válida."
    exit 1
fi

# Contar las líneas del archivo de wordlist para mostrar el progreso
total_lines=$(wc -l < "$wordlist_file")
current_line=0
password_found=false  # Variable bandera para indicar si se encontró la contraseña

# Leer cada contraseña del archivo y procesarla en paralelo
while IFS= read -r password; do
    process_password "$password" "$ssh_key_file" &
    pid=$!
    # Mostrar progreso mientras se procesan las contraseñas
    current_line=$((current_line + 1))
    echo -ne "Progreso: $current_line/$total_lines - Probando '$password'\r"
    sleep 0.1

    # Salir del bucle si se encontró la contraseña
    if $password_found; then
        break
    fi
done < "$wordlist_file"

wait # Esperar a que todos los subprocesos terminen

# No mostrar mensaje final si se encontró la contraseña
if ! $password_found; then
    echo -e "\nNo se encontró ninguna contraseña válida."
fi

exit 0
