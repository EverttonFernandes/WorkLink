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
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Como foi o serviço?',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Nota obrigatória',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var starRating = 1; starRating <= 5; starRating++)
                    ChoiceChip(
                      key: ValueKey('professional-review-star-$starRating'),
                      selected: state.starRating == starRating,
                      avatar: Icon(
                        state.starRating != null &&
                                state.starRating! >= starRating
                            ? Icons.star
                            : Icons.star_border,
                        size: 18,
                      ),
                      label: Text('$starRating'),
                      onSelected: (_) => professionalReviewController
                          .selectStarRating(starRating),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                key: const ValueKey('professional-review-comment-field'),
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Comentário opcional',
                ),
                onChanged: professionalReviewController.changeComment,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                key: const ValueKey('professional-review-anonymous-switch'),
                contentPadding: EdgeInsets.zero,
                value: state.anonymousToPublic,
                title: const Text('Ocultar meu nome publicamente'),
                subtitle: const Text(
                  'A plataforma mantém rastreabilidade interna.',
                ),
                onChanged: professionalReviewController.toggleAnonymousToPublic,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const ValueKey('submit-professional-review-button'),
                onPressed: professionalReviewController.submitReview,
                icon: const Icon(Icons.verified_outlined),
                label: const Text('Enviar avaliação'),
              ),
              if (state.hasError) ...[
                const SizedBox(height: 16),
                Text(
                  state.errorMessage!,
                  key: const ValueKey('professional-review-error-message'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              if (state.submitted) ...[
                const SizedBox(height: 16),
                const Text('Avaliação registrada.'),
              ],
            ],
          );
        },
      ),
    );
  }
}
