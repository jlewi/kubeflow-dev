local env = std.extVar("__ksonnet/environments");
local params = std.extVar("__ksonnet/params").components["tf-job-simple"];

local k = import "k.libsonnet";

local name = params.name;
local namespace = env.namespace;
local image = "gcr.io/kubeflow/tf-benchmarks-cpu:v20171202-bdab599-dirty-284af3";

local tfjob = {
  apiVersion: "kubeflow.org/v1alpha2",
  kind: "TFJob",
  metadata: {
    name: name,
    namespace: namespace,
  },
  spec: {
    tfReplicaSpecs: {
      Worker: {
        replicas: 1,
        template: {
          spec: {
            containers: [
              {
                args: [
                  "python",
                  "tf_cnn_benchmarks.py",
                  "--batch_size=32",
                  "--model=resnet50",
                  "--variable_update=parameter_server",
                  "--flush_stdout=true",
                  "--num_gpus=1",
                  "--local_parameter_device=cpu",
                  "--device=cpu",
                  "--data_format=NHWC",
                ],
                image: image,
                name: "tensorflow",
                workingDir: "/opt/tf-benchmarks/scripts/tf_cnn_benchmarks",
              },
            ],
            restartPolicy: "OnFailure",
          },
        },
      },
      Ps: {
        template: {
          spec: {
            containers: [
              {
                args: [
                  "python",
                  "tf_cnn_benchmarks.py",
                  "--batch_size=32",
                  "--model=resnet50",
                  "--variable_update=parameter_server",
                  "--flush_stdout=true",
                  "--num_gpus=1",
                  "--local_parameter_device=cpu",
                  "--device=cpu",
                  "--data_format=NHWC",
                ],
                image: image,
                name: "tensorflow",
                workingDir: "/opt/tf-benchmarks/scripts/tf_cnn_benchmarks",
              },
            ],
            restartPolicy: "OnFailure",
          },
        },
        tfReplicaType: "PS",
      },
    },
    terminationPolicy: {
      chief: {
        replicaIndex: 0,
        replicaName: "WORKER",
      },
    },
    tfimage: image,
  },
};

k.core.v1.list.new([
  tfjob,
])
