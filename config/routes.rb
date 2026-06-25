Rails.application.routes.draw do
  # Ruta principal del sistema.
  # Al entrar a localhost:3000 se muestra la lista de grupos del Mundial.
  root "groups#index"

  # Rutas para consultar tablas de posiciones y clasificados.
  get "standings", to: "standings#index", as: :standings
  get "classified", to: "standings#classified", as: :classified

  # CRUD principal del sistema.
  resources :groups
  resources :teams
  resources :matches

  # Ruta interna de Rails para verificar que la aplicación esté funcionando.
  get "up" => "rails/health#show", as: :rails_health_check
end