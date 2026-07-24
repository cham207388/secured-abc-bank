package com.abcham.securedbankapi.repository;

import com.abcham.securedbankapi.entity.Accounts;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AccountsRepository extends CrudRepository<Accounts, Long> {

    Accounts findByCustomerId(long customerId);

}