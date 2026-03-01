import mlflow
import mlflow.sklearn

from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score


# MLflow server no EKS
mlflow.set_tracking_uri(
    "http://a8fe0a21bec93462da391532ddddacce-05b35fc46a839e90.elb.us-east-2.amazonaws.com:5000"
)

mlflow.set_experiment("iris-demo")


iris = load_iris()

X_train, X_test, y_train, y_test = train_test_split(
    iris.data,
    iris.target,
    test_size=0.2,
    random_state=42
)


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


    mlflow.sklearn.log_model(
        sk_model=model,
        artifact_path="model",
        registered_model_name="iris-classifier",
        input_example=X_train[:5],
    )


    print("Accuracy:", accuracy)
