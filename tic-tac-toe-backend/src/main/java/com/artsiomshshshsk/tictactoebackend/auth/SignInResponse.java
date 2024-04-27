package com.artsiomshshshsk.tictactoebackend.auth;

public record SignInResponse(
        String accessToken,
        String refreshToken
) { }
