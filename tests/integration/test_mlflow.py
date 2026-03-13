import mlflow
import tempfile


def test_mlflow_run():

    with tempfile.TemporaryDirectory() as tmpdir:

        mlflow.set_tracking_uri(f"file:{tmpdir}")

        # criar experimento
        experiment_name = "test-experiment"

        try:
            experiment_id = mlflow.create_experiment(experiment_name)
        except Exception:
            experiment = mlflow.get_experiment_by_name(experiment_name)
            experiment_id = experiment.experiment_id

        mlflow.set_experiment(experiment_name)

        with mlflow.start_run():

            mlflow.log_param("param1", 10)
            mlflow.log_metric("accuracy", 0.95)

        runs = mlflow.search_runs(experiment_ids=[experiment_id])

        assert len(runs) >= 1
