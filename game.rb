
require 'ruby2d'
require_relative "setup.rb"
require_relative "helpfunc.rb"

set width: 1920
set height: 1080
set fullscreen: true

on :key_down do |event|
    case event.key
        when 'd'
            @right = 1
        when 'a'
            @left = -1
        when 'w'
            if @playerstate[:on_ground] || @playerstate[:wall_clinging]
                @y_velocity = @jump_speed
                # if @wall_clinging
                #     if @right == 1
                #         @x_velocity -= @move_speed
                #     elsif @left == -1
                #         @x_velocity += @move_speed
                #     end    
                # end
            end
        when 's'
            # if @jumping && @y_velocity < @fast_fall_speed
            #     @y_velocity = @fast_fall_speed
            # end
    end     
end

on :key_up do |event|
    case event.key
        when 'd'
            @right = 0
        when 'a'
            @left = 0
        when 'w'
            if @y_velocity < @jump_speed/5 
                @y_velocity = @jump_speed/5
            end
    end     
end

update do
    
    x_dir = @right + @left
    @x_velocity = accelerate(@x_velocity, x_dir*@move_acceleration, @move_speed_cap)


    # Ha en samling med wall_jumping = true där alla variabler används för att bestämma @y_velocity
    @y_velocity = accelerate(@y_velocity, @gravity, @fall_speed_cap)

    @playerstate[:on_ground] = false # False until proven true at least once
    @playerstate[:wall_clinging] = false

    @sprite_array.each do |row|
        row.each do |position|
            if position != nil
                
                output_array = wall_collision(@player, position, @x_velocity, @y_velocity)
                new_x_velocity = output_array[0]
                new_y_velocity = output_array[1]

                if @y_velocity > 0 && new_y_velocity == 0 # On ground?
                    @playerstate[:on_ground] = true
                elsif @x_velocity != 0 && new_x_velocity == 0 # Clinging to wall?
                    @playerstate[:wall_clinging] = true
                end

                @x_velocity = new_x_velocity 
                @y_velocity = new_y_velocity
            end
        end
    end
        

    # Plot armor kod vet inte varför detta funkar så bra men vi kör på det för nu
    if @grid_box.x - @x_velocity > 0 || @grid_box.x + @grid_box.width - @x_velocity < Window.width
        @player.x += @x_velocity
    else
        if @player.x > Window.width/2 - @player.width/2 && @player.x < Window.width/2 + @player.width/2
            @grid_box.x -= @x_velocity
        else
            @player.x += @x_velocity
        end
    end
    if @grid_box.y - @y_velocity > 0 || @grid_box.y + @grid_box.height - @y_velocity < Window.height
        @player.y += @y_velocity
    else
        if @player.y > Window.height/2 - @player.height/2 && @player.y < Window.height/2 + @player.height/2
            @grid_box.y -= @y_velocity
        else
            @player.y += @y_velocity
        end
    end
    draw_map_on_screen(@grid_box, @sprite_array, 60)

end

show