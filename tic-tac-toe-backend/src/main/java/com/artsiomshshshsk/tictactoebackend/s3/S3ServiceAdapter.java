package com.artsiomshshshsk.tictactoebackend.s3;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.services.s3.model.StorageClass;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

public record S3ServiceAdapter(AmazonS3 s3Client, String bucketName) implements S3Service{

    @Override
    public String uploadFile(String key, MultipartFile file) {
        try {
            var originalFilename = file.getOriginalFilename();
            if (originalFilename != null && !originalFilename.isEmpty()) {
                key = key + "." + getFileExtension(originalFilename);
            }

            var putObjectRequest = new PutObjectRequest(bucketName, key, file.getInputStream(), null)
                    .withStorageClass(StorageClass.Standard);

            s3Client.putObject(putObjectRequest);
            return s3Client.getUrl(bucketName, key).toString();
        } catch (IOException e) {
            throw new RuntimeException("Failed to upload file", e);
        }
    }

    private String getFileExtension(String filename) {
        var dotIndex = filename.lastIndexOf('.');
        return (dotIndex == -1) ? "" : filename.substring(dotIndex + 1);
    }
}
