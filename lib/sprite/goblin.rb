require "sprite/root_sprite"

module Sprite
  class Goblin < RootSprite
    def animations
      {
        :light => [8, [[0, 0, 80, 80],
                       [80, 0, 80, 80]]],
      }
    end

    def init
      start_action :light
    end

    def start_action(action)
      @action = action

      a = "#{action}".to_sym
      @image.start_animation a
    end

    def image_offset
      [0, 0]
    end

    def update
      super
    end
  end
end
