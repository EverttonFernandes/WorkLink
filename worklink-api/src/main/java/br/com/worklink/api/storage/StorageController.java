package br.com.worklink.api.storage;

import br.com.worklink.application.storage.usecase.PrepareFileUploadRequest;
import br.com.worklink.application.storage.usecase.PrepareFileUploadUseCase;
import br.com.worklink.application.storage.usecase.PreparedFileUploadResponse;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/storage/uploads")
public class StorageController {

    private final PrepareFileUploadUseCase prepareFileUploadUseCase;

    public StorageController(PrepareFileUploadUseCase prepareFileUploadUseCase) {
        this.prepareFileUploadUseCase = prepareFileUploadUseCase;
    }

    @PostMapping("/prepare")
    @ResponseStatus(HttpStatus.CREATED)
    PreparedFileUploadHttpResponse prepareFileUpload(@RequestBody PrepareFileUploadHttpRequest request) {
        PreparedFileUploadResponse response = prepareFileUploadUseCase.prepareFileUpload(new PrepareFileUploadRequest(
                request.filePurpose(),
                request.originalFilename(),
                request.contentType(),
                request.sizeInBytes()
        ));
        return PreparedFileUploadHttpResponse.fromPreparedFileUploadResponse(response);
    }
}
