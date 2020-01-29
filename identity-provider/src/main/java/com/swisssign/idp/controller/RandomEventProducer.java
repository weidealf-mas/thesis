package com.swisssign.idp.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.swisssign.idp.model.AuthenticationRequest;
import com.swisssign.idp.service.KafkaProducer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Random;

@RestController
@RequestMapping(value = "/eventing")
public class RandomEventProducer {

    private boolean started = false;

    @Autowired
    private KafkaProducer producer;

    @GetMapping(value = "/start")
    public void start() throws JsonProcessingException {

        System.out.println("event generator started");

        started = true;

        Random rand = new Random();
        Random randTime = new Random();

        while (started){

            String subject = "" + rand.nextInt(10);
            String client = "" + rand.nextInt(10);

            AuthenticationRequest request = new AuthenticationRequest(subject, "loa-1", client);

            producer.sendMessage(subject, request.toJson());

            try {
                Thread.sleep(randTime.nextInt(30));
            } catch (InterruptedException e) {
                started = false;
                e.printStackTrace();
            }

        }

    }

    @GetMapping(value = "/stop")
    public String stop() {
        System.out.println("event generation stopped");
        started = false;
        return "stopped";
    }

}
