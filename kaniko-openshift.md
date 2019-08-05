# Kaniko en OpenShift

La ejecución en Openshift tiene alguna diferencias con respecto a la ejecución de Kubernete.

Ejecutamos el ejemplo que teníamos en kubernetes y buscamos las diferencias
  * La **configuración de Credenciales** tiene diferencias con respecto a Kubernetes, en Opehshift es solo necesario el servidor y el campo auth.
  * Habilitar la ejecución de contenedores en con **root** y **no privilegiados**

## Credenciales para la autenticación contra el registro Docker

Para crear las credenciales para openshift podemos o bien crear un PersistentVolumeClaim para gestionar directorio **<HOME>/.docker/config.json**. En nuestro ejemplo ejecutado contra MiniShift debe ser **/kaniko/.docker/config.json** en este se almacena el servidor y la variable auth.

### Crear PersistentVolumeClaim

**TODO: Rellenar el ejemplo de como mapear el volumen persistente**

``` yaml
mountclaim:

volumen:

```

 * **server-name** : URl Del Servidor
 * **auth** : Este valor es en base64 el usuaro:password del registro al que referencia el servidor

**TODO: Revisar si funciona poniendo la URL del Servidor parecía que en Openshift funciona solo el nombre del servidor**
  

``` json
{
  "auths": {
    "server-name": {
      "auth": "<auth>"
    }
  }
}
```

La sección <auth> es el "user:password" condificado en base64

Otra forma de almacenar la credencial es mediante un secreto de tipo secret-registry

``` shell
oc create secret-registry.....
```



## Ejecución con root y no privilegiados

En los Openshift Productivos lo normal es que no se ejecute los contenedores como privilegiados, además se suele restringir el uso de root en la ejecución de los propios contedores, todo esto para reducir el riesgo de vulnerabilidades. 

Kaniko se ejecuta debe ejecutar como "unprivileged container" pero sí que necesita permisos de root en Docker para ejecutarse.  Dicho de otro modo, el contenedor de Kaniko se ejecuta de manera no privilegiada, pero dentro del contenedor necesitas permisos de root.

Para conseguir creamos una Service Account con permisos adecuados :

 * Crear Cluster Role que ejecute con un SCC (Contexto de Seguridad) en nuestro caso **anyuid**
 * Crear una Service Account y crear el ClusterRole Recién creado.
 * Ejecutar kaniko con dicha serviceaccount

### Crear cluster ClusterRole

* Revisar que SCC tenemos

``` shell

oc get SCC

oc create -f create-cluster-role-kaniko.yaml
```

``` yaml 
./create-cluster-role-kaniko.yaml

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
    openshift.io/description: "Role-Based Access to SCCs for kaniko deployer"
  name: kaniko-deployer
rules:
- apiGroups:
  - security.openshift.io 
  resources:
  - securitycontextconstraints 
  verbs:
  - use
  resourceNames:
  - anyuid

```





## Referencias:

**TODO: Revisar Referencias**
* [building-container-images](https://kurtmadel.com/posts/native-kubernetes-continuous-delivery/building-container-images-with-kubernetes/) 
* [Reducing build time on OpenShift using Kaniko](https://medium.com/developers-writing/reducing-build-time-on-openshift-using-kaniko-909d4bf0a874)




