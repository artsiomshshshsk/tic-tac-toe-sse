package com.artsiomshshshsk.tictactoebackend.auth;


import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
public record AuthController(AuthService authService) {

    @PostMapping("/sign-up")
    public void signUp(@RequestBody SignUpRequest request) {
        authService.signUp(request.username, request.password, request.email);
    }

    @PostMapping("/sign-in")
    public SignInResponse signIn(@RequestBody SignInRequest request) {
        return authService.login(request.username, request.password);
    }

    @PostMapping("/confirm-sign-up")
    public void confirmSignUp(@RequestBody ConfirmSignUpRequest request) {
        authService.confirmSignUp(request.username, request.confirmationCode);
    }

    @PostMapping("refresh-token")
    public SignInResponse refreshToken(@RequestBody RefreshTokenRequest request) {
        return authService.refreshToken(request.refreshToken);
    }

    @PostMapping("/sign-out")
    public void signOut(@RequestBody SignOutRequest request) {
        authService.signOut(request.accessToken);
    }

    public record SignOutRequest(String accessToken) { }

    public record RefreshTokenRequest(String refreshToken) { }

    public record SignUpRequest(String username, String password, String email) { }

    public record SignInRequest(String username, String password) { }

    public record ConfirmSignUpRequest(String username, String confirmationCode) { }
}
