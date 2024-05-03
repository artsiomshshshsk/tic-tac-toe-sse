package com.artsiomshshshsk.tictactoebackend;

import com.amazonaws.auth.*;
import com.amazonaws.services.cognitoidp.AWSCognitoIdentityProvider;
import com.amazonaws.services.cognitoidp.AWSCognitoIdentityProviderClientBuilder;
import com.artsiomshshshsk.tictactoebackend.auth.CognitoClientConfig;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AWSConfiguration {

    @Bean
    public AWSCredentialsProvider amazonAWSCredentialsProvider() {
        return DefaultAWSCredentialsProviderChain.getInstance();
    }

    @Bean
    public AWSCognitoIdentityProvider cognitoIdentityProvider(AWSCredentialsProvider credentialsProvider,
                                                              CognitoClientConfig config) {

        return AWSCognitoIdentityProviderClientBuilder.standard()
                .withCredentials(credentialsProvider)
                .withRegion(config.region())
                .build();
    }

    @Bean
    CognitoClientConfig cognitoClientConfig(@Value("${AWS_COGNITO_CLIENT_ID}") String clientId,
                                            @Value("${AWS_COGNITO_USER_POOL_ID}") String userPoolId,
                                            @Value("${AWS_REGION}") String region){
        return new CognitoClientConfig(clientId, userPoolId, region);
    }
}
