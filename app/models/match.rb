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

  # Este campo se usará después para avanzar automáticamente al ganador.
  belongs_to :next_match, class_name: "Match", optional: true

  # Antes de validar un partido nuevo, se marca como no jugado por defecto.
  before_validation :set_default_status, on: :create

  # Después de guardar o eliminar un partido de fase de grupos,
  # se recalcula la tabla de posiciones del grupo correspondiente.
  after_save :recalculate_affected_group_standings
  after_destroy :recalculate_current_group_standings

  validates :stage, presence: { message: "no puede estar vacía" }
  validate :teams_must_be_different

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