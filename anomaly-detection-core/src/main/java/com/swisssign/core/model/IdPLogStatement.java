package com.swisssign.core.model;

import com.google.gson.annotations.SerializedName;

import java.util.Objects;


public class IdPLogStatement {

    private String uuid;

    @SerializedName("time_stamp")
    private String timestamp;

    @SerializedName("label_nr")
    private int labelNumber;

    @SerializedName("label")
    private String label;

    @SerializedName("date_weekday")
    private int weekday;

    @SerializedName("date_hour")
    private int hour;

    @SerializedName("src_ip")
    private String sourceIP;

    @SerializedName("src_software_name")
    private String softwareName;

    @SerializedName("src_operating_system_name")
    private String operatingSystemName;

    @SerializedName("src_software_type")
    private String softwareType;

    @SerializedName("src_software_sub_type")
    private String softwareSubType;

    @SerializedName("src_hardware_type")
    private String hardwareType;

    @SerializedName("src_hardware_sub_type")
    private String hardwareSubType;

    @SerializedName("http_method")
    private String httpMethod;

    @SerializedName("response_status")
    private String responseStatus;

    @SerializedName("response_status_code")
    private int responseStatusCode;

    @SerializedName("response_time_ms")
    private long responseTime;

    @SerializedName("response_time_cat")
    private String responseTimeCategory;

    @SerializedName("oidc_response_type")
    private String oidcResponseType;

    @SerializedName("oidc_acr_values")
    private String oidcAcrValues;

    @SerializedName("oidc_client_id")
    private String oidcClientId;

    @SerializedName("client_name")
    private String clientName;

    @SerializedName("client_type")
    private String clientType;

    @SerializedName("ido_id")
    private String idoId;

    @SerializedName("ido_email")
    private String idoEmail;

    @SerializedName("ido_type")
    private String idoType;

    @SerializedName("oidc_scopes")
    private String oidcScopes;

    @SerializedName("oidc_ui_locales")
    private String oidcUILocales;

    @SerializedName("loc_country")
    private String country;

    @SerializedName("loc_region")
    private String region;

    @SerializedName("loc_city")
    private String city;

    @SerializedName("loc_country_code")
    private String countryCode;

    public String getUuid() {
        return uuid;
    }

    public void setUuid(String uuid) {
        this.uuid = uuid;
    }

    public String getTimestamp() {
        return timestamp;
    }

    public int getLabelNumber() {
        return labelNumber;
    }

    public String getLabel() {
        return label;
    }

    public int getWeekday() {
        return weekday;
    }

    public int getHour() {
        return hour;
    }

    public String getSourceIP() {
        return sourceIP;
    }

    public String getSoftwareName() {
        return softwareName;
    }

    public String getOperatingSystemName() {
        return operatingSystemName;
    }

    public String getSoftwareType() {
        return softwareType;
    }

    public String getSoftwareSubType() {
        return softwareSubType;
    }

    public String getHardwareType() {
        return hardwareType;
    }

    public String getHardwareSubType() {
        return hardwareSubType;
    }

    public String getHttpMethod() {
        return httpMethod;
    }

    public String getResponseStatus() {
        return responseStatus;
    }

    public int getResponseStatusCode() {
        return responseStatusCode;
    }

    public long getResponseTime() {
        return responseTime;
    }

    public String getResponseTimeCategory() {
        return responseTimeCategory;
    }

    public String getOidcResponseType() {
        return oidcResponseType;
    }

    public String getOidcAcrValues() {
        return oidcAcrValues;
    }

    public String getOidcClientId() {
        return oidcClientId;
    }

    public String getClientName() {
        return clientName;
    }

    public String getClientType() {
        return clientType;
    }

    public String getIdoId() {
        return idoId;
    }

    public String getIdoEmail() {
        return idoEmail;
    }

    public String getIdoType() {
        return idoType;
    }

    public String getOidcScopes() {
        return oidcScopes;
    }

    public String getOidcUILocales() {
        return oidcUILocales;
    }

    public String getCountry() {
        return country;
    }

    public String getRegion() {
        return region;
    }

    public String getCity() {
        return city;
    }

    public String getCountryCode() {
        return countryCode;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        IdPLogStatement that = (IdPLogStatement) o;
        return uuid.equals(that.uuid);
    }

    @Override
    public int hashCode() {
        return Objects.hash(uuid);
    }

    @Override
    public String toString() {
        return "IdPLogStatement{" +
                "uuid='" + uuid + '\'' +
                ", timestamp='" + timestamp + '\'' +
                ", labelNumber=" + labelNumber +
                ", label='" + label + '\'' +
                ", weekday=" + weekday +
                ", hour=" + hour +
                ", sourceIP='" + sourceIP + '\'' +
                ", softwareName='" + softwareName + '\'' +
                ", operatingSystemName='" + operatingSystemName + '\'' +
                ", softwareType='" + softwareType + '\'' +
                ", softwareSubType='" + softwareSubType + '\'' +
                ", hardwareType='" + hardwareType + '\'' +
                ", hardwareSubType='" + hardwareSubType + '\'' +
                ", httpMethod='" + httpMethod + '\'' +
                ", responseStatus='" + responseStatus + '\'' +
                ", responseStatusCode=" + responseStatusCode +
                ", responseTime=" + responseTime +
                ", responseTimeCategory='" + responseTimeCategory + '\'' +
                ", oidcResponseType='" + oidcResponseType + '\'' +
                ", oidcAcrValues='" + oidcAcrValues + '\'' +
                ", oidcClientId='" + oidcClientId + '\'' +
                ", clientName='" + clientName + '\'' +
                ", clientType='" + clientType + '\'' +
                ", idoId='" + idoId + '\'' +
                ", idoEmail='" + idoEmail + '\'' +
                ", idoType='" + idoType + '\'' +
                ", oidcScopes='" + oidcScopes + '\'' +
                ", oidcUILocales='" + oidcUILocales + '\'' +
                ", country='" + country + '\'' +
                ", region='" + region + '\'' +
                ", city='" + city + '\'' +
                ", countryCode='" + countryCode + '\'' +
                '}';
    }
}
