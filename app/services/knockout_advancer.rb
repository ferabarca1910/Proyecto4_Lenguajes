class KnockoutAdvancer
  # Servicio encargado de avanzar automáticamente al ganador de un partido
  # de eliminación directa hacia la siguiente ronda.
  #
  # También maneja el caso especial de semifinales, donde el ganador avanza
  # a la final y el perdedor avanza al partido por tercer lugar.

  def self.process(match)
    return unless match.present?
    return if match.stage == "group_stage"
    return unless match.played?
    return unless match.home_team.present? && match.away_team.present?

    winner = WinnerResolver.resolve(match)
    return unless winner.present?

    loser = WinnerResolver.loser(match, winner)

    save_winner(match, winner)
    advance_winner_to_next_match(match, winner)
    advance_semifinal_loser_to_third_place(match, loser)
  end

  def self.save_winner(match, winner)
    return if match.winner_team_id == winner.id

    match.update_column(:winner_team_id, winner.id)
  end

  def self.advance_winner_to_next_match(match, winner)
    return unless match.next_match.present?
    return unless match.next_match_slot.present?

    if match.next_match_slot == "home"
      match.next_match.update_column(:home_team_id, winner.id)
    elsif match.next_match_slot == "away"
      match.next_match.update_column(:away_team_id, winner.id)
    end
  end

  def self.advance_semifinal_loser_to_third_place(match, loser)
    return unless match.stage == "semifinal"
    return unless loser.present?

    third_place_match = Match.find_by(stage: "third_place")
    return unless third_place_match.present?

    if match.match_number == 101
      third_place_match.update_column(:home_team_id, loser.id)
    elsif match.match_number == 102
      third_place_match.update_column(:away_team_id, loser.id)
    end
  end
end
