class TournamentSimulator
  # Servicio encargado de generar resultados automáticos de prueba.
  #
  # Este servicio no sustituye el registro manual de resultados.
  # Su objetivo es facilitar la revisión del proyecto, permitiendo completar
  # rápidamente la fase de grupos y la fase eliminatoria para demostrar el flujo
  # completo del sistema.
  #
  # La simulación de fase eliminatoria garantiza que todos los partidos tengan
  # un ganador. Si un partido termina empatado, se asigna una tanda de penales.

  KNOCKOUT_ORDER = [
    "round_of_32",
    "round_of_16",
    "quarterfinal",
    "semifinal",
    "third_place",
    "final"
  ].freeze

  # Simula todos los partidos de fase de grupos.
  # En fase de grupos sí se permiten empates.
  def self.simulate_group_stage
    group_matches = Match.where(stage: "group_stage").order(:match_number)

    return false if group_matches.empty?

    group_matches.each do |match|
      result = group_stage_result(match)

      match.update!(
        home_score: result[:home_score],
        away_score: result[:away_score],
        home_penalties: nil,
        away_penalties: nil,
        winner_team_id: nil,
        played: true
      )
    end

    Group.find_each do |group|
      StandingsCalculator.calculate(group)
    end

    true
  end

  # Simula todos los partidos de eliminación directa.
  # Se procesan las rondas en orden para que los ganadores avancen correctamente.
  #
  # Ejemplo:
  # Dieciseisavos -> Octavos -> Cuartos -> Semifinales -> Tercer lugar / Final.
  def self.simulate_knockout_stage
    return false unless Match.where(stage: "round_of_32").exists?

    KNOCKOUT_ORDER.each do |stage|
      matches = Match.where(stage: stage).order(:match_number)

      matches.each do |match|
        next unless match.home_team.present? && match.away_team.present?

        result = knockout_result(match)

        match.update!(
          home_score: result[:home_score],
          away_score: result[:away_score],
          home_penalties: result[:home_penalties],
          away_penalties: result[:away_penalties],
          played: true
        )

        KnockoutAdvancer.process(match)
      end
    end

    true
  end

  # Elimina únicamente los partidos de eliminación directa.
  # Esto permite volver a generar la llave durante pruebas sin borrar grupos,
  # selecciones ni partidos de fase de grupos.
  def self.reset_knockout_stage
    Match.where(stage: KnockoutGenerator::KNOCKOUT_STAGES).destroy_all
  end

  # Genera un resultado automático para fase de grupos.
  # Estos resultados pueden incluir empates porque la fase de grupos lo permite.
  def self.group_stage_result(match)
    {
      home_score: (match.match_number * 2) % 5,
      away_score: (match.match_number + 1) % 4
    }
  end

  # Genera un resultado automático para eliminación directa.
  #
  # En eliminación directa no se puede dejar un empate sin resolver.
  # Por eso, si el marcador queda empatado, se agregan penales.
  def self.knockout_result(match)
    if match.match_number % 5 == 0
      return {
        home_score: 1,
        away_score: 1,
        home_penalties: 4,
        away_penalties: 3
      }
    end

    home_score = ((match.match_number + 1) % 4) + 1
    away_score = match.match_number % 3

    if home_score == away_score
      {
        home_score: home_score,
        away_score: away_score,
        home_penalties: 5,
        away_penalties: 4
      }
    else
      {
        home_score: home_score,
        away_score: away_score,
        home_penalties: nil,
        away_penalties: nil
      }
    end
  end
end