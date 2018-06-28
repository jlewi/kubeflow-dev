local env = std.extVar("__ksonnet/environments");
local params = std.extVar("__ksonnet/params").components["kubeflow-core"];
local k = import "k.libsonnet";

local centraldashboard = import "test-central.libsonnet";
local namespace = env.namespace;

local uiService = {
      apiVersion: "v1",
      kind: "Service",
      metadata: {
        labels: {
          app: "centraldashboard",
        },
        name: "centraldashboard",
        namespace: namespace,
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
    }; //service

local parts = {
	uiService :: uiService,
};
std.prune(k.core.v1.list.new([centraldashboard.uiService(namespace)]))
