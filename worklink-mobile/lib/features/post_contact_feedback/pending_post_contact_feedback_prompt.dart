import 'package:flutter/material.dart';

import 'post_contact_feedback_request.dart';

class PendingPostContactFeedbackPrompt extends StatelessWidget {
  const PendingPostContactFeedbackPrompt({
    super.key,
    required this.request,
    required this.onRespond,
    required this.onDismiss,
  });

  final PostContactFeedbackRequest request;
  final VoidCallback onRespond;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conte como foi seu contato com ${request.professionalName}.',
              key: const ValueKey('pending-post-contact-feedback-title'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Seu feedback ajuda a medir responsividade e melhorar a busca.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    key: const ValueKey(
                      'respond-pending-post-contact-feedback-button',
                    ),
                    onPressed: onRespond,
                    child: const Text('Responder'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    key: const ValueKey(
                      'dismiss-pending-post-contact-feedback-button',
                    ),
                    onPressed: onDismiss,
                    child: const Text('Agora não'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
