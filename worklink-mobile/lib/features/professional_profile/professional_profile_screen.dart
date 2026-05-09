// coverage:ignore-file

import 'package:flutter/material.dart';

import 'professional_profile.dart';
import 'professional_profile_review.dart';

class ProfessionalProfileScreen extends StatelessWidget {
  const ProfessionalProfileScreen({
    super.key,
    required this.professionalProfile,
    this.onContactProfessional,
    this.onReportProfessional,
    this.onRequestReviewAnalysis,
  });

  final ProfessionalProfile professionalProfile;
  final ValueChanged<String>? onContactProfessional;
  final ValueChanged<String>? onReportProfessional;
  final ValueChanged<String>? onRequestReviewAnalysis;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do profissional'),
        actions: [
          IconButton(
            tooltip: 'Compartilhar perfil',
            onPressed: () {},
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProfessionalProfileHeader(professionalProfile: professionalProfile),
          const SizedBox(height: 16),
          _ProfileDisclaimer(),
          const SizedBox(height: 16),
          _ProfileActions(
            professionalProfile: professionalProfile,
            onContactProfessional: onContactProfessional,
            onReportProfessional: onReportProfessional,
          ),
          if (professionalProfile.hasAboutDescription) ...[
            const SizedBox(height: 16),
            _ProfileTextSection(
              title: 'Sobre mim',
              body: professionalProfile.aboutDescription,
            ),
          ],
          if (professionalProfile.hasServiceNames) ...[
            const SizedBox(height: 16),
            _ProfileChipSection(
              title: 'Serviços',
              values: professionalProfile.serviceNames,
            ),
          ],
          if (professionalProfile.hasUsefulLinks) ...[
            const SizedBox(height: 16),
            _ProfileChipSection(
              title: 'Links úteis',
              values: professionalProfile.usefulLinks,
            ),
          ],
          if (professionalProfile.hasPortfolioItems) ...[
            const SizedBox(height: 16),
            _ProfileChipSection(
              title: 'Portfólio',
              values: professionalProfile.portfolioItemDescriptions,
            ),
          ],
          if (professionalProfile.hasReviewSummary) ...[
            const SizedBox(height: 16),
            _ProfileReviewSection(
              reviewSummary: professionalProfile.reviewSummary!,
              onRequestReviewAnalysis: onRequestReviewAnalysis,
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileReviewSection extends StatelessWidget {
  const _ProfileReviewSection({
    required this.reviewSummary,
    required this.onRequestReviewAnalysis,
  });

  final ProfessionalProfileReviewSummary reviewSummary;
  final ValueChanged<String>? onRequestReviewAnalysis;

  @override
  Widget build(BuildContext context) {
    if (!reviewSummary.hasReviews) {
      return const _ProfileTextSection(
        title: 'Avaliações',
        body: 'Este profissional ainda não possui avaliações.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Avaliações',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, size: 18),
            const SizedBox(width: 4),
            Text('${reviewSummary.averageRatingLabel} de 5'),
            const SizedBox(width: 8),
            Text(reviewSummary.reviewCountLabel),
          ],
        ),
        if (!reviewSummary.hasComments) ...[
          const SizedBox(height: 8),
          const Text('Ainda não há comentários públicos.'),
        ],
        for (final reviewComment in reviewSummary.comments) ...[
          const SizedBox(height: 12),
          _ProfileReviewCommentTile(
            reviewComment: reviewComment,
            onRequestReviewAnalysis: onRequestReviewAnalysis,
          ),
        ],
      ],
    );
  }
}

class _ProfileReviewCommentTile extends StatelessWidget {
  const _ProfileReviewCommentTile({
    required this.reviewComment,
    required this.onRequestReviewAnalysis,
  });

  final ProfessionalProfileReviewComment reviewComment;
  final ValueChanged<String>? onRequestReviewAnalysis;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.star_outline, size: 18),
            const SizedBox(width: 4),
            Text('${reviewComment.starRating} de 5'),
            const SizedBox(width: 8),
            Text(reviewComment.publicAuthorDisplayName),
          ],
        ),
        const SizedBox(height: 4),
        Text(reviewComment.comment),
        const SizedBox(height: 4),
        TextButton.icon(
          key: ValueKey(
            'request-review-analysis-${reviewComment.professionalReviewIdentifier}',
          ),
          onPressed: onRequestReviewAnalysis == null
              ? null
              : () => onRequestReviewAnalysis!(
                    reviewComment.professionalReviewIdentifier,
                  ),
          icon: const Icon(Icons.flag_outlined),
          label: const Text('Solicitar análise'),
        ),
      ],
    );
  }
}

class _ProfessionalProfileHeader extends StatelessWidget {
  const _ProfessionalProfileHeader({
    required this.professionalProfile,
  });

  final ProfessionalProfile professionalProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProfessionalProfileAvatar(
          profilePhotoUrl: professionalProfile.profilePhotoUrl,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                professionalProfile.professionalName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(professionalProfile.categoryName),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 18),
                  const SizedBox(width: 4),
                  Text(professionalProfile.baseCityDisplayName),
                ],
              ),
              if (professionalProfile.hasAttendedCities) ...[
                const SizedBox(height: 4),
                Text(
                  'Atendimento em: ${professionalProfile.attendedCitiesSummary}',
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final profileBadgeLabel
                      in professionalProfile.visibleProfileBadgeLabels)
                    Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text(profileBadgeLabel),
                    ),
                  if (professionalProfile.hasAvailability)
                    Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text(professionalProfile.availabilityLabel),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfessionalProfileAvatar extends StatelessWidget {
  const _ProfessionalProfileAvatar({
    required this.profilePhotoUrl,
  });

  final String? profilePhotoUrl;

  @override
  Widget build(BuildContext context) {
    final availableProfilePhotoUrl = profilePhotoUrl;
    if (availableProfilePhotoUrl == null ||
        availableProfilePhotoUrl.trim().isEmpty) {
      return const CircleAvatar(
        radius: 44,
        child: Icon(Icons.person_outline),
      );
    }

    return CircleAvatar(
      radius: 44,
      backgroundImage: NetworkImage(availableProfilePhotoUrl),
    );
  }
}

class _ProfileDisclaimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 18),
        SizedBox(width: 8),
        Expanded(
          child: Text('Completude do perfil não garante qualidade do serviço.'),
        ),
      ],
    );
  }
}

class _ProfileActions extends StatelessWidget {
  const _ProfileActions({
    required this.professionalProfile,
    required this.onContactProfessional,
    required this.onReportProfessional,
  });

  final ProfessionalProfile professionalProfile;
  final ValueChanged<String>? onContactProfessional;
  final ValueChanged<String>? onReportProfessional;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          key: ValueKey(
            'contact-professional-${professionalProfile.professionalIdentifier}',
          ),
          onPressed: () => onContactProfessional
              ?.call(professionalProfile.professionalIdentifier),
          icon: const Icon(Icons.chat_outlined),
          label: const Text('Chamar no WhatsApp'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          key: ValueKey(
            'report-professional-${professionalProfile.professionalIdentifier}',
          ),
          onPressed: () => onReportProfessional
              ?.call(professionalProfile.professionalIdentifier),
          icon: const Icon(Icons.flag_outlined),
          label: const Text('Denunciar'),
        ),
      ],
    );
  }
}

class _ProfileTextSection extends StatelessWidget {
  const _ProfileTextSection({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(body),
      ],
    );
  }
}

class _ProfileChipSection extends StatelessWidget {
  const _ProfileChipSection({
    required this.title,
    required this.values,
  });

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final value in values)
              Chip(
                visualDensity: VisualDensity.compact,
                label: Text(value),
              ),
          ],
        ),
      ],
    );
  }
}
