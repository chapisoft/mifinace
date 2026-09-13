package com.bmf.mobile.api.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.web.embedded.tomcat.TomcatProtocolHandlerCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.task.AsyncTaskExecutor;
import org.springframework.core.task.support.TaskExecutorAdapter;

import java.util.concurrent.Executors;

/**
 * Cấu hình Java 21 Virtual Threads (Project Loom) cho Tomcat HTTP Server và Async Executor.
 */
@Slf4j
@Configuration
public class VirtualThreadConfig {

    @Bean
    @SuppressWarnings("null")
    public AsyncTaskExecutor applicationTaskExecutor() {
        log.info("Initializing Java 21 Virtual Threads Async Task Executor");
        return new TaskExecutorAdapter(Executors.newVirtualThreadPerTaskExecutor());
    }

    @Bean
    @ConditionalOnProperty(name = "spring.threads.virtual.enabled", havingValue = "true", matchIfMissing = true)
    public TomcatProtocolHandlerCustomizer<?> protocolHandlerVirtualThreadExecutorCustomizer() {
        log.info("Enabling Java 21 Virtual Threads for Tomcat Protocol Handler");
        return protocolHandler -> protocolHandler.setExecutor(Executors.newVirtualThreadPerTaskExecutor());
    }
}
