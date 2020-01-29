package com.swisssign.idp.service;

import org.springframework.scheduling.annotation.Async;

import java.util.concurrent.CompletableFuture;

public interface LogStatementProducer {

    @Async("asyncExecutor")
    CompletableFuture<String> produce(String csvFile);

    void interrupt();

    void reset();
}
