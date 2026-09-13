package com.bmf.mobile.infra.i18n;

import com.bmf.mobile.app.service.I18nService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.MessageSource;
import org.springframework.context.NoSuchMessageException;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.stereotype.Service;

import java.util.Locale;

/**
 * Hiện thực I18nService sử dụng Spring MessageSource và LocaleContextHolder.
 */
@Slf4j
@Service
@RequiredArgsConstructor
@SuppressWarnings("null")
public class I18nServiceImpl implements I18nService {

    private final MessageSource messageSource;

    @Override
    public String getMessage(String code, Object... args) {
        Locale currentLocale = LocaleContextHolder.getLocale();
        return getMessage(code, currentLocale, args);
    }

    @Override
    public String getMessage(String code, Locale locale, Object... args) {
        try {
            return messageSource.getMessage(code, args, locale);
        } catch (NoSuchMessageException e) {
            log.warn("Missing i18n translation key: code={}, locale={}", code, locale);
            return code;
        }
    }
}
