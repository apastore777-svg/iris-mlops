import mlflow

mlflow.set_tracking_uri("http://a8fe0a21bec93462da391532ddddacce-05b35fc46a839e90.elb.us-east-2.amazonaws.com:5000")

with mlflow.start_run():
    mlflow.log_param("test", 123)

print("OK")
