local env = std.extVar("__ksonnet/environments");
local params = std.extVar("__ksonnet/params").components["pyt2"];

local k = import "k.libsonnet";
local operator = import "kubeflow/pytorch-job/pytorch-operator.libsonnet";

std.prune(k.core.v1.list.new(operator.all(params, env)))
