## K8s Configuration Last Mile Problem

< This is a knowledge dump and needs to be polished

A common scenario is that we want to publish a package that makes it easy for users to stamp out new instances of an application e.g.

A new flink cluster

A new tenant How to use Datastores | Deploying-a-tenant

A new Jupyter instance

A package commonly consists of the following artifacts

A kustomize package

A Dockerfile

A skaffold file

A user often pulls down a copy of the kustomize package. However, this leads to two problems

One the user might need to set some values consistently in multiple places

e.g. they may need to change the ECR repository in their skaffold file and also in their kustomization.yaml

They might want to key a bunch of different values (e.g. name, namespace, ECR repo) of a single “name” parameter

They need some way to pull in changes to the base kustomize package when the upstream repository changes

Unfortunately, we do not have a good solution for solving these problems. Nonetheless this page attempts to try to provide some evolving recommendations.

kpt is a really promising tool for package management. Unfortunately, its parameter substitution method (setters) relies on inline comments which creates problems with editing kustomization.yaml files. kustomize edit doesn’t preserve inline comments. So if a user runs kustomize edit e.g. to change the image then kpt parameter substitution no longer works.  `kustomize edit add resource` deletes comment lines · Issue #3587 · kubernetes-sigs/kustomize

Centralize Configuration in kustomization.yaml
To the extent possible we’d like to treat kustomization.yaml as the source of truth for all user defined parameters. If a user needs to set a parameter they should do so by editing values in the kustomization.yaml

Rely on builtin kustomization transformations to the extent possible
The preferred option is rely on values defined in kustomization.yaml.

For example, ask the user to set namespace or namePrefix.As a way to give unique names to all resources associated with a specific application instance.

Customizing kustomize transformers
Kustomize defines a bunch of transformers; e.g. the namePrefix transformation adds a prefix to all name fields.

Oftentimes when dealing with custom resources there are additional fields that these transformations need to be applied to. For example, we need to tell Kustomize to change the host field in VirtualService’s based on namePrefix since the service the virtualService references will have the namePrefix applied to it.

Refer to the docs for a list of transformer configurations.

Lets walkthrough a simple example.

platform-docs is the K8s manifests for a simple static server. The package basically consists of the following k8s resources

Deployment for the service

Service to direct traffic

Virtual service

We rely on namePrefix to ensure all resources have a unique name. Here the namePrefix is set to docs-

The Virtual service contains a reference to the K8s service;


apiVersion: v1
kind: Service
metadata:
  # Note that this doesn't include the namePrefix
  name: s3-proxy
...
----

apiVersion: networking.istio.io/v1beta1
kind: VirtualService
...
spec:
  ...
  http:
  - route:
    - destination:
        # Reference to the k8s service.
        # N.B note the name here doesn't include namePrefix
        host: s3-proxy
        ...
When we run kustomize build, kustomize will add the prefix so the K8s service will have the name docs-s3-proxy.

Therefore we need kustomize to change the value of spec.http.route.destination.host to docs-s3-proxy. So we need to tell kustomize that the host field should also be prefixed with the value of namePrefix.

We do this by creating a configurations.yaml file that tells kustomize which fields in which custom resources should also get namePrefix added to them. This file gets referenced in our kustomization.yaml.

Use a ConfigMapGenerator to have users set defined parameters
A common pattern is to ask users to set parameters by editing a ConfigMap generator inside the kustomization.yaml file. Example


apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
configMapGenerator:
- name: parameters
  literals:
  - SOMEARG=user-set-value
  - OTHERARG=other-value
This way a user can edit these parameters just by editing the literals defined in kustomization.yaml.

The ConfigMap values can then be referenced in other resources; e.g. in deployment command line arguments.

kustomization.yaml and yq
Sometimes we want the user to set a parameter and it doesn’t make sense or we can’t use a configMapGenerator.

In this case the recommended pattern is to leverage the fact that we can use a kustomization’s annotations field to store arbitrary key value pairs e.g.


apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
metadata:
  ...
  annotations:
    # We can leverage annotations to store arbitrary key value pairs
    PARAM1: <User sets value here>
We can then leverage yq and a custom shell script to read in the annotations from kustomization.yaml file and then substitute in any values.

For an example see generate_params.sh

The user would then do the following

Edit the annotations in kustomization.yaml to set the parameter value

Run generate_params.sh to set any fields based on the parameter as needed.

DO NOT use SED or other template based methods
Do not use SED or any other substitution tool that works by matching some template and then replacing it with some field. This is inherently brittle because it can only be run once. For example suppose you use SED to replace the value TOBESET with some user defined value. Suppose the user did the substitution and then changes their mind and wants to change the value. At this point the SED script will likely no longer work because the value TOBESET has been replaced.

Pattern matching tools like SED also break because of unintended matches.

Using yq and leveraging YAML structure to do template free configuration is much better.
