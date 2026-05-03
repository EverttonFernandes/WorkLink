package br.com.worklink.infrastructure.catalog;

import br.com.worklink.domain.catalog.ServiceCategory;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;

import java.sql.ResultSet;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class JdbcServiceCategoryRepositoryAdapterTest {

    @Test
    @DisplayName("Deve persistir categoria de servico usando JdbcTemplate")
    void shouldPersistServiceCategoryUsingJdbcTemplate() {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcServiceCategoryRepositoryAdapter adapter = new JdbcServiceCategoryRepositoryAdapter(jdbcTemplate);
        ServiceCategory serviceCategory = ServiceCategory.createServiceCategory("Eletricista");

        // WHEN
        ServiceCategory savedServiceCategory = adapter.saveServiceCategory(serviceCategory);

        // THEN
        assertThat(savedServiceCategory).isEqualTo(serviceCategory);
        verify(jdbcTemplate).update(
                any(String.class),
                eq(serviceCategory.categoryIdentifier()),
                eq(serviceCategory.categoryName()),
                eq(serviceCategory.categorySlug())
        );
    }

    @Test
    @DisplayName("Deve listar categorias de servico usando JdbcTemplate")
    void shouldListServiceCategoriesUsingJdbcTemplate() throws Exception {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcServiceCategoryRepositoryAdapter adapter = new JdbcServiceCategoryRepositoryAdapter(jdbcTemplate);
        ServiceCategory serviceCategory = ServiceCategory.createServiceCategory("Pintor");
        ResultSet resultSet = categoryResultSet(serviceCategory);
        when(jdbcTemplate.query(any(String.class), any(RowMapper.class))).thenAnswer(invocation -> {
            RowMapper<ServiceCategory> rowMapper = invocation.getArgument(1);
            return List.of(rowMapper.mapRow(resultSet, 0));
        });

        // WHEN
        List<ServiceCategory> serviceCategories = adapter.listServiceCategories();

        // THEN
        assertThat(serviceCategories).containsExactly(serviceCategory);
    }

    @Test
    @DisplayName("Deve carregar categoria de servico por identificador usando JdbcTemplate")
    void shouldLoadServiceCategoryByIdentifierUsingJdbcTemplate() throws Exception {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcServiceCategoryRepositoryAdapter adapter = new JdbcServiceCategoryRepositoryAdapter(jdbcTemplate);
        ServiceCategory serviceCategory = ServiceCategory.createServiceCategory("Pedreiro");
        ResultSet resultSet = categoryResultSet(serviceCategory);
        when(jdbcTemplate.query(any(String.class), any(RowMapper.class), any(UUID.class))).thenAnswer(invocation -> {
            RowMapper<ServiceCategory> rowMapper = invocation.getArgument(1);
            return List.of(rowMapper.mapRow(resultSet, 0));
        });

        // WHEN
        Optional<ServiceCategory> loadedServiceCategory = adapter.loadServiceCategoryByIdentifier(serviceCategory.categoryIdentifier());

        // THEN
        assertThat(loadedServiceCategory).contains(serviceCategory);
    }

    private ResultSet categoryResultSet(ServiceCategory serviceCategory) throws Exception {
        ResultSet resultSet = mock(ResultSet.class);
        when(resultSet.getObject("category_identifier", UUID.class)).thenReturn(serviceCategory.categoryIdentifier());
        when(resultSet.getString("category_name")).thenReturn(serviceCategory.categoryName());
        when(resultSet.getString("category_slug")).thenReturn(serviceCategory.categorySlug());
        return resultSet;
    }
}
