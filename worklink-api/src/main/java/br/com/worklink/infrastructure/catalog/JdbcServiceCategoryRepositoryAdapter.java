package br.com.worklink.infrastructure.catalog;

import br.com.worklink.application.catalog.port.ListServiceCategoriesPort;
import br.com.worklink.application.catalog.port.LoadServiceCategoryByIdentifierPort;
import br.com.worklink.application.catalog.port.SaveServiceCategoryPort;
import br.com.worklink.domain.catalog.ServiceCategory;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public class JdbcServiceCategoryRepositoryAdapter
        implements SaveServiceCategoryPort, ListServiceCategoriesPort, LoadServiceCategoryByIdentifierPort {

    private final JdbcTemplate jdbcTemplate;

    public JdbcServiceCategoryRepositoryAdapter(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public ServiceCategory saveServiceCategory(ServiceCategory serviceCategory) {
        jdbcTemplate.update(
                """
                INSERT INTO worklink.service_categories (category_identifier, category_name, category_slug)
                VALUES (?, ?, ?)
                """,
                serviceCategory.categoryIdentifier(),
                serviceCategory.categoryName(),
                serviceCategory.categorySlug()
        );
        return serviceCategory;
    }

    @Override
    public List<ServiceCategory> listServiceCategories() {
        return jdbcTemplate.query(
                """
                SELECT category_identifier, category_name, category_slug
                FROM worklink.service_categories
                ORDER BY category_name ASC
                """,
                (resultSet, rowNumber) -> ServiceCategory.restoreServiceCategory(
                        resultSet.getObject("category_identifier", UUID.class),
                        resultSet.getString("category_name"),
                        resultSet.getString("category_slug")
                )
        );
    }

    @Override
    public Optional<ServiceCategory> loadServiceCategoryByIdentifier(UUID categoryIdentifier) {
        List<ServiceCategory> serviceCategories = jdbcTemplate.query(
                """
                SELECT category_identifier, category_name, category_slug
                FROM worklink.service_categories
                WHERE category_identifier = ?
                """,
                (resultSet, rowNumber) -> ServiceCategory.restoreServiceCategory(
                        resultSet.getObject("category_identifier", UUID.class),
                        resultSet.getString("category_name"),
                        resultSet.getString("category_slug")
                ),
                categoryIdentifier
        );
        return serviceCategories.stream().findFirst();
    }
}
