local env = std.extVar("__ksonnet/environments");
local params = std.extVar("__ksonnet/params").components["echo-server"];

local k = import "k.libsonnet";

local namespace = env.namespace;

local service = {
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    labels: {
      app: "echo",
    },
    name: "echo-new",
    namespace: namespace,
    annotations: {
      "getambassador.io/config":
        std.join("\n ", [
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
        targetPort: 8080,
      },
    ],
    selector: {
      app: "echo",
    },
    type: "ClusterIP",
  },
};  // service

local deploy = {
  apiVersion: "extensions/v1beta1",
  kind: "Deployment",
  metadata: {
    name: "echo",
    namespace: namespace,

  },
  spec: {
    replicas: 1,
    template: {
      metadata: {
        labels: {
          app: "echo",
        },
      },
      spec: {
        containers: [
          {
            image: params.image,
            name: "app",
            ports: [
              {
                containerPort: 8080,
              },
            ],

            readinessProbe: {
              httpGet: {
                path: "/headers",
                port: 8080,
              },
              initialDelaySeconds: 5,
              periodSeconds: 30,
            },
          },
        ],
      },
    },
  },
};

std.prune(k.core.v1.list.new([service, deploy]))
