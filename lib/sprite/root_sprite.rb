module Sprite
  class RootSprite
    attr_accessor :x, :y, :w, :h

    def initialize(x = 0, y = 0)
      @x, @y = x, y
      create_img
      @image.add_animation(animations) if animations
      init
    end

    def create_img
      @image = TransparentImage.new(image_fname)
      @image.w, @image.h = image_size
      @image.offset_x, @image.offset_y = image_offset
    end

    def image_fname
      "../img/#{self.class.name.downcase.sub(/sprite::/,"")}.png"
    end

    def image_size
      [w, h]
    end

    def image_offset
      [-@image.w/2, -@image.h/2]
    end

    def w
      @image.w
    end

    def h
      @image.h
    end

    def init
    end

    def animations
    end

    def update
      control
      move
      @image.update
    end

    def control
    end

    def move
    end

    def render
      @image.x = @x - $camera_x
      @image.y = @y - $camera_y
      @image.render
    end
  end
end
