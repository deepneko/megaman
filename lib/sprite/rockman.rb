require "sprite/root_sprite"

module Sprite
  class Rockman < RootSprite
    attr_writer :blocks
    START_HORIZON = 0
    DEFAULT_X = 110
    DEFAULT_Y = -10 # 128 - rockman_height
    LAND_Y = 400

    def image_size
      [41, 23]
    end

    def image_offset
      [-@image.w/2, -@image.h]
    end

    def init
      @vy = @vx = 0
      self.x = DEFAULT_X
      self.y = DEFAULT_Y
      @last_y = self.y
      start_action :stand, :right
    end

    def animations
      {
        :stand_right => [0, [[0, 0, 41, 23]]],
        :stand_left => [0, [[50, 0, 41, 23]]],
        :move_right => [8, [[0, 48, 41, 23],
                            [0, 148, 41, 23],
                            [0, 98, 41, 23],
                            [0, 148, 41, 23]]],
        :move_left => [8, [[50, 48, 41, 23],
                           [50, 148, 41, 23],
                           [50, 98, 41, 23],
                           [50, 148, 41, 23]]],
        :jump_right => [0, [[0,200, 41, 30]]],
        :jump_left => [0, [[50, 200, 41, 30]]],
        :fall_right => [0, [[0, 200, 41, 30]]],
        :fall_left => [0, [[50, 200, 41, 30]]],
      }
    end

    def temp_img
      @shot_stand_right = @img.copy_rect(0, 25, 31, 23)
      @shot_stand_left = @img.copy_rect(35, 25, 31, 23)
      @shot_move1_right = @img.copy_rect(0, 75, 31, 23)
      @shot_move1_left = @img.copy_rect(35, 75, 31, 23)
      @shot_move2_right = @img.copy_rect(0, 125, 31, 23)
      @shot_move2_left = @img.copy_rect(35, 125, 31, 23)
      @shot_move3_right = @img.copy_rect(0, 175, 31, 23)
      @shot_move3_left = @img.copy_rect(35, 175, 31, 23)

      @jump_right = @img.copy_rect(75, 0, 29, 30)
      @jump_left = @img.copy_rect(105, 0, 29, 30)
      @jump_shot_right = @img.copy_rect(75, 30, 29, 30)
      @jump_shot_left = @img.copy_rect(105, 30, 29, 30)

      @damage_right.push(@img.copy_rect(75, 60, 26, 28))
      @damage_left = @img.copy_rect(105, 60, 26, 28)
    end

    def start_action(action, direction = @direction)
      @action = action
      @direction = direction

      a = "#{action}_#{direction}".to_sym
      @image.start_animation a

      @vy = -10 if action == :jump
      @vy = DEFAULT_Y if action == :stand
    end

    def control
      press_left_or_right = (key_pressed? Key::RIGHT or key_pressed? Key::LEFT)
      unless jumping?
        start_action(:move, :right) if key_pressed? Key::RIGHT
        start_action(:move, :left) if key_pressed? Key::LEFT
        start_action(:stand) if move? and !press_left_or_right
        start_action(:jump) if key_pressed? Key::B
      else
        start_action(:fall) if @vy > 1
        @vx += 0.1 if @vx < 2 and key_pressed? Key::RIGHT
        @vx -= 0.1 if @vx < -2 and key_pressed? Key::LEFT
        @vx *= 0.95 unless press_left_or_right
      end
    end

    def move
      case @action
      when :move
       if move?
         @vx = 1 if @direction == :right
         @vx = -1 if @direction == :left
         @x += @vx
         if @x <= START_HORIZON
           @x = START_HORIZON
         end
       end
      when :jump, :fall
        @vy += 0.5
        self.x += @vx
        self.y += @vy
        if @y >= LAND_Y
          start_action :stand
          @y = LAND_Y
        end
      else
        @vx = @vy = 0
      end
    end

    def move?
      @action == :move
    end

    def jumping?
      @action == :jump or @action == :fall
    end

    def stand_on_block
      @blocks.each do |block|
        if hit_block?(block)
          start_action :stand
          self.y = block.y
          break
        end
      end
      @last_y = y
    end

    def fall_from_block
      return if jumping? or y >= LAND_Y
      return if @blocks.any? {|b| b.y == y and hit_x?(b)}
      start_action(:fall)
    end

    def hit_block?(block)
      hit_x?(block) and @last_y < block.y and y >= block.y
    end

    def hit_x?(target)
      dx = target.w / 2
      x >= target.x - dx and x <= target.x + dx
    end

    def update
      super
      fall_from_block
      stand_on_block
    end
  end
end
