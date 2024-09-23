require_relative "helpfunc.rb"

# @background= Image.new('sprites\background.png',
#     width: 1920,
#     height: 1080
# )


file_array = File.readlines("saved_stages/Stage #{Dir.glob("saved_stages/*").length}.txt")
output_array = read_file_array(file_array)
@dictionary_array = output_array[0]
@player_row = output_array[1]
@player_column = output_array[2]
@grid_box = Rectangle.new(x: 0, y: 0, color: 'blue')
@sprite_array = sprite_array_generator(@dictionary_array, [])

draw_map_on_screen(@grid_box, @sprite_array, 60)

@grid_box.x = 960 - 60*@player_column
@grid_box.y = 540 - 60*@player_row
if @grid_box.x > 0
    @grid_box.x = 0
elsif @grid_box.x + @grid_box.width < 1920
    @grid_box.x = 1920 - @grid_box.width
end
if @grid_box.y > 0
    @grid_box.y = 0
elsif @grid_box.y + @grid_box.height < 1080
    @grid_box.y = 1080 - @grid_box.height
end

@player= Square.new(
    size: 60,
    x: @grid_box.x + 60*@player_column,
    y: @grid_box.y + 60*@player_row,
    color: 'white' 
)



@y_velocity = 0
@fall_speed_cap = 30
@gravity = 1
@jump_speed = -25
@fast_fall_speed = 15


@x_velocity = 0
@move_speed_cap = 9
@move_acceleration = 1
@right = 0
@left = 0
@friction = 0.5

@playerstate = {
    jumping: false,
    on_ground: false,
    wall_clinging: false
}

