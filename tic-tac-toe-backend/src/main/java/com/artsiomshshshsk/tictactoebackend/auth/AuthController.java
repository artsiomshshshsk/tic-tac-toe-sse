package com.artsiomshshshsk.tictactoebackend.auth;


import com.artsiomshshshsk.tictactoebackend.s3.S3Service;
import com.artsiomshshshsk.tictactoebackend.user.GameUser;
import com.artsiomshshshsk.tictactoebackend.user.GameUserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@Slf4j
@RequestMapping("/auth")
public record AuthController(AuthService authService, S3Service s3Service, GameUserService gameUserService) {

    @PostMapping("/sign-up")
    public void signUp(@RequestPart("username") String username,
                       @RequestPart("password") String password,
                       @RequestPart("email") String email,
                       @RequestPart("avatar") MultipartFile avatar) {
        authService.signUp(username, password, email);
        String avatarUrl = s3Service.uploadFile(username + "-avatar", avatar);
        gameUserService.saveGameUser(new GameUser(username, avatarUrl));
        log.info("Uploaded avatar to: {}", avatarUrl);
    }

    @PostMapping("/sign-in")
    public SignInResponse signIn(@RequestBody SignInRequest request) {
        return authService.login(request.username, request.password);
    }

    @PostMapping("/confirm-sign-up")
    public void confirmSignUp(@RequestBody ConfirmSignUpRequest request) {
        authService.confirmSignUp(request.username, request.confirmationCode);
    }

    @PostMapping("/refresh-token")
    public SignInResponse refreshToken(@RequestBody RefreshTokenRequest request) {
        return authService.refreshToken(request.refreshToken);
    }

    @GetMapping("/user-info")
    public GameUser getUserInfo(@RequestParam String username) {
        var gameUser = gameUserService.findByUsername(username);
        return new GameUser(gameUser.getUsername(), gameUser.getAvatarUrl());
    }

    @PostMapping("/sign-out")
    public void signOut(@RequestBody SignOutRequest request) {
        authService.signOut(request.accessToken);
    }

    public record SignOutRequest(String accessToken) { }

    public record RefreshTokenRequest(String refreshToken) { }

    public record SignInRequest(String username, String password) { }

    public record ConfirmSignUpRequest(String username, String confirmationCode) { }
}
