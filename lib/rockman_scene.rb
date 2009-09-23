require "sprite/rockman"
require "sprite/smallblock"
require "sprite/largeblock"
require "sprite/goblin"
require "stage/bg"

class RockmanScene < Scene::Base
  def init
    @bg = Stage::Bg.new
    create_blocks
    @rockman = Sprite::Rockman.new
    @rockman.blocks = @blocks
    set_camera_position(@rockman)
  end

  def set_camera_position(target)
    x = target.x - (screen.w) / 2
    if x < 0
      $camera_x = 0
    else
      $camera_x = x
    end
  end

  def create_blocks
    @blocks = []
    @blocks << Sprite::SmallBlock.new(0, 128)
    @blocks << Sprite::SmallBlock.new(16, 128)
    @blocks << Sprite::LargeBlock.new(32, 128)
    @blocks << Sprite::SmallBlock.new(64, 128)
    @blocks << Sprite::SmallBlock.new(80, 128)
    @blocks << Sprite::SmallBlock.new(96, 128)
    @blocks << Sprite::SmallBlock.new(112, 128)
    @blocks << Sprite::LargeBlock.new(128, 128)
    @blocks << Sprite::SmallBlock.new(160, 128)
    @blocks << Sprite::SmallBlock.new(176, 128)
    @blocks << Sprite::SmallBlock.new(192, 128)
    @blocks << Sprite::SmallBlock.new(208, 128)
    @blocks << Sprite::LargeBlock.new(224, 128)
    @blocks << Sprite::SmallBlock.new(399, 96)
    @blocks << Sprite::SmallBlock.new(415, 96)
    @blocks << Sprite::SmallBlock.new(575, 96)
    @blocks << Sprite::SmallBlock.new(750, 80)
    @blocks << Sprite::SmallBlock.new(910, 96)
    @blocks << Sprite::SmallBlock.new(1071, 96)
    @blocks << Sprite::SmallBlock.new(1087, 96)
    @blocks << Sprite::SmallBlock.new(1093, 96)

    @blocks << Sprite::Goblin.new(288, 112)
    @blocks << Sprite::Goblin.new(463, 128)
    @blocks << Sprite::Goblin.new(623, 64)
    @blocks << Sprite::Goblin.new(798, 96)
    @blocks << Sprite::Goblin.new(958, 96)
  end

  def update
    @bg.update
    @blocks.each {|b| b.update}
    @rockman.update
    set_camera_position(@rockman)
  end

  def render
    @bg.render
    @blocks.each {|b| b.render}
    @rockman.render
  end
end

