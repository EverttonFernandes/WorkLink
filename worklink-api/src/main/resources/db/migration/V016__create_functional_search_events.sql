CREATE TABLE worklink.professional_search_events (
    professional_search_event_identifier UUID PRIMARY KEY,
    category_identifier UUID REFERENCES worklink.service_categories(category_identifier),
    keyword VARCHAR(120),
    result_count INTEGER NOT NULL CHECK (result_count >= 0),
    created_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE worklink.professional_search_event_cities (
    professional_search_event_identifier UUID NOT NULL
        REFERENCES worklink.professional_search_events(professional_search_event_identifier) ON DELETE CASCADE,
    city_identifier UUID NOT NULL REFERENCES worklink.service_cities(city_identifier),
    PRIMARY KEY (professional_search_event_identifier, city_identifier)
);

CREATE INDEX professional_search_events_created_index
    ON worklink.professional_search_events (created_at DESC);

CREATE INDEX professional_search_event_cities_city_index
    ON worklink.professional_search_event_cities (city_identifier);
