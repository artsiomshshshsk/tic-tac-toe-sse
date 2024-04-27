package com.artsiomshshshsk.tictactoebackend.auth;

import com.amazonaws.services.cognitoidp.AWSCognitoIdentityProvider;
import com.amazonaws.services.cognitoidp.model.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
@Slf4j
public record AwsCognitoAuthService(
        AWSCognitoIdentityProvider client,
        CognitoClientConfig config) implements AuthService {

    @Override
    public void signUp(String username, String password, String email) {
        log.info("Signing up user with username: {}", username);
        SignUpRequest signUpRequest = new SignUpRequest()
                .withClientId(config.clientId())
                .withUsername(username)
                .withPassword(password)
                .withUserAttributes(
                        new AttributeType().withName("email").withValue(email)
                );
        var resp = client.signUp(signUpRequest);
        log.info("User signed up: {}", resp);
    }

    @Override
    public SignInResponse login(String username, String password) {
        log.info("Logging in user with username: {}", username);
        AdminInitiateAuthRequest authRequest = new AdminInitiateAuthRequest()
                .withAuthFlow(AuthFlowType.ADMIN_NO_SRP_AUTH)
                .withUserPoolId(config.userPoolId())
                .withClientId(config.clientId())
                .withAuthParameters(Map.of(
                        "USERNAME", username,
                        "PASSWORD", password
                ));
        AdminInitiateAuthResult authResponse = client.adminInitiateAuth(authRequest);
        AuthenticationResultType authResult = authResponse.getAuthenticationResult();

        log.info("User logged in: {}", authResult);

        return new SignInResponse(authResult.getAccessToken(), authResult.getRefreshToken());
    }

    @Override
    public void confirmSignUp(String username, String code) {
        log.info("Confirming sign up for user: {}", username);
        ConfirmSignUpRequest confirmSignUpRequest = new ConfirmSignUpRequest()
                .withUsername(username)
                .withConfirmationCode(code)
                .withClientId(config.clientId());
        client.confirmSignUp(confirmSignUpRequest);
        log.info("User confirmed sign up");
    }
}