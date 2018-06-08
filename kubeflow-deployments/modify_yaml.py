#!/usr/local/bin/python
#
# A simple python script to modfiy the yaml spec to fill in the required fvalues
import yaml
import os

if __name__ == "__main__":
  with open("cluster-kubeflow.yaml") as hf:
    contents = yaml.load(hf)
    
  contents["resources"][0]["properties"]["ipName"] = "jlewi-kubeflow-ip"
  config = yaml.load(contents["resources"][0]["properties"]["bootstrapperConfig"])
  
  for c in config["app"]["parameters"]:

    if c["name"] == "acmeEmail":
      c["value"] = "jlewi@google.com"
    if c["name"] == "hostname":
      c["value"] = "jlewi-kubeflow.endpoints.cloud-ml-dev.cloud.goog"
    if c["name"] == "ipName":
      c["value"] = "jlewi-kubeflow-ip"
  contents["resources"][0]["properties"]["bootstrapperConfig"] = yaml.dump(config)
  
  with open("cluster-kubeflow.yaml", "w") as hf:
    output = yaml.dump(contents,  default_flow_style=False)
    hf.write(output)
  