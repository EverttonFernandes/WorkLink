// coverage:ignore-file

import 'package:flutter/material.dart';

import '../professional_availability/professional_availability_status.dart';
import 'professional_registration_controller.dart';
import 'professional_registration_draft.dart';

const Color _workLinkGreen = Color(0xFF16C35B);
const Color _workLinkDark = Color(0xFF10233F);
const Color _workLinkMuted = Color(0xFF6E7D95);

class ProfessionalRegistrationScreen extends StatefulWidget {
  const ProfessionalRegistrationScreen({
    super.key,
    required this.professionalRegistrationController,
    required this.availableCategoryNames,
    required this.availableCityDisplayNames,
    this.onContinue,
    this.onSaveAndContinueLater,
  });

  final ProfessionalRegistrationController professionalRegistrationController;
  final List<String> availableCategoryNames;
  final List<String> availableCityDisplayNames;
  final ValueChanged<ProfessionalRegistrationDraft>? onContinue;
  final ValueChanged<ProfessionalRegistrationDraft>? onSaveAndContinueLater;

  @override
  State<ProfessionalRegistrationScreen> createState() =>
      _ProfessionalRegistrationScreenState();
}

class _ProfessionalRegistrationScreenState
    extends State<ProfessionalRegistrationScreen> {
  @override
  void initState() {
    super.initState();
    widget.professionalRegistrationController.addListener(refreshScreen);
  }

  @override
  void dispose() {
    widget.professionalRegistrationController.removeListener(refreshScreen);
    super.dispose();
  }

  void refreshScreen() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.professionalRegistrationController.draft;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro do profissional'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          _ProgressHeader(draft: draft),
          const SizedBox(height: 22),
          _ProfilePhotoSection(
            hasProfilePhoto: draft.hasProfilePhoto,
            onToggleProfilePhoto:
                widget.professionalRegistrationController.toggleProfilePhoto,
          ),
          const SizedBox(height: 22),
          _RegistrationTextField(
            key: const ValueKey('professional-registration-name-field'),
            labelText: 'Nome completo',
            hintText: 'Ex.: Roberto Silva',
            icon: Icons.person_outline,
            initialValue: draft.professionalName,
            onChanged: widget
                .professionalRegistrationController.changeProfessionalName,
          ),
          const SizedBox(height: 12),
          _RegistrationTextField(
            key: const ValueKey('professional-registration-document-field'),
            labelText: 'CPF ou CNPJ',
            hintText: 'Ex.: 123.456.789-00',
            icon: Icons.badge_outlined,
            initialValue: draft.documentNumber,
            onChanged:
                widget.professionalRegistrationController.changeDocumentNumber,
          ),
          const SizedBox(height: 8),
          const _PrivacyHint(),
          const SizedBox(height: 12),
          _RegistrationDropdown(
            key: const ValueKey('professional-registration-category-field'),
            labelText: 'Categoria do serviço',
            value: draft.categoryName,
            values: widget.availableCategoryNames,
            icon: Icons.work_outline,
            onChanged:
                widget.professionalRegistrationController.changeCategoryName,
          ),
          const SizedBox(height: 12),
          _RegistrationDropdown(
            key: const ValueKey('professional-registration-city-field'),
            labelText: 'Cidade / região de atendimento',
            value: draft.cityDisplayName,
            values: widget.availableCityDisplayNames,
            icon: Icons.location_on_outlined,
            onChanged:
                widget.professionalRegistrationController.changeCityDisplayName,
          ),
          const SizedBox(height: 12),
          _RegistrationDropdown(
            key: const ValueKey('professional-registration-availability-field'),
            labelText: 'Disponibilidade',
            value: draft.availabilityStatus.badgeLabel,
            values: ProfessionalAvailabilityStatus.values
                .map((availabilityStatus) => availabilityStatus.badgeLabel)
                .toList(),
            icon: Icons.event_available_outlined,
            onChanged: widget.professionalRegistrationController
                .changeAvailabilityStatusByLabel,
          ),
          const SizedBox(height: 12),
          _RegistrationTextField(
            key: const ValueKey('professional-registration-whatsapp-field'),
            labelText: 'WhatsApp',
            hintText: 'Ex.: (51) 99999-9999',
            icon: Icons.chat_outlined,
            initialValue: draft.whatsappNumber,
            onChanged:
                widget.professionalRegistrationController.changeWhatsappNumber,
          ),
          const SizedBox(height: 12),
          _RegistrationTextField(
            key: const ValueKey('professional-registration-description-field'),
            labelText: 'Breve descrição do trabalho',
            hintText: 'Ex.: Instalações, manutenção e reparos residenciais.',
            icon: Icons.edit_outlined,
            initialValue: draft.shortDescription,
            maxLines: 3,
            maxLength: 250,
            onChanged: widget
                .professionalRegistrationController.changeShortDescription,
          ),
          const SizedBox(height: 12),
          _RegistrationTextField(
            key: const ValueKey('professional-registration-instagram-field'),
            labelText: 'Instagram (opcional)',
            hintText: 'Ex.: @seuinstagram',
            icon: Icons.alternate_email,
            initialValue: draft.instagramProfile,
            onChanged: widget
                .professionalRegistrationController.changeInstagramProfile,
          ),
          const SizedBox(height: 12),
          _RegistrationTextField(
            key: const ValueKey('professional-registration-link-field'),
            labelText: 'Facebook ou outro link útil (opcional)',
            hintText: 'Ex.: facebook.com/seuperfil',
            icon: Icons.public,
            initialValue: draft.usefulLink,
            onChanged:
                widget.professionalRegistrationController.changeUsefulLink,
          ),
          const SizedBox(height: 16),
          const _TrustExplanation(),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const ValueKey('professional-registration-continue-button'),
            onPressed: draft.hasMinimumRequiredFields
                ? () => widget.onContinue?.call(draft)
                : null,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Continuar'),
          ),
          TextButton(
            key: const ValueKey(
              'professional-registration-save-later-button',
            ),
            onPressed: () => widget.onSaveAndContinueLater?.call(draft),
            child: const Text('Salvar e continuar depois'),
          ),
        ],
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.draft,
  });

  final ProfessionalRegistrationDraft draft;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cadastro do Profissional',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: _workLinkDark,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF8EF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                draft.stepLabel,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: _workLinkGreen,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: draft.profileCompletenessPercentage / 100,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE4EBF2),
                  color: _workLinkGreen,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          draft.completenessLabel,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: _workLinkMuted,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          'Preencha seus dados para criar seu perfil profissional.',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: _workLinkMuted,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

class _ProfilePhotoSection extends StatelessWidget {
  const _ProfilePhotoSection({
    required this.hasProfilePhoto,
    required this.onToggleProfilePhoto,
  });

  final bool hasProfilePhoto;
  final VoidCallback onToggleProfilePhoto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          key: const ValueKey('professional-registration-photo-button'),
          onTap: onToggleProfilePhoto,
          child: Container(
            width: 152,
            height: 152,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFBFEBCF),
                width: 2,
              ),
              color: const Color(0xFFF8FCF9),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  hasProfilePhoto ? Icons.check_circle_outline : Icons.camera_alt_outlined,
                  size: 36,
                  color: _workLinkGreen,
                ),
                const SizedBox(height: 10),
                Text(
                  hasProfilePhoto ? 'Foto adicionada' : 'Adicionar foto',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _workLinkGreen,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 18),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sua foto ajuda clientes a conhecerem você.',
                style: TextStyle(
                  color: _workLinkDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Use uma foto nítida e profissional.',
                style: TextStyle(
                  color: _workLinkMuted,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RegistrationTextField extends StatelessWidget {
  const _RegistrationTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.icon,
    required this.initialValue,
    required this.onChanged,
    this.maxLines = 1,
    this.maxLength,
  });

  final String labelText;
  final String hintText;
  final IconData icon;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon, color: icon == Icons.chat_outlined ? _workLinkGreen : _workLinkMuted),
      ),
      onChanged: onChanged,
    );
  }
}

class _RegistrationDropdown extends StatelessWidget {
  const _RegistrationDropdown({
    super.key,
    required this.labelText,
    required this.value,
    required this.values,
    required this.icon,
    required this.onChanged,
  });

  final String labelText;
  final String? value;
  final List<String> values;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: _workLinkMuted),
      ),
      items: [
        for (final dropdownValue in values)
          DropdownMenuItem<String>(
            value: dropdownValue,
            child: Text(dropdownValue),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

class _PrivacyHint extends StatelessWidget {
  const _PrivacyHint();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.shield_outlined, size: 16, color: _workLinkMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Usado para aumentar a confiança do seu perfil.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _workLinkMuted,
                ),
          ),
        ),
      ],
    );
  }
}

class _TrustExplanation extends StatelessWidget {
  const _TrustExplanation();

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
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF8EF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    color: _workLinkGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Perfil completo gera mais confiança',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: _workLinkDark,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Profissionais com perfil completo se destacam e recebem mais contatos.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: _workLinkMuted,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: _TrustBenefitCard(
                    icon: Icons.call,
                    title: 'Telefone verificado',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _TrustBenefitCard(
                    icon: Icons.shield_outlined,
                    title: 'Perfil mais confiável',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _TrustBenefitCard(
                    icon: Icons.trending_up,
                    title: 'Mais chances de receber contatos',
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

class _TrustBenefitCard extends StatelessWidget {
  const _TrustBenefitCard({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4EBF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF8EF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _workLinkGreen),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: _workLinkDark,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
