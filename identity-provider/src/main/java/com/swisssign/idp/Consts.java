package com.swisssign.idp;

public final class Consts {

    public static final String[] CSV_COLUMNS = {"time_stamp", "label_nr", "label", "date_weekday", "date_hour", "src_ip", "src_software_name", "src_operating_system_name",
            "src_software_type", "src_software_sub_type", "src_hardware_type", "src_hardware_sub_type", "http_method", "response_status","response_status_code",
            "response_time_ms", "response_time_cat", "oidc_response_type", "oidc_acr_values", "oidc_client_id","client_name", "client_type", "ido_id", "ido_email",
            "ido_type", "oidc_scopes", "oidc_ui_locales", "loc_country", "loc_region","loc_city", "loc_country_code"};

    public static final String TS_FORMAT = "yyyy-MM-dd HH:mm:ss.SSS";

    public static final String CSV_AUTHORIZE_LOG_DATA = "/shared/data/swissid_authorize_logs_april_to_sept_2019.csv";

    public static final String CSV_ANOMALIES_LOG_DATA = "/shared/data/swissid_authorize_anomaly_logs_april_to_sept_2019.csv";

}
