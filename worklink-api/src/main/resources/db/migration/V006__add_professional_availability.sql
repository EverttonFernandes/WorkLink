ALTER TABLE worklink.professionals
    ADD COLUMN availability_status VARCHAR(40) NOT NULL DEFAULT 'ACCEPTING_NEW_CLIENTS';

ALTER TABLE worklink.professionals
    ADD CONSTRAINT professionals_availability_status_check
        CHECK (
            availability_status IN (
                'AVAILABLE_TODAY',
                'AVAILABLE_THIS_WEEK',
                'ACCEPTING_NEW_CLIENTS',
                'EMERGENCY_SERVICE',
                'TEMPORARILY_UNAVAILABLE'
            )
        );

CREATE INDEX professionals_availability_status_index
    ON worklink.professionals (availability_status);
