package com.swisssign.core.model;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;

public class AuthenticationRequest {

    private String subject;
    private String acr;
    private String client;

    protected AuthenticationRequest() {
    }

    public AuthenticationRequest(String subject, String acr, String client) {
        this.subject = subject;
        this.acr = acr;
        this.client = client;
    }

    public String getSubject() {
        return subject;
    }

    public String getAcr() {
        return acr;
    }

    public String getClient() {
        return client;
    }

    public String toJson() throws JsonProcessingException {
        ObjectMapper mapper = new ObjectMapper();
        return mapper.writeValueAsString(this);
    }

    public static AuthenticationRequest fromJson(String json) throws IOException {
        ObjectMapper mapper = new ObjectMapper();
        return mapper.readValue(json, AuthenticationRequest.class);
    }
}
