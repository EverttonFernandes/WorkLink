// coverage:ignore-file

import 'package:flutter/material.dart';

import 'professional_review_controller.dart';

class ProfessionalReviewScreen extends StatelessWidget {
  const ProfessionalReviewScreen({
    super.key,
    required this.professionalReviewController,
  });

  final ProfessionalReviewController professionalReviewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avaliar profissional')),
      body: AnimatedBuilder(
        animation: professionalReviewController,
        builder: (context, child) {
          final state = professionalReviewController.state;
          if (state.submitted) {
            return _ProfessionalReviewSuccessState(
              anonymousToPublic: state.anonymousToPublic,
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Text(
                'Como foi o serviço?',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF10233F),
                    ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Sua avaliação ajuda outros usuários a escolherem melhor.',
                style: TextStyle(
                  color: Color(0xFF73839B),
                  fontSize: 18,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              const _ProfessionalReviewInfoCard(),
              const SizedBox(height: 18),
              _ProfessionalReviewSectionCard(
                stepLabel: '1',
                title: 'Avalie sua experiência',
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (var starRating = 1; starRating <= 5; starRating++)
                          InkWell(
                            key: ValueKey(
                              'professional-review-star-$starRating',
                            ),
                            onTap: () => professionalReviewController
                                .selectStarRating(starRating),
                            borderRadius: BorderRadius.circular(18),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                state.starRating != null &&
                                        state.starRating! >= starRating
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: const Color(0xFFE9A900),
                                size: 42,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _labelForRating(state.starRating),
                      style: const TextStyle(
                        color: Color(0xFF16C35B),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ProfessionalReviewSectionCard(
                stepLabel: '2',
                title: 'Deixe um comentário (opcional)',
                child: TextField(
                  key: const ValueKey('professional-review-comment-field'),
                  minLines: 4,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText:
                        'Conte como foi seu atendimento e o que mais gostou.',
                  ),
                  onChanged: professionalReviewController.changeComment,
                ),
              ),
              const SizedBox(height: 16),
              _ProfessionalReviewSectionCard(
                stepLabel: '3',
                title: 'Avaliação anônima',
                child: Material(
                  color: Colors.transparent,
                  child: SwitchListTile.adaptive(
                    key: const ValueKey(
                      'professional-review-anonymous-switch',
                    ),
                    contentPadding: EdgeInsets.zero,
                    value: state.anonymousToPublic,
                    title: const Text('Ocultar meu nome publicamente'),
                    subtitle: const Text(
                      'Seu nome não será exibido publicamente.',
                    ),
                    onChanged:
                        professionalReviewController.toggleAnonymousToPublic,
                    activeThumbColor: const Color(0xFF16C35B),
                  ),
                ),
              ),
              if (state.hasError) ...[
                const SizedBox(height: 14),
                Text(
                  state.errorMessage!,
                  key: const ValueKey('professional-review-error-message'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 22),
              FilledButton.icon(
                key: const ValueKey('submit-professional-review-button'),
                onPressed: professionalReviewController.submitReview,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Enviar avaliação'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _labelForRating(int? starRating) {
    return switch (starRating) {
      1 => 'Muito ruim',
      2 => 'Ruim',
      3 => 'Bom',
      4 => 'Muito bom',
      5 => 'Excelente',
      _ => 'Escolha uma nota',
    };
  }
}

class _ProfessionalReviewInfoCard extends StatelessWidget {
  const _ProfessionalReviewInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF5FFF8), Color(0xFFF8FCFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE0F2E7)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: Color(0xFFEAF8EF),
            child: Icon(
              Icons.verified_user_outlined,
              color: Color(0xFF16C35B),
              size: 32,
            ),
          ),
          SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sua opinião faz a diferença!',
                  style: TextStyle(
                    color: Color(0xFF10233F),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Avaliações reais ajudam outros usuários a encontrarem profissionais com mais confiança.',
                  style: TextStyle(
                    color: Color(0xFF73839B),
                    fontSize: 16,
                    height: 1.5,
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

class _ProfessionalReviewSectionCard extends StatelessWidget {
  const _ProfessionalReviewSectionCard({
    required this.stepLabel,
    required this.title,
    required this.child,
  });

  final String stepLabel;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE8EDF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFF16C35B),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    stepLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF10233F),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _ProfessionalReviewSuccessState extends StatelessWidget {
  const _ProfessionalReviewSuccessState({
    required this.anonymousToPublic,
  });

  final bool anonymousToPublic;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        const SizedBox(height: 12),
        const Center(
          child: CircleAvatar(
            radius: 86,
            backgroundColor: Color(0xFFEAF8EF),
            child: Icon(
              Icons.check_rounded,
              size: 92,
              color: Color(0xFF16C35B),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Obrigado pela sua avaliação!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF10233F),
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Sua avaliação foi enviada com sucesso e vai ajudar outras pessoas a encontrar profissionais com mais confiança.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF73839B),
            fontSize: 18,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 26),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFEFFAF3),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFD8EEDC)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFF16C35B),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  anonymousToPublic
                      ? 'Sua identidade será preservada quando a avaliação for anônima.'
                      : 'Sua avaliação foi registrada com identificação pública.',
                  style: const TextStyle(
                    color: Color(0xFF10233F),
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          icon: const Icon(Icons.home_outlined),
          label: const Text('Voltar para o início'),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(58),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          icon: const Icon(Icons.person_outline_rounded),
          label: const Text('Ver perfil do profissional'),
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          icon: const Icon(Icons.search_rounded),
          label: const Text('Buscar outro profissional'),
        ),
        const SizedBox(height: 18),
        const Text(
          'Avaliação registrada.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF16C35B),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
