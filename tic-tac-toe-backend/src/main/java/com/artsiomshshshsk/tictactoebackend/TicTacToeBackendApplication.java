package com.artsiomshshshsk.tictactoebackend;

import com.artsiomshshshsk.tictactoebackend.user.GameUser;
import com.artsiomshshshsk.tictactoebackend.user.GameUserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
@RequiredArgsConstructor
public class TicTacToeBackendApplication {

    private final GameUserRepository gameUserRepository;

    public static void main(String[] args) {
        SpringApplication.run(TicTacToeBackendApplication.class, args);
    }

    @Bean
    CommandLineRunner runner(@Value("${PROFILE_IMG_URL_1}") String profileImgUrl1,
                             @Value("${PROFILE_IMG_URL_2}") String profileImgUrl2) {
        return args -> {
            gameUserRepository.save(new GameUser("user1", profileImgUrl1));
            gameUserRepository.save(new GameUser("user2", profileImgUrl2));
        };
    }
}
