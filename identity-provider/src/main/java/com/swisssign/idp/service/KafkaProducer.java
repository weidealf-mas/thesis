package com.swisssign.idp.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.swisssign.idp.model.AuthenticationEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationListener;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
public class KafkaProducer implements ApplicationListener<AuthenticationEvent> {

    private static final Logger logger = LoggerFactory.getLogger(KafkaProducer.class);

    @Value("${spring.kafka.producer.topic}")
    private String kafkaTopic;

    @Autowired
    private KafkaTemplate<String, String> kafkaTemplate;


    public void onApplicationEvent(AuthenticationEvent event) {
        String msg = null;
        try {
            msg = event.getRequest().toJson();
            logger.info(String.format("#### -> Received spring authentication event -> %s", msg));
            sendMessage(event.getRequest().getSubject(), msg);
        } catch (JsonProcessingException e) {
            e.printStackTrace();
        }

    }

    public void sendMessage(String message) {
        this.kafkaTemplate.send(kafkaTopic, message);
    }

    public void sendMessage(String key, String message) {
        this.kafkaTemplate.send("idp-events", key, message);
    }
}
