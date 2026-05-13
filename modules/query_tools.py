from google.cloud import bigquery


# =========================
# BigQuery Configuration
# =========================

BQ_PROJECT_NAME = "your-gcp-project-id"

client = bigquery.Client(
    project=BQ_PROJECT_NAME
)


# =========================
# Query Utilities
# =========================

def run_query(query_file, params=None):
    """
    Load a SQL query from file,
    replace query parameters,
    and execute the query.
    """

    query = get_query(query_file)

    if params:
        query = replace_query_params(query, params)

    response = execute_query(query)

    return response


def get_query(query_file):
    """
    Read a SQL query file from the queries directory.
    """

    with open(f"queries/{query_file}", "r") as query_file_obj:
        query = query_file_obj.read()

    return query


def replace_query_params(query, params):
    """
    Replace placeholder query parameters with runtime values.
    """

    for key, value in params.items():
        query = query.replace(key, str(value))

    return query


def execute_query(query):
    """
    Execute a BigQuery SQL query
    and return the result as a dataframe.
    """

    query_job = client.query(query)

    response = query_job.result().to_dataframe()

    return response
