package com.bmf.mobile.infra.security;

import com.bmf.mobile.domain.constant.AppConstants;
import com.bmf.mobile.domain.enums.PlatformType;
import com.bmf.mobile.domain.enums.UserType;
import io.jsonwebtoken.Claims;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.MDC;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.UUID;

/**
 * Filter chặn mọi HTTP request để trích xuất và thẩm tra Token JWT Bearer.
 * Kiểm tra Blacklist trên Redis trước khi cấp quyền vào SecurityContextHolder.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private static final String BEARER_PREFIX = "Bearer ";
    private static final String AUTHORIZATION_HEADER = "Authorization";

    private final JwtTokenProvider jwtTokenProvider;
    private final TokenBlacklistService tokenBlacklistService;

    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain) throws ServletException, IOException {

        // Đảm bảo traceId luôn hiện diện trong MDC
        String traceId = request.getHeader(AppConstants.HEADER_TRACE_ID);
        if (!StringUtils.hasText(traceId)) {
            traceId = UUID.randomUUID().toString();
        }
        MDC.put(AppConstants.MDC_TRACE_ID, traceId);
        response.setHeader(AppConstants.HEADER_TRACE_ID, traceId);

        try {
            String jwt = parseJwt(request);

            if (StringUtils.hasText(jwt) && jwtTokenProvider.validateToken(jwt)) {
                Claims claims = jwtTokenProvider.extractClaims(jwt);
                String jti = claims.getId();

                // Kiểm tra xem Token có bị Blacklist (đã logout) hay không
                if (tokenBlacklistService.isBlacklisted(jti)) {
                    log.warn("[{}] Rejected request with blacklisted token: jti={}, path={}",
                            traceId, jti, request.getRequestURI());
                } else {
                    String userId = claims.getSubject();
                    String userTypeStr = claims.get("userType", String.class);
                    String deviceId = claims.get("deviceId", String.class);
                    String platformStr = claims.get("platform", String.class);

                    UserType userType = UserType.valueOf(userTypeStr);
                    PlatformType platform = platformStr != null ? PlatformType.valueOf(platformStr) : null;

                    UserPrincipal principal = UserPrincipal.builder()
                            .userId(userId)
                            .jti(jti)
                            .userType(userType)
                            .deviceId(deviceId)
                            .platform(platform)
                            .build();

                    UsernamePasswordAuthenticationToken authentication =
                            new UsernamePasswordAuthenticationToken(principal, null, principal.getAuthorities());
                    authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

                    SecurityContextHolder.getContext().setAuthentication(authentication);
                }
            }
        } catch (Exception e) {
            log.error("[{}] Cannot set user authentication in security context: {}", traceId, e.getMessage());
        }

        try {
            filterChain.doFilter(request, response);
        } finally {
            MDC.remove(AppConstants.MDC_TRACE_ID);
        }
    }

    private String parseJwt(HttpServletRequest request) {
        String headerAuth = request.getHeader(AUTHORIZATION_HEADER);
        if (StringUtils.hasText(headerAuth) && headerAuth.startsWith(BEARER_PREFIX)) {
            return headerAuth.substring(BEARER_PREFIX.length()).trim();
        }
        return null;
    }
}
