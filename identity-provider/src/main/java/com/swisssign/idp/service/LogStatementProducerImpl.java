package com.swisssign.idp.service;

import com.opencsv.CSVParser;
import com.opencsv.CSVParserBuilder;
import com.opencsv.CSVReader;
import com.opencsv.CSVReaderBuilder;
import com.opencsv.exceptions.CsvValidationException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;

import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;

import static com.swisssign.idp.Consts.*;

@Component
@Scope(ConfigurableBeanFactory.SCOPE_PROTOTYPE)
public class LogStatementProducerImpl implements LogStatementProducer {

    private static final Logger logger = LoggerFactory.getLogger(LogStatementProducerImpl.class);

    private LogStatementConsumer consumer;
    private boolean interrupt = false;
    private long counter = 0;
    private long maxNumberOfStatements = Long.MAX_VALUE;

    @Autowired
    public LogStatementProducerImpl(LogStatementConsumer consumer) {
        logger.info("Producer=" + UUID.randomUUID());

        this.consumer = consumer;
    }

    public synchronized void interrupt() {
        this.interrupt = true;
    }

    public synchronized void reset() {
        this.interrupt = false;
        this.counter = 0;
    }

//    @Override
//    public void onApplicationEvent(ApplicationEvent event) {
//
//        if (event.getSource().getClass().equals(LogStatementHandler.class)){
//            interrupt();
//        }
//
//    }


    public long getMaxNumberOfStatements() {
        return maxNumberOfStatements;
    }

    public void setMaxNumberOfStatements(long maxNumberOfStatements) {
        this.maxNumberOfStatements = maxNumberOfStatements;
    }

    @Override
    @Async("asyncExecutor")
    public CompletableFuture<String> produce(String csvFile)  {

        CSVReader reader = null;

        try {

            reader = createCSVReader(csvFile);

            String[] line;

            while ((line = reader.readNext()) != null && !interrupt && (counter < maxNumberOfStatements)) {
                consumer.consume(asMap(line));
                counter++;
            }

        } catch (IOException | CsvValidationException e) {
            logger.error("Error during CSV reading", e);
        }

        return CompletableFuture.completedFuture("finished");
        
    }

    private CSVReader createCSVReader(String csvFile) throws FileNotFoundException {

        final CSVParser parser = new CSVParserBuilder()
                        .withSeparator('\t')
                        .withQuoteChar('"')
                        .build();

        return new CSVReaderBuilder(new FileReader(csvFile))
                        .withCSVParser(parser)
                        .build();
    }

    private Map<String, String> asMap(String[] line) {

        final Map<String, String> row = new HashMap<>();

        for (int i = 0; i < CSV_COLUMNS.length; i++) {
            row.put(CSV_COLUMNS[i],line[i]);
        }
        return row;
    }


}
