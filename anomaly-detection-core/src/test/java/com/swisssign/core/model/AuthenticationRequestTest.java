package com.swisssign.core.model;

import java.io.IOException;

import static org.junit.jupiter.api.Assertions.*;

class AuthenticationRequestTest {

    @org.junit.jupiter.api.Test
    void serialization() throws IOException {

        //Arrange
        AuthenticationRequest event = new AuthenticationRequest("subjectId", "loa-1", "clientId");

        //Act
        String json  = event.toJson();
        AuthenticationRequest clone = AuthenticationRequest.fromJson(json);

        //Assert
        assertEquals(event.getSubject(),clone.getSubject());
        assertEquals(event.getAcr(),clone.getAcr());
        assertEquals(event.getClient(),clone.getClient());

    }
}