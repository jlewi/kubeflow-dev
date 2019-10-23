"""Count number of cards in a YAML file corresponding to the deep learning
Foundation landscape.
https://github.com/lfai/lfai-landscape

Commit: ebed91dca0454d9c648ff279d8a827999b41099f of https://github.com/lfai/lfai-landscape
corresponds to Nov 30 2018
"""

import fire
import yaml

class Count:
    def count(self, path):
        with open(path) as hf:
            data = yaml.load(hf)

        num_items = 0
        for c in data["landscape"]:
            if c["name"] == "LF AI Member Company":
                continue

            for s in c["subcategories"]:
                num_items += len(s["items"])

        print("num_items={0}".format(num_items))

if __name__ == "__main__":
    fire.Fire(Count)
