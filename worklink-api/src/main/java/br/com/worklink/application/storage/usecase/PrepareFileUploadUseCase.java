package br.com.worklink.application.storage.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.storage.port.SaveStoredFileMetadataPort;
import br.com.worklink.domain.BusinessRuleViolationException;
import br.com.worklink.domain.storage.StoredFile;
import br.com.worklink.domain.storage.StoredFilePurpose;

public class PrepareFileUploadUseCase {

    private final SaveStoredFileMetadataPort saveStoredFileMetadataPort;

    public PrepareFileUploadUseCase(SaveStoredFileMetadataPort saveStoredFileMetadataPort) {
        this.saveStoredFileMetadataPort = saveStoredFileMetadataPort;
    }

    public PreparedFileUploadResponse prepareFileUpload(PrepareFileUploadRequest request) {
        try {
            StoredFile storedFile = StoredFile.prepareStoredFile(
                    parseFilePurpose(request.filePurpose()),
                    request.originalFilename(),
                    request.contentType(),
                    request.sizeInBytes()
            );
            return PreparedFileUploadResponse.fromStoredFile(
                    saveStoredFileMetadataPort.saveStoredFileMetadata(storedFile)
            );
        } catch (BusinessRuleViolationException exception) {
            throw new ApplicationRuleViolationException(exception.getMessage(), exception);
        }
    }

    private StoredFilePurpose parseFilePurpose(String filePurpose) {
        try {
            return StoredFilePurpose.valueOf(filePurpose);
        } catch (IllegalArgumentException | NullPointerException exception) {
            throw new ApplicationRuleViolationException("O proposito do arquivo e invalido.", exception);
        }
    }
}
