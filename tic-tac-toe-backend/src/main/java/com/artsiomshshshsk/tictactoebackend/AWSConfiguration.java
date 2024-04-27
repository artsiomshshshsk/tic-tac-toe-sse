package com.artsiomshshshsk.tictactoebackend;

import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicSessionCredentials;
import com.amazonaws.services.cognitoidp.AWSCognitoIdentityProvider;
import com.amazonaws.services.cognitoidp.AWSCognitoIdentityProviderClientBuilder;
import com.artsiomshshshsk.tictactoebackend.auth.CognitoClientConfig;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AWSConfiguration {

    @Bean
    public AWSCognitoIdentityProvider cognitoIdentityProvider(AWSCredentials credentials,
                                                              @Value("${AWS_REGION}") String region) {

        return AWSCognitoIdentityProviderClientBuilder.standard()
                .withCredentials(new AWSStaticCredentialsProvider(credentials))
                .withRegion(region)
                .build();
    }


    @Bean
    CognitoClientConfig cognitoClientConfig(@Value("${AWS_COGNITO_CLIENT_ID}") String clientId,
                                            @Value("${AWS_COGNITO_USER_POOL_ID}") String userPoolId) {
        return new CognitoClientConfig(clientId, userPoolId);
    }

    @Bean
    AWSCredentials credentials(@Value("${AWS_ACCESS_KEY_ID}") String accessKeyId,
                               @Value("${AWS_SECRET_ACCESS_KEY}") String secretAccessKey,
                               @Value("${AWS_SESSION_TOKEN}") String sessionToken) {
        return new BasicSessionCredentials(accessKeyId, secretAccessKey, sessionToken);
    }
}
