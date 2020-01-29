#!/usr/bin/python

"""
Some helper functions used for data cleaning
"""

import config as cfg
import spark_utils as su
import autoencoder as ae

import numpy as np

from pyspark.sql import functions as func
from pyspark.sql.types import StructType, StructField, StringType, ArrayType, IntegerType, DoubleType, FloatType

from pyspark.ml.feature import StringIndexer, VectorAssembler, StandardScaler
from pyspark.ml import Pipeline, PipelineModel
from pyspark.sql.functions import udf


__author__ = "Fredi Weideli"
__credits__ = ["Fredi Weideli"]
__version__ = "1.0.0"
__maintainer__ = "Fredi Weideli"
__email__ = "fredi.weideli@bluewin.ch"
__status__ = "Masterthesis-POC"


# spark structured streaming does not yet support the automatic inference of JSON Kafka values into a dataframe
# without a schema, that's why we define the schema explicitly
feature_schema = StructType([
    StructField("time_stamp", StringType()),
    StructField("label_nr", DoubleType()),
    StructField("label", StringType()),
    StructField("date_weekday", IntegerType()),
    StructField("date_hour", IntegerType()),
    StructField("src_ip", StringType()),
    StructField("src_software_name", StringType()),
    StructField("src_operating_system_name", StringType()),
    StructField("src_software_type", StringType()),
    StructField("src_software_sub_type", StringType()),
    StructField("src_hardware_type", StringType()),
    StructField("src_hardware_sub_type", StringType()),
    StructField("http_method", StringType()),
    StructField("response_status", StringType()),
    StructField("response_status_code", StringType()),
    StructField("response_time_ms", IntegerType()),
    StructField("response_time_cat", StringType()),
    StructField("oidc_response_type", StringType()),
    StructField("oidc_acr_values", StringType()),
    StructField("oidc_client_id", StringType()),
    StructField("client_name", StringType()),
    StructField("client_type", StringType()),
    StructField("ido_id", StringType()),
    StructField("ido_email", StringType()),
    StructField("ido_type", StringType()),
    StructField("oidc_scopes", StringType()),
    StructField("oidc_ui_locales", StringType()),
    StructField("loc_country", StringType()),
    StructField("loc_region", StringType()),
    StructField("loc_city", StringType()),
    StructField("loc_country_code", StringType())
])


# Structured Streaming has only worked with StringType, no other type were possible
feature_schema_all_string = StructType([
    StructField("time_stamp", StringType()),
    StructField("label_nr", StringType()),
    StructField("label", StringType()),
    StructField("date_weekday", StringType()),
    StructField("date_hour", StringType()),
    StructField("src_ip", StringType()),
    StructField("src_software_name", StringType()),
    StructField("src_operating_system_name", StringType()),
    StructField("src_software_type", StringType()),
    StructField("src_software_sub_type", StringType()),
    StructField("src_hardware_type", StringType()),
    StructField("src_hardware_sub_type", StringType()),
    StructField("http_method", StringType()),
    StructField("response_status", StringType()),
    StructField("response_status_code", StringType()),
    StructField("response_time_ms", StringType()),
    StructField("response_time_cat", StringType()),
    StructField("oidc_response_type", StringType()),
    StructField("oidc_acr_values", StringType()),
    StructField("oidc_client_id", StringType()),
    StructField("client_name", StringType()),
    StructField("client_type", StringType()),
    StructField("ido_id", StringType()),
    StructField("ido_email", StringType()),
    StructField("ido_type", StringType()),
    StructField("oidc_scopes", StringType()),
    StructField("oidc_ui_locales", StringType()),
    StructField("loc_country", StringType()),
    StructField("loc_region", StringType()),
    StructField("loc_city", StringType()),
    StructField("loc_country_code", StringType())
])


feature_array_schema = StructType([StructField("features", ArrayType(FloatType()), True)])

prediction_schema = StructType([
    StructField("features", ArrayType(FloatType())),
    StructField("label_nr", StringType())])


def clean_log_entries(log_entries_df, incl_suspect=True, incl_json_col=True, incl_uuid_col=True, reduced_feature_set=False, add_label=True):

    # filter 'admin and monitoring' statements
    if incl_suspect:
        filtered_df = log_entries_df.filter("ido_type != 'admin' and ido_type != 'monitoring'")
    else:
        filtered_df = log_entries_df.filter("ido_type != 'admin' and ido_type != 'monitoring' and label != 'suspect'")


    if reduced_feature_set:
        features = cfg.reduced_feature_list.copy()
    else:
        features = cfg.feature_list.copy()

    if add_label:
        features.append(cfg.label_col_name)

    if incl_uuid_col:
        features.append(cfg.key_col_name)

    if incl_json_col:
        features.append(cfg.value_col_name)

    # select a subset of all features
    filtered_df = filtered_df.select(*features)

    return filtered_df


def map_existing_ido_id(df, map_to='x'):
    return df.withColumn(cfg.ido_id_col_name, func.when(func.col(cfg.ido_id_col_name) == cfg.unknown_value, func.lit(cfg.unknown_value)).otherwise(func.lit(map_to)))


def build_scaled_features_pipeline(categorical_columns):
    pipeline_stages = []

    # encode the columns
    for col in categorical_columns:
        indexer = StringIndexer(inputCol=col, outputCol=col + '_idx')
        pipeline_stages += [indexer]

    # build feature vector
    features = [c + "_idx" for c in categorical_columns]
    assembler = VectorAssembler(inputCols=features, outputCol="feature_vec")
    pipeline_stages += [assembler]

    # scale the features
    scaler = StandardScaler(inputCol="feature_vec", outputCol="features", withStd=True, withMean=False)
    pipeline_stages += [scaler]

    # add a new label column but this time
    # label_string_indexer = StringIndexer(inputCol='label', outputCol='label_idx')
    # pipeline_stages += [label_string_indexer]

    return Pipeline(stages=pipeline_stages)


def convert_feature_vector_to_feature_row_list_udf():
    return udf(lambda features: features.toArray().tolist(), ArrayType(DoubleType()))


def convert_row_list_to_list(row_list):
    return list(map(lambda row: row.features, row_list))


def convert_feature_vector_to_rows(feature_df, col_name='features'):
    feature_udf = convert_feature_vector_to_feature_row_list_udf()
    return feature_df.select(feature_udf(col_name).alias(col_name)).collect()


def convert_feature_vector_to_list(feature_df, col_name='features'):
    rows = convert_feature_vector_to_rows(feature_df, col_name)
    return convert_row_list_to_list(rows)


def convert_feature_vector_to_feature_array(feature_vector_df, sql_context, col_name='features'):
    rows = convert_feature_vector_to_rows(feature_vector_df, col_name)
    return sql_context.createDataFrame(rows, feature_array_schema)


def predict(model_path, x_values_df, input_col='features', output_col='predictions'):
    from sparkdl import KerasTransformer

    transformer = KerasTransformer(inputCol=input_col, outputCol=output_col, modelFile=model_path)
    return transformer.transform(x_values_df)


def convert_column_to_list(df, col_name, to_int=False):
    if to_int:
        return [int(row[col_name]) for row in df.select(col_name).collect()]
    else:
        return [row[col_name] for row in df.select(col_name).collect()]


def convert_feature_vector_to_X_df(df, sql_context, feature_col_name='features', label_col_name='label_nr'):
    feature_udf = convert_feature_vector_to_feature_row_list_udf()
    rows = df.select(feature_udf(feature_col_name).alias(feature_col_name), label_col_name).collect()
    return sql_context.createDataFrame(rows, prediction_schema)


def convert_prediction_df_to_lists(predictions_df, prediction_col_name='predictions', feature_col_name='features', label_col_name='label_nr'):
    tuples = [(row[prediction_col_name], row[feature_col_name], int(row[label_col_name])) for row in predictions_df.select(prediction_col_name, feature_col_name, label_col_name).collect()]
    return zip(*tuples)


def find_max_f1(pdf):
    max_f1 = 0
    thres = 0
    idx = 0
    for i in range(pdf.shape[0]):
        f1,r,p,fpr = get_metrics(pdf,i)
        if f1 > max_f1:
            max_f1 = f1
            thres = pdf['threshold'][i]
            idx = i
            
    return thres, max_f1,idx


def get_metrics(pdf, th_idx):
    r = pdf['recall'][th_idx]
    p = pdf['precision'][th_idx]
    fpr = pdf['fpr'][th_idx]
    f1 = (2 * p * r) / (p + r)
    
    return f1,r,p,fpr



