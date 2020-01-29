package com.swisssign.idp.controller;

import com.swisssign.idp.model.AuthenticationEvent;
import com.swisssign.idp.model.AuthenticationRequest;
import com.swisssign.idp.service.LogStatementProducer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.web.bind.annotation.*;

import java.util.concurrent.CompletableFuture;

import static com.swisssign.idp.Consts.CSV_AUTHORIZE_LOG_DATA;

@RestController
@RequestMapping(value = "/oidc")
public class OpenIdConnectController {

    @Autowired
    private ApplicationEventPublisher applicationEventPublisher;

    @Autowired
    private LogStatementProducer producer;

    @PostMapping(value = "/authorize")
    public void publishAuthorizeEvent(@RequestParam("user") String user) {
        AuthenticationEvent authEvent = new AuthenticationEvent(this, new AuthenticationRequest(user, "loa-1", "clientId-123"));
        applicationEventPublisher.publishEvent(authEvent);
    }

    @GetMapping(value = "/start")
    public String start() {
        producer.reset();
        System.out.println("event generator started");
        CompletableFuture<String> res = producer.produce(CSV_AUTHORIZE_LOG_DATA);
        return "started";
    }

    @GetMapping(value = "/stop")
    public String stop() {
        System.out.println("event generation stopped");
        producer.interrupt();
        return "stopped";
    }

}
