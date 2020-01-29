package com.swisssign.idp.service;

import java.util.Map;

interface LogStatementConsumer {

    void consume(Map<String, String> logStatement);

}
