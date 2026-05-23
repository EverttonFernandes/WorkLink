// coverage:ignore-file

import 'package:flutter/material.dart';

import 'professional_profile.dart';
import 'professional_profile_review.dart';

const Color _workLinkGreen = Color(0xFF16C35B);
const Color _workLinkDark = Color(0xFF10233F);
const Color _workLinkMuted = Color(0xFF6E7D95);

class ProfessionalProfileScreen extends StatefulWidget {
  const ProfessionalProfileScreen({
    super.key,
    required this.professionalProfile,
    this.onContactProfessional,
    this.onReportProfessional,
    this.onRequestReviewAnalysis,
    this.savedByCustomer = false,
    this.onToggleSavedProfessional,
  });

  final ProfessionalProfile professionalProfile;
  final ValueChanged<String>? onContactProfessional;
  final ValueChanged<String>? onReportProfessional;
  final ValueChanged<String>? onRequestReviewAnalysis;
  final bool savedByCustomer;
  final Future<bool> Function(bool currentlySaved)? onToggleSavedProfessional;

  @override
  State<ProfessionalProfileScreen> createState() =>
      _ProfessionalProfileScreenState();
}

class _ProfessionalProfileScreenState extends State<ProfessionalProfileScreen> {
  late bool _savedByCustomer;

  @override
  void initState() {
    super.initState();
    _savedByCustomer = widget.savedByCustomer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do profissional'),
        actions: [
          IconButton(
            tooltip: _savedByCustomer
                ? 'Remover dos profissionais salvos'
                : 'Salvar profissional',
            onPressed: widget.onToggleSavedProfessional == null
                ? null
                : () async {
                    final nextSavedState =
                        await widget.onToggleSavedProfessional!(
                      _savedByCustomer,
                    );
                    if (!mounted) {
                      return;
                    }
                    setState(() {
                      _savedByCustomer = nextSavedState;
                    });
                  },
            icon: Icon(
              _savedByCustomer ? Icons.bookmark : Icons.bookmark_border,
            ),
          ),
          IconButton(
            tooltip: 'Compartilhar perfil',
            onPressed: () {},
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          _ProfessionalProfileHeader(
            professionalProfile: widget.professionalProfile,
          ),
          const SizedBox(height: 20),
          _ProfileDisclaimer(),
          const SizedBox(height: 20),
          _ProfileActions(
            professionalProfile: widget.professionalProfile,
            savedByCustomer: _savedByCustomer,
            onContactProfessional: widget.onContactProfessional,
            onReportProfessional: widget.onReportProfessional,
          ),
          if (widget.professionalProfile.hasAboutDescription) ...[
            const SizedBox(height: 20),
            _ProfileTextSection(
              title: 'Sobre mim',
              body: widget.professionalProfile.aboutDescription,
            ),
          ],
          if (widget.professionalProfile.hasServiceNames) ...[
            const SizedBox(height: 20),
            _ProfileChipSection(
              title: 'Serviços',
              values: widget.professionalProfile.serviceNames,
            ),
          ],
          if (widget.professionalProfile.hasUsefulLinks) ...[
            const SizedBox(height: 20),
            _ProfileChipSection(
              title: 'Links úteis',
              values: widget.professionalProfile.usefulLinks,
            ),
          ],
          if (widget.professionalProfile.hasPortfolioItems) ...[
            const SizedBox(height: 20),
            _ProfilePortfolioSection(
              title: 'Portfólio',
              values: widget.professionalProfile.portfolioItemDescriptions,
            ),
          ],
          if (widget.professionalProfile.hasReviewSummary) ...[
            const SizedBox(height: 20),
            _ProfileReviewSection(
              reviewSummary: widget.professionalProfile.reviewSummary!,
              onRequestReviewAnalysis: widget.onRequestReviewAnalysis,
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
        Row(
          children: [
            Text(
              'Avaliações',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _workLinkDark,
                  ),
            ),
            if (reviewSummary.reviewCount > 0)
              Text(
                ' (${reviewSummary.reviewCountLabel})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _workLinkMuted,
                    ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, size: 22, color: Color(0xFFF4B400)),
                const SizedBox(width: 6),
                Text(
                  '${reviewSummary.averageRatingLabel} de 5',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _workLinkDark,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(width: 10),
                Text(
                  reviewSummary.reviewCountLabel,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: _workLinkMuted,
                      ),
                ),
              ],
            ),
          ),
        ),
        if (!reviewSummary.hasComments) ...[
          const SizedBox(height: 12),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF1F8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_outline, color: _workLinkMuted),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reviewComment.publicAuthorDisplayName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: _workLinkDark,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          for (var starIndex = 0;
                              starIndex < reviewComment.starRating;
                              starIndex++)
                            const Padding(
                              padding: EdgeInsets.only(right: 2),
                              child: Icon(
                                Icons.star_rounded,
                                size: 18,
                                color: Color(0xFFF4B400),
                              ),
                            ),
                          const SizedBox(width: 6),
                          Text(
                            '${reviewComment.starRating} de 5',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: _workLinkMuted,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              reviewComment.comment,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: _workLinkDark,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 10),
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
        ),
      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfessionalProfileAvatar(
              profilePhotoUrl: professionalProfile.profilePhotoUrl,
              profileIsVerified:
                  professionalProfile.phoneNumberVerified ||
                  professionalProfile.documentProvided,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    professionalProfile.professionalName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: _workLinkDark,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    professionalProfile.categoryName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: _workLinkMuted,
                        ),
                  ),
                  if (professionalProfile.hasReviewSummary) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 20,
                          color: Color(0xFFF4B400),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          professionalProfile.reviewSummary!.averageRatingLabel,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: _workLinkDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${professionalProfile.reviewSummary!.reviewCountLabel})',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: _workLinkMuted,
                                  ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final profileBadgeLabel
                          in professionalProfile.visibleProfileBadgeLabels)
                        _ProfileStatusChip(
                          label: profileBadgeLabel,
                          icon: profileBadgeLabel == 'Documento informado'
                              ? Icons.badge_outlined
                              : profileBadgeLabel == 'Telefone verificado'
                                  ? Icons.call_outlined
                                  : Icons.verified_user_outlined,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on, color: _workLinkGreen),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    professionalProfile.baseCityDisplayName.replaceFirst(' - ', ', '),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: _workLinkDark,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (professionalProfile.hasAttendedCities) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Atendimento em: ${professionalProfile.attendedCitiesSummary}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: _workLinkMuted,
                            height: 1.35,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (professionalProfile.hasAvailability) ...[
          const SizedBox(height: 14),
          _ProfileStatusChip(
            label: professionalProfile.availabilityLabel,
            icon: Icons.schedule_outlined,
          ),
        ],
      ],
    );
  }
}

class _ProfessionalProfileAvatar extends StatelessWidget {
  const _ProfessionalProfileAvatar({
    required this.profilePhotoUrl,
    required this.profileIsVerified,
  });

  final String? profilePhotoUrl;
  final bool profileIsVerified;

  @override
  Widget build(BuildContext context) {
    final availableProfilePhotoUrl = profilePhotoUrl?.trim();
    final avatarChild =
        availableProfilePhotoUrl == null || availableProfilePhotoUrl.isEmpty
            ? const CircleAvatar(
                radius: 54,
                backgroundColor: Color(0xFFEAF1F8),
                child: Icon(
                  Icons.person_outline,
                  size: 46,
                  color: _workLinkMuted,
                ),
              )
            : CircleAvatar(
                radius: 54,
                backgroundImage: NetworkImage(availableProfilePhotoUrl),
              );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatarChild,
        if (profileIsVerified)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _workLinkGreen,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 20),
            ),
          ),
      ],
    );
  }
}

class _ProfileDisclaimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, size: 18, color: _workLinkMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Completude do perfil não garante qualidade do serviço.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: _workLinkMuted,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileActions extends StatelessWidget {
  const _ProfileActions({
    required this.professionalProfile,
    required this.savedByCustomer,
    required this.onContactProfessional,
    required this.onReportProfessional,
  });

  final ProfessionalProfile professionalProfile;
  final bool savedByCustomer;
  final ValueChanged<String>? onContactProfessional;
  final ValueChanged<String>? onReportProfessional;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
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
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: ValueKey(
                      'call-professional-${professionalProfile.professionalIdentifier}',
                    ),
                    onPressed: () => onContactProfessional
                        ?.call(professionalProfile.professionalIdentifier),
                    icon: const Icon(Icons.call_outlined),
                    label: const Text('Ligar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    key: ValueKey(
                      'report-professional-${professionalProfile.professionalIdentifier}',
                    ),
                    onPressed: () => onReportProfessional
                        ?.call(professionalProfile.professionalIdentifier),
                    icon: Icon(
                      savedByCustomer
                          ? Icons.bookmark
                          : Icons.bookmark_border_outlined,
                    ),
                    label: Text(savedByCustomer ? 'Salvo' : 'Salvar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield_outlined, size: 16, color: _workLinkMuted),
                const SizedBox(width: 8),
                Text(
                  'Seus dados e conversas são protegidos',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _workLinkMuted,
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

class _ProfileTextSection extends StatelessWidget {
  const _ProfileTextSection({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _workLinkDark,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: _workLinkDark,
                    height: 1.42,
                  ),
            ),
            if (title == 'Sobre mim') ...[
              const SizedBox(height: 12),
              Text(
                'Ver mais',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: _workLinkGreen,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ],
        ),
      ),
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: _workLinkDark,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final value in values)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE4EBF2)),
                ),
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: _workLinkGreen,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ProfilePortfolioSection extends StatelessWidget {
  const _ProfilePortfolioSection({
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
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: _workLinkDark,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            Text(
              'Ver todas',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: _workLinkGreen,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 126,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final value = values[index];
              return Container(
                width: 150,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: index.isEven
                      ? const Color(0xFFEFF4F9)
                      : const Color(0xFFF7FBF8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE4EBF2)),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: _workLinkDark,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProfileStatusChip extends StatelessWidget {
  const _ProfileStatusChip({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8EF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _workLinkGreen),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _workLinkGreen,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
