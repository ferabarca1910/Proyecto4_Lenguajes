class QualificationService
  # Servicio encargado de calcular las selecciones clasificadas a la fase eliminatoria.
  # Según el enunciado del proyecto, clasifican los dos primeros lugares de cada grupo
  # y los ocho mejores terceros lugares.

  def self.first_places
    Group.order(:name).map do |group|
      StandingsCalculator.standings_for(group).to_a[0]
    end.compact
  end

  def self.second_places
    Group.order(:name).map do |group|
      StandingsCalculator.standings_for(group).to_a[1]
    end.compact
  end

  def self.third_places
    Group.order(:name).map do |group|
      StandingsCalculator.standings_for(group).to_a[2]
    end.compact
  end

  def self.best_third_places
    third_places.sort_by do |team|
      [
        -team.points.to_i,
        -team.goal_difference.to_i,
        -team.goals_for.to_i,
        team.country_name
      ]
    end.first(8)
  end

  def self.qualified_teams
    first_places + second_places + best_third_places
  end

  # Valida si todos los partidos de fase de grupos ya tienen resultado.
  # Esta condición es necesaria antes de generar la llave de eliminación directa.
  def self.group_stage_completed?
    group_stage_matches = Match.where(stage: "group_stage")

    return false if group_stage_matches.empty?

    group_stage_matches.all? do |match|
      match.played? && match.home_score.present? && match.away_score.present?
    end
  end
end
