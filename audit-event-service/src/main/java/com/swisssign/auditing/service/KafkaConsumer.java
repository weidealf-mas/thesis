package com.swisssign.auditing.service;

import com.google.gson.Gson;
import com.swisssign.auditing.model.AuditEvent;
import com.swisssign.auditing.model.AuditEventType;
import com.swisssign.core.model.IdPLogStatement;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import java.util.UUID;


@Service
public class KafkaConsumer {

    @Autowired
    private AuditEventRepository repository;

    private final Logger logger = LoggerFactory.getLogger(KafkaConsumer.class);

    private Gson converter = new Gson();

    private MeterRegistry meterRegistry;

    private Counter successfulAuthNCounter;
    private Counter failedAuthNCounter;
    private Counter anomalyCounter;

    public KafkaConsumer(MeterRegistry registry) {
        this.meterRegistry = registry;
    }

    @PostConstruct
    private void initMetrics() {
        logger.info("initMetrics is called");

        successfulAuthNCounter = this.meterRegistry.counter("audit.events", "type",AuditEventType.AUTHENTICATION_SUCCESSFUL.name());
        failedAuthNCounter = this.meterRegistry.counter("audit.events", "type", AuditEventType.AUTHENTICATION_FAILED.name());

        // just as an example
        anomalyCounter = Counter.builder("audit.events")
                .tag("type", AuditEventType.ANOMALY_DETECTED.name())
                .description("The number of anomaly audit events")
                .register(this.meterRegistry);
    }


    @KafkaListener(topics = "idp-events", groupId = "idp-events-consumers")
    public void consume(@Payload(required = true) String value, @Header(KafkaHeaders.RECEIVED_MESSAGE_KEY) String key) {

        IdPLogStatement stmt = converter.fromJson(value, IdPLogStatement.class);
        stmt.setUuid(UUID.fromString(key).toString());

        logger.debug("********* key: " + stmt.getUuid());
        logger.debug("********* ido-id: " + stmt.getIdoId());

        if (!stmt.getIdoId().equals("-")) {

            AuditEventType eventType = AuditEventType.AUTHENTICATION_SUCCESSFUL;

            if (!stmt.getResponseStatus().equalsIgnoreCase("SUCCESSFUL")) {
                eventType = AuditEventType.AUTHENTICATION_FAILED;
            }

            incAuditEventTypeCounter(eventType);

            repository.save(new AuditEvent(stmt.getUuid(), stmt.getTimestamp(), stmt.getIdoId(), eventType.name()));
        }

    }

    private void incAuditEventTypeCounter(AuditEventType type) {

        switch (type)
        {
            case AUTHENTICATION_SUCCESSFUL:
                successfulAuthNCounter.increment();
                break;
            case AUTHENTICATION_FAILED:
                failedAuthNCounter.increment();
                break;
            case ANOMALY_DETECTED:
                anomalyCounter.increment();
                break;
            default:
        }

    }
}
