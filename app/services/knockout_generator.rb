class KnockoutGenerator
  # Servicio encargado de crear la fase eliminatoria del torneo.
  #
  # La llave se genera con 32 selecciones:
  # - 12 primeros lugares
  # - 12 segundos lugares
  # - 8 mejores terceros lugares
  #
  # La distribución utilizada es lógica para efectos del sistema.
  # No busca replicar exactamente la llave oficial de FIFA, sino cumplir
  # con el flujo solicitado por el proyecto.

  KNOCKOUT_STAGES = [
    "round_of_32",
    "round_of_16",
    "quarterfinal",
    "semifinal",
    "third_place",
    "final"
  ].freeze

  def self.generate
    return false unless QualificationService.group_stage_completed?
    return false if knockout_already_generated?

    qualified_teams = QualificationService.qualified_teams
    return false unless qualified_teams.size == 32

    ActiveRecord::Base.transaction do
      final_match = create_match("final", 104)
      third_place_match = create_match("third_place", 103)

      semifinal_matches = create_empty_round(
        stage: "semifinal",
        start_number: 101,
        amount: 2,
        next_stage_matches: [final_match]
      )

      quarterfinal_matches = create_empty_round(
        stage: "quarterfinal",
        start_number: 97,
        amount: 4,
        next_stage_matches: semifinal_matches
      )

      round_of_16_matches = create_empty_round(
        stage: "round_of_16",
        start_number: 89,
        amount: 8,
        next_stage_matches: quarterfinal_matches
      )

      create_round_of_32(qualified_teams, round_of_16_matches)

      third_place_match
    end

    true
  end

  def self.knockout_already_generated?
    Match.where(stage: KNOCKOUT_STAGES).exists?
  end

  def self.create_match(stage, match_number)
    Match.create!(
      stage: stage,
      played: false,
      match_number: match_number
    )
  end

  def self.create_empty_round(stage:, start_number:, amount:, next_stage_matches:)
    matches = []

    amount.times do |index|
      next_match = next_stage_matches[index / 2]
      next_slot = index.even? ? "home" : "away"

      matches << Match.create!(
        stage: stage,
        played: false,
        match_number: start_number + index,
        next_match: next_match,
        next_match_slot: next_slot
      )
    end

    matches
  end

  def self.create_round_of_32(qualified_teams, round_of_16_matches)
    first_half = qualified_teams.first(16)
    second_half = qualified_teams.last(16).reverse

    first_half.each_with_index do |home_team, index|
      away_team = second_half[index]
      next_match = round_of_16_matches[index / 2]
      next_slot = index.even? ? "home" : "away"

      Match.create!(
        stage: "round_of_32",
        home_team: home_team,
        away_team: away_team,
        played: false,
        match_number: 73 + index,
        next_match: next_match,
        next_match_slot: next_slot
      )
    end
  end
end
