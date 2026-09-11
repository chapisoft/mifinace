package com.bmf.mobile.api;

import org.mockito.Mockito;
import org.redisson.api.RBucket;
import org.redisson.api.RedissonClient;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Profile;

import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

@TestConfiguration
@Profile("test")
public class TestConfig {

    @Bean
    @Primary
    @SuppressWarnings("unchecked")
    public RedissonClient redissonClient() {
        RedissonClient redissonClient = mock(RedissonClient.class);
        RBucket<Object> bucket = mock(RBucket.class);
        when(redissonClient.getBucket(anyString())).thenReturn((RBucket) bucket);
        return redissonClient;
    }
}
