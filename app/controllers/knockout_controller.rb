class KnockoutController < ApplicationController
  # Controlador encargado de mostrar, generar y consultar la fase eliminatoria.
  # También incluye acciones de simulación para facilitar la revisión del sistema.

  def index
    @matches_by_stage = Match
      .where(stage: KnockoutGenerator::KNOCKOUT_STAGES)
      .includes(:home_team, :away_team, :winner_team)
      .order(:match_number)
      .group_by(&:stage)

    @group_stage_completed = QualificationService.group_stage_completed?
    @knockout_generated = Match.where(stage: KnockoutGenerator::KNOCKOUT_STAGES).exists?
  end

  # Genera la llave de eliminación directa.
  # Solo se genera si todos los partidos de fase de grupos están completos.
  def generate
    if KnockoutGenerator.generate
      redirect_to knockout_path, notice: "Fase eliminatoria generada correctamente."
    else
      redirect_to knockout_path, alert: "No se pudo generar la fase eliminatoria. Verifique que todos los partidos de fase de grupos estén completos y que no exista una llave ya generada."
    end
  end

  # Simula todos los partidos de fase de grupos.
  # Esto permite probar rápidamente tablas, clasificados y generación de eliminatoria.
  def simulate_group_stage
    if TournamentSimulator.simulate_group_stage
      redirect_to standings_path, notice: "Resultados de fase de grupos simulados correctamente."
    else
      redirect_to knockout_path, alert: "No se pudieron simular los partidos de fase de grupos."
    end
  end

  # Simula todos los partidos de eliminación directa.
  # Para que funcione, primero debe existir una llave eliminatoria generada.
  def simulate_knockout
    if TournamentSimulator.simulate_knockout_stage
      redirect_to podium_path, notice: "Fase eliminatoria simulada correctamente."
    else
      redirect_to knockout_path, alert: "No se pudo simular la fase eliminatoria. Primero debe generar la llave."
    end
  end

  # Reinicia únicamente la fase eliminatoria.
  # No elimina grupos, selecciones ni partidos de fase de grupos.
  def reset
    TournamentSimulator.reset_knockout_stage
    redirect_to knockout_path, notice: "Fase eliminatoria reiniciada correctamente."
  end

  # Muestra el campeón, subcampeón y tercer lugar.
  def podium
    final_match = Match.find_by(stage: "final")
    third_place_match = Match.find_by(stage: "third_place")

    @champion = final_match&.winner_team
    @runner_up = final_loser(final_match)
    @third_place = third_place_match&.winner_team
  end

  private

  # Calcula el perdedor de la final para mostrarlo como subcampeón.
  def final_loser(final_match)
    return nil unless final_match.present?
    return nil unless final_match.winner_team.present?

    WinnerResolver.loser(final_match, final_match.winner_team)
  end
end
