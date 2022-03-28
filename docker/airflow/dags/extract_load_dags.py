import os
import logging
from datetime import datetime, timedelta, timezone



from airflow import DAG
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from airflow.utils.dates import days_ago
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.providers.google.cloud.operators.bigquery import BigQueryCreateExternalTableOperator
from extract_load import get_api_data, upload_to_gcs
from airflow.utils.dates import days_ago

parquet_path_file = "/opt/iowa/data/data_{{execution_date.strftime(\'%Y-%m\')}}.parquet"
parquet_file = "data_{{execution_date.strftime(\'%Y-%m\')}}.parquet"
GCP_PATH_TEMPLATE = "raw/iowa_sales/{{execution_date.strftime(\'%Y\')}}/"+parquet_file

PROJECT_ID = os.getenv('GCP_PROJECT_ID')
BUCKET = os.getenv('GCP_GCS_BUCKET')
BIGQUERY_DATASET = os.getenv('GCP_BQ_DATASET')
default_args = {
    "owner":"airflow",
    "depends_on_past": True,
    "retries":1
}

with DAG(
    dag_id = "EL_dag",
    schedule_interval = "0 1 3 * *",
    default_args = default_args,
    start_date =datetime(2012,1,1), 
    max_active_runs = 3,
    tags = ['iowa'],
) as dag:


    
    download_dataset_task = PythonOperator(
        task_id = "extract_task",
        python_callable = get_api_data,
        op_kwargs={
            "year":'{{execution_date.strftime(\'%Y\')}}',
            "month":'{{execution_date.strftime(\'%m\')}}'
        }
    )
    local_to_gcs_task = PythonOperator(
        task_id = "local_to_gcs_task",
        python_callable = upload_to_gcs,
        op_kwargs = {
            "bucket":BUCKET,
            "object_name":GCP_PATH_TEMPLATE,
            "local_file":f"{parquet_path_file}",
        },
    )

    remove_dataset_task = BashOperator(
        task_id = "remove_dataset_task",
        bash_command = f"rm {parquet_path_file} "
    )
    

    

    download_dataset_task >> local_to_gcs_task >> remove_dataset_task


with DAG(
    dag_id = "BQ_dag",
    schedule_interval = "@once",
    default_args = default_args,
    start_date =datetime(2012,1,3),    
    max_active_runs = 3,
    catchup=False,
    tags = ['iowa'],
) as dag_bq:

    trigger_dependent_dag = TriggerDagRunOperator(
        task_id="trigger_dependent_dag",
        trigger_dag_id="EL_dag",
        execution_date=datetime(2012,1,3,tzinfo=timezone.utc),
        wait_for_completion=True
    )

    bigquery_external_dataset_task = BigQueryCreateExternalTableOperator(
        task_id = "bigquery_external_dataset_task",
        table_resource = {
            "tableReference" : {
                "projectId":PROJECT_ID,
                "datasetId":BIGQUERY_DATASET,
                "tableId":"raw_data",
            },
            "externalDataConfiguration":{
                "sourceFormat":"PARQUET",
                "sourceUris":[f"gs://{BUCKET}/raw/iowa_sales/*"],
            }
        }
    )

    trigger_dependent_dag >> bigquery_external_dataset_task
    

