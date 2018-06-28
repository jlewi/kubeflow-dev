local env = std.extVar("__ksonnet/environments");
local params = std.extVar("__ksonnet/params").components["cloud-endpoints"];
local k = import "k.libsonnet";
local cloudEndpoints = import "kubeflow/core/cloud-endpoints.libsonnet";

// updatedParams uses the environment namespace if
// the namespace parameter is not explicitly set
local updatedParams = params {
  namespace: if params.namespace == "null" then env.namespace else params.namespace,
};

cloudEndpoints.parts(updatedParams.namespace).cloudEndpointsParts(params.secretName, params.secretKey)
