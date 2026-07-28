package com.abcham.securedbankapi.controller;

import com.abcham.securedbankapi.entity.Customer;
import com.abcham.securedbankapi.repository.CustomerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Optional;

@RestController
@RequiredArgsConstructor
public class UserController {

    private final CustomerRepository customerRepository;


    @RequestMapping("/user")
    public Customer getUserDetailsAfterLogin(Authentication authentication) {

        Optional<Customer> optionalCustomer =
                customerRepository.findByEmail(authentication.getName());
        return optionalCustomer.orElse(null);
    }

}