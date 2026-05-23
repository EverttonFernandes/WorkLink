// coverage:ignore-file
import 'package:flutter/material.dart';

import 'administrative_console_controller.dart';
import 'administrative_console_state.dart';

class AdministrativeConsoleScreen extends StatefulWidget {
  const AdministrativeConsoleScreen({
    super.key,
    required this.administrativeConsoleController,
  });

  final AdministrativeConsoleController administrativeConsoleController;

  @override
  State<AdministrativeConsoleScreen> createState() =>
      _AdministrativeConsoleScreenState();
}

class _AdministrativeConsoleScreenState
    extends State<AdministrativeConsoleScreen> {
  final TextEditingController categoryNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.administrativeConsoleController.addListener(refreshScreen);
    widget.administrativeConsoleController.loadAdministrativeConsoleAsync();
  }

  @override
  void dispose() {
    widget.administrativeConsoleController.removeListener(refreshScreen);
    categoryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final administrativeConsoleState =
        widget.administrativeConsoleController.state;
    return Scaffold(
      appBar: AppBar(title: const Text('Console administrativo')),
      body: administrativeConsoleState.loading &&
              !administrativeConsoleState.hasContent
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              key: const ValueKey('administrative-console-content'),
              padding: const EdgeInsets.all(16),
              children: [
                if (administrativeConsoleState.errorMessage != null) ...[
                  _AdministrativeFeedbackBanner(
                    message: administrativeConsoleState.errorMessage!,
                    backgroundColor:
                        Theme.of(context).colorScheme.errorContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(height: 16),
                ],
                if (administrativeConsoleState.statusMessage != null) ...[
                  _AdministrativeFeedbackBanner(
                    message: administrativeConsoleState.statusMessage!,
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(height: 16),
                ],
                _AdministrativeSummarySection(
                  administrativeMetrics:
                      administrativeConsoleState.administrativeMetrics,
                  functionalMetrics:
                      administrativeConsoleState.functionalMetrics,
                ),
                const SizedBox(height: 16),
                _AdministrativeCategorySection(
                  categoryNames: administrativeConsoleState.categoryNames,
                  categoryNameController: categoryNameController,
                  onRegisterCategory: () async {
                    final categoryName = categoryNameController.text.trim();
                    if (categoryName.isEmpty) {
                      return;
                    }
                    await widget.administrativeConsoleController
                        .registerCategoryAsync(categoryName);
                    if (mounted &&
                        widget.administrativeConsoleController.state
                                .errorMessage ==
                            null) {
                      categoryNameController.clear();
                    }
                  },
                ),
                const SizedBox(height: 16),
                _AdministrativeProfessionalsSection(
                  professionals: administrativeConsoleState.professionals,
                  onBlockProfessional: widget
                      .administrativeConsoleController.blockProfessionalAsync,
                  onUnblockProfessional: widget
                      .administrativeConsoleController.unblockProfessionalAsync,
                ),
                const SizedBox(height: 16),
                _AdministrativeReportsSection(
                  reports: administrativeConsoleState.professionalReports,
                  onApproveReport: widget.administrativeConsoleController
                      .approveProfessionalReportAsync,
                  onEscalateReport: widget.administrativeConsoleController
                      .escalateProfessionalReportAsync,
                ),
                const SizedBox(height: 16),
                _AdministrativeReviewAnalysisSection(
                  reviewAnalysisRequests:
                      administrativeConsoleState.reviewAnalysisRequests,
                  onKeepReviewPublic: widget
                      .administrativeConsoleController.keepReviewPublicAsync,
                  onHideReviewFromPublic: widget.administrativeConsoleController
                      .hideReviewFromPublicAsync,
                ),
                const SizedBox(height: 16),
                _AdministrativeFunctionalSignalsSection(
                  functionalMetrics:
                      administrativeConsoleState.functionalMetrics,
                ),
              ],
            ),
    );
  }

  void refreshScreen() {
    setState(() {});
  }
}

class _AdministrativeFeedbackBanner extends StatelessWidget {
  const _AdministrativeFeedbackBanner({
    required this.message,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String message;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: foregroundColor),
      ),
    );
  }
}

class _AdministrativeSummarySection extends StatelessWidget {
  const _AdministrativeSummarySection({
    required this.administrativeMetrics,
    required this.functionalMetrics,
  });

  final AdministrativeMetricsSummary administrativeMetrics;
  final AdministrativeFunctionalMetricsSummary functionalMetrics;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumo operacional',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _SummaryCard(
              label: 'Profissionais',
              value: administrativeMetrics.professionalCount.toString(),
            ),
            _SummaryCard(
              label: 'Bloqueados',
              value: administrativeMetrics.blockedProfessionalCount.toString(),
            ),
            _SummaryCard(
              label: 'Denuncias',
              value: administrativeMetrics.professionalReportCount.toString(),
            ),
            _SummaryCard(
              label: 'Contestacoes',
              value:
                  administrativeMetrics.reviewAnalysisRequestCount.toString(),
            ),
            _SummaryCard(
              label: 'Categorias',
              value: administrativeMetrics.serviceCategoryCount.toString(),
            ),
            _SummaryCard(
              label: 'Buscas',
              value: functionalMetrics.searchCount.toString(),
            ),
            _SummaryCard(
              label: 'Contatos',
              value: functionalMetrics.contactCount.toString(),
            ),
            _SummaryCard(
              label: 'Nota media',
              value: functionalMetrics.averageRating.toStringAsFixed(1),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdministrativeCategorySection extends StatelessWidget {
  const _AdministrativeCategorySection({
    required this.categoryNames,
    required this.categoryNameController,
    required this.onRegisterCategory,
  });

  final List<String> categoryNames;
  final TextEditingController categoryNameController;
  final Future<void> Function() onRegisterCategory;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gestao minima de categorias',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          key: const ValueKey('administrative-category-name-field'),
          controller: categoryNameController,
          decoration: const InputDecoration(
            labelText: 'Nova categoria',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            key: const ValueKey('administrative-register-category-button'),
            onPressed: onRegisterCategory,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar'),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categoryNames
              .map((categoryName) => Chip(label: Text(categoryName)))
              .toList(),
        ),
      ],
    );
  }
}

class _AdministrativeProfessionalsSection extends StatelessWidget {
  const _AdministrativeProfessionalsSection({
    required this.professionals,
    required this.onBlockProfessional,
    required this.onUnblockProfessional,
  });

  final List<AdministrativeProfessionalItem> professionals;
  final Future<void> Function(String professionalIdentifier)
      onBlockProfessional;
  final Future<void> Function(String professionalIdentifier)
      onUnblockProfessional;

  @override
  Widget build(BuildContext context) {
    return _AdministrativeSectionCard(
      title: 'Profissionais',
      emptyMessage: 'Nenhum profissional administrativo encontrado.',
      children: professionals
          .map(
            (professional) => _AdministrativeActionItem(
              key: ValueKey(
                'administrative-professional-${professional.professionalIdentifier}',
              ),
              title: professional.professionalName,
              subtitle:
                  '${professional.categoryName} - ${professional.cityDisplayName}\n'
                  '${professional.profileClassification} - ${professional.availabilityLabel}',
              actions: [
                professional.blocked
                    ? OutlinedButton(
                        onPressed: () => onUnblockProfessional(
                          professional.professionalIdentifier,
                        ),
                        child: const Text('Desbloquear'),
                      )
                    : FilledButton(
                        onPressed: () => onBlockProfessional(
                          professional.professionalIdentifier,
                        ),
                        child: const Text('Bloquear'),
                      ),
              ],
            ),
          )
          .toList(),
    );
  }
}

class _AdministrativeReportsSection extends StatelessWidget {
  const _AdministrativeReportsSection({
    required this.reports,
    required this.onApproveReport,
    required this.onEscalateReport,
  });

  final List<AdministrativeProfessionalReportItem> reports;
  final Future<void> Function(String professionalReportIdentifier)
      onApproveReport;
  final Future<void> Function(String professionalReportIdentifier)
      onEscalateReport;

  @override
  Widget build(BuildContext context) {
    return _AdministrativeSectionCard(
      title: 'Denuncias',
      emptyMessage: 'Nenhuma denuncia pendente ou historica.',
      children: reports
          .map(
            (report) => _AdministrativeActionItem(
              key: ValueKey(
                'administrative-report-${report.professionalReportIdentifier}',
              ),
              title: '${report.professionalName} - ${report.reportReasonLabel}',
              subtitle:
                  '${report.moderationStatusLabel}'
                  '${report.moderationDecisionLabel == null ? '' : ' - ${report.moderationDecisionLabel}'}\n'
                  '${report.createdAtLabel}${report.seriousCase ? ' - Caso grave' : ''}',
              actions: [
                OutlinedButton(
                  onPressed: () =>
                      onApproveReport(report.professionalReportIdentifier),
                  child: const Text('Manter'),
                ),
                FilledButton(
                  onPressed: () =>
                      onEscalateReport(report.professionalReportIdentifier),
                  child: const Text('Exigir acao'),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}

class _AdministrativeReviewAnalysisSection extends StatelessWidget {
  const _AdministrativeReviewAnalysisSection({
    required this.reviewAnalysisRequests,
    required this.onKeepReviewPublic,
    required this.onHideReviewFromPublic,
  });

  final List<AdministrativeReviewAnalysisItem> reviewAnalysisRequests;
  final Future<void> Function(String reviewAnalysisRequestIdentifier)
      onKeepReviewPublic;
  final Future<void> Function(String reviewAnalysisRequestIdentifier)
      onHideReviewFromPublic;

  @override
  Widget build(BuildContext context) {
    return _AdministrativeSectionCard(
      title: 'Contestacoes de avaliacao',
      emptyMessage: 'Nenhuma contestacao registrada.',
      children: reviewAnalysisRequests
          .map(
            (request) => _AdministrativeActionItem(
              key: ValueKey(
                'administrative-review-analysis-${request.reviewAnalysisRequestIdentifier}',
              ),
              title: request.professionalName,
              subtitle:
                  '${request.moderationStatusLabel}'
                  '${request.moderationDecisionLabel == null ? '' : ' - ${request.moderationDecisionLabel}'}\n'
                  '${request.createdAtLabel}',
              actions: [
                OutlinedButton(
                  onPressed: () => onKeepReviewPublic(
                    request.reviewAnalysisRequestIdentifier,
                  ),
                  child: const Text('Manter'),
                ),
                FilledButton(
                  onPressed: () => onHideReviewFromPublic(
                    request.reviewAnalysisRequestIdentifier,
                  ),
                  child: const Text('Ocultar'),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}

class _AdministrativeActionItem extends StatelessWidget {
  const _AdministrativeActionItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actions,
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(subtitle),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: actions,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdministrativeFunctionalSignalsSection extends StatelessWidget {
  const _AdministrativeFunctionalSignalsSection({
    required this.functionalMetrics,
  });

  final AdministrativeFunctionalMetricsSummary functionalMetrics;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metricas funcionais',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        _AdministrativeSignalsCard(
          title: 'Top categorias buscadas',
          metrics: functionalMetrics.topSearchCategories,
        ),
        const SizedBox(height: 12),
        _AdministrativeSignalsCard(
          title: 'Top cidades buscadas',
          metrics: functionalMetrics.topSearchCities,
        ),
        const SizedBox(height: 12),
        _AdministrativeSignalsCard(
          title: 'Profissionais com mais contatos',
          metrics: functionalMetrics.topContactProfessionals,
        ),
        const SizedBox(height: 12),
        _AdministrativeSignalsCard(
          title: 'Sinais de responsividade',
          metrics: functionalMetrics.responsivenessSignals,
        ),
        const SizedBox(height: 12),
        _AdministrativeSignalsCard(
          title: 'Sinais de reputacao',
          metrics: functionalMetrics.reputationSignals,
        ),
      ],
    );
  }
}

class _AdministrativeSignalsCard extends StatelessWidget {
  const _AdministrativeSignalsCard({
    required this.title,
    required this.metrics,
  });

  final String title;
  final List<AdministrativeLabeledMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return _AdministrativeSectionCard(
      title: title,
      emptyMessage: 'Sem dados consolidados.',
      children: metrics
          .map(
            (metric) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(metric.label),
              trailing: Text(metric.value),
            ),
          )
          .toList(),
    );
  }
}

class _AdministrativeSectionCard extends StatelessWidget {
  const _AdministrativeSectionCard({
    required this.title,
    required this.emptyMessage,
    required this.children,
  });

  final String title;
  final String emptyMessage;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (children.isEmpty) Text(emptyMessage) else ...children,
          ],
        ),
      ),
    );
  }
}
