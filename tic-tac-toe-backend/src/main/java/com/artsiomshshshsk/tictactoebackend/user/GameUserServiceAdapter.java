package com.artsiomshshshsk.tictactoebackend.user;

import org.springframework.stereotype.Service;

@Service
public record GameUserServiceAdapter(GameUserRepository repository) implements GameUserService{
    @Override
    public void saveGameUser(GameUser gameUser) {
        repository.save(gameUser);
    }

    @Override
    public GameUser findByUsername(String username) {
        return repository.findById(username).orElse(null);
    }
}
