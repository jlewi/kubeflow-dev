{
  parts(params):: {
    local ambassador = import "kubeflow/core/ambassador.libsonnet",
    local jupyterhub = import "kubeflow/core/jupyterhub.libsonnet",
    local nfs = import "kubeflow/core/nfs.libsonnet",
    local tfjob = import "kubeflow/core/tf-job-operator.libsonnet",
    local spartakus = import "kubeflow/core/spartakus.libsonnet",
    local centraldashboard = import "kubeflow/core/centraldashboard.libsonnet",
    local version = import "kubeflow/core/version.libsonnet",

    all:: //jupyterhub.all(params)
          //+ tfjob.all(params)
          //+ ambassador.all(params)
          //+ nfs.all(params)
          //+ spartakus.all(params)
          + centraldashboard.all(params),
          //+ version.all(params),
  },

  uiService(namespace):: {
      apiVersion: "v1",
      kind: "Service",
      metadata: {
        labels: {
          app: "centraldashboard",
        },
        name: "centraldashboard",
        namespace: "namespace",
        annotations: {
          "getambassador.io/config":
            std.join("\n", [
              "---",
              "apiVersion: ambassador/v0",
              "kind:  Mapping",
              "name: centralui-mapping",
              "prefix: /",
              "rewrite: /",
              "service: centraldashboard." + namespace,
            ]),
        },  //annotations
      },
      spec: {
        ports: [
          {
            port: 80,
            targetPort: 8082,
          },
        ],
        selector: {
          app: "centraldashboard",
        },
        sessionAffinity: "None",
        type: "ClusterIP",
      },
    },
}
