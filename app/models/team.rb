class Team < ApplicationRecord
  # Cada selección pertenece a un grupo.
  belongs_to :group

  # El nombre de la selección es obligatorio y único.
  validates :country_name,
            presence: { message: "no puede estar vacío" },
            uniqueness: { message: "ya existe" }

  # Antes de validar una selección nueva, se inicializan sus estadísticas.
  # Esto evita valores nulos en puntos, goles y diferencia de goles.
  before_validation :set_default_statistics, on: :create

  # Antes de guardar se calcula la diferencia de goles.
  before_save :calculate_goal_difference

  private

  # Define los valores iniciales de una selección.
  # Todas las selecciones empiezan con cero puntos y cero goles.
  def set_default_statistics
    self.points = 0 if points.nil?
    self.goals_for = 0 if goals_for.nil?
    self.goals_against = 0 if goals_against.nil?
    self.goal_difference = 0 if goal_difference.nil?
  end

  # Calcula la diferencia de goles usando goles a favor menos goles en contra.
  def calculate_goal_difference
    self.goal_difference = goals_for.to_i - goals_against.to_i
  end
end