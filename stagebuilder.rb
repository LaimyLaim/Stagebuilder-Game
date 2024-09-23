
# Blastzone

require 'ruby2d'
require_relative "helpfunc.rb"

# File
file_array = []

#Mått ---------------------------------------------------------
set width: 1920
set height: 1080
set fullscreen: true

columns = Window.width/60 # 32 columns
rows = Window.height/60 # 18 rows

scaler = 50.0 # För att passa in i HUDen

# Där man kan klicka för att placera ut block ------------------
builder_window = Rectangle.new(x:160, y: 50, height: 899, width: 1599, color: 'red') #borde typ skriva om lite kod med denna nya variabel
builder_window.remove

# Hud stuff ----------------------------------------------------
hud = Image.new('sprites\stage_builder_hud.png',
    width: 1920,
    height: 1080,
    z: 1
)

horizontal_scrollbar = Rectangle.new(x:449, y: 15, z: hud.z + 1, height: 20, width: 1020, color: 'gray', opacity: 1)
vertical_scrollbar = Rectangle.new(x:1831, y: 176, z: hud.z + 1, height: 647, width: 20, color: 'gray', opacity: 1)

element_1_btn = Square.new(size: 91, color: 'white', z: hud.z + 1, x: 211, y: 969, opacity: 0.3)
element_2_btn = Square.new(size: 91, color: 'white', z: hud.z + 1, x: 314, y: 969, opacity: 0.3)
column_add_btn = Square.new(size: 35, color: 'white', z: hud.z + 1, x: 1451, y: 978, opacity: 0.3)
column_remove_btn = Square.new(size: 35, color: 'white', z: hud.z + 1, x: 1451, y: 1018, opacity: 0.3)
row_add_btn = Square.new(size: 35, color: 'white', z: hud.z + 1, x: 1707, y: 978, opacity: 0.3)
row_remove_btn = Square.new(size: 35, color: 'white', z: hud.z + 1, x: 1707, y: 1018, opacity: 0.3)
save_btn = Rectangle.new(width: 85, height: 78, color: 'white', z: hud.z + 1, x: 38, y: 656, opacity: 0.3)
load_btn = Rectangle.new(width: 85, height: 78, color: 'white', z: hud.z + 1, x: 38, y: 484, opacity: 0.3)

button_array = [element_1_btn, element_2_btn, row_add_btn, row_remove_btn, column_add_btn, column_remove_btn, save_btn, load_btn]

# Setting up the map variables ---------------------------------

dictionary_array = [] # Om man redan hade en mapp sedan innan
dictionary_array = dictionary_array_generator(rows, columns, dictionary_array)

# Setting up "draw the map on screen" variables ----------------

sprite_array = []

grid_box = Rectangle.new(x: 160, y: 50, height: rows * scaler, width: columns * scaler, z: hud.z - 4, color: 'blue') # Där man placerar alla block

grid_lines = {
    rows_array: [],
    columns_array: []
}

player = Sprite.new('sprites\player.png',
    width: 40,
    height: 70,
    z: grid_box.z + 3
)
player_column = 5
player_row = 5
move_player = false


# Setting up user variables -------------------------------------

mousex = 0
mousey = 0
delta_mousex = 0
delta_mousey = 0
mouse_held = false
drawing = false
removing = false
ver_scrolling = false
hor_scrolling = false
element_index = 1
mouse_grid_position = {}

# input ----------------------------------------------------------

on :mouse_move do |event|
    # Change in the x and y coordinates
    delta_mousex = event.delta_x
    delta_mousey = event.delta_y

    # Position of the mouse
    mousex = event.x
    mousey = event.y
end
  

on :mouse_down do |event|
    case event.button
    when :left

        mouse_held = true
        if click_collision(mousex, mousey, player)
            move_player = true
        elsif click_collision(mousex, mousey, horizontal_scrollbar)
            hor_scrolling = true
        elsif click_collision(mousex, mousey, vertical_scrollbar)
            ver_scrolling = true
        elsif click_collision(mousex, mousey, element_1_btn)
            element_index = 1
        elsif click_collision(mousex, mousey, element_2_btn)
            element_index = 2
        elsif click_collision(mousex, mousey, row_add_btn)
            rows += 1
        elsif click_collision(mousex, mousey, row_remove_btn) && rows > 18
            rows -= 1
        elsif click_collision(mousex, mousey, column_add_btn)
            columns += 1
        elsif click_collision(mousex, mousey, column_remove_btn) && columns > 32
            columns -= 1
        elsif click_collision(mousex, mousey, save_btn)
            file_array = create_file_array(dictionary_array, player_row, player_column)
            file = File.open("saved_stages/Stage #{Dir.glob("saved_stages/*").length + 1}.txt", "w")
                file_array.each do |row_with_data|
                    file.puts(row_with_data)
                end
            file.close
        elsif click_collision(mousex, mousey, load_btn)
            file_array = File.readlines("saved_stages/Stage #{Dir.glob("saved_stages/*").length}.txt")
            output_array = read_file_array(file_array)
            dictionary_array = output_array[0]
            rows = dictionary_array.length
            columns = dictionary_array[0].length
            player_row = output_array[1]
            player_column = output_array[2]
        elsif click_collision(mousex, mousey, builder_window)
            drawing = true
        end

    when :middle
  
    when :right
        mouse_held = true
        removing = true
    end
end

on :mouse_up do |event|
    case event.button
    when :left
        mouse_held = false
        drawing = false
        ver_scrolling = false
        hor_scrolling = false
        move_player = false
    when :middle

    when :right
        mouse_held = false
        removing = false
    end
end

on :mouse_scroll do |event|
    if event.delta_y == -1
        if scaler + 0.05*60 < 1.50*60
            scaler += 0.05*60
        else
            scaler = 1.50*60 
        end
    elsif event.delta_y == 1
        if scaler - 0.05*60 > 50.0
            scaler -= 0.05*60
        else
            scaler = 50.0
        end
    end
end

update do
    
    # Struktur: 1. ta user input (mesta händer i input redan) 2. ändra dictionary variabler, map variabler, 3. draw on screen

    # vilken ruta muspekaren befinner sig i
    output_array = mouse_grid_position_func(dictionary_array, grid_box, mousex, mousey)
    mouse_grid_position[:rows] = output_array[0]
    mouse_grid_position[:columns] = output_array[1]


    if mouse_held
        if hor_scrolling
            horizontal_scrollbar.x += delta_mousex
            delta_mousex = 0
        elsif ver_scrolling
            vertical_scrollbar.y += delta_mousey
            delta_mousey = 0
        elsif removing 
            if click_collision(mousex, mousey, builder_window)
                dictionary_array[mouse_grid_position[:rows]][mouse_grid_position[:columns]][:element_index] = 0
            end 
        elsif drawing 
            if click_collision(mousex, mousey, builder_window)
                dictionary_array[mouse_grid_position[:rows]][mouse_grid_position[:columns]][:element_index] = element_index
            end  
        end
    end
    

    # Detta går lite emot filosofin men i guess att det är fine för nu
    grid_box.width = columns*scaler
    grid_box.height = rows*scaler

    horizontal_scrollbar.width = ((Window.width - 320)/grid_box.width)*1020
    vertical_scrollbar.height = ((Window.height - 180)/grid_box.height)*647

    # Kollar att scrollbar inte går över gränsen
    if horizontal_scrollbar.x + horizontal_scrollbar.width > 1469
        horizontal_scrollbar.x = 1469 - horizontal_scrollbar.width
    elsif horizontal_scrollbar.x < 449
        horizontal_scrollbar.x = 449
    end
    if vertical_scrollbar.y + vertical_scrollbar.height > 822
        vertical_scrollbar.y = 822 - vertical_scrollbar.height
    elsif vertical_scrollbar.y < 176
        vertical_scrollbar.y = 176
    end

    if 1469 - 449 - horizontal_scrollbar.width == 0
        grid_box.x = 160
    else
        grid_box.x = -((horizontal_scrollbar.x - 449)/(1469 - 449 - horizontal_scrollbar.width))*(grid_box.width - 1600) + 160
    end
    if 822 - 175 - vertical_scrollbar.height == 0
        grid_box.y = 50
    else
        grid_box.y = -((vertical_scrollbar.y - 176)/(822 - 175 - vertical_scrollbar.height))*(grid_box.height - 900) + 50
    end


    dictionary_array = dictionary_array_generator(rows, columns, dictionary_array)
    sprite_array = sprite_array_generator(dictionary_array, sprite_array)
    draw_map_on_screen(grid_box, sprite_array, scaler)


    player.width = scaler
    player.height = 2*scaler
    player.x = grid_box.x + player_column*scaler
    player.y = grid_box.y + player_row*scaler
    if move_player   
        player.x = grid_box.x + mouse_grid_position[:columns]*scaler
        player.y = grid_box.y + mouse_grid_position[:rows]*scaler
        player_column = mouse_grid_position[:columns]
        player_row = mouse_grid_position[:rows]
    end


    button_array.each do |button| 
        if click_collision(mousex, mousey, button)
            if mouse_held
                button.remove
            else
                button.add
            end
        else
            button.remove
        end
    end

end

show