class GroupsController < ApplicationController
  before_action :set_group, only: %i[show edit update destroy]

  # Muestra todos los grupos registrados.
  def index
    @groups = Group.order(:name)
  end

  # Muestra el detalle de un grupo específico.
  def show
  end

  # Prepara el formulario para crear un grupo.
  def new
    @group = Group.new
  end

  # Prepara el formulario para editar un grupo.
  def edit
  end

  # Guarda un nuevo grupo en la base de datos.
  def create
    @group = Group.new(group_params)

    if @group.save
      redirect_to @group, notice: "Grupo creado correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Actualiza la información de un grupo existente.
  def update
    if @group.update(group_params)
      redirect_to @group, notice: "Grupo actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Elimina un grupo del sistema.
  def destroy
    @group.destroy
    redirect_to groups_path, notice: "Grupo eliminado correctamente."
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:name)
  end
end