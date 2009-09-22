require "sprite/rockman"
require "sprite/smallblock"
require "sprite/largeblock"
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
    @blocks << Sprite::SmallBlock.new(16, 128)
    @blocks << Sprite::SmallBlock.new(32, 128)
    @blocks << Sprite::SmallBlock.new(48, 128)
    @blocks << Sprite::SmallBlock.new(64, 128)
    @blocks << Sprite::SmallBlock.new(80, 128)
    @blocks << Sprite::SmallBlock.new(96, 128)
    @blocks << Sprite::SmallBlock.new(112, 128)
    @blocks << Sprite::SmallBlock.new(128, 128)
    @blocks << Sprite::SmallBlock.new(144, 128)
    @blocks << Sprite::SmallBlock.new(160, 128)
    @blocks << Sprite::SmallBlock.new(176, 128)
    @blocks << Sprite::SmallBlock.new(192, 128)
    @blocks << Sprite::SmallBlock.new(208, 128)
    @blocks << Sprite::LargeBlock.new(224, 128)
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

