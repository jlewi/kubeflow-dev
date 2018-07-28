# Hack to try using the tf_job_client to get the status of a job.
# Use this to diagnose why v1alpha2 TFJob tests are failing.
from kubernetes import client as k8s_client
from py import tf_job_client

from kubeflow.testing import util
name = "tfjob-issue-summarization"
namespace = "kubeflow"
util.load_kube_config()
client = k8s_client.ApiClient()
masterHost = client.configuration.host

results = tf_job_client.wait_for_condition(
  client, namespace, name, ["Running", "Succeeded", "Failed"],
  status_callback=tf_job_client.log_status)

print("Done")