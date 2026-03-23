import mlflow
import mlflow.sklearn

from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score


def main():
    # ---------------------------------------------------
    # Configuração MLflow
    # ---------------------------------------------------

    mlflow.set_tracking_uri("databricks")
    mlflow.set_registry_uri("databricks-uc")

    mlflow.set_experiment("/Users/pastoreaws@gmail.com/iris-demo")

    # ---------------------------------------------------
    # Dataset
    # ---------------------------------------------------

    iris = load_iris()

    X_train, X_test, y_train, y_test = train_test_split(
        iris.data,
        iris.target,
        test_size=0.2,
        random_state=42
    )

    # ---------------------------------------------------
    # Training
    # ---------------------------------------------------

    with mlflow.start_run(run_name="rf-iris-training"):

        model = RandomForestClassifier(
            n_estimators=100,
            random_state=42
        )

        model.fit(X_train, y_train)

        predictions = model.predict(X_test)

        accuracy = accuracy_score(y_test, predictions)

        mlflow.log_param("n_estimators", 100)
        mlflow.log_metric("accuracy", accuracy)

        model_info = mlflow.sklearn.log_model(
            sk_model=model,
            artifact_path="model",
            registered_model_name="workspace.default.iris-classifier",
            input_example=X_train[:5],
        )

        print("Accuracy:", accuracy)

        model_version = model_info.registered_model_version

        print(f"MODEL_VERSION={model_version}")

        # ---------------------------------------------------
        # Exporta valor para Databricks Job
        # ---------------------------------------------------

        try:
            from databricks.sdk.runtime import dbutils

            dbutils.jobs.taskValues.set(
                key="model_version",
                value=model_version
            )

            print("Model version exported to task values")

        except Exception:
            print("Not running inside Databricks Job")


# 👇 ESSENCIAL
if __name__ == "__main__":
    main()
