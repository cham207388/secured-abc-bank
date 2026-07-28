package com.abcham.securedbankapi.controller;

import com.abcham.securedbankapi.entity.AccountTransactions;
import com.abcham.securedbankapi.entity.Customer;
import com.abcham.securedbankapi.repository.AccountTransactionsRepository;
import com.abcham.securedbankapi.repository.CustomerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Optional;

@RestController
@RequiredArgsConstructor
public class BalanceController {

    private final AccountTransactionsRepository accountTransactionsRepository;
    private final CustomerRepository customerRepository;

    @GetMapping("/myBalance")
    public List<AccountTransactions> getBalanceDetails(@RequestParam String email) {
        Optional<Customer> optionalCustomer = customerRepository.findByEmail(email);
        return optionalCustomer.map(customer -> accountTransactionsRepository.
                findByCustomerIdOrderByTransactionDtDesc(customer.getId())).orElse(null);
    }
}