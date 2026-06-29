class StandingsController < ApplicationController
  # Muestra todas las tablas de posiciones, grupo por grupo.
  def index
    @groups = Group.order(:name)
  end

  # Muestra los clasificados a eliminación directa.
  # Se reutiliza QualificationService para no repetir lógica en el controlador.
  def classified
    @first_places = QualificationService.first_places
    @second_places = QualificationService.second_places
    @best_third_places = QualificationService.best_third_places
  end
end