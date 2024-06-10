package com.artsiomshshshsk.tictactoebackend.s3;

import org.springframework.web.multipart.MultipartFile;

public interface S3Service {
    String uploadFile(String key, MultipartFile file);
}
