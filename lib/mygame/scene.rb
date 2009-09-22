require 'mygame'

module MyGame
  #= Scene
  #
  #シーンとシーン遷移を実現する簡易フレームワークです。
  #Scene::Base クラスを継承してシーンを作成します。
  #
  #シーンクラスには init, quit, update, render メソッドを定義してください（使わないメソッドは省略可能）。
  #シーンクラスは Scene.main_loop メソッドを使って実行します。
  #
  # Scene.main_loop MyScene             # シーンクラスを実行
  #
  #2 つのシーンクラスを作成し、 Title シーンから Game シーンへ遷移するサンプルです。
  #
  # require 'mygame/boot'
  # 
  # class Title < Scene::Base           # タイトルシーン
  #   def init                          # 初期化処理（シーン生成時に呼ばれる）
  #     @image = Image.new("sample.png")
  #   end
  # 
  #   def quit                          # 終了処理（シーン終了時に呼ばれる）
  #   end
  # 
  #   def update                        # 更新処理（毎フレーム呼ばれる）
  #     if new_key_pressed?(Key::SPACE)
  #       self.next_scene = Game        # Game シーンへ遷移
  #     end
  #     if new_key_pressed?(Key::Q)
  #       self.next_scene = Scene::Exit # プログラムの終了
  #     end
  #   end
  # 
  #   def render                        # 描画処理（毎フレーム呼ばれる）
  #     @image.render
  #   end
  # end
  # 
  # class Game < Scene::Base            # ゲームシーン
  #   # ゲームシーン定義（略）
  # end
  # 
  # Scene.main_loop Title               # シーンクラスを実行
  #
  module Scene
    #このクラスを next_scene に与えるとプログラムが終了します。
    #
    # self.next_scene = MyGame::Scene::Exit
    class Exit; end

    #シーンのクラスのスーパークラスです。
    #このクラスを継承してシーンを作成してください。
    #
    #具体的な使い方は Scene の頁を参照してください。
    class Base
      attr_accessor :next_scene
      attr_reader :frame_counter
      def initialize
        @next_scene = nil
        @frame_counter = 0
        init
      end

      def __quit
        quit
        MyGame.init_events
        Font.clear_cache
        Image.clear_cache
        Wave.clear_cache
      end
      private :__quit

      def __update
        update
        @frame_counter += 1
      end
      private :__update

      def __render
        render
      end
      private :__render

      # 初期化処理を行うメソッド。サブクラスで再定義してください。
      def init
      end

      # 終了処理を行うメソッド。サブクラスで再定義してください。
      def quit
      end

      # 更新処理を行うメソッド。サブクラスで再定義してください。
      def update
      end

      # 描画処理を行うメソッド。サブクラスで再定義してください。
      def render
      end
    end

    #シーンクラスを実行します。
    #
    #  Scene.main_loop MyScene             # シーンクラスを実行
    def self.main_loop(scene_class, fps = 60, step = 1)
      MyGame.create_screen
      scene = scene_class.new
      default_step = step
      MyGame.main_loop(fps) do
        if MyGame.new_key_pressed?(Key::PAGEDOWN)
          step += 1
          MyGame.fps = fps * default_step / step
        end
        if MyGame.new_key_pressed?(Key::PAGEUP) and step > default_step
          step -= 1
          MyGame.fps = fps * default_step / step
        end
        step.times do
          break if scene.next_scene
          scene.__send__ :__update
        end
        scene.__send__ :__render
        if scene.next_scene
          scene.__send__ :__quit
          break if Exit == scene.next_scene
          scene = scene.next_scene.new
        end
      end
    end
  end
end
