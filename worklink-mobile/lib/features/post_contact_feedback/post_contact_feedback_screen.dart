// coverage:ignore-file

import 'package:flutter/material.dart';

import 'post_contact_feedback_controller.dart';
import 'post_contact_feedback_state.dart';

class PostContactFeedbackScreen extends StatelessWidget {
  const PostContactFeedbackScreen({
    super.key,
    required this.postContactFeedbackController,
    this.onOpenProfessionalReview,
  });

  final PostContactFeedbackController postContactFeedbackController;
  final ValueChanged<String>? onOpenProfessionalReview;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pós-contato')),
      body: AnimatedBuilder(
        animation: postContactFeedbackController,
        builder: (context, child) {
          final state = postContactFeedbackController.state;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Como foi o contato?',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _ChoiceSection<PostContactConversationOutcome>(
                title: 'Conseguiu falar?',
                selectedValue: state.conversationOutcome,
                values: const {
                  PostContactConversationOutcome.customerReachedProfessional:
                      'Consegui falar',
                  PostContactConversationOutcome
                      .customerDidNotReachProfessional: 'Não consegui falar',
                },
                keyPrefix: 'conversation-outcome',
                onSelected:
                    postContactFeedbackController.selectConversationOutcome,
              ),
              const SizedBox(height: 16),
              _ChoiceSection<PostContactResponsiveness>(
                title: 'Como foi a resposta?',
                selectedValue: state.contactResponsiveness,
                values: const {
                  PostContactResponsiveness.fastResponse: 'Respondeu rápido',
                  PostContactResponsiveness.slowResponse: 'Demorou',
                  PostContactResponsiveness.noResponse: 'Não respondeu',
                },
                keyPrefix: 'contact-responsiveness',
                onSelected:
                    postContactFeedbackController.selectContactResponsiveness,
              ),
              const SizedBox(height: 16),
              _ChoiceSection<PostContactServiceExecutionOutcome>(
                title: 'O serviço foi realizado?',
                selectedValue: state.serviceExecutionOutcome,
                values: const {
                  PostContactServiceExecutionOutcome.servicePerformed:
                      'Serviço realizado',
                  PostContactServiceExecutionOutcome.serviceNotPerformed:
                      'Serviço não realizado',
                },
                keyPrefix: 'service-execution',
                onSelected:
                    postContactFeedbackController.selectServiceExecutionOutcome,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const ValueKey('submit-post-contact-feedback-button'),
                onPressed: postContactFeedbackController.submitFeedback,
                icon: const Icon(Icons.check_outlined),
                label: const Text('Enviar feedback'),
              ),
              if (state.hasError) ...[
                const SizedBox(height: 16),
                Text(
                  state.errorMessage!,
                  key: const ValueKey('post-contact-feedback-error-message'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              if (state.submitted) ...[
                const SizedBox(height: 16),
                const Text('Feedback pós-contato registrado.'),
                if (state.serviceExecutionOutcome ==
                    PostContactServiceExecutionOutcome.servicePerformed) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    key: const ValueKey('open-professional-review-button'),
                    onPressed: onOpenProfessionalReview == null
                        ? null
                        : () => onOpenProfessionalReview!(
                              postContactFeedbackController
                                  .contactIntentionIdentifier,
                            ),
                    icon: const Icon(Icons.star_outline),
                    label: const Text('Avaliar profissional'),
                  ),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ChoiceSection<T> extends StatelessWidget {
  const _ChoiceSection({
    required this.title,
    required this.selectedValue,
    required this.values,
    required this.keyPrefix,
    required this.onSelected,
  });

  final String title;
  final T? selectedValue;
  final Map<T, String> values;
  final String keyPrefix;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in values.entries)
              ChoiceChip(
                key: ValueKey('$keyPrefix-${entry.key}'),
                selected: selectedValue == entry.key,
                label: Text(entry.value),
                onSelected: (_) => onSelected(entry.key),
              ),
          ],
        ),
      ],
    );
  }
}
