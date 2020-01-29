package com.swisssign.idp.service;

import com.google.gson.Gson;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Map;
import java.util.UUID;

import static com.swisssign.idp.Consts.*;

@Component
@Scope(ConfigurableBeanFactory.SCOPE_PROTOTYPE)
public class LogStatementConsumerImpl implements LogStatementConsumer {

    private static final String TIME_STAMP = "time_stamp";
    private static final String IDO_ID = "ido_id";
    private static final String LABEL = "label";

    private static final Logger logger = LoggerFactory.getLogger(LogStatementConsumerImpl.class);

    private Gson converter = new Gson();
    private SimpleDateFormat formatter = new SimpleDateFormat(TS_FORMAT);

    private long last_ts = 0;
    private boolean fixed_wait_time = true;
    private long wait_time = 1000;

    private KafkaProducer kafkaProducer;
    private MeterRegistry meterRegistry;

    private Counter normalLabelCounter;
    private Counter suspectLabelCounter;
    private Counter anomalyLabelCounter;

    @Autowired
    public LogStatementConsumerImpl(KafkaProducer producer, MeterRegistry registry) {
        logger.info("Consumer=" + UUID.randomUUID());

        this.kafkaProducer = producer;
        this.meterRegistry = registry;

    }

    @PostConstruct
    private void initMetrics() {
        logger.info("initMetrics is called");

        normalLabelCounter = this.meterRegistry.counter("idp.events", "type", "normal");
        suspectLabelCounter = this.meterRegistry.counter("idp.events", "type", "suspect");

        // just as an example
        anomalyLabelCounter = Counter.builder("idp.events")
                .tag("type", "anomaly")
                .description("The number of anomaly events")
                .register(this.meterRegistry);
    }


    @Override
    public void consume(Map<String, String> logStatement) {

        long diff = 0;
        long cur_ts = 0;

        try {
            cur_ts = formatter.parse(logStatement.get(TIME_STAMP)).getTime();
        } catch (ParseException e) {
            logger.error("error during timestamp parsing", e);
        }

        if (fixed_wait_time) {
            diff = wait_time;
        } else if (last_ts != 0) {
            diff = cur_ts - last_ts;
        }

        try {
            Thread.sleep(wait_time);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        last_ts = cur_ts;

        incLabelCounter(logStatement.get(LABEL));

        kafkaProducer.sendMessage(UUID.randomUUID().toString(), converter.toJson(logStatement));

    }

    private void incLabelCounter(String label) {
        if ("normal".equals(label)) {
            normalLabelCounter.increment();
        } else if ("suspect".equals(label)) {
            suspectLabelCounter.increment();
        } else if ("anomaly".equals(label)) {
            anomalyLabelCounter.increment();
        }
    }

}
