package com.abcham.securedbankapi.repository;

import com.abcham.securedbankapi.entity.Notice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;


public interface NoticeRepository extends JpaRepository<Notice, Long> {

    @Query("from Notice n where CURRENT_DATE BETWEEN n.noticBegDt AND n.noticEndDt")
    List<Notice> findAllActiveNotices();

}