FROM python:3.9

COPY requirements.txt .
RUN pip install -r requirements.txt


RUN pip uninstall markupsafe -y
RUN pip install markupsafe==2.0.1

RUN mkdir /project
COPY scripts/ /project/scripts/

COPY dbt/profiles.yml /root/.dbt/profiles.yml
COPY /home/ace/.google/credentials/google_credentials_iowa.json /.google/credentials/google_credentials_iowa.json

RUN chmod +x /project/scripts/airflow_init.sh

ENTRYPOINT [ "/project/scripts/airflow_init.sh" ]



# FROM base as dbt-core
# RUN python -m pip install --no-cache-dir "git+https://github.com/dbt-labs/${dbt_core_ref}#egg=dbt-core&subdirectory=core"

# ##
# # dbt-bigquery
# ##
# FROM base as dbt-bigquery
# RUN python -m pip install --no-cache-dir "git+https://github.com/dbt-labs/${dbt_bigquery_ref}#egg=dbt-bigquery"
