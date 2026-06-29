class StandingsCalculator
  # Servicio encargado de calcular la tabla de posiciones de un grupo.
  # Toma los partidos de fase de grupos marcados como jugados y actualiza
  # las estadísticas de cada selección: puntos, goles a favor, goles en contra
  # y diferencia de goles.

  def self.calculate(group)
    return if group.nil?

    teams = group.teams

    stats = {}

    teams.each do |team|
      stats[team.id] = {
        points: 0,
        goals_for: 0,
        goals_against: 0,
        goal_difference: 0
      }
    end

    matches = group.matches.where(stage: "group_stage", played: true)

    matches.each do |match|
      next unless valid_group_match?(match)

      home_id = match.home_team_id
      away_id = match.away_team_id

      next unless stats[home_id].present? && stats[away_id].present?

      home_goals = match.home_score.to_i
      away_goals = match.away_score.to_i

      update_goals(stats, home_id, away_id, home_goals, away_goals)
      update_points(stats, home_id, away_id, home_goals, away_goals)
    end

    update_teams(teams, stats)
  end

  # Retorna las selecciones del grupo ordenadas según los criterios solicitados:
  # puntos, diferencia de goles y goles a favor.
  def self.standings_for(group)
    calculate(group)

    group.teams.order(
      points: :desc,
      goal_difference: :desc,
      goals_for: :desc,
      country_name: :asc
    )
  end

  # Verifica que el partido tenga equipos y marcador completo.
  def self.valid_group_match?(match)
    match.home_team_id.present? &&
      match.away_team_id.present? &&
      match.home_score.present? &&
      match.away_score.present?
  end

  # Actualiza goles a favor y goles en contra para ambos equipos.
  def self.update_goals(stats, home_id, away_id, home_goals, away_goals)
    stats[home_id][:goals_for] += home_goals
    stats[home_id][:goals_against] += away_goals

    stats[away_id][:goals_for] += away_goals
    stats[away_id][:goals_against] += home_goals
  end

  # Actualiza los puntos de acuerdo con el resultado del partido.
  # Victoria: 3 puntos. Empate: 1 punto. Derrota: 0 puntos.
  def self.update_points(stats, home_id, away_id, home_goals, away_goals)
    if home_goals > away_goals
      stats[home_id][:points] += 3
    elsif away_goals > home_goals
      stats[away_id][:points] += 3
    else
      stats[home_id][:points] += 1
      stats[away_id][:points] += 1
    end
  end

  # Guarda las estadísticas calculadas en cada selección.
  # Se usa update_columns para evitar callbacks innecesarios durante el recálculo.
  def self.update_teams(teams, stats)
    teams.each do |team|
      team_stats = stats[team.id]

      goals_for = team_stats[:goals_for]
      goals_against = team_stats[:goals_against]

      team.update_columns(
        points: team_stats[:points],
        goals_for: goals_for,
        goals_against: goals_against,
        goal_difference: goals_for - goals_against
      )
    end
  end
end
