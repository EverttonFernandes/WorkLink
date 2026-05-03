package br.com.worklink.architecture;

import com.tngtech.archunit.core.domain.JavaClasses;
import com.tngtech.archunit.core.importer.ClassFileImporter;
import com.tngtech.archunit.core.importer.ImportOption;
import com.tngtech.archunit.lang.ArchRule;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses;
import static com.tngtech.archunit.library.Architectures.layeredArchitecture;

class ModularHexagonalArchitectureTest {

    private static final String WORKLINK_BASE_PACKAGE = "br.com.worklink";

    private final JavaClasses productionClasses = new ClassFileImporter()
            .withImportOption(ImportOption.Predefined.DO_NOT_INCLUDE_TESTS)
            .importPackages(WORKLINK_BASE_PACKAGE);

    @Test
    @DisplayName("Deve proteger o dominio contra dependencias de framework e infraestrutura")
    void shouldProtectDomainFromFrameworkAndInfrastructureDependencies() {
        // GIVEN
        ArchRule domainMustNotDependOnFrameworkOrInfrastructure = noClasses()
                .that()
                .resideInAPackage("..domain..")
                .should()
                .dependOnClassesThat()
                .resideInAnyPackage(
                        "..api..",
                        "..infrastructure..",
                        "org.springframework..",
                        "jakarta.persistence..",
                        "redis.clients..",
                        "software.amazon.awssdk..",
                        "org.hibernate.."
                )
                .allowEmptyShould(true);

        // WHEN
        // As classes de producao sao analisadas pelo ArchUnit.

        // THEN
        domainMustNotDependOnFrameworkOrInfrastructure.check(productionClasses);
    }

    @Test
    @DisplayName("Deve proteger a aplicacao contra adaptadores concretos")
    void shouldProtectApplicationFromConcreteAdapters() {
        // GIVEN
        ArchRule applicationMustNotDependOnApiOrInfrastructure = noClasses()
                .that()
                .resideInAPackage("..application..")
                .should()
                .dependOnClassesThat()
                .resideInAnyPackage("..api..", "..infrastructure..")
                .allowEmptyShould(true);

        // WHEN
        // As classes de producao sao analisadas pelo ArchUnit.

        // THEN
        applicationMustNotDependOnApiOrInfrastructure.check(productionClasses);
    }

    @Test
    @DisplayName("Deve impedir que a API acesse infraestrutura diretamente")
    void shouldPreventApiFromAccessingInfrastructureDirectly() {
        // GIVEN
        ArchRule apiMustNotDependOnInfrastructure = noClasses()
                .that()
                .resideInAPackage("..api..")
                .should()
                .dependOnClassesThat()
                .resideInAPackage("..infrastructure..")
                .allowEmptyShould(true);

        // WHEN
        // As classes de producao sao analisadas pelo ArchUnit.

        // THEN
        apiMustNotDependOnInfrastructure.check(productionClasses);
    }

    @Test
    @DisplayName("Deve manter o fluxo de dependencias entre camadas da arquitetura hexagonal")
    void shouldKeepDependencyFlowBetweenHexagonalArchitectureLayers() {
        // GIVEN
        ArchRule layerDependenciesMustFollowPortsAndAdapters = layeredArchitecture()
                .consideringAllDependencies()
                .withOptionalLayers(true)
                .layer("API").definedBy("..api..")
                .layer("Application").definedBy("..application..")
                .layer("Domain").definedBy("..domain..")
                .layer("Infrastructure").definedBy("..infrastructure..")
                .whereLayer("API").mayNotBeAccessedByAnyLayer()
                .whereLayer("Application").mayOnlyBeAccessedByLayers("API", "Infrastructure")
                .whereLayer("Domain").mayOnlyBeAccessedByLayers("Application", "Infrastructure")
                .whereLayer("Infrastructure").mayNotBeAccessedByAnyLayer();

        // WHEN
        // As classes de producao sao analisadas pelo ArchUnit.

        // THEN
        layerDependenciesMustFollowPortsAndAdapters.check(productionClasses);
    }
}
