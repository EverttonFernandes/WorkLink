enum ProfessionalAvailabilityStatus {
  availableToday('Disponível hoje', 0),
  availableThisWeek('Disponível esta semana', 1),
  acceptingNewClients('Aceitando novos clientes', 2),
  emergencyService('Atendimento emergencial', 0),
  temporarilyUnavailable('Indisponível temporariamente', 9);

  const ProfessionalAvailabilityStatus(this.badgeLabel, this.listingPriority);

  final String badgeLabel;
  final int listingPriority;

  bool get reducesListingHighlight =>
      this == ProfessionalAvailabilityStatus.temporarilyUnavailable;
}
