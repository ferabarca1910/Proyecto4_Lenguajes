Rails.application.routes.draw do
  # Ruta principal del sistema.
  # Al entrar a localhost:3000 se muestra la lista de grupos del Mundial.
  root "groups#index"

  # Rutas para consultar tablas de posiciones y clasificados.
  get "standings", to: "standings#index", as: :standings
  get "classified", to: "standings#classified", as: :classified

  # Rutas para la fase de eliminación directa.
  # También se incluyen acciones de simulación para facilitar la revisión.
  get "knockout", to: "knockout#index", as: :knockout
  post "knockout/generate", to: "knockout#generate", as: :generate_knockout
  post "knockout/simulate_group_stage", to: "knockout#simulate_group_stage", as: :simulate_group_stage
  post "knockout/simulate_knockout", to: "knockout#simulate_knockout", as: :simulate_knockout
  delete "knockout/reset", to: "knockout#reset", as: :reset_knockout
  get "podium", to: "knockout#podium", as: :podium

  # CRUD principal del sistema.
  resources :groups
  resources :teams
  resources :matches

  # Ruta interna de Rails para verificar que la aplicación esté funcionando correctamente.
  get "up" => "rails/health#show", as: :rails_health_check
end
