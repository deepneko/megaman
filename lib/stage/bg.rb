module Stage
  class Bg
    def initialize
      @stage = Image.new("../img/stage1.png")
    end

    def update
    end

    def render
      @stage.x = -$camera_x
      @stage.y = -$camera_y
      @stage.render
    end
  end
end
