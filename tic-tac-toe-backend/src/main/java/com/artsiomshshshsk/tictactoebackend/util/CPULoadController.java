package com.artsiomshshshsk.tictactoebackend.util;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class CPULoadController {

    @GetMapping("/load-cpu")
    public String loadCpu() {
        long result = fibonacci(40);
        return "CPU load generated. Fibonacci result: " + result;
    }

    private long fibonacci(int n) {
        if (n <= 1) {
            return n;
        }
        return fibonacci(n - 1) + fibonacci(n - 2);
    }
}