local env = std.extVar("__ksonnet/environments");
local params = std.extVar("__ksonnet/params").components["echo-server"];

local k = import "k.libsonnet";

// TODO(https://github.com/ksonnet/ksonnet/issues/670) If we don't import the service
// from a libsonnet file the annotation doesn't end up being escaped/represented in a way that 
// Ambassador can understand.
local echoParts = import "kubeflow/core/echo-server.libsonnet";
local namespace = env.namespace;

std.prune(k.core.v1.list.new([echoParts.service(namespace, params.name), echoParts.deploy(namespace, params.name, params.image)]))
