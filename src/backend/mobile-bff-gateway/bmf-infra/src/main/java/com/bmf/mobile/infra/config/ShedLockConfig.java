package com.bmf.mobile.infra.config;

import lombok.extern.slf4j.Slf4j;
import net.javacrumbs.shedlock.core.LockConfiguration;
import net.javacrumbs.shedlock.core.LockProvider;
import net.javacrumbs.shedlock.core.SimpleLock;
import net.javacrumbs.shedlock.provider.redis.spring.RedisLockProvider;
import net.javacrumbs.shedlock.spring.annotation.EnableSchedulerLock;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.scheduling.annotation.EnableScheduling;

import java.time.Instant;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Cấu hình ShedLock bảo vệ các Cron Job / Scheduled Tasks chạy trên cụm server phân tán.
 * Ngăn chặn xung đột xử lý trùng lặp khi chạy đa node / container.
 */
@Slf4j
@Configuration
@EnableScheduling
@EnableSchedulerLock(defaultLockAtMostFor = "30m")
public class ShedLockConfig {

    private static final String SHEDLOCK_ENV = "bmf:shedlock";

    @Bean
    public LockProvider lockProvider(ObjectProvider<RedisConnectionFactory> redisConnectionFactoryProvider) {
        RedisConnectionFactory connectionFactory = redisConnectionFactoryProvider.getIfAvailable();
        if (connectionFactory != null) {
            try {
                log.info("Configuring RedisLockProvider for ShedLock cluster coordination with namespace: {}", SHEDLOCK_ENV);
                return new RedisLockProvider(connectionFactory, SHEDLOCK_ENV);
            } catch (Exception e) {
                log.warn("Failed to initialize RedisLockProvider, falling back to InMemoryLockProvider: {}", e.getMessage());
            }
        }

        log.info("Configuring InMemoryLockProvider for ShedLock (single-node/testing mode)");
        return new InMemoryLockProvider();
    }

    /**
     * InMemory LockProvider phục vụ môi trường kiểm thử hoặc khi chưa kết nối Redis.
     */
    private static class InMemoryLockProvider implements LockProvider {
        private final Map<String, Instant> lockedUntilMap = new ConcurrentHashMap<>();

        @Override
        public Optional<SimpleLock> lock(LockConfiguration lockConfiguration) {
            String name = lockConfiguration.getName();
            Instant now = Instant.now();
            Instant lockedUntil = lockedUntilMap.get(name);

            if (lockedUntil == null || now.isAfter(lockedUntil)) {
                lockedUntilMap.put(name, lockConfiguration.getLockAtMostUntil());
                return Optional.of(new SimpleLock() {
                    @Override
                    public void unlock() {
                        Instant lockAtLeastUntil = lockConfiguration.getLockAtLeastUntil();
                        Instant unlockTime = Instant.now();
                        if (unlockTime.isBefore(lockAtLeastUntil)) {
                            lockedUntilMap.put(name, lockAtLeastUntil);
                        } else {
                            lockedUntilMap.remove(name);
                        }
                    }
                });
            }
            return Optional.empty();
        }
    }
}
