package com.swisssign.auditing.service;


import com.swisssign.auditing.model.AuditEvent;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AuditEventRepository extends CrudRepository<AuditEvent, String> {

    List<AuditEvent> findByIdoId(String idoId);

}
