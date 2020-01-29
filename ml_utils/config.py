#!/usr/bin/python

"""
Configuration values and constants
"""

__author__ = "Fredi Weideli"
__credits__ = ["Fredi Weideli"]
__version__ = "1.0.0"
__maintainer__ = "Fredi Weideli"
__email__ = "fredi.weideli@bluewin.ch"
__status__ = "Masterthesis-POC"


# data constants
label_normal = 'normal'
label_normal_idx = 0

label_anomaly = 'anomaly'
label_anomaly_idx = 1

label_suspect = 'suspect'
label_suspect_idx = 2

label_col_name = 'label'
label_nr_col_name = 'label_nr'
label_index_col_name = 'label_idx'

label_mapping_dict = {label_normal: label_normal_idx, label_anomaly: label_anomaly_idx, label_suspect: label_suspect_idx}

ido_id_col_name = 'ido_id'
ido_id_present_col_name = 'ido_id_present'

unknown_value = '-'

# number of features is 31
complete_feature_list = ['time_stamp', 'label_nr', 'label', 'date_weekday', 'date_hour', 'src_ip', 'src_software_name', 'src_operating_system_name',
           'src_software_type', 'src_software_sub_type', 'src_hardware_type', 'src_hardware_sub_type', 'http_method', 'response_status',
           'response_status_code', 'response_time_ms', 'response_time_cat', 'oidc_response_type', 'oidc_acr_values', 'oidc_client_id',
           'client_name', 'client_type', 'ido_id', 'ido_email', 'ido_type', 'oidc_scopes', 'oidc_ui_locales', 'loc_country', 'loc_region',
           'loc_city', 'loc_country_code']


unused_feature_list = ['time_stamp', 'label_nr', 'src_ip', 'src_software_sub_type', 'src_hardware_sub_type', 'response_status_code',
                     'response_time_ms', 'response_time_cat', 'client_name', 'ido_email', 'ido_type', 'loc_region', 'loc_city', 'loc_country_code']

feature_list = ['label', 'label_nr', 'date_weekday', 'date_hour', 'src_software_name', 'src_operating_system_name', 'src_software_type',
                'src_hardware_type', 'http_method', 'response_status', 'oidc_response_type', 'oidc_acr_values', 'oidc_client_id',
                'client_type', 'ido_id', 'oidc_scopes', 'oidc_ui_locales', 'loc_country']

reduced_feature_list = ['label_nr', 'src_software_sub_type', 'src_operating_system_name', 'src_hardware_type', 'response_status_code', 
            'oidc_client_id', 'oidc_scopes', 'oidc_ui_locales', 'loc_city', 'loc_country_code', 'date_weekday']


# Apache Kafka
bootstrap_servers = 'kafka-server:29092'
data_encoding = 'utf-8'
log_entries_kafka_topic = 'idp-events'
anomaly_kafka_topic = 'anomalies'


# Apache Spark
key_col_name = 'log_stmt_uuid'
value_col_name = 'log_stmt_json'


# Filesystem
checkpoint_path = '/shared/checkpoints'
