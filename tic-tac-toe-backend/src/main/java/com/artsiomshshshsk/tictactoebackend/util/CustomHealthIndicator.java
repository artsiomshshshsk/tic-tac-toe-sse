package com.artsiomshshshsk.tictactoebackend.util;

import lombok.Setter;
import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.HealthIndicator;
import org.springframework.context.annotation.Primary;
import org.springframework.stereotype.Component;

@Setter
@Component
@Primary
public class CustomHealthIndicator implements HealthIndicator {

    private String healthStatus = "UP";

    @Override
    public Health health() {
        if ("DOWN".equalsIgnoreCase(healthStatus)) {
            return Health.down().build();
        } else {
            return Health.up().build();
        }
    }

}