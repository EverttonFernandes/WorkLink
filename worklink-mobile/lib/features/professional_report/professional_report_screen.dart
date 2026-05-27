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
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          const Text(
            'Conte o que aconteceu para que possamos analisar a situação com segurança e tomar as medidas necessárias.',
            style: TextStyle(
              color: Color(0xFF73839B),
              fontSize: 18,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          _ProfessionalReportProfileCard(
            professionalName: widget.professionalName,
          ),
          const SizedBox(height: 22),
          const Text(
            '1. Qual foi o problema?',
            style: TextStyle(
              color: Color(0xFF10233F),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE8EDF3)),
            ),
            child: Column(
              children: [
                for (final reportReason in ProfessionalReportReason.values) ...[
                  _ProfessionalReportReasonTile(
                    reportReason: reportReason,
                    selected:
                        reportState.selectedReason == reportReason,
                    onTap: () => widget.professionalReportController
                        .selectReason(reportReason),
                  ),
                  if (reportReason != ProfessionalReportReason.values.last)
                    const Divider(height: 1),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '2. Detalhes',
            style: TextStyle(
              color: Color(0xFF10233F),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            key: const ValueKey('professional-report-description'),
            minLines: 4,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Descreva o ocorrido com o máximo de detalhes possível',
            ),
            onChanged: widget.professionalReportController.updateDescription,
          ),
          const SizedBox(height: 16),
          InkWell(
            key: const ValueKey('attach-professional-report-evidence'),
            onTap: () => widget.professionalReportController
                .attachEvidence('evidencia-denuncia.pdf'),
            borderRadius: BorderRadius.circular(22),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE8EDF3)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFFEAF8EF),
                    child: Icon(
                      Icons.attach_file_outlined,
                      color: Color(0xFF16C35B),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      reportState.hasEvidence
                          ? reportState.evidenceFileName!
                          : 'Anexar evidências (opcional)',
                      style: const TextStyle(
                        color: Color(0xFF10233F),
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF73839B),
                  ),
                ],
              ),
            ),
          ),
          if (reportState.hasEvidence) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              key: const ValueKey('remove-professional-report-evidence'),
              onPressed: widget.professionalReportController.removeEvidence,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remover evidência'),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFF),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE3EAF5)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  color: Color(0xFF73839B),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tratamos sua denúncia com responsabilidade e preservamos seus dados pessoais durante a análise.',
                    style: TextStyle(
                      color: Color(0xFF73839B),
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (reportState.shouldShowAuthorityGuidance) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFAF1),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFF4D38D)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    color: Color(0xFFF5A623),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ProfessionalReportState.authorityGuidance,
                      style: TextStyle(
                        color: Color(0xFF10233F),
                        fontSize: 15,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (reportState.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              reportState.errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (reportState.submitted) ...[
            const SizedBox(height: 12),
            const Text(
              'Denuncia enviada para analise.',
              style: TextStyle(
                color: Color(0xFF16C35B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            key: const ValueKey('submit-professional-report'),
            onPressed: widget.professionalReportController.submitReport,
            icon: const Icon(Icons.shield_outlined),
            label: const Text('Enviar denúncia'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _refreshReportState() {
    setState(() {});
  }
}

class _ProfessionalReportProfileCard extends StatelessWidget {
  const _ProfessionalReportProfileCard({
    required this.professionalName,
  });

  final String professionalName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE8EDF3)),
      ),
      child: Row(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEAEFF5),
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 48,
              color: Color(0xFF73839B),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  professionalName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFF10233F),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Eletricista residencial',
                  style: TextStyle(
                    color: Color(0xFF73839B),
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: Color(0xFF8A97AD),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Charqueadas, RS',
                      style: TextStyle(
                        color: Color(0xFF8A97AD),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF8EF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: 18,
                        color: Color(0xFF16C35B),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Perfil verificado',
                        style: TextStyle(
                          color: Color(0xFF16C35B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfessionalReportReasonTile extends StatelessWidget {
  const _ProfessionalReportReasonTile({
    required this.reportReason,
    required this.selected,
    required this.onTap,
  });

  final ProfessionalReportReason reportReason;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey('report-reason-${reportReason.name}'),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFF4F6FA),
              child: Icon(
                _iconForReason(reportReason),
                color: reportReason == ProfessionalReportReason.harassment
                    ? const Color(0xFF16C35B)
                    : const Color(0xFF73839B),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _labelForReason(reportReason),
                style: const TextStyle(
                  color: Color(0xFF10233F),
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected
                  ? const Color(0xFF16C35B)
                  : const Color(0xFF9AA6BB),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForReason(ProfessionalReportReason reportReason) {
    return switch (reportReason) {
      ProfessionalReportReason.fraud => Icons.warning_amber_outlined,
      ProfessionalReportReason.harassment => Icons.front_hand_outlined,
      ProfessionalReportReason.threat => Icons.gpp_bad_outlined,
      ProfessionalReportReason.fakeProfile => Icons.person_outline_rounded,
      ProfessionalReportReason.serviceNotPerformed => Icons.report_problem_outlined,
      ProfessionalReportReason.other => Icons.more_horiz_rounded,
    };
  }

  String _labelForReason(ProfessionalReportReason reportReason) {
    return switch (reportReason) {
      ProfessionalReportReason.fraud => 'Tentativa de golpe ou fraude',
      ProfessionalReportReason.harassment => 'Assédio sexual',
      ProfessionalReportReason.threat => 'Ameaça ou intimidação',
      ProfessionalReportReason.fakeProfile => 'Perfil falso',
      ProfessionalReportReason.serviceNotPerformed => 'Serviço não realizado',
      ProfessionalReportReason.other => 'Outro',
    };
  }
}
