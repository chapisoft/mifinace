package com.bmf.mobile.infra.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

/**
 * Cấu hình OpenAPI 3.0 / Swagger UI cho tài liệu API Mobile BFF Gateway.
 */
@Configuration
public class OpenApiConfig {

    @Value("${server.port:8080}")
    private String serverPort;

    @Bean
    public OpenAPI customOpenAPI() {
        final String securitySchemeName = "BearerAuthentication";

        return new OpenAPI()
                .info(new Info()
                        .title("BMF Mobile BFF Gateway API Documentation")
                        .version("1.0.0")
                        .description("Tài liệu đặc tả RESTful API cho phân hệ Ứng dụng Di động BMF Myanmar (Agent App & Customer App)")
                        .contact(new Contact()
                                .name("BMF Core Engineering Team")
                                .email("engineering@bmf.mm"))
                        .license(new License()
                                .name("Proprietary - BMF Microfinance Platform")))
                .servers(List.of(
                        new Server().url("http://localhost:" + serverPort).description("Môi trường Phát triển Cục bộ (Localhost)"),
                        new Server().url("https://api-dev.bmf.mm").description("Môi trường Thử nghiệm Tích hợp (Staging/Dev)"),
                        new Server().url("https://api-mobile.bmf.mm").description("Môi trường Sản xuất Chính thức (Production)")
                ))
                .addSecurityItem(new SecurityRequirement().addList(securitySchemeName))
                .components(new Components()
                        .addSecuritySchemes(securitySchemeName, new SecurityScheme()
                                .name(securitySchemeName)
                                .type(SecurityScheme.Type.HTTP)
                                .scheme("bearer")
                                .bearerFormat("JWT")
                                .description("Nhập Access Token JWT dạng: Bearer {token}")));
    }
}
