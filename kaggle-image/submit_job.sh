#!/bin/bash
# Submit the gcloud workflow to retag the images.
gcloud container --project=kubeflow-releasing builds submit --config retag_image.yaml --no-source