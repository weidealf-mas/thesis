package com.swisssign.idp.model;

import org.springframework.context.ApplicationEvent;

public class AuthenticationEvent extends ApplicationEvent {

    private AuthenticationRequest request;


    public AuthenticationEvent(Object source, AuthenticationRequest request) {
        super(source);
        this.request = request;
    }

    public AuthenticationRequest getRequest() {
        return request;
    }
}
