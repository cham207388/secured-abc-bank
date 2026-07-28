package com.abcham.securedbankapi.controller;

import com.abcham.securedbankapi.entity.Accounts;
import com.abcham.securedbankapi.entity.Customer;
import com.abcham.securedbankapi.repository.AccountsRepository;
import com.abcham.securedbankapi.repository.CustomerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Optional;

@RestController
@RequiredArgsConstructor
public class AccountController {

    private final AccountsRepository accountsRepository;
    private final CustomerRepository customerRepository;

    @GetMapping("/myAccount")
    public Accounts getAccountDetails(@RequestParam String email) {
        Optional<Customer> optionalCustomer = customerRepository.findByEmail(email);
        return optionalCustomer.map(customer -> accountsRepository
                .findByCustomerId(customer.getId())).orElse(null);
    }

}