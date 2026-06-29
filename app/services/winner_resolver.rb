class WinnerResolver
  # Servicio encargado de determinar el ganador de un partido de eliminación directa.
  # En eliminación directa no puede existir empate. Si el marcador queda igual,
  # se utilizan los penales para definir al ganador.

  def self.resolve(match)
    return nil unless match.present?
    return nil unless match.played?
    return nil unless match.home_score.present? && match.away_score.present?
    return nil if match.stage == "group_stage"

    home_score = match.home_score.to_i
    away_score = match.away_score.to_i

    return match.home_team if home_score > away_score
    return match.away_team if away_score > home_score

    resolve_by_penalties(match)
  end

  def self.resolve_by_penalties(match)
    return nil unless match.home_penalties.present? && match.away_penalties.present?

    home_penalties = match.home_penalties.to_i
    away_penalties = match.away_penalties.to_i

    return match.home_team if home_penalties > away_penalties
    return match.away_team if away_penalties > home_penalties

    nil
  end

  # Retorna el perdedor de un partido a partir del ganador.
  # Se usa principalmente para definir el subcampeón y los equipos del tercer lugar.
  def self.loser(match, winner)
    return nil unless match.present? && winner.present?

    if winner.id == match.home_team_id
      match.away_team
    elsif winner.id == match.away_team_id
      match.home_team
    end
  end
end
