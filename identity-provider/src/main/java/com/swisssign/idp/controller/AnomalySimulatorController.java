package com.swisssign.idp.controller;

import com.swisssign.idp.service.LogStatementProducer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.concurrent.CompletableFuture;

import static com.swisssign.idp.Consts.CSV_ANOMALIES_LOG_DATA;

@RestController
@RequestMapping(value = "/simulator")
public class AnomalySimulatorController {

    @Autowired
    private LogStatementProducer producer;

    @GetMapping(value = "/start")
    public String start() {
        producer.reset();
        System.out.println("event generator started");
        CompletableFuture<String> res =producer.produce(CSV_ANOMALIES_LOG_DATA);
        return "started";
    }

    @GetMapping(value = "/stop")
    public String stop() {
        System.out.println("event generation stopped");
        producer.interrupt();
        return "stopped";
    }

}
