package com.abcham.securedbankapi;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;

@SpringBootApplication
@EnableWebSecurity(debug = true)
public class SecuredbankApiApplication {

    static void main(String[] args) {

        SpringApplication.run(SecuredbankApiApplication.class, args);
    }

}
