"""Experiment with using modeldb to track model information using its

API:
https://github.com/mitdbg/modeldb/blob/master/client/python/light_api.md

based on:
https://github.com/mitdbg/modeldb/blob/master/client/python/samples/basic/BasicWorkflow.py
"""
from modeldb.basic.Structs import (
  Model, ModelConfig, ModelMetrics, Dataset)
from modeldb.basic.ModelDbSyncerBase import Syncer


if __name__ == "__main__":
  # Create a syncer using a convenience API
  # syncer_obj = Syncer.create_syncer("gensim test", "test_user", \
  #     "using modeldb light logging")

  # Example: Create a syncer from a config file
  syncer_obj = Syncer.create_syncer_from_config("syncer.json")

  # Example: Create a syncer explicitly
  # syncer_obj = Syncer(
  #     NewOrExistingProject("gensim test", "test_user",
  #     "using modeldb light logging"),
  #     DefaultExperiment(),
  #     NewExperimentRun("", "sha_A1B2C3D4"))

  # Example: Create a syncer from an existing experiment run
  # experiment_run_id = int(sys.argv[len(sys.argv) - 1])
  # syncer_obj = Syncer.create_syncer_for_experiment_run(experiment_run_id)

  print("I'm training some model")

  datasets = {
    "train" : Dataset("/path/to/train", {"num_cols" : 15, "dist" : "random"}),
    "test" : Dataset("/path/to/test", {"num_cols" : 15, "dist" : "gaussian"})
  }

  # create the Model, ModelConfig, and ModelMetrics instances
  model = "model_obj"
  model_type = "NN"
  mdb_model1 = Model(model_type, model, "/path/to/model1")
  model_config1 = ModelConfig(model_type, {"l1" : 10})
  model_metrics1 = ModelMetrics({"accuracy" : 0.8})

  # sync the datasets to modeldb
  syncer_obj.sync_datasets(datasets)

  # sync the model with its model config and specify which dataset tag to use for it
  syncer_obj.sync_model("train", model_config1, mdb_model1)

  # sync the metrics to the model and also specify which dataset tag to use for it
  syncer_obj.sync_metrics("test", mdb_model1, model_metrics1)

  syncer_obj.sync()