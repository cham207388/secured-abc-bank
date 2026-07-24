package com.abcham.securedbankapi.repository;

import com.abcham.securedbankapi.entity.AccountTransactions;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;


@Repository
public interface AccountTransactionsRepository extends JpaRepository<AccountTransactions, String> {

    List<AccountTransactions> findByCustomerIdOrderByTransactionDtDesc(long customerId);

}
