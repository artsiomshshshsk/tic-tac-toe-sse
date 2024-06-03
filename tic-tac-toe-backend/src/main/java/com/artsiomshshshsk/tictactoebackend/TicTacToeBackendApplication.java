package com.artsiomshshshsk.tictactoebackend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.HealthIndicator;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class TicTacToeBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(TicTacToeBackendApplication.class, args);
    }
}
