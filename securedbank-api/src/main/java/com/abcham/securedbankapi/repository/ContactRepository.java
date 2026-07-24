package com.abcham.securedbankapi.repository;

import com.abcham.securedbankapi.entity.Contact;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;


@Repository
public interface ContactRepository extends JpaRepository<Contact, String> {


}
