$LOAD_PATH.unshift File.expand_path("../lib", File.dirname(__FILE__))

require "mygame/boot"
require "rockman_scene"

$camera_x = $camera_y = 0
Scene.main_loop RockmanScene
