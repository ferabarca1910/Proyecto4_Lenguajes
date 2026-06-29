class Match < ApplicationRecord
  # Etapas oficiales que maneja el sistema.
  # Se usa una llave interna para guardar la etapa en base de datos
  # y un texto más claro para mostrarlo en formularios.
  STAGES = {
    "Fase de grupos" => "group_stage",
    "Dieciseisavos" => "round_of_32",
    "Octavos" => "round_of_16",
    "Cuartos de final" => "quarterfinal",
    "Semifinal" => "semifinal",
    "Partido por tercer lugar" => "third_place",
    "Final" => "final"
  }.freeze

  # Un partido puede pertenecer a un grupo.
  # En eliminación directa no es obligatorio que tenga grupo.
  belongs_to :group, optional: true

  # Un partido tiene dos selecciones: local y visitante.
  # Ambas asociaciones apuntan al modelo Team.
  belongs_to :home_team, class_name: "Team", optional: true
  belongs_to :away_team, class_name: "Team", optional: true

  # En partidos de eliminación directa se guarda el ganador.
  belongs_to :winner_team, class_name: "Team", optional: true

  # Este campo se usa para avanzar automáticamente al ganador.
  belongs_to :next_match, class_name: "Match", optional: true

  # Antes de validar un partido nuevo, se marca como no jugado por defecto.
  before_validation :set_default_status, on: :create

  # Después de guardar o eliminar un partido de fase de grupos,
  # se recalcula la tabla de posiciones del grupo correspondiente.
  after_save :recalculate_affected_group_standings
  after_destroy :recalculate_current_group_standings

  validates :stage, presence: { message: "no puede estar vacía" }

  validates :home_score,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0,
              allow_nil: true,
              message: "debe ser un número entero mayor o igual a cero"
            }

  validates :away_score,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0,
              allow_nil: true,
              message: "debe ser un número entero mayor o igual a cero"
            }

  validates :home_penalties,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0,
              allow_nil: true,
              message: "debe ser un número entero mayor o igual a cero"
            }

  validates :away_penalties,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0,
              allow_nil: true,
              message: "debe ser un número entero mayor o igual a cero"
            }

  validate :teams_must_be_different
  validate :group_stage_must_have_group
  validate :played_match_must_have_teams
  validate :played_match_must_have_scores
  validate :group_stage_must_not_have_penalties
  validate :knockout_draw_must_have_valid_penalties

  # Devuelve el nombre visible de la etapa.
  def stage_name
    STAGES.key(stage) || stage
  end

  # Indica si un partido ya tiene resultado registrado.
  def completed?
    played == true && home_score.present? && away_score.present?
  end

  private

  # Marca el partido como no jugado si no se indicó ningún valor.
  def set_default_status
    self.played = false if played.nil?
  end

  # Valida que una selección no juegue contra sí misma.
  def teams_must_be_different
    return if home_team_id.blank? || away_team_id.blank?

    if home_team_id == away_team_id
      errors.add(:away_team_id, "no puede ser igual al equipo local")
    end
  end

  # En fase de grupos, el partido debe pertenecer a un grupo.
  def group_stage_must_have_group
    return unless stage == "group_stage"

    if group_id.blank?
      errors.add(:group_id, "debe indicarse para partidos de fase de grupos")
    end
  end

  # Si el partido está marcado como jugado, debe tener ambos equipos definidos.
  def played_match_must_have_teams
    return unless played == true

    if home_team_id.blank?
      errors.add(:home_team_id, "debe indicarse si el partido está jugado")
    end

    if away_team_id.blank?
      errors.add(:away_team_id, "debe indicarse si el partido está jugado")
    end
  end

  # Si el partido está marcado como jugado, debe tener marcador completo.
  def played_match_must_have_scores
    return unless played == true

    if home_score.blank?
      errors.add(:home_score, "debe indicarse si el partido está jugado")
    end

    if away_score.blank?
      errors.add(:away_score, "debe indicarse si el partido está jugado")
    end
  end

  # En fase de grupos no se usan penales.
  def group_stage_must_not_have_penalties
    return unless stage == "group_stage"

    if home_penalties.present? || away_penalties.present?
      errors.add(:base, "los partidos de fase de grupos no deben tener penales")
    end
  end

  # En eliminación directa, si hay empate en goles, debe existir definición por penales.
  # Además, los penales no pueden quedar empatados porque debe haber un ganador.
  def knockout_draw_must_have_valid_penalties
    return if stage == "group_stage"
    return unless played == true
    return unless home_score.present? && away_score.present?
    return unless home_score.to_i == away_score.to_i

    if home_penalties.blank? || away_penalties.blank?
      errors.add(:base, "los partidos de eliminación directa empatados deben definirse por penales")
      return
    end

    if home_penalties.to_i == away_penalties.to_i
      errors.add(:base, "los penales no pueden quedar empatados en eliminación directa")
    end
  end

  # Recalcula la tabla cuando se guarda un partido de fase de grupos.
  # También contempla el caso de que el partido haya sido movido de grupo.
  def recalculate_affected_group_standings
    return unless stage == "group_stage" || stage_before_last_save == "group_stage"

    if saved_change_to_group_id? && group_id_before_last_save.present?
      previous_group = Group.find_by(id: group_id_before_last_save)
      StandingsCalculator.calculate(previous_group) if previous_group.present?
    end

    StandingsCalculator.calculate(group) if group.present?
  end

  # Recalcula la tabla cuando se elimina un partido de fase de grupos.
  def recalculate_current_group_standings
    return unless stage == "group_stage"
    return unless group.present?

    StandingsCalculator.calculate(group)
  end
end