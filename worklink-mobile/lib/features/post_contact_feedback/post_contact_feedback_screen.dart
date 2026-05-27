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
      appBar: AppBar(title: const Text('Como foi seu contato?')),
      body: AnimatedBuilder(
        animation: postContactFeedbackController,
        builder: (context, child) {
          final state = postContactFeedbackController.state;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              const Text(
                'Sua avaliação ajuda outros usuários a escolherem melhor.',
                style: TextStyle(
                  color: Color(0xFF73839B),
                  fontSize: 18,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              const _PostContactFeedbackEncouragementCard(),
              const SizedBox(height: 18),
              _PostContactFeedbackQuestionCard<PostContactConversationOutcome>(
                stepLabel: '1',
                title: 'Você conseguiu falar com o profissional?',
                selectedValue: state.conversationOutcome,
                values: const {
                  PostContactConversationOutcome.customerReachedProfessional:
                      'Sim',
                  PostContactConversationOutcome
                      .customerDidNotReachProfessional: 'Não',
                },
                keyPrefix: 'conversation-outcome',
                onSelected:
                    postContactFeedbackController.selectConversationOutcome,
              ),
              const SizedBox(height: 16),
              _PostContactFeedbackQuestionCard<PostContactServiceExecutionOutcome>(
                stepLabel: '2',
                title: 'O serviço foi realizado?',
                selectedValue: state.serviceExecutionOutcome,
                values: const {
                  PostContactServiceExecutionOutcome.servicePerformed: 'Sim',
                  PostContactServiceExecutionOutcome.serviceNotPerformed: 'Não',
                },
                keyPrefix: 'service-execution',
                onSelected:
                    postContactFeedbackController.selectServiceExecutionOutcome,
              ),
              const SizedBox(height: 16),
              _PostContactFeedbackQuestionCard<PostContactResponsiveness>(
                stepLabel: '3',
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
              const SizedBox(height: 22),
              FilledButton.icon(
                key: const ValueKey('submit-post-contact-feedback-button'),
                onPressed: postContactFeedbackController.submitFeedback,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Enviar feedback'),
              ),
              if (state.hasError) ...[
                const SizedBox(height: 14),
                Text(
                  state.errorMessage!,
                  key: const ValueKey('post-contact-feedback-error-message'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              if (state.submitted) ...[
                const SizedBox(height: 18),
                const _PostContactFeedbackSuccessCard(),
                if (state.serviceExecutionOutcome ==
                    PostContactServiceExecutionOutcome.servicePerformed) ...[
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    key: const ValueKey('open-professional-review-button'),
                    onPressed: onOpenProfessionalReview == null
                        ? null
                        : () => onOpenProfessionalReview!(
                              postContactFeedbackController
                                  .contactIntentionIdentifier,
                            ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(58),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    icon: const Icon(Icons.star_outline_rounded),
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

class _PostContactFeedbackEncouragementCard extends StatelessWidget {
  const _PostContactFeedbackEncouragementCard();

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
        border: Border.all(color: const Color(0xFFE1F2E7)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: Color(0xFFE9F9EE),
            child: Icon(
              Icons.favorite_outline_rounded,
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
                  'Avaliações reais ajudam outros usuários a encontrarem profissionais de confiança.',
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

class _PostContactFeedbackQuestionCard<T> extends StatelessWidget {
  const _PostContactFeedbackQuestionCard({
    required this.stepLabel,
    required this.title,
    required this.selectedValue,
    required this.values,
    required this.keyPrefix,
    required this.onSelected,
  });

  final String stepLabel;
  final String title;
  final T? selectedValue;
  final Map<T, String> values;
  final String keyPrefix;
  final ValueChanged<T> onSelected;

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
          const SizedBox(height: 16),
          Row(
            children: [
              for (final entry in values.entries)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: entry == values.entries.last ? 0 : 12,
                    ),
                    child: _PostContactFeedbackOptionButton(
                      key: ValueKey('$keyPrefix-${entry.key}'),
                      selected: selectedValue == entry.key,
                      label: entry.value,
                      onTap: () => onSelected(entry.key),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostContactFeedbackOptionButton extends StatelessWidget {
  const _PostContactFeedbackOptionButton({
    super.key,
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF0FBF4) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? const Color(0xFF16C35B)
                : const Color(0xFFDCE4EE),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selected) ...[
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF16C35B),
                size: 20,
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFF16C35B)
                      : const Color(0xFF73839B),
                  fontSize: 17,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostContactFeedbackSuccessCard extends StatelessWidget {
  const _PostContactFeedbackSuccessCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFAF3),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD8EEDC)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.verified_outlined,
            color: Color(0xFF16C35B),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Feedback pós-contato registrado.',
              style: TextStyle(
                color: Color(0xFF10233F),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
