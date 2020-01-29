package com.swisssign.auditing.model;

import org.springframework.data.domain.Persistable;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import java.util.Objects;

@Entity
@Table(name = "idp_audit_events")
public class AuditEvent implements Persistable<String> {

    @Id
    private String uuid;

    @Column(name="time_stamp", nullable=false, length=128)
    private String timestamp;

    @Column(name="ido_id", nullable=false, length=128)
    private String idoId;

    @Column(name="event_id", nullable=false, length=128)
    private String eventId;

    public AuditEvent() {
    }

    public AuditEvent(String uuid, String timestamp, String idoId, String eventId) {
        this.uuid = uuid;
        this.timestamp = timestamp;
        this.idoId = idoId;
        this.eventId = eventId;
    }

    public String getUuid() {
        return uuid;
    }

    public void setUuid(String uuid) {
        this.uuid = uuid;
    }

    public String getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(String timestamp) {
        this.timestamp = timestamp;
    }

    public String getIdoId() {
        return idoId;
    }

    public void setIdoId(String idoId) {
        this.idoId = idoId;
    }

    public String getEventId() {
        return eventId;
    }

    public void setEventId(String eventId) {
        this.eventId = eventId;
    }

    @Override
    public String getId() {
        return uuid;
    }

    @Override
    public boolean isNew() {
        return true;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        AuditEvent that = (AuditEvent) o;
        return uuid.equals(that.uuid);
    }

    @Override
    public int hashCode() {
        return Objects.hash(uuid);
    }

    @Override
    public String toString() {
        return "AuditEvent{" +
                "uuid='" + uuid + '\'' +
                ", timestamp='" + timestamp + '\'' +
                ", idoId='" + idoId + '\'' +
                ", eventId='" + eventId + '\'' +
                '}';
    }
}
