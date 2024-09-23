def dictionary_array_generator(rows, columns, origin_array)
    
    if origin_array.length != 0 
        while rows < origin_array.length
            origin_array.delete_at(rows - origin_array.length)
        end

        while columns < origin_array[0].length
            i = 0
            origin_array_columns = origin_array[0].length
            while i < origin_array.length
                origin_array[i].delete_at(columns-origin_array_columns)
                i += 1
            end
        end
    end

    i = 0
    while i < rows
        if origin_array[i] == nil
            origin_array << []
        end
        j = 0
        while j < columns
            if origin_array[i][j] == nil
                element_dictionary = { # Måste skapa en ny dictionary i taget för att de ska räknas som olika dictionaries. Annars räknas de alla som samma, alltså om man ändrar key för en så ändras samma key för alla.
                    element_index: 0 # Lägg till mer här sen med tiden
                }
                origin_array[i] << element_dictionary
            end
            j += 1
        end
        i += 1
    end
    return origin_array
end

def sprite_array_generator(dictionary_array, origin_array)
    rows = dictionary_array.length
    columns = dictionary_array[0].length

    if origin_array.length != 0 
        while rows < origin_array.length
            j = 0
            while j < origin_array[0].length
                if origin_array[(rows-origin_array.length)][j] != nil
                    origin_array[(rows-origin_array.length)][j].remove
                end
                j += 1
            end
            origin_array.delete_at(rows-origin_array.length)
        end

        while columns < origin_array[0].length
            i = 0
            origin_array_columns = origin_array[0].length
            while i < origin_array.length
                if origin_array[i][(columns-origin_array_columns)] != nil
                    origin_array[i][(columns-origin_array_columns)].remove
                end
                origin_array[i].delete_at(columns-origin_array_columns)
                i += 1
            end
        end
    end

    i = 0
    while i < rows
        if origin_array[i] == nil
            origin_array << []
        end
        j = 0
        while j < columns
            if dictionary_array[i][j][:element_index] == 0
                if origin_array[i][j] != nil 
                    origin_array[i][j].remove
                end
                origin_array[i][j] = nil
            elsif dictionary_array[i][j][:element_index] == 1
                if origin_array[i][j] == nil 
                    origin_array[i][j] = Square.new(color: 'black')
                end
            end # Lägg till mer här sen
            j += 1
        end
        i += 1
    end
    return origin_array
end

def draw_map_on_screen(grid_box, sprite_array, scaler)
    rows = sprite_array.length
    columns = sprite_array[0].length
    grid_box.width = columns * scaler
    grid_box.height = rows * scaler

    i = 0
    while i < rows
        j = 0
        while j < columns
            if sprite_array[i][j] != nil
                sprite_array[i][j].y = grid_box.y + i * scaler
                sprite_array[i][j].x = grid_box.x + j * scaler
                sprite_array[i][j].size = scaler
            end
            j += 1
        end
        i += 1
    end
    # kanske behöver returnera grid_box här 
end

def mouse_grid_position_func(dictionary_array, grid_box, mousex, mousey)
    rows = dictionary_array.length
    columns = dictionary_array[0].length
    scaler = grid_box.width/columns

    relative_y = mousey - grid_box.y
    relative_x = mousex - grid_box.x

    j = (relative_y - relative_y%scaler)/scaler
    i = (relative_x - relative_x%scaler)/scaler
    
    j = j.round()
    i = i.round() #Av anledningar, typ 0.0003/3 situationen, kanske pga att inte alla decimaler hamnar med etc, blir det lite rounding errors som man måste parrera för här 
    
    # Så att den aldrig kan vara utanför grid_box
    if j >= rows
        j = rows - 1
    elsif j < 0
        j = 0
    end
    if i >= columns
        i = columns - 1
    elsif i < 0
        i = 0
    end


    return [j, i]
end

def click_collision(mousex, mousey, object)
    if mousex > object.x && mousex < object.x + object.width
        if mousey > object.y && mousey < object.y + object.height
            return true
        end
    end
    return false
end 

def mouse_obj_relation(mousex, mousey, obj)
    relative_x = obj.x - mousex
    relative_y = obj.y - mouse_y
    return [relative_x, relative_y]
end

def create_file_array(dictionary_array, player_row, player_column)
    output_array = []    
    dictionary_array.each do |row|
        temp_string = ""
        row.each do |grid_position_hash|
            hash_value_array = grid_position_hash.values
            temp_string = temp_string + hash_value_array.join("") + ","
        end
        temp_string.slice!(-1)
        output_array << temp_string
    end
    output_array << "#{player_row},#{player_column}"
    return output_array
end

def read_file_array(file_array)
    i = 0
    output_array = []
    while i < file_array.length - 1
        row_with_data = file_array[i].chomp
        row_array = row_with_data.split(",")
        temp_array = []
        row_array.each do |hash_values_string|
            dictionary = {
                element_index: hash_values_string[0].to_i
                # lägg till mer här sen (och kanske ändra denna funktionen?)
            }
            temp_array << dictionary
        end
        output_array << temp_array
        i += 1
    end
    player_position_array = file_array[i].chomp.split(",")
    player_row = player_position_array[0].to_i
    player_column = player_position_array[1].to_i
    return [output_array, player_row, player_column]
end



# game.rb -------------------------------------

def accelerate(velocity, acceleration, cap)
    if velocity + acceleration > cap
        velocity = cap
    elsif velocity + acceleration < -cap
        velocity = -cap
    else
        velocity = (velocity + acceleration)
    end
    return velocity
end

def collision(obj1, obj1_x, obj1_y, obj2, obj2_x, obj2_y)
    if obj2_y + obj2.height > obj1_y && obj2_y < obj1_y + obj1.height
        if  obj2_x + obj2.width > obj1_x && obj2_x < obj1_x + obj1.width
            return true
        end
    end
    return false
end

def wall_collision(player, wall, x_velocity, y_velocity)
    new_player_x = player.x + x_velocity
    new_player_y = player.y + y_velocity
    if collision(player, new_player_x, new_player_y, wall, wall.x, wall.y)
        if collision(player, new_player_x, player.y, wall, wall.x, wall.y)
            if x_velocity > 0
                x_velocity = wall.x - (player.x + player.width)
            else 
                x_velocity = (wall.x + wall.width) - player.x
            end
        end
        if collision(player, player.x, new_player_y, wall, wall.x, wall.y)
            if y_velocity > 0
                y_velocity = wall.y - (player.y + player.height)
            else 
                y_velocity = (wall.y + wall.height) - player.y
            end
        end
        if !collision(player, new_player_x, player.y, wall, wall.x, wall.y) && !collision(player, player.x, new_player_y, wall, wall.x, wall.y)
            if x_velocity > y_velocity # Funkar för någon logisk anledning
                if x_velocity > 0
                    x_velocity = wall.x - (player.x + player.width)
                else 
                    x_velocity = (wall.x + wall.width) - player.x
                end
            else
                if y_velocity > 0
                    y_velocity = wall.y - (player.y + player.height)
                else 
                    y_velocity = (wall.y + wall.height) - player.y
                end
            end
        end
    end
    return [x_velocity, y_velocity]
end

# def wall_sliding()