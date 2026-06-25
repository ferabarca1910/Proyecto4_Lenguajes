# Datos iniciales del sistema.
# Este archivo carga la estructura actual del Mundial FIFA 2026.
#
# Se crean:
# - 12 grupos, identificados de la A a la L.
# - 48 selecciones participantes.
# - 72 partidos de fase de grupos.
#
# Los partidos se crean como pendientes, sin marcador inicial.
# El objetivo es que el usuario registre los resultados desde la interfaz
# y que el sistema calcule automáticamente las tablas de posiciones.

Match.destroy_all
Team.destroy_all
Group.destroy_all

groups = {}

("A".."L").each do |letter|
  groups[letter] = Group.create!(name: letter)
end

teams_by_group = {
  "A" => ["México", "Sudáfrica", "Corea del Sur", "Chequia"],
  "B" => ["Canadá", "Bosnia y Herzegovina", "Qatar", "Suiza"],
  "C" => ["Brasil", "Marruecos", "Haití", "Escocia"],
  "D" => ["Estados Unidos", "Paraguay", "Australia", "Turquía"],
  "E" => ["Alemania", "Curazao", "Costa de Marfil", "Ecuador"],
  "F" => ["Países Bajos", "Japón", "Suecia", "Túnez"],
  "G" => ["Bélgica", "Egipto", "Irán", "Nueva Zelanda"],
  "H" => ["España", "Cabo Verde", "Arabia Saudita", "Uruguay"],
  "I" => ["Francia", "Senegal", "Irak", "Noruega"],
  "J" => ["Argentina", "Argelia", "Austria", "Jordania"],
  "K" => ["Portugal", "República Democrática del Congo", "Uzbekistán", "Colombia"],
  "L" => ["Inglaterra", "Croacia", "Ghana", "Panamá"]
}

teams_by_group.each do |group_name, country_names|
  group = groups[group_name]

  country_names.each do |country_name|
    Team.create!(
      country_name: country_name,
      group: group,
      points: 0,
      goals_for: 0,
      goals_against: 0,
      goal_difference: 0
    )
  end
end

# Partidos de fase de grupos.
# Cada entrada contiene el grupo y los enfrentamientos correspondientes.
# Todos se crean como partidos pendientes para que el resultado sea ingresado
# posteriormente desde la aplicación web.

matches_by_group = {
  "A" => [
    ["México", "Sudáfrica"],
    ["Corea del Sur", "Chequia"],
    ["Chequia", "Sudáfrica"],
    ["México", "Corea del Sur"],
    ["Chequia", "México"],
    ["Sudáfrica", "Corea del Sur"]
  ],
  "B" => [
    ["Canadá", "Bosnia y Herzegovina"],
    ["Qatar", "Suiza"],
    ["Suiza", "Bosnia y Herzegovina"],
    ["Canadá", "Qatar"],
    ["Suiza", "Canadá"],
    ["Bosnia y Herzegovina", "Qatar"]
  ],
  "C" => [
    ["Brasil", "Marruecos"],
    ["Haití", "Escocia"],
    ["Escocia", "Marruecos"],
    ["Brasil", "Haití"],
    ["Escocia", "Brasil"],
    ["Marruecos", "Haití"]
  ],
  "D" => [
    ["Estados Unidos", "Paraguay"],
    ["Australia", "Turquía"],
    ["Estados Unidos", "Australia"],
    ["Turquía", "Paraguay"],
    ["Turquía", "Estados Unidos"],
    ["Paraguay", "Australia"]
  ],
  "E" => [
    ["Alemania", "Curazao"],
    ["Costa de Marfil", "Ecuador"],
    ["Alemania", "Costa de Marfil"],
    ["Ecuador", "Curazao"],
    ["Ecuador", "Alemania"],
    ["Curazao", "Costa de Marfil"]
  ],
  "F" => [
    ["Países Bajos", "Japón"],
    ["Suecia", "Túnez"],
    ["Países Bajos", "Suecia"],
    ["Túnez", "Japón"],
    ["Japón", "Suecia"],
    ["Túnez", "Países Bajos"]
  ],
  "G" => [
    ["Bélgica", "Egipto"],
    ["Irán", "Nueva Zelanda"],
    ["Bélgica", "Irán"],
    ["Nueva Zelanda", "Egipto"],
    ["Nueva Zelanda", "Bélgica"],
    ["Egipto", "Irán"]
  ],
  "H" => [
    ["España", "Cabo Verde"],
    ["Arabia Saudita", "Uruguay"],
    ["España", "Arabia Saudita"],
    ["Uruguay", "Cabo Verde"],
    ["Uruguay", "España"],
    ["Cabo Verde", "Arabia Saudita"]
  ],
  "I" => [
    ["Francia", "Senegal"],
    ["Irak", "Noruega"],
    ["Francia", "Irak"],
    ["Noruega", "Senegal"],
    ["Noruega", "Francia"],
    ["Senegal", "Irak"]
  ],
  "J" => [
    ["Argentina", "Argelia"],
    ["Austria", "Jordania"],
    ["Argentina", "Austria"],
    ["Jordania", "Argelia"],
    ["Jordania", "Argentina"],
    ["Argelia", "Austria"]
  ],
  "K" => [
    ["Portugal", "República Democrática del Congo"],
    ["Uzbekistán", "Colombia"],
    ["Portugal", "Uzbekistán"],
    ["Colombia", "República Democrática del Congo"],
    ["Colombia", "Portugal"],
    ["República Democrática del Congo", "Uzbekistán"]
  ],
  "L" => [
    ["Inglaterra", "Croacia"],
    ["Ghana", "Panamá"],
    ["Inglaterra", "Ghana"],
    ["Panamá", "Croacia"],
    ["Panamá", "Inglaterra"],
    ["Croacia", "Ghana"]
  ]
}

match_number = 1

matches_by_group.each do |group_name, pairings|
  group = groups[group_name]

  pairings.each do |home_country_name, away_country_name|
    home_team = Team.find_by!(country_name: home_country_name)
    away_team = Team.find_by!(country_name: away_country_name)

    Match.create!(
      stage: "group_stage",
      group: group,
      home_team: home_team,
      away_team: away_team,
      played: false,
      match_number: match_number
    )

    match_number += 1
  end
end

puts "Datos iniciales creados correctamente."
puts "Grupos creados: #{Group.count}"
puts "Selecciones creadas: #{Team.count}"
puts "Partidos de fase de grupos creados: #{Match.where(stage: 'group_stage').count}"