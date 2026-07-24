# HikariCP Thread Starvation Issue & Solutions

## Problem Overview

### Symptoms

Multiple warnings detected in application logs:

```
WARN 59386 --- [securedbank-api] [l-1:housekeeper] com.zaxxer.hikari.pool.HikariPool: 
HikariPool-1 - Thread starvation or clock leap detected (housekeeper delta=2m-12m)
```

The "delta" shows how long the housekeeper thread was delayed from expected execution (2-12 minutes).

### Root Cause

**No HikariCP connection pool configuration** in `application.yaml` - the application is using defaults which are
inadequate for current load.

---

## Current Configuration Analysis

### ✅ What's Good

- Spring Boot 4.1.0 (latest)
- PostgreSQL driver properly configured
- Java 25 with virtual threads enabled
- Flyway migrations properly setup
- SQL logging disabled in production

### ❌ What's Missing

- **No pool size configuration**
- **No connection timeout settings**
- **No idle connection handling**
- **No leak detection**

---

## Practical Solutions

### Solution 1: Add HikariCP Configuration (RECOMMENDED)

**File**: `src/main/resources/application.yaml`

Add under `spring.datasource`:

```yaml
spring:
  datasource:
    driver-class-name: org.postgresql.Driver
    url: ${SPRING_DATASOURCE_URL:jdbc:postgresql://${DATABASE_HOST:localhost}:${DATABASE_PORT:5434}/${DATABASE_NAME:securedbank}}
    username: ${SPRING_DATASOURCE_USERNAME:postgres}
    password: ${SPRING_DATASOURCE_PASSWORD:postgres}
    hikari:
      maximum-pool-size: 20              # Adjust based on your load
      minimum-idle: 5                    # Keep 5 connections ready
      connection-timeout: 30000          # 30 seconds - fail fast
      idle-timeout: 600000               # 10 minutes - release stale connections
      max-lifetime: 1800000              # 30 minutes - connection lifecycle
      auto-commit: true
      leak-detection-threshold: 60000    # Detect leaks after 60 seconds
```

### Solution 2: Production Configuration

**File**: `src/main/resources/application-prod.yaml`

Use higher pool sizes for production:

```yaml
spring:
  datasource:
    hikari:
      maximum-pool-size: 30              # Higher for production
      minimum-idle: 10
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000
      auto-commit: true
      leak-detection-threshold: 60000
```

### Solution 3: Add Connection Pool Monitoring

Add to `application.yaml` for debugging:

```yaml
spring:
  jpa:
    properties:
      hibernate:
        generate_statistics: true        # Enable Hibernate stats
  logging:
    level:
      com.zaxxer.hikari.pool.HikariPool: DEBUG  # Monitor pool behavior
      org.hibernate.stat: DEBUG                 # Monitor query execution
```

---

## Configuration Parameters Explained

| Parameter                  | Value           | Purpose                                         |
|----------------------------|-----------------|-------------------------------------------------|
| `maximum-pool-size`        | 20-30           | Maximum connections; prevents exhaustion        |
| `minimum-idle`             | 5-10            | Pre-warmed connections; reduces creation delays |
| `connection-timeout`       | 30000ms         | Fail fast if no connection available            |
| `idle-timeout`             | 600000ms (10m)  | Close unused connections                        |
| `max-lifetime`             | 1800000ms (30m) | Max connection age before recycling             |
| `leak-detection-threshold` | 60000ms (60s)   | Alert if connection held too long               |

---

## Why This Fixes Thread Starvation

1. **Adequate Pool Size**: Prevents connection exhaustion
2. **Connection Reuse**: Minimum-idle keeps connections warm
3. **Timeout Handling**: Fails fast instead of queuing forever
4. **Resource Cleanup**: Idle/max-lifetime releases stale connections
5. **Leak Detection**: Identifies long-held connections

---

## Additional Quick Wins (No Changes)

### 1. Review Slow Queries

- Check for N+1 queries in JPA repositories
- Monitor query execution times with `generate_statistics: true`

### 2. Reduce Security Logging

**File**: `application.yaml` (default profile)

Currently set to `TRACE` which is expensive:

```yaml
spring:
  logging:
    level:
      org.springframework.security: WARN  # Change from TRACE to WARN
```

### 3. Optimize Session Timeout

Currently `20m` (default), consider:

```yaml
server:
  servlet:
    session:
      timeout: 15m  # Reduce to free resources sooner
```

### 4. Monitor Connection Leaks

If warnings persist after config, check for:

- Controllers/Services holding DB connections too long
- Missing `@Transactional` closing transactions properly
- Resource leaks in exception handlers

---

## Implementation Steps

### Step 1: Backup Current Config

```bash
cp src/main/resources/application.yaml src/main/resources/application.yaml.bak
```

### Step 2: Update application.yaml

Add HikariCP configuration as shown in Solution 1

### Step 3: Update application-prod.yaml

Add HikariCP configuration as shown in Solution 2

### Step 4: Restart Application

Test with the new configuration

### Step 5: Monitor Logs

Watch for HikariCP warnings; they should decrease or disappear

---

## Expected Results

After implementation:

- ✅ HikariCP housekeeper runs without delays
- ✅ Connection reuse improves performance
- ✅ Application handles load more efficiently
- ✅ Reduced thread starvation warnings

---

## References

- [HikariCP Configuration](https://github.com/brettwooldridge/HikariCP/wiki/Configuration)
- [Spring Boot DataSource](https://spring.io/blog/2019/03/11/wondering-what-to-do-with-your-jdbc/)
