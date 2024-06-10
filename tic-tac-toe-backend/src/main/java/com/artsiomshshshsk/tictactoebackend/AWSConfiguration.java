package com.artsiomshshshsk.tictactoebackend;

import com.amazonaws.auth.*;
import com.amazonaws.services.cognitoidp.AWSCognitoIdentityProvider;
import com.amazonaws.services.cognitoidp.AWSCognitoIdentityProviderClientBuilder;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.artsiomshshshsk.tictactoebackend.auth.CognitoClientConfig;
import com.artsiomshshshsk.tictactoebackend.s3.S3Service;
import com.artsiomshshshsk.tictactoebackend.s3.S3ServiceAdapter;
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

    @Bean
    AmazonS3 amazonS3Client(AWSCredentialsProvider credentialsProvider,
                            @Value("${AWS_REGION}") String region) {
        return AmazonS3ClientBuilder
                .standard()
                .withCredentials(credentialsProvider)
                .withRegion(region).build();
    }

    @Bean
    S3Service s3Service(AmazonS3 s3Client) {
        var bucketName = "tic-tac-toe-bucket-34cb38ee-927a-4f5f-a5e0-bd5bfabe6fd6";
        return new S3ServiceAdapter(s3Client, bucketName);
    }

}
