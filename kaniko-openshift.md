Ejecución con root y no privilegiados
En los Openshift Productivos lo normal es que no se ejecute los contenedores como privilegiados, además se suele restringir el uso de root en la ejecución de los propios contedores, todo esto para reducir el riesgo de vulnerabilidades.

Kaniko se ejecuta debe ejecutar como "unprivileged container" pero sí que necesita permisos de root en Docker para ejecutarse. Dicho de otro modo, el contenedor de Kaniko se ejecuta de manera no privilegiada, pero dentro del contenedor necesitas permisos de root.

Para conseguir creamos una Service Account con permisos adecuados :

Crear Cluster Role que ejecute con un SCC (Contexto de Seguridad) en nuestro caso anyuid
Crear una Service Account y crear el ClusterRole Recién creado.
Ejecutar kaniko con dicha serviceaccount
Crear cluster ClusterRole
Revisar que SCC tenemos
 
oc get SCC
 
oc create -f create-cluster-role-kaniko.yaml

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

Referencias:
TODO: Revisar Referencias

building-container-images
Reducing build time on OpenShift using Kaniko
Git
GitHub
Create Repository
Initialize a new project directory with a Git repository
Create repository
kaniko-with-openshift.md
GitHubGit (0)
