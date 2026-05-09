// coverage:ignore-file

import 'package:flutter/material.dart';

import 'professional_report_controller.dart';
import 'professional_report_state.dart';

class ProfessionalReportScreen extends StatefulWidget {
  const ProfessionalReportScreen({
    super.key,
    required this.professionalName,
    required this.professionalReportController,
  });

  final String professionalName;
  final ProfessionalReportController professionalReportController;

  @override
  State<ProfessionalReportScreen> createState() =>
      _ProfessionalReportScreenState();
}

class _ProfessionalReportScreenState extends State<ProfessionalReportScreen> {
  @override
  void initState() {
    super.initState();
    widget.professionalReportController.addListener(_refreshReportState);
  }

  @override
  void dispose() {
    widget.professionalReportController.removeListener(_refreshReportState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportState = widget.professionalReportController.state;
    return Scaffold(
      appBar: AppBar(title: const Text('Denunciar profissional')),
      body: ListView(
        key: const ValueKey('professional-report-form'),
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            widget.professionalName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Motivo',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final reportReason in ProfessionalReportReason.values)
            RadioListTile<ProfessionalReportReason>(
              key: ValueKey('report-reason-${reportReason.name}'),
              value: reportReason,
              groupValue: reportState.selectedReason,
              onChanged: (selectedReason) {
                if (selectedReason != null) {
                  widget.professionalReportController
                      .selectReason(selectedReason);
                }
              },
              title: Text(reportReason.label),
            ),
          if (reportState.shouldShowAuthorityGuidance) ...[
            const SizedBox(height: 8),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_outlined, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(ProfessionalReportState.authorityGuidance),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            key: const ValueKey('professional-report-description'),
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Descricao',
              border: OutlineInputBorder(),
            ),
            onChanged: widget.professionalReportController.updateDescription,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            key: const ValueKey('attach-professional-report-evidence'),
            onPressed: () => widget.professionalReportController
                .attachEvidence('evidencia-denuncia.pdf'),
            icon: const Icon(Icons.attach_file_outlined),
            label: Text(
              reportState.hasEvidence
                  ? reportState.evidenceFileName!
                  : 'Anexar evidencia opcional',
            ),
          ),
          if (reportState.hasEvidence)
            TextButton.icon(
              key: const ValueKey('remove-professional-report-evidence'),
              onPressed: widget.professionalReportController.removeEvidence,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remover evidencia'),
            ),
          if (reportState.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              reportState.errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (reportState.submitted) ...[
            const SizedBox(height: 8),
            const Text('Denuncia enviada para analise.'),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const ValueKey('submit-professional-report'),
            onPressed: widget.professionalReportController.submitReport,
            icon: const Icon(Icons.flag_outlined),
            label: const Text('Enviar denuncia'),
          ),
        ],
      ),
    );
  }

  void _refreshReportState() {
    setState(() {});
  }
}
