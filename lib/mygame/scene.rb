require 'mygame'

module MyGame
  #= Scene
  #
  #�V�[���ƃV�[���J�ڂ���������ȈՃt���[�����[�N�ł��B
  #Scene::Base �N���X���p�����ăV�[�����쐬���܂��B
  #
  #�V�[���N���X�ɂ� init, quit, update, render ���\�b�h���`���Ă��������i�g��Ȃ����\�b�h�͏ȗ��\�j�B
  #�V�[���N���X�� Scene.main_loop ���\�b�h���g���Ď��s���܂��B
  #
  # Scene.main_loop MyScene             # �V�[���N���X�����s
  #
  #2 �̃V�[���N���X���쐬���A Title �V�[������ Game �V�[���֑J�ڂ���T���v���ł��B
  #
  # require 'mygame/boot'
  # 
  # class Title < Scene::Base           # �^�C�g���V�[��
  #   def init                          # �����������i�V�[���������ɌĂ΂��j
  #     @image = Image.new("sample.png")
  #   end
  # 
  #   def quit                          # �I�������i�V�[���I�����ɌĂ΂��j
  #   end
  # 
  #   def update                        # �X�V�����i���t���[���Ă΂��j
  #     if new_key_pressed?(Key::SPACE)
  #       self.next_scene = Game        # Game �V�[���֑J��
  #     end
  #     if new_key_pressed?(Key::Q)
  #       self.next_scene = Scene::Exit # �v���O�����̏I��
  #     end
  #   end
  # 
  #   def render                        # �`�揈���i���t���[���Ă΂��j
  #     @image.render
  #   end
  # end
  # 
  # class Game < Scene::Base            # �Q�[���V�[��
  #   # �Q�[���V�[����`�i���j
  # end
  # 
  # Scene.main_loop Title               # �V�[���N���X�����s
  #
  module Scene
    #���̃N���X�� next_scene �ɗ^����ƃv���O�������I�����܂��B
    #
    # self.next_scene = MyGame::Scene::Exit
    class Exit; end

    #�V�[���̃N���X�̃X�[�p�[�N���X�ł��B
    #���̃N���X���p�����ăV�[�����쐬���Ă��������B
    #
    #��̓I�Ȏg������ Scene �̕ł��Q�Ƃ��Ă��������B
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

      # �������������s�����\�b�h�B�T�u�N���X�ōĒ�`���Ă��������B
      def init
      end

      # �I���������s�����\�b�h�B�T�u�N���X�ōĒ�`���Ă��������B
      def quit
      end

      # �X�V�������s�����\�b�h�B�T�u�N���X�ōĒ�`���Ă��������B
      def update
      end

      # �`�揈�����s�����\�b�h�B�T�u�N���X�ōĒ�`���Ă��������B
      def render
      end
    end

    #�V�[���N���X�����s���܂��B
    #
    #  Scene.main_loop MyScene             # �V�[���N���X�����s
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
