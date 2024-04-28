package com.artsiomshshshsk.tictactoebackend.auth;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;

public interface AuthAcknowledged {

    default String getUserName() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        var jwt = ((Jwt) authentication.getPrincipal());
        return jwt.getClaims().get("username").toString();
    }
}
