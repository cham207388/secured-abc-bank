package com.abcham.securedbankapi.controller;

import com.abcham.securedbankapi.entity.Loans;
import com.abcham.securedbankapi.repository.LoanRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class LoansController {

    private final LoanRepository loanRepository;

    @GetMapping("/myLoans")
    public List<Loans> getLoanDetails(@RequestParam long id) {

        List<Loans> loans = loanRepository.findByCustomerIdOrderByStartDtDesc(id);
        return loans;
    }

}
