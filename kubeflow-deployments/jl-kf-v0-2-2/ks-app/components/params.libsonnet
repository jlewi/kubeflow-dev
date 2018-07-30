{
  global: {},
  components: {
    // Component-level parameters, defined initially from 'ks prototype use ...'
    // Each object below should correspond to a component in the components/ directory
    "kubeflow-core": {
      AmbassadorImage: 'quay.io/datawire/ambassador:0.30.1',
      AmbassadorServiceType: 'ClusterIP',
      StatsdImage: 'quay.io/datawire/statsd:0.30.1',
      centralUiImage: 'gcr.io/kubeflow-images-public/centraldashboard:v0.2.1',
      cloud: 'null',
      disks: 'null',
      jupyterHubAuthenticator: 'iap',
      jupyterHubImage: 'gcr.io/kubeflow/jupyterhub-k8s:v20180531-3bb991b1',
      jupyterHubServiceType: 'ClusterIP',
      jupyterNotebookPVCMount: '/home/jovyan',
      jupyterNotebookRegistry: 'gcr.io',
      jupyterNotebookRepoName: 'kubeflow-images-public',
      name: 'kubeflow-core',
      namespace: 'null',
      reportUsage: true,
      tfDefaultImage: 'null',
      tfJobImage: 'gcr.io/kubeflow-images-public/tf_operator:v0.2.0',
      tfJobUiServiceType: 'ClusterIP',
      tfJobVersion: 'v1alpha2',
      usageId: '95c5a115-b51a-4453-80e9-bacd73d20edb',
    },
    "cloud-endpoints": {
      name: 'cloud-endpoints',
      namespace: 'null',
      secretKey: 'admin-gcp-sa.json',
      secretName: 'admin-gcp-sa',
    },
    "cert-manager": {
      acmeEmail: 'jlewi@google.com',
      acmeUrl: 'https://acme-v01.api.letsencrypt.org/directory',
      name: 'cert-manager',
      namespace: 'null',
    },
    "iap-ingress": {
      disableJwtChecking: 'false',
      envoyImage: 'gcr.io/kubeflow-images-public/envoy:v20180309-0fb4886b463698702b6a08955045731903a18738',
      hostname: 'jl-kf-v0-2-2.endpoints.cloud-ml-dev.cloud.goog',
      ipName: 'jl-kf-v0-2-2-ip',
      issuer: 'letsencrypt-prod',
      name: 'iap-ingress',
      namespace: 'null',
      oauthSecretName: 'kubeflow-oauth',
      secretName: 'envoy-ingress-tls',
    },
    tfjob: {
      name: "tfjob",
    },
    "tfjob2": {
      name: "tfjob2",
    },
  },
}