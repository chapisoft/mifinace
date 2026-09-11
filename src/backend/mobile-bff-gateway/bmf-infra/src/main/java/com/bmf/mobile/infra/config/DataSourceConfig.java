package com.bmf.mobile.infra.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.jdbc.core.simple.JdbcClient;

import javax.sql.DataSource;

/**
 * Cấu hình Connection Pool HikariCP tối ưu kết nối Microsoft SQL Server 2017 Core NG-mFINA.
 */
@Slf4j
@Configuration
public class DataSourceConfig {

    @Value("${spring.datasource.url:jdbc:sqlserver://localhost:1433;databaseName=NG-mFINA-BMF_20180402;encrypt=false;trustServerCertificate=true}")
    private String dbUrl;

    @Value("${spring.datasource.username:sa}")
    private String dbUsername;

    @Value("${spring.datasource.password:Bmf@2026Secure!}")
    private String dbPassword;

    @Value("${spring.datasource.driver-class-name:com.microsoft.sqlserver.jdbc.SQLServerDriver}")
    private String driverClassName;

    @Bean
    @Primary
    @ConditionalOnProperty(name = "spring.datasource.hikari-custom.enabled", havingValue = "true", matchIfMissing = false)
    public DataSource hikariDataSource() {
        log.info("Initializing HikariCP Connection Pool for NG-mFINA Database: url={}", dbUrl);

        HikariConfig config = new HikariConfig();
        config.setPoolName("BMF-NG-mFINA-Pool");
        config.setJdbcUrl(dbUrl);
        config.setUsername(dbUsername);
        config.setPassword(dbPassword);
        config.setDriverClassName(driverClassName);

        // Tham số tối ưu tải cao
        config.setMaximumPoolSize(30);
        config.setMinimumIdle(10);
        config.setConnectionTimeout(30000);   // 30s chờ kết nối
        config.setIdleTimeout(600000);         // 10 phút ngắt kết nối rỗi
        config.setMaxLifetime(1800000);        // 30 phút tái tạo kết nối
        config.setAutoCommit(false);           // Quản trị giao dịch nguyên tử tường minh
        config.setConnectionTestQuery("SELECT 1");

        // Các thiết lập tối ưu hiệu năng MSSQL JDBC
        config.addDataSourceProperty("cachePrepStmts", "true");
        config.addDataSourceProperty("prepStmtCacheSize", "250");
        config.addDataSourceProperty("prepStmtCacheSqlLimit", "2048");
        config.addDataSourceProperty("useServerPrepStmts", "true");

        return new HikariDataSource(config);
    }

    @Bean
    public JdbcClient jdbcClient(DataSource dataSource) {
        return JdbcClient.create(dataSource);
    }
}
