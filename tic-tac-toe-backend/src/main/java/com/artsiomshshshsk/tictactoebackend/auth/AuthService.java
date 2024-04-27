package com.artsiomshshshsk.tictactoebackend.auth;

public interface AuthService {

    void signUp(String username, String password, String email);

    SignInResponse login(String username, String password);

    void confirmSignUp(String username, String code);
}
