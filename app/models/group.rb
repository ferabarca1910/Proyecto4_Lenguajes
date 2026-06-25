class Group < ApplicationRecord
  # Un grupo tiene varias selecciones. Si se elimina un grupo,
  # también se eliminan las selecciones asociadas.
  has_many :teams, dependent: :destroy

  # Un grupo tiene varios partidos de fase de grupos.
  # En la fase eliminatoria el grupo puede quedar vacío porque ya no aplica.
  has_many :matches, dependent: :destroy

  # El nombre del grupo es obligatorio y no se puede repetir.
  validates :name,
            presence: { message: "no puede estar vacío" },
            uniqueness: { message: "ya existe" }

  # Retorna la tabla de posiciones ordenada del grupo.
  # La lógica se deja en un servicio separado para mantener el modelo más limpio.
  def ordered_standings
    StandingsCalculator.standings_for(self)
  end
end