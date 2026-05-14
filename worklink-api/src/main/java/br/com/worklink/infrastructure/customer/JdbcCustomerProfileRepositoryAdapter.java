package br.com.worklink.infrastructure.customer;

import br.com.worklink.application.customer.port.CustomerProfilePreferencesProjection;
import br.com.worklink.application.customer.port.ListCustomerSavedProfessionalIdentifiersPort;
import br.com.worklink.application.customer.port.LoadCustomerProfilePreferencesPort;
import br.com.worklink.application.customer.port.RemoveCustomerSavedProfessionalPort;
import br.com.worklink.application.customer.port.SaveCustomerProfilePreferencesPort;
import br.com.worklink.application.customer.port.SaveCustomerSavedProfessionalPort;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public class JdbcCustomerProfileRepositoryAdapter implements
        LoadCustomerProfilePreferencesPort,
        SaveCustomerProfilePreferencesPort,
        ListCustomerSavedProfessionalIdentifiersPort,
        SaveCustomerSavedProfessionalPort,
        RemoveCustomerSavedProfessionalPort {

    private final JdbcTemplate jdbcTemplate;

    public JdbcCustomerProfileRepositoryAdapter(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public Optional<CustomerProfilePreferencesProjection> loadCustomerProfilePreferences(UUID customerIdentifier) {
        return jdbcTemplate.query(
                """
                SELECT customer_identifier,
                       whatsapp_notifications_enabled,
                       profile_personalization_enabled
                FROM worklink.customer_profile_preferences
                WHERE customer_identifier = ?
                """,
                (resultSet, rowNumber) -> new CustomerProfilePreferencesProjection(
                        resultSet.getObject("customer_identifier", UUID.class),
                        resultSet.getBoolean("whatsapp_notifications_enabled"),
                        resultSet.getBoolean("profile_personalization_enabled")
                ),
                customerIdentifier
        ).stream().findFirst();
    }

    @Override
    public CustomerProfilePreferencesProjection saveCustomerProfilePreferences(
            CustomerProfilePreferencesProjection customerProfilePreferencesProjection
    ) {
        jdbcTemplate.update(
                """
                INSERT INTO worklink.customer_profile_preferences (
                    customer_identifier,
                    whatsapp_notifications_enabled,
                    profile_personalization_enabled
                ) VALUES (?, ?, ?)
                ON CONFLICT (customer_identifier) DO UPDATE
                   SET whatsapp_notifications_enabled = EXCLUDED.whatsapp_notifications_enabled,
                       profile_personalization_enabled = EXCLUDED.profile_personalization_enabled,
                       updated_at = CURRENT_TIMESTAMP
                """,
                customerProfilePreferencesProjection.customerIdentifier(),
                customerProfilePreferencesProjection.whatsappNotificationsEnabled(),
                customerProfilePreferencesProjection.profilePersonalizationEnabled()
        );
        return customerProfilePreferencesProjection;
    }

    @Override
    public List<UUID> listCustomerSavedProfessionalIdentifiers(UUID customerIdentifier) {
        return jdbcTemplate.query(
                """
                SELECT professional_identifier
                FROM worklink.customer_saved_professionals
                WHERE customer_identifier = ?
                ORDER BY created_at DESC
                """,
                (resultSet, rowNumber) -> resultSet.getObject("professional_identifier", UUID.class),
                customerIdentifier
        );
    }

    @Override
    public void saveCustomerSavedProfessional(UUID customerIdentifier, UUID professionalIdentifier) {
        jdbcTemplate.update(
                """
                INSERT INTO worklink.customer_saved_professionals (
                    customer_identifier,
                    professional_identifier
                ) VALUES (?, ?)
                ON CONFLICT (customer_identifier, professional_identifier) DO NOTHING
                """,
                customerIdentifier,
                professionalIdentifier
        );
    }

    @Override
    public void removeCustomerSavedProfessional(UUID customerIdentifier, UUID professionalIdentifier) {
        jdbcTemplate.update(
                """
                DELETE FROM worklink.customer_saved_professionals
                WHERE customer_identifier = ?
                  AND professional_identifier = ?
                """,
                customerIdentifier,
                professionalIdentifier
        );
    }
}
