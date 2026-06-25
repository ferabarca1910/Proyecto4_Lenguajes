class TeamsController < ApplicationController
  before_action :set_team, only: %i[show edit update destroy]

  # Muestra todas las selecciones registradas.
  def index
    @teams = Team.includes(:group).order(:country_name)
  end

  # Muestra el detalle de una selección específica.
  def show
  end

  # Prepara el formulario para crear una selección.
  def new
    @team = Team.new
  end

  # Prepara el formulario para editar una selección.
  def edit
  end

  # Guarda una nueva selección en la base de datos.
  def create
    @team = Team.new(team_params)

    if @team.save
      redirect_to @team, notice: "Selección creada correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Actualiza la información de una selección existente.
  def update
    if @team.update(team_params)
      redirect_to @team, notice: "Selección actualizada correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Elimina una selección del sistema.
  def destroy
    @team.destroy
    redirect_to teams_path, notice: "Selección eliminada correctamente."
  end

  private

  def set_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(
      :country_name,
      :group_id,
      :points,
      :goals_for,
      :goals_against,
      :goal_difference
    )
  end
end