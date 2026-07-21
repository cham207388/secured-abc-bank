package com.abcham.securedbank;

import org.flywaydb.core.Flyway;
import org.junit.jupiter.api.Test;
import org.testcontainers.containers.PostgreSQLContainer;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DriverManagerDataSource;

import javax.sql.DataSource;

import static org.assertj.core.api.Assertions.assertThat;

public class MigrationIT {

    @Test
    void flywayMigrationsApply() {
        try (PostgreSQLContainer<?> pg = new PostgreSQLContainer<>("postgres:16")) {
            pg.start();

            DriverManagerDataSource ds = new DriverManagerDataSource(pg.getJdbcUrl(), pg.getUsername(), pg.getPassword());

            Flyway flyway = Flyway.configure()
                    .dataSource(ds)
                    .locations("classpath:db/migration")
                    .load();

            flyway.migrate();

            JdbcTemplate jt = new JdbcTemplate(ds);
            Integer count = jt.queryForObject("SELECT count(*) FROM users", Integer.class);
            assertThat(count).isNotNull();

            pg.stop();
        }
    }
}
