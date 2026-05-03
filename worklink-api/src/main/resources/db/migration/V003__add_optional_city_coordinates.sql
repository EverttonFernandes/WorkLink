ALTER TABLE worklink.service_cities
    ADD COLUMN latitude DOUBLE PRECISION,
    ADD COLUMN longitude DOUBLE PRECISION;

ALTER TABLE worklink.service_cities
    ADD CONSTRAINT service_cities_latitude_range_check
        CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),
    ADD CONSTRAINT service_cities_longitude_range_check
        CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180);
