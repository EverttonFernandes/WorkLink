// coverage:ignore-file

import 'package:flutter/material.dart';

import '../professional_availability/professional_availability_status.dart';
import 'professional_registration_controller.dart';
import 'professional_registration_draft.dart';

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
        padding: const EdgeInsets.all(16),
        children: [
          _ProgressHeader(draft: draft),
          const SizedBox(height: 16),
          _ProfilePhotoSection(
            hasProfilePhoto: draft.hasProfilePhoto,
            onToggleProfilePhoto:
                widget.professionalRegistrationController.toggleProfilePhoto,
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 4),
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
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Chip(label: Text(draft.stepLabel)),
            const SizedBox(width: 12),
            Expanded(
              child: LinearProgressIndicator(
                value: draft.profileCompletenessPercentage / 100,
                minHeight: 6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(draft.completenessLabel),
        const SizedBox(height: 8),
        const Text('Preencha seus dados para criar seu perfil profissional.'),
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
        OutlinedButton.icon(
          key: const ValueKey('professional-registration-photo-button'),
          onPressed: onToggleProfilePhoto,
          icon: Icon(
            hasProfilePhoto ? Icons.check_circle_outline : Icons.camera_alt,
          ),
          label: Text(hasProfilePhoto ? 'Foto adicionada' : 'Adicionar foto'),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Text(
            'Sua foto ajuda clientes a conhecerem você.',
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
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
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
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
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
    return const Row(
      children: [
        Icon(Icons.shield_outlined, size: 16),
        SizedBox(width: 6),
        Expanded(
          child: Text('Usado para aumentar a confiança do seu perfil.'),
        ),
      ],
    );
  }
}

class _TrustExplanation extends StatelessWidget {
  const _TrustExplanation();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.verified_user_outlined),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Perfil completo gera mais confiança',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Completude ajuda seu perfil a se destacar, mas não garante qualidade do serviço.',
            ),
          ],
        ),
      ),
    );
  }
}
