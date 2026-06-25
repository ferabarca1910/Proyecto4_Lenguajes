class ApplicationController < ActionController::Base
  # Controlador base de la aplicación.
  # Todos los controladores del sistema heredan de esta clase.
  #
  # La interfaz del proyecto se maneja directamente en español desde las vistas,
  # formularios y mensajes de los controladores. Por eso no se fuerza un locale
  # global de Rails, evitando errores de configuración con I18n.
end