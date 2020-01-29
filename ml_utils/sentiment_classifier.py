#!/usr/bin/python

"""
Anomaly Detecion based on sentiment analysis.
Pre-Processing and Feature Vectorization Spark Pipeline function definitions
"""

import config as cfg

from pyspark.ml.feature import HashingTF, IDF
from pyspark.sql.functions import *
from pyspark.ml.classification import DecisionTreeClassificationModel


__author__ = "Fredi Weideli"
__credits__ = ["Fredi Weideli"]
__version__ = "1.0.0"
__maintainer__ = "Fredi Weideli"
__email__ = "fredi.weideli@bluewin.ch"
__status__ = "Masterthesis-POC"


def preprocess(log_entries_df, additional_cols=True, reduced_feature_set=True):

    """
    Pre-process the raw log entries
    """

    # Since we are only interested in detecting log statements with negative sentiment, generate a new label
    # whereby if the sentiment is negative, the label is TRUE (Positive Outcome) otherwise FALSE
    #preprocessed_df = log_entries_df.withColumn("negative_label", when(col("label") == "anomaly",lit("true")).otherwise(lit("false")))
    preprocessed_df = log_entries_df

    # Concatenate the columns to one string
    if reduced_feature_set:
        preprocessed_df = preprocessed_df.withColumn("text", concat_ws(" ", col("date_weekday"),col("src_software_sub_type"),
                                                                        col("src_operating_system_name"),col("src_hardware_type"),col("response_status_code"),
                                                                        col("oidc_client_id"),col("oidc_scopes"),col("oidc_ui_locales"),
                                                                        col("loc_city"),col("loc_country_code")))
    else:
        preprocessed_df = preprocessed_df.withColumn("text", concat_ws(" ", col("date_weekday"),col("date_hour"),col("src_software_name"),
                                                                        col("src_operating_system_name"),col("src_software_type"),col("src_hardware_type"),
                                                                        col("http_method"),col("response_status"),col("oidc_response_type"),col("oidc_acr_values"),
                                                                        col("oidc_client_id"),col("client_type"),col("ido_id"),col("oidc_scopes"),
                                                                        col("oidc_ui_locales"),col("loc_country")))

    columns = ['label_nr', 'text', 'tokens']

    if additional_cols:
        columns.append(cfg.key_col_name)
        columns.append(cfg.value_col_name)

    # split the token string into an array of tokens
    preprocessed_df = preprocessed_df.withColumn("tokens", split(col("text"), " ").cast("array<string>")).select(*columns)

    return preprocessed_df


def vectorize(preprocessed_df, incl_idf=False):

    """ Generate Feature Vectors from the Pre-processed corpus using the
    hashingTF transformer on the filtered, stemmed and normalised list of Tokens
    """

    # Generate Term Frequency Feature Vectors by passing the sequence of tokens to the HashingTF Transformer.
    # Then fit an IDF Estimator to the Featurized Dataset to generate the IDFModel.
    # Finally pass the TF Feature Vectors to the IDFModel to scale based on frequency across the corpus
    if incl_idf:
        hashing_tf = HashingTF(inputCol="tokens", outputCol="raw_features", numFeatures=280)
        features_df = hashing_tf.transform(preprocessed_df)

        idf = IDF(inputCol="raw_features", outputCol="features")
        idf_model = idf.fit(features_df)
        scaled_features_df = idf_model.transform(features_df)

        return scaled_features_df
    else:
        hashing_tf = HashingTF(inputCol="tokens", outputCol="features", numFeatures=280)
        features_df = hashing_tf.transform(preprocessed_df)
        # Return the final vectorized DataFrame
        return features_df


def detect(log_entries_df, model_path='/shared/models/sentiment/overall/optimized', additional_cols=True, incl_idf=False, reduced_feature_set=True):

    # load the pre-trained 'Decision Tree Classifier'
    model = DecisionTreeClassificationModel.load(model_path)

    # preprocess the raw log statements commin from kafka
    preprocessed_df = preprocess(log_entries_df, additional_cols, reduced_feature_set)

    # apply the Feature Vectorization to these Pre-Processed log entries (Tokens)
    features_df = vectorize(preprocessed_df, incl_idf)

    # apply the Trained Decision Tree Classifier to the Pre-Processed Feature Vectors to predict and classify sentiment
    if additional_cols:
        predictions_df = model.transform(features_df).select("text", "prediction", cfg.key_col_name, cfg.value_col_name)

        # .filter("prediction == 1.0") \
        # anomalies_df = predictions_df \
        #     .select(concat(lit('{"prediction":"'), when(col("prediction") == 1.0, lit("anomaly")).otherwise(lit("normal")),
        #                    lit('","classifier":"decision_tree","uuid":"'), col(cfg.key_col_name), lit('","log_stmt":"'), col(cfg.value_col_name), lit('"}')).alias("value"))

        predictions_df = predictions_df.withColumn('classifier', lit('sentiment'))
        anomalies_df = predictions_df.select(when(col("prediction") == 1.0, lit("anomaly")).otherwise(lit("normal")).alias("prediction"), 'classifier', cfg.key_col_name, cfg.value_col_name)

    else:
        predictions_df = model.transform(features_df).select("text", "prediction")

        # .filter("prediction == 1.0") \
        anomalies_df = predictions_df.select(concat(lit('{"prediction":"'), when(col("prediction") == 1.0, lit("anomaly")).otherwise(lit("normal")),
                                                    lit('","text":"'), col('text'), lit('"}')).alias("value"))

    return anomalies_df
