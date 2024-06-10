package com.artsiomshshshsk.tictactoebackend.user;

import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface GameUserRepository extends CrudRepository<GameUser, String> { }
