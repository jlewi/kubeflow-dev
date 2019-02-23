#!/usr/bin/python
#
# A simple script to delete all role bindings for the service
# accounts created as part of a Kubeflow deployment
# This is an effort to deal with
# https://github.com/kubeflow/kubeflow/issues/953
import argparse
import logging
import os
import yaml
import subprocess

if __name__ == "__main__":
  parser = argparse.ArgumentParser()
  parser.add_argument(
    "--project", default=None, type=str, help=("The project."))
  parser.add_argument(
    "--service_account",
    type=str,
    help=("The service account."))

  parser.add_argument(
    "--policy_file",
    type=str,
    help="The file to cache the policy to.",
  )
  args = parser.parse_args()

  if not os.path.exists(args.policy_file):
    output = subprocess.check_output(["gcloud", "projects", "get-iam-policy",
                                      "--format=yaml", args.project,])

    with open(args.policy_file, "w") as hf:
      hf.write(output)

  with open(args.policy_file) as hf:
    bindings = yaml.load(hf)
  roles = []
  entry = "serviceAccount:" + args.service_account

  for b in bindings["bindings"]:
    if entry in b["members"]:
      roles.append(b["role"])


  # TODO(jlewi): Can we issue a single gcloud command.

  for r in roles:
    command = ["gcloud", "projects", "remove-iam-policy-binding",
          args.project,
          "--member=" + entry, "--role=" + r]

    print(" ".join(command))
    subprocess.call(command)

  # TODO(jlewi): Add back the policy bindings
  for r in roles:
    command = [
          "gcloud", "projects", "add-iam-policy-binding",
          args.project,
          "--member", entry, "--role=" + r
    ]
    print(" ".join(command))
    subprocess.call(command)
