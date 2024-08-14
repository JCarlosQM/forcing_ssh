
# forcing_ssh
Para iniciar este servicio creado en bash, es necesario usarlo en entorno "Linux", con el cual se verificará una llave ssh tras otra y posterior a ello se probarán las credenciales que se indiquen desde un archivo externo, asimismo cabe destacar que la ejecución del programa crea un archivo temporal ssh en ´/tmp/temp_key.´ para no modificar la ssh_keygen que se pase al inicio.
## Uso

El proyecto no requiere de una instalación directo, sino más bien de tenerlo en nuestra máquina y ejecutar con permisos de "sudo"

```bash
  sudo forcing_ssh.sh -w wodlist -d clave_ssh
```
    
