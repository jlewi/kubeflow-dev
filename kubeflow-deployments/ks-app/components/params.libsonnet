{
  global: {
  },
  components: {
    // Component-level parameters, defined initially from 'ks prototype use ...'
    // Each object below should correspond to a component in the components/ directory
    "kubeflow-core": {
      cloud: "null",
      disks: "null",
      jupyterHubAuthenticator: "iap",
      jupyterHubImage: "gcr.io/kubeflow/jupyterhub-k8s:v20180531-3bb991b1",
      jupyterHubServiceType: "ClusterIP",
      jupyterNotebookPVCMount: "/home/jovyan",
      jupyterNotebookRegistry: "gcr.io",
      jupyterNotebookRepoName: "kubeflow-images-public",
      name: "kubeflow-core",
      namespace: "null",
      reportUsage: "false",
      tfAmbassadorImage: "quay.io/datawire/ambassador:0.30.1",
      tfAmbassadorServiceType: "ClusterIP",
      tfDefaultImage: "null",
      tfJobImage: "gcr.io/kubeflow-images-public/tf_operator:v20180615-b2ac020",
      tfJobUiServiceType: "ClusterIP",
      tfJobVersion: "v1alpha2",
      tfStatsdImage: "quay.io/datawire/statsd:0.30.1",
      usageId: "unknown_cluster",
    },
    "cloud-endpoints": {
      name: "cloud-endpoints",
      namespace: "null",
      secretKey: "admin-gcp-sa.json",
      secretName: "admin-gcp-sa",
    },
    "cert-manager": {
      acmeEmail: "jlewi@google.com",
      acmeUrl: "https://acme-v01.api.letsencrypt.org/directory",
      name: "cert-manager",
      namespace: "null",
    },
    "iap-ingress": {
      disableJwtChecking: "false",
      envoyImage: "gcr.io/kubeflow-images-public/envoy:v20180309-0fb4886b463698702b6a08955045731903a18738",
      hostname: "jlewi-kubeflow.endpoints.cloud-ml-dev.cloud.goog",
      ipName: "jlewi-kubeflow-ip",
      issuer: "letsencrypt-prod",
      name: "iap-ingress",
      namespace: "null",
      oauthSecretName: "kubeflow-oauth",
      secretName: "envoy-ingress-tls",
    },
    "pytorch-operator": {
      cloud: "null",
      disks: "null",
      name: "pytorch-operator",
      namespace: "null",
      pytorchDefaultImage: "null",
      pytorchJobImage: "jgaguirr/pytorch-operator:latest",
    },
    "echo-server": {
      image: "gcr.io/kubeflow-images-staging/echo-server:latest",
      name: "echo-server",
    },
  },
}