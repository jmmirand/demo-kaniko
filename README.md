# Hello World Kaniko

Usando minikube se puede montar el ejemplo HelloWorld de Kaniko

  * https://github.com/debuggy/kaniko-example

El ejemplo crea una imagen a partir de un dockerfile que está almacenado en un dicectorio local dentro del cluster.


## Crear directorio dentro del cluster

```
$ minikube ssh
$ mkdir kaniko && cd kaniko
$ echo 'FROM ubuntu' >> dockerfile
$ echo 'ENTRYPOINT ["/bin/bash", "-c", "echo hello"]' >> dockerfile
$ cat dockerfile
FROM ubuntu
ENTRYPOINT ["/bin/bash", "-c", "echo hello"]
$ pwd
/home/docker/kaniko
```
 

## Crear Secreto para conectar al registro

Para el ejemplo utilizamos una cuenta creada en docker-hub

```
kubectl create secret docker-registry regcred --docker-server=https://index.docker.io/v1/  --docker-username=jmmmirand --docker-password=xxxxxxxxx   --docker-email=jmmirand@gmail.com

```

## Crear los recursos kubernetes

### Persistent Volume

Creamos un volumen persistente det tipo Local de 10Gigas que después lo utilizará el pod.

Le indicaremos la ruta local del cluster. Es donde previamente hemos creado el dockerfile

El estado en el que se queda es Available/Disponible

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: dockerfile
  labels:
    type: local
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: local-storage
  hostPath:
    path: "/home/docker/kaniko"
```

```
$ kubectl create -f volume.yaml
persistentvolume/dockerfile created

$kubectl get pv
NAME         CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS    REASON   AGE
dockerfile   10Gi       RWO            Retain           Available           local-storage            110s

```

### Persistent Volume CLAIM

Creamos un pvc a partir del volumen que acabamos de CREAR

En este caso consumimos 10 Gigas . En nuestro caso se llama dockerfile-claim

```
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: dockerfile-claim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 8Gi
  storageClassName: local-storage

```

Creado el pvc se ve que está enlazado al volumen docker file que tiene 10 Gigas de capacidad

```
$ kubectl create -f volume-claim.yaml
persistentvolumeclaim/dockerfile-claim created

$kubectl get pvc
NAME               STATUS   VOLUME       CAPACITY   ACCESS MODES   STORAGECLASS    AGE
dockerfile-claim   Bound    dockerfile   10Gi       RWO            local-storage   22s

```

### Creamos el Pod que ejecutara la construcción de la imagen

```
apiVersion: v1
kind: Pod
metadata:
  name: kaniko
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    args: ["--dockerfile=/workspace/dockerfile",
            "--context=dir://workspace",
            "--destination=jmmirand/demo-kaniko"] # replace with your dockerhub account
    volumeMounts:
      - name: kaniko-secret
        mountPath: /root
      - name: dockerfile-storage
        mountPath: /workspace
  restartPolicy: Never
  volumes:
    - name: kaniko-secret
      secret:
        secretName: regcred
        items:
          - key: .dockerconfigjson
            path: .docker/config.json
    - name: dockerfile-storage
      persistentVolumeClaim:
        claimName: dockerfile-claim
```

Aplicamos el pod y ya solo queda comprobar


### Comprobar que se ha creado correctamente

```
kubectl logs kaniko
INFO[0001] Resolved base name ubuntu to ubuntu
INFO[0001] Resolved base name ubuntu to ubuntu
INFO[0001] Downloading base image ubuntu
INFO[0002] Error while retrieving image from cache: getting file info: stat /cache/sha256:d91842ef309155b85a9e5c59566719308fab816b40d376809c39cf1cf4de3c6a: no such file or directory
INFO[0002] Downloading base image ubuntu
INFO[0003] Built cross stage deps: map[]
INFO[0003] Downloading base image ubuntu
INFO[0004] Error while retrieving image from cache: getting file info: stat /cache/sha256:d91842ef309155b85a9e5c59566719308fab816b40d376809c39cf1cf4de3c6a: no such file or directory
INFO[0004] Downloading base image ubuntu
INFO[0006] Skipping unpacking as no commands require it.
INFO[0006] Taking snapshot of full filesystem...
INFO[0006] ENTRYPOINT ["/bin/bash", "-c", "echo hello"]
2019/07/24 15:05:48 mounted blob: sha256:1d425c98234572d4221a1ac173162c4279f9fdde4726ec22ad3c399f59bb7503
2019/07/24 15:05:48 mounted blob: sha256:344da5c95cecd0f55238ce59b8469ee301056001ece2b769e9691b80f94f9f37
2019/07/24 15:05:48 mounted blob: sha256:0fe7e7cbb2e88617d969efeeb3bd3125f7d309335c736a0525233ec2dc06aee1
2019/07/24 15:05:48 mounted blob: sha256:7413c47ba209e555018c4be91101d017737f24b0c9d1f65339b97a4da98acb2a
2019/07/24 15:05:49 pushed blob: sha256:12f75c4839a05ace81e1e8d6e14d4f0cce596fb74592bfbb83903d60073336f4
2019/07/24 15:05:50 index.docker.io/jmmirand/demo-kaniko:latest: digest: sha256:0478613c60a92fdf1130590cc85ec6c05c99260bcaa42cd862d1d385a6d6702d size: 911


➜  demo-kaniko git:(master) ✗ docker run jmmirand/demo-kaniko
Unable to find image 'jmmirand/demo-kaniko:latest' locally
latest: Pulling from jmmirand/demo-kaniko
7413c47ba209: Already exists
0fe7e7cbb2e8: Already exists
1d425c982345: Already exists
344da5c95cec: Already exists
Digest: sha256:0478613c60a92fdf1130590cc85ec6c05c99260bcaa42cd862d1d385a6d6702d
Status: Downloaded newer image for jmmirand/demo-kaniko:latest
hello

```

Si nos vamos al repositorio de docker github debieramos ver la imagen jmmirand/demo-kaniko

 * https://cloud.docker.com/repository/list





# Referencias

## Proyecto  kaniko
  * https://github.com/GoogleContainerTools/kaniko
  

## CREAR Secretos Kubectl para conectar al Registro

 * [ Pull imágen del registro Kubernetes](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/)
 * [ Doc Secreto Kubernetes ](https://kubernetes.io/docs/concepts/configuration/secret/)

```
kubectl create secret docker-registry regcred
  --docker-server=<your-registry-server>
  --docker-username=<your-name>
  --docker-password=<your-pword>
  --docker-email=<your-email>
```

El servidor por defecto es https://index.docker.io/v1/
