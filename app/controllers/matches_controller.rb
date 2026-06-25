class MatchesController < ApplicationController
  before_action :set_match, only: %i[show edit update destroy]

  # Muestra todos los partidos registrados.
  def index
    @matches = Match.includes(:group, :home_team, :away_team, :winner_team).order(:match_number)
  end

  # Muestra el detalle de un partido específico.
  def show
  end

  # Prepara el formulario para crear un partido.
  def new
    @match = Match.new
  end

  # Prepara el formulario para editar un partido.
  def edit
  end

  # Guarda un nuevo partido en la base de datos.
  def create
    @match = Match.new(match_params)

    if @match.save
      redirect_to @match, notice: "Partido creado correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Actualiza la información o el resultado de un partido.
  def update
    if @match.update(match_params)
      redirect_to @match, notice: "Partido actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Elimina un partido del sistema.
  def destroy
    @match.destroy
    redirect_to matches_path, notice: "Partido eliminado correctamente."
  end

  private

  def set_match
    @match = Match.find(params[:id])
  end

  def match_params
    params.require(:match).permit(
      :stage,
      :group_id,
      :home_team_id,
      :away_team_id,
      :home_score,
      :away_score,
      :home_penalties,
      :away_penalties,
      :winner_team_id,
      :played,
      :match_number,
      :next_match_id,
      :next_match_slot
    )
  end
end