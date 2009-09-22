require 'sdl'
#
#= MyGame ���t�@�����X�}�j���A��
#
#Copyright:: Copyright (C) Dan Yamamoto, 2007. All rights reserved.
#License::   Ruby ���C�Z���X�ɏ���
#
#MyGame �� Ruby/SDL �����b�v�����Q�[���J���p�̃��C�u�����ł��B
#�u�V���v���ȃQ�[���J���v��ڎw���ĊJ������Ă��܂��B
#
#=== �O���T�C�g�ւ̃����N
#
#* MyGame[http://dgames.jp/ja/projects/mygame/] �c�c MyGame �̃T�C�g
#* Ruby/SDL[http://www.kmc.gr.jp/~ohai/rubysdl.html] �c�c Ruby/SDL �̃T�C�g
#
#=== �J������
#
#* 2007-05-25
#  * �h�L�������g�ǋL
#  * ver 0.9.0 �����[�X
#
#* 2007-03-03
#  * �n�b�V���ɂ��L�[���[�h�����I API ����
#
#* 2007-01-07
#  * RDOC �Ń��t�@�����X�쐬
#
#* 2006-12-07
#  * ��{�d�l�Ǝ���������
#
module MyGame
  # = ���ʉ��N���X
  # 
  # ���ʉ��𐧌䂷��N���X�ł��B
  # 
  # ���̃T���v���͌��ʉ� sample.wav ���Đ������ł��B
  # 
  #  require 'mygame/boot'
  #  main_loop do
  #    Wave.play("sample.wav") if new_key_pressed?(Key::SPACE)
  #  end
  # 
  # ���̃T���v���͌��ʉ��I�u�W�F�N�g�������� sample.wav ���Đ������ł��B
  # 
  #  require 'mygame/boot'
  #  wav = Wave.new("sample.wav")
  #  main_loop do
  #    wav.play if new_key_pressed?(Key::SPACE)
  #  end
  # 
  class Wave
    @@wave = {}
    # ���ʉ��I�u�W�F�N�g�𐶐����܂��B
    def initialize(filename, ch = :auto, loop = 1)
      @ch = ch
      @loop = loop
      @filename = filename
      load(filename)
    end

    # ���ʉ������[�h���܂��B
    # WAVE, AIFF, RIFF, OGG, VOC �`���ɑΉ����Ă��܂��B
    def load(filename)
      @@wave[filename] = SDL::Mixer::Wave.load(filename)
    end

    # ���[�h�������ʉ��̃L���b�V�����N���A���܂��B
    def self.clear_cache
      @@wave = {}
    end

    def _loops(loop)
      if loop.nil?
        0
      elsif loop == :loop or loop <= 0
        -1
      else
        loop - 1
      end
    end
    private :_loops

    def _ch(ch)
      if ch.nil? or ch == :auto
        -1
      else
        ch
      end
    end
    private :_ch

    def _play(ch, wave, loop)
      SDL::Mixer.play_channel(_ch(ch), wave, _loops(loop))
    end
    private :_play

    # ���ʉ����Đ����܂��B
    def play(ch = @ch, loop = @loop)
      _play(ch, @@wave[@filename], loop)
    end

    # ���ʉ����Đ����܂��B
    def self.play(*args)
      new(*args).play
    end
  end

  # = ���y�N���X
  #
  # BGM �Ƃ��Ďg�p���鉹�y�t�@�C���𐧌䂷��N���X�ł��B
  #
  class Music < Wave
    # ���y�I�u�W�F�N�g�𐶐����܂��B
    def initialize(filename, loop = 1)
      @loop = loop
      @filename = filename
      load(filename)
    end

    # ���y�t�@�C�������[�h���܂��B
    # WAVE, MOD, MIDI, OGG, MP3 �`���ɑΉ����Ă��܂��B
    def load(filename)
      @@wave[filename] = SDL::Mixer::Music.load(filename)
    end

    def _play(wave, loop)
      SDL::Mixer.play_music(wave, loop)
    end
    private :_play

    # ���y���Đ����܂��B
    def play(loop = @loop)
      _play(@@wave[@filename], loop)
    end

    # ���y�̍Đ����~���܂��B
    def self.stop
      SDL::Mixer.halt_music
    end

    # ���y�̍Đ����~���܂��B
    def stop
       self.class.stop
    end
  end

  # = �`��v���~�e�B�u
  #
  # �`��v���~�e�B�u�̃X�[�p�[�N���X�ŁA�`��v���~�e�B�u�̊�{�I�ȋ@�\���`���Ă��܂��B
  # �e��`��v���~�e�B�u�͂��̃N���X���p�����Ă��܂��B
  #
  # �ʏ�͂��̃N���X���g���K�v�͂���܂���B���̃N���X�̃T�u�N���X�i Image TransparentImage Font ShadowFont Square FillSquare �j���g�p���Ă��������B
  #
  class DrawPrimitive
    attr_accessor :screen
    private :screen
    # �`����W
    attr_accessor :x, :y
    # �`�扡�T�C�Y�i�P�ʂ̓s�N�Z���j
    attr_accessor :w
    # �`��c�T�C�Y�i�P�ʂ̓s�N�Z���j
    attr_accessor :h
    # �`��I�t�Z�b�g�B�`����W�ɂ��̒l�����Z�����ʒu�ɕ`�悳��܂��B
    attr_accessor :offset_x, :offset_y
    # �A���t�@�l
    attr_accessor :alpha
    # true ��ݒ肷��� render ���\�b�h���Ă�ł��`�悳��Ȃ��Ȃ�܂��B
    attr_accessor :hide

    Options = {
      :x => 0,
      :y => 0,
      :w => nil,
      :h => nil,
      :offset_x => 0,
      :offset_y => 0,
      :alpha => 255,
      :hide => false,
    } # :nodoc:
    def self.default_options # :nodoc:
      Options
    end

    def self.check_options(options) # :nodoc:
      options.each {|k, v|
        next unless Symbol === k
        unless default_options.include? k
          raise ArgumentError, "unrecognized option: #{k}"
        end
      }
    end

    # �v���~�e�B�u�`����s���܂��B
    def self.render(*args)
      new(*args).render
    end

    # �`��v���~�e�B�u�𐶐����܂��B
    def initialize(*options)
      @screen = MyGame.screen
      @disp_x = @disp_y = nil
      init_options(*options)
    end

    def init_options(*options) # :nodoc:
      opts = options.shift if !options.empty? && Hash === options.first
      raise ArgumentError.new("extra arguments") if !options.empty?
      opts ||= {}
      self.class.check_options(opts)
      self.class.default_options.each do |k, v|
        __send__ "#{k}=", opts[k] || v
      end
    end

    # hide ���^�̏ꍇ�� true ��Ԃ��܂��B
    def hide?
      !!hide
    end

    # target.x, target.y ���`�敨��ɂ���ꍇ�� true ��Ԃ��܂��B
    def hit?(target)
      return nil if hide? or @disp_x.nil?
      SDL::CollisionMap.bounding_box_check(@disp_x, @disp_y, w, h, target.x, target.y, 1, 1)
    end

    # �`��v���~�e�B�u�̍X�V�������s���܂��B
    def update
    end

    # �`��v���~�e�B�u��`�悵�܂��B
    def render
    end

    #def <=>(other)
    #  y <=> other.y
    #end
  end

  # = �摜�v���~�e�B�u
  # 
  # �摜�`������邽�߂̃v���~�e�B�u�ł��B
  # �L�����N�^�摜�̎���𓧖��F�Ƃ��Ĉ����ꍇ�� TransparentImage ���g�p���Ă��������B
  # 
  # ���̃T���v���͉摜�I�u�W�F�N�g�������� sample.bmp ����ʂɕ`�悷���ł��B
  # 
  #  require 'mygame/boot'
  #  img = Image.new("sample.bmp")
  #  main_loop do
  #    img.render
  #  end
  # 
  class Image < DrawPrimitive
    @@image_cache = {}
    # �摜�̒��_�𒆐S�Ƃ�����]�p�B 360 �� 1 ��]
    attr_accessor :angle
    # �g�嗦�i�k�����j�B��l�� 1.0
    attr_accessor :scale
    attr_reader :image, :animation

    Options = {
      :angle => 0,
      :scale => 1,
    } # :nodoc:
    def self.default_options # :nodoc:
      super.merge Options; end

    # �摜�v���~�e�B�u�𐶐����܂��B
    def initialize(filename = nil, *options)
      super(*options)

      @filename = filename
      load(@filename) if @filename
      @ox = @oy = 0
      @animation = nil
      @animation_counter = 0
      @animation_labels = {}
    end

    def update_animation
      if a = @animation_labels[@animation]
        size = a[:patten].size
        idx = @animation_counter / a[:time]
        if idx >= size
          case a[:following]
          when nil
            stop_animation
            return
          when :loop
          else
            start_animation a[:following]
            a = @animation_labels[@animation]
          end
          @animation_counter = 0
          idx = 0
        end
        offset = a[:patten][idx]
        @ox = offset[0]
        @oy = offset[1]
        @w = offset[2]
        @h = offset[3]

        #num = @image.w / @w
        #@ox = offset % num * @w
        #@oy = offset / num * @h
        @animation_counter += 1
      end
    end
    private :update_animation

    # �摜�v���~�e�B�u�̍X�V�������s���܂��B
    # �A�j���[�V�������X�V����ɂ͂��̃��\�b�h�𖈃t���[���Ă�ł��������B
    def update
      update_animation
    end

    def _set_animation(label, time, patten = nil, following = :loop)
      raise "`#{label}' cannot be used for the label." if label == :loop
      @animation_labels[label] = {
        :time      => [time, 1].max,
        :patten    => patten,
        :following => following,
      }
    end
    private :_set_animation

    # �A�j���[�V�����p�^����ǉ����܂��B
    # 
    # ���̗�ł� animation.bmp ���� 3 �p�^���̉摜�� 20 �t���[�����ɐ؂�ւ��ĕ`�悵�܂��B
    # 
    #  img = Image.new("animation.bmp", :w => 100, :h => 100)
    #  img.add_animation :abc => [20, [0, 1, 2]]     # �A�j���[�V�����p�^���̐ݒ�
    #  img.start_animation :abc                      # �ŏ��̃A�j���[�V�������w��
    #
    def add_animation(hash)
      hash.each do |key, params|
        _set_animation(key, *params)
      end
    end

    # �A�j���[�V�������J�n���܂��B
    def start_animation(label, restart = false)
      @animation_labels[label] or raise "cannot find animation label `#{label}'"
      return if @animation == label and !restart
      @animation = label
      @animation_counter = 0
    end

    # �A�j���[�V�������~���܂��B
    def stop_animation
      @animation = nil
    end

    # �摜�t�@�C�������[�h���܂��B
    # �Ή����Ă���摜�t�H�[�}�b�g�� BMP, PNM (PPM/PGM/PBM), XPM, XCF, PCX, GIF, JPEG, TIFF, TGA, PNG, LBM �ł��B
    def load(filename)
      unless @image = @@image_cache[filename]
        @image = SDL::Surface.load(filename).display_format
        @@image_cache[filename] = @image
      end
      @w ||= @image.w
      @h ||= @image.h
      @alpha_image = nil
      @image
    end

    # �����F�̎w������܂��B�����F�����݂���s�N�Z���̍��W�������ŗ^���܂��B
    def set_transparent_pixel(x = 0, y = 0)
      pix = @image.getPixel(x, y)
      key = [@filename, pix]
      if image = @@image_cache[key]
        @image = image
      else
        # make dup
        @image = @image.display_format
        @image.set_color_key SDL::SRCCOLORKEY, pix
        @image = @image.display_format
        @@image_cache[key] = @image
      end
      @alpha_image = nil
      @image
    end

    # �摜�v���~�e�B�u��`�悵�܂��B
    def render
      if hide? or @image.nil?
        @disp_x = @disp_y = nil
        return
      end
      x = @x + offset_x
      y = @y + offset_y
      @disp_x, @disp_y = x, y
      @disp_x, @disp_y = x, y
      return if @alpha <= 0
      img = if alpha < 255
              @alpha_image ||= @image.display_format
              @alpha_image.set_alpha(SDL::SRCALPHA, alpha)
              @alpha_image
            else
              @image
            end
      if scale == 1 and angle == 0
        SDL.blit_surface img, @ox, @oy, @w, @h, screen, x, y
      else
        SDL.transform_blit(img, screen, @angle, @scale, @scale, @w/2, @h/2, x, y, 0)
      end
    end

    # ���[�h�����摜�f�[�^�̃L���b�V�����N���A���܂��B
    def self.clear_cache
      @@image_cache = {}
    end
  end

  # = ���߉摜�v���~�e�B�u
  #
  # ���ߏ������s���摜�`��v���~�e�B�u�ł��B
  #
  # �摜�ɓ��ߏ������s����_�ȊO�� 
  # Image �N���X�Ɠ����ł��B
  # �摜�C���[�W����[ (0, 0) �̃s�N�Z���F�������F�ɂȂ�܂��B
  #
  class TransparentImage < Image
    # �摜�v���~�e�B�u�𐶐����܂��B
    def initialize(filename = nil, *options)
      #super
      super(filename, *options)
      set_transparent_pixel 0, 0
    end
  end

  require 'kconv'
  require 'rbconfig'

  # = �t�H���g�v���~�e�B�u
  # 
  # �t�H���g��`�悷�邽�߂̃v���~�e�B�u�ł��B
  # �܂� ShadowFont ���g���Ɖe���t�H���g��`�悷�邱�Ƃ��ł��܂��B
  # 
  # ���̃T���v���̓t�H���g�I�u�W�F�N�g�������� "Hello" ����ʂɕ`�悷���ł��B
  # 
  #  require 'mygame/boot'
  #  fnt = Font.new("Hello")
  #  main_loop do
  #    fnt.render
  #  end
  # 
  class Font < DrawPrimitive
    def self.default_options # :nodoc:
      opts = {
          :color => [255, 255, 255],
          :size => default_size,
          :ttf_path => default_ttf_path,
      }
      super.merge opts
    end

    # �f�t�H���g�Ŏg�p���Ă��� TTF �ł��B
    DEFALUT_TTF = 'VL-Gothic-Regular.ttf'
    # �f�t�H���g�� TTF �ƃt�H���g�T�C�Y��ݒ肵�܂��B
    def self.setup_default_setting(ttf = nil, size = nil)
      datadir = Config::CONFIG["datadir"]
      mygame_datadir = File.join(datadir, 'mygame')
      ['./fonts', mygame_datadir].each do |dir|
        path = ttf || File.join(dir, DEFALUT_TTF)
        if File.exist?(path)
          @@default_ttf_path = path
          break
        end
      end
      @@default_size = size || 16
    end
    setup_default_setting

    # �f�t�H���g�̃t�H���g�T�C�Y��Ԃ��܂��B
    def self.default_size
      @@default_size
    end

    # �f�t�H���g�̃t�H���g�T�C�Y��ݒ肵�܂��B
    def self.default_size=(size)
      @@default_size = size
    end

    # �f�t�H���g�Ŏg�p���� TTF �̃p�X��Ԃ��܂��B
    def self.default_ttf_path
      @@default_ttf_path
    end

    # �f�t�H���g�Ŏg�p���� TTF ��ݒ肵�܂��B
    def self.default_ttf_path=(path)
      @@default_ttf_path = path
    end

    # �t�H���g�I�u�W�F�N�g�𐶐����܂��B
    def initialize(string = '', *options)
      super(*options)

      @font = open_tff(@ttf_path, @size)
      @font.style = SDL::TTF::STYLE_NORMAL

      @last_string = nil
      self.string = string
    end

    @@tff_cache = {}
    # ���[�h���� TTF �f�[�^�̃L���b�V�����N���A���܂��B
    def self.clear_cache
      @@tff_cache = {}
    end

    def open_tff(ttf_path, size)
      @@tff_cache[[ttf_path, size]] ||= SDL::TTF.open(ttf_path, size)
    end
    private :open_tff

    def refresh # :nodoc:
      if @font
        @font = open_tff(@ttf_path, @size)
        create_surface
      end
    end

    # �`�悷�邷�镶����
    attr_accessor :string
    # �t�H���g�̐F�i [r, g, b] �Ŏw�肷��B�ԂȂ� [255, 0, 0] �j
    attr_accessor :color
    # �t�H���g�̉e�F
    attr_accessor :shadow_color
    # �t�H���g�T�C�Y
    attr_accessor :size
    # �g�p���� TTF
    attr_accessor :ttf_path
    attr_accessor :added_width # :nodoc:
    %w(color shadow_color size ttf_path).each do |e|
      attr_reader e
      eval "    def #{e}=(arg)
      return if arg == (@last_#{e} ||= nil)
      @last_#{e} = @#{e} = arg
      refresh
    end"
    end

    def string=(arg) # :nodoc:
      return if @last_string == (arg = arg.to_s)
      @last_string = arg
      @string = Kconv.toutf8(arg)
      create_surface
    end

    def create_surface # :nodoc:
      @w, @h = @font.text_size(@string)
      @max_w, @max_h = @w, @h
      @dx, @dy = if @shadow_color
                   [1 + @size / 24, 1 + @size / 24]
                 else
                   [0, 0]
                 end
      @surface = SDL::Surface.new(SDL::SWSURFACE, w + @dx, h + @dy, 32, *MyGame.mask_rgba)
      if @shadow_color
        @font.drawSolidUTF8(@surface, @string, @dx, @dy, *@shadow_color)
        @font.drawSolidUTF8(@surface, @string, 0, @dy, *@shadow_color)
      end
      @font.drawSolidUTF8(@surface, @string, 0, 0, *@color)
      @surface.set_color_key SDL::SRCCOLORKEY, @surface.getPixel(0, 0)
      @surface = @surface.display_format
    end

    def start_effect(w) # :nodoc:
      @added_width = w
      @w = 0
    end

    def max_w? # :nodoc:
      @w.nil? or @w >= @max_w
    end

    # �t�H���g�I�u�W�F�N�g���X�V���܂��B
    def update
      @w += @added_width unless max_w?
    end

    # �t�H���g�I�u�W�F�N�g��`�悵�܂��B
    def render
      if hide? or @surface.nil?
        @disp_x = @disp_y = nil
        return
      end
      x = @x + offset_x
      y = @y + offset_y
      if max_w?
        disp_w = 0
        disp_h = 0
      else
        disp_w = w# / 2 * size
        disp_h = h + @dy
      end
      @disp_x, @disp_y = x, y
      return if @alpha <= 0
      @surface.set_alpha(SDL::SRCALPHA, alpha) if alpha < 255
      SDL.blit_surface @surface, 0, 0, disp_w, disp_h, screen, x, y
   end
  end

  # = �e���t�H���g�v���~�e�B�u
  #
  # �e���t�H���g��`�悷�邽�߂̃v���~�e�B�u�ł��B
  #
  # Font �ƈႤ�̂́A�I�u�W�F�N�g�������� shadow_color �� [64, 64, 64] �ŏ���������邱�Ƃ����ł��B
  #
  class ShadowFont < Font
    # �e���t�H���g�𐶐����܂��B
    def initialize(*args)
      @shadow_color = [64, 64, 64]
      super
    end
  end

  # = �l�p�`�v���~�e�B�u
  # 
  # �l�p�`��`�悷��v���~�e�B�u�ł��B
  # �h��Ԃ����s���܂���B����h��Ԃ��ꍇ��FillSquare���g�p���Ă��������B
  # 
  # ���̃T���v���͎l�p�`�v���~�e�B�u�g�������āu�������v����ʂɕ`�悷���ł��B
  # 
  #  require 'mygame/boot'
  #  box = Square.new(20, 20, 100, 100, :color => [255, 255, 255])
  #  main_loop do
  #    box.render
  #  end
  # 
  class Square < DrawPrimitive
    Options = {
      :color => [255, 255, 255],
      :fill => false,
    } # :nodoc:
    def self.default_options # :nodoc:
      super.merge Options; end

    # �t�H���g�̐F
    attr_accessor :color
    # ����h��Ԃ��ꍇ��true��ݒ�
    attr_accessor :fill

    # �l�p�`�v���~�e�B�u�𐶐����܂��B
    def initialize(x = 0, y = 0, w = 0, h = 0, *options)
      super(*options)
      @x, @y = x, y
      @w, @h = w, h
      @fill = false
    end

    # �l�p�`�v���~�e�B�u��`�悵�܂��B
    def render
      if hide?
        @disp_x = @disp_y = nil
        return
      end
      x = @x + offset_x
      y = @y + offset_y
      @disp_x, @disp_y = x, y
      return if @alpha <= 0
      if @alpha < 255
        @@screen.send((@fill ? :draw_filled_rect_alpha : :draw_rect_alpha),
                      x, y, w, h, color, @alpha)
      else
        @@screen.send((@fill ? :fill_rect : :draw_rect),
                      x, y, w, h, color)
      end
    end
  end

  # = �l�p�`�v���~�e�B�u�i����h��Ԃ��j
  #
  # �l�p�`��`�悷��v���~�e�B�u�ł��B
  # ����h��Ԃ��܂��B�g������Square�Ɠ����ł��B
  #
  class FillSquare < Square
    # �l�p�`�v���~�e�B�u�i����h��Ԃ��j�𐶐����܂��B
    def initialize(*args)
      super
      @fill = true
    end
  end

  @@screen = nil
  @@ran_loop = false
  @@ran_init = false
  @@ran_create_screen = false
  @@loop_end = false
  @@events = {}
  @@background_color = [0, 0, 0]
  @@fps = nil

  # MyGame �����������܂��B
  # 
  # �� mygame/boot �����[�h�����ꍇ�͎����I�ɌĂ΂�܂��B
  def init(flags = SDL::INIT_AUDIO | SDL::INIT_VIDEO)
    raise if SDL.inited_system(flags) > 0
    @@ran_init = true
    init_events
    SDL.init flags
    SDL::Mixer.open if flags & SDL::INIT_AUDIO
    SDL::Mixer.allocate_channels(16)
    SDL::TTF.init
  end
  module_function :init

  # MyGame ���I�����܂��B
  def quit
    SDL.quit
  end
  module_function :quit

  # �X�N���[���𐶐����܂��B
  # �f�t�H���g�ł� 640x480 �̃X�N���[������������܂��B
  # 
  # �ȉ��̃T���v���� 320x240 �̃X�N���[���𐶐������ł��B
  # 
  #  require 'mygame'
  #  MyGame.create_screen 320, 240    # 320 �~ 240 �̃X�N���[���𐶐�
  #  MyGame.main_loop do
  #    MyGame.Image.render "sample.bmp"
  #  end
  #
  # mygame/boot �����[�h����ƃf�t�H���g�̃X�N���[���T�C�Y 640x480 �ŃX�N���[������������܂��B
  # mygame/boot �Ŏ����I�ɐ��������X�N���[���̃T�C�Y��ύX�������ꍇ�́A
  # ���̂悤�ɃX�N���[���T�C�Y��ݒ肵�Ă��������B
  #
  #  DEFAULT_SCREEN_W, DEFAULT_SCREEN_H = 320, 240
  #  require 'mygame/boot'
  #  main_loop do
  #    Image.render "sample.bmp"
  #  end
  #
  # �� mygame/boot �����[�h�����ꍇ�͎����I�� create_screen ���Ă΂�܂��B
  def create_screen(screen_w = (defined?(DEFAULT_SCREEN_W) && DEFAULT_SCREEN_W) || 640,
                    screen_h = (defined?(DEFAULT_SCREEN_H) && DEFAULT_SCREEN_H) || 480,
                    bpp = 16, flags = SDL::SWSURFACE)
    init unless @@ran_init
    @@ran_create_screen = true
    screen = SDL.set_video_mode(screen_w, screen_h, bpp, flags)
    def screen.update(x = 0, y = 0, w = 0, h = 0)
      self.update_rect x, y, w, h
    end
    @@screen = screen
  end
  module_function :create_screen

  # ���C�����[�v�����s���܂��B
  # ���C�����[�v���Ŏ��s���鏈�����u���b�N�ŋL�q���܂��B
  # 
  #  require 'mygame/boot'
  #  main_loop do
  #    # ���[�v����
  #    Font.render "Hello, World"
  #  end
  # 
  # �u���b�N�œn�������[�v�����͕b�� 60 ��Ă΂�܂��B
  # �܂�f�t�H���g�ł͕b��60�t���[���Ń��[�v���������s����܂��B
  # 
  #  require 'mygame/boot'
  #  ct = 0
  #  main_loop do
  #    Font.render ct
  #    ct += 1    # 1�b�Ԃ� 60 ����Z�����
  #  end
  # 
  def main_loop(fps = 60)
    create_screen unless @@ran_create_screen
    @@ran_loop = true
    @@fps = fps
    @@real_fps = 0

    do_wait = true
    @@count = 0
    @@tm_start = @@ticks = SDL.get_ticks

    until @@loop_end
      poll_event
      if block_given?
        screen.fillRect 0, 0, screen.w, screen.h, background_color if background_color
        yield screen
      end
      sync(@@fps) if do_wait
      screen.flip
    end
  end
  module_function :main_loop

  def poll_event # :nodoc:
    while event = SDL::Event2.poll
      event.class.name =~ /\w+\z/
      name = $&.gsub(/([a-z])([A-Z])/) { "#{$1}_#{$2.downcase}" }.downcase
      (@@events[name.to_sym] || {}).each {|key, block| block.call(event) }
    end
    SDL::Key.scan
  end
  module_function :poll_event

  def sync(fps) # :nodoc:
    if fps > 0
      diff = @@ticks + (1000 / fps) - SDL.get_ticks
      SDL.delay(diff) if diff > 0
    end
    @@ticks = SDL.get_ticks
    @@count += 1
    if @@count >= 30
      @@count = 0
      @@real_fps = 30 * 1000 / (@@ticks - @@tm_start)
      @@tm_start = @@ticks
    end
  end
  module_function :sync

  # FPS ���擾���܂��B
  def fps
    @@fps
  end
  module_function :fps

  # FPS ��ݒ肵�܂��B
  def fps=(fps)
    @@fps = fps
  end
  module_function :fps=

  # FPS �i�����l�j���擾���܂��B
  def real_fps
    @@real_fps
  end
  module_function :real_fps

  def ran_main_loop? # :nodoc:
    @@ran_loop
  end
  module_function :ran_main_loop?

  # �X�N���[���I�u�W�F�N�g���擾���܂��B
  def screen
    @@screen
  end
  module_function :screen

  # �w�i�F���擾���܂��B
  # 
  #  MyGame.background_color # => [0, 0, 0]
  # 
  def background_color
    @@background_color
  end
  module_function :background_color

  # �w�i�F��ݒ肵�܂��B
  # �ݒ肵�����F�� RGB �l��z��Ƃ��ė^���܂��B�f�t�H���g�l�͍� [0, 0, 0] �ł��B
  # 
  #  MyGame.background_color = [0, 0, 255]  # �w�i�F��ɐݒ�
  # 
  def background_color=(color)
    @@background_color = color
  end
  module_function :background_color=

  # �w�i�F��ݒ肵�܂��B
  # �ݒ肵�����F�� RGB �l��z��Ƃ��ė^���܂��B�f�t�H���g�l�͍� [0, 0, 0] �ł��B
  # 
  #  MyGame.set_background_color [0, 0, 255]  # �w�i�F��ɐݒ�
  # 
  def set_background_color(color)
    self.background_color = color
  end
  module_function :set_background_color

  # �C�x���g������ǉ����܂��B
  # event �̓V���{���Ŏw�肵�܂��B
  # 
  #  # �}�E�X�𓮂������Ƃ��ɔ�������C�x���g��o�^�����
  #  MyGame.add_event(:mouse_motion) {|event| puts "x:#{event.x} y:#{event.y}" }
  # 
  # event �Ɏw��ł���V���{���ɂ͎��̂��̂�����܂��B
  #
  # * :active �c�c �}�E�X�J�[�\���̃E�C���h�E�̏o����A�L�[�{�[�h�t�H�[�J�X�̓����A����эŏ����E�A�C�R�������ꂽ�茳�ɖ߂����Ƃ��ɔ������܂��B
  # * :key_down �c�c �L�[�{�[�h���������Ƃ��ɔ�������C�x���g�ł��B
  # * :key_up �c�c �L�[�{�[�h�𗣂����Ƃ��ɔ�������C�x���g�ł��B
  # * :mouse_motion �c�c �}�E�X�𓮂������Ƃ��ɔ�������C�x���g�ł��B
  # * :mouse_button_down �c�c �}�E�X�{�^�����������Ƃ��̃C�x���g�ł��B
  # * :mouse_button_up �c�c �}�E�X�{�^���𗣂����Ƃ��̃C�x���g�ł��B
  # * :joy_axis joy_ball �c�c ���[�U���W���C�X�e�B�b�N�̎����ړ�������Ƃ��̃C�x���g���������܂��B
  # * :joy_hat joy_button_up �c�c �W���C�X�e�B�b�N�̃g���b�N�{�[���̓����C�x���g�ł��B
  # * :joy_button_down �c�c �W���C�X�e�B�b�N�̃n�b�g�X�C�b�`�̈ʒu�ω��C�x���g�ł��B
  # * :quit �c�c �I���v���C�x���g�ł��B
  # * :video_resize �c�c �E�B���h�E�����T�C�Y���ꂽ���ɂ��̃C�x���g���������܂��B
  # 
  # �Q�l: http://www.kmc.gr.jp/~ohai/rubysdl_ref.html �iSDL::Event2�̕����j
  # 
  def add_event(event, key = nil, &block)
    @@events[event] || raise("unknown event type `#{event}'")
    key ||= block.object_id
    @@events[event][key] = block
    key
  end
  module_function :add_event

  # �C�x���g�������폜���܂��B
  # 
  #  # �}�E�X�𓮂������Ƃ��ɔ�������C�x���g���폜
  #  MyGame.remove_event(:mouse_motion)
  # 
  def remove_event(event, key=nil)
    if key
      @@events[event].delete(key)
    else
      @@events[event].each {|key, | @@events[event].delete(key) }
    end
  end
  module_function :remove_event

  Events = %w(active key_down key_up mouse_motion mouse_button_down mouse_button_up
              joy_axis joy_ball joy_hat joy_button_up joy_button_down
              quit sys_wm video_resize).map {|e| e.to_sym } # :nodoc:
  # �C�x���g�����������܂��B���̃��\�b�h�����s����Ɠo�^����Ă���C�x���g�͂��ׂăN���A����܂��B
  def init_events
    Events.each {|e| @@events[e] = {} }
    add_event(:quit, :close) { @@loop_end = true }
    add_event(:key_down, :close) {|e| @@loop_end = true if e.sym == Key::ESCAPE }
    @@press_last_key = {}
  end
  module_function :init_events

  # �L�[���͂̃`�F�b�N���s���܂��B
  # �g�p�ł���L�[�V���{���ɂ��Ă� MyGame::Key ���Q�Ƃ��Ă��������B
  # 
  # ���̃v���O�����̓X�y�[�X�L�[��������Ă���� puts �����s����܂��B
  # 
  #  MyGame.mian_loop do
  #    puts "�����ꂽ!" if key_pressed?(MyGame::Key::SPACE)
  #  end
  # 
  def key_pressed?(key)
    SDL::Key.press?(key)
  end
  module_function :key_pressed?

  # �V�K�L�[���͂̃`�F�b�N���s���܂��B
  # �g�p�ł���L�[�V���{���ɂ��Ă� MyGame::Key ���Q�Ƃ��Ă��������B
  # 
  #  MyGame.mian_loop do
  #    puts "�����ꂽ!" if new_key_pressed?(MyGame::Key::SPACE)
  #  end
  # 
  def new_key_pressed?(key)
    flag = @@press_last_key[key] == false && SDL::Key.press?(key)
    @@press_last_key[key] = SDL::Key.press?(key)
    flag
  end
  module_function :new_key_pressed?

  def mask_rgba # :nodoc:
    masks = [0x000000ff, 0x0000ff00, 0x00ff0000, 0xff000000]
    masks.reverse! if big_endian = ([1].pack("N") == [1].pack("L"))
    masks
  end
  module_function :mask_rgba

  # MyGame �ł̓L�[�{�[�h���͂ɑΉ�����ȉ��̒萔����`����Ă��܂��B
  #
  #            �L�[�萔                    �Ή��L�[           
  #   MyGame::Key::BACKSPACE    backspace                     
  #   MyGame::Key::TAB          tab                           
  #   MyGame::Key::CLEAR        clear �N���A                  
  #   MyGame::Key::RETURN       return                        
  #   MyGame::Key::PAUSE        pause                         
  #   MyGame::Key::ESCAPE       escape                        
  #   MyGame::Key::SPACE        �X�y�[�X                      
  #   MyGame::Key::EXCLAIM      ���Q��                        
  #   MyGame::Key::QUOTEDBL     ��d���p��                    
  #   MyGame::Key::HASH         �n�b�V��(�V���[�v)            
  #   MyGame::Key::DOLLAR       �h��                          
  #   MyGame::Key::AMPERSAND    �A���p�T���h                  
  #   MyGame::Key::QUOTE        ���p��                        
  #   MyGame::Key::LEFTPAREN    ���ۊ���                      
  #   MyGame::Key::RIGHTPAREN   �E�ۊ���                      
  #   MyGame::Key::ASTERISK     �A�X�^���X�N                  
  #   MyGame::Key::PLUS         �v���X                        
  #   MyGame::Key::COMMA        �J���}                        
  #   MyGame::Key::MINUS        �}�C�i�X                      
  #   MyGame::Key::PERIOD       �s���I�h                      
  #   MyGame::Key::SLASH        �X���b�V��                    
  #   MyGame::Key::K0           0                             
  #   MyGame::Key::K1           1                             
  #   MyGame::Key::K2           2                             
  #   MyGame::Key::K3           3                             
  #   MyGame::Key::K4           4                             
  #   MyGame::Key::K5           5                             
  #   MyGame::Key::K6           6                             
  #   MyGame::Key::K7           7                             
  #   MyGame::Key::K8           8                             
  #   MyGame::Key::K9           9                             
  #   MyGame::Key::COLON        �R����                        
  #   MyGame::Key::SEMICOLON    �Z�~�R����                    
  #   MyGame::Key::LESS         ���Ȃ�                        
  #   MyGame::Key::EQUALS       �C�R�[��                      
  #   MyGame::Key::GREATER      ��Ȃ�                        
  #   MyGame::Key::QUESTION     �^�╄                        
  #   MyGame::Key::AT           �A�b�g�}�[�N                  
  #   MyGame::Key::LEFTBRACKET  ����������                    
  #   MyGame::Key::BACKSLASH    �o�b�N�X���b�V��              
  #   MyGame::Key::RIGHTBRACKET �E��������                    
  #   MyGame::Key::CARET        �L�����b�g                    
  #   MyGame::Key::UNDERSCORE   �A���_�[�X�R�A                
  #   MyGame::Key::BACKQUOTE    �t���p��                      
  #   MyGame::Key::A            a                             
  #   MyGame::Key::B            b                             
  #   MyGame::Key::C            c                             
  #   MyGame::Key::D            d                             
  #   MyGame::Key::E            e                             
  #   MyGame::Key::F            f                             
  #   MyGame::Key::G            g                             
  #   MyGame::Key::H            h                             
  #   MyGame::Key::I            i                             
  #   MyGame::Key::J            j                             
  #   MyGame::Key::K            k                             
  #   MyGame::Key::L            l                             
  #   MyGame::Key::M            m                             
  #   MyGame::Key::N            n                             
  #   MyGame::Key::O            o                             
  #   MyGame::Key::P            p                             
  #   MyGame::Key::Q            q                             
  #   MyGame::Key::R            r                             
  #   MyGame::Key::S            s                             
  #   MyGame::Key::T            t                             
  #   MyGame::Key::U            u                             
  #   MyGame::Key::V            v                             
  #   MyGame::Key::W            w                             
  #   MyGame::Key::X            x                             
  #   MyGame::Key::Y            y                             
  #   MyGame::Key::Z            z                             
  #   MyGame::Key::DELETE       delete                        
  #   MyGame::Key::KP0          �L�[�o�b�h(�e���L�[)��0       
  #   MyGame::Key::KP1          �L�[�o�b�h��1                 
  #   MyGame::Key::KP2          �L�[�o�b�h��2                 
  #   MyGame::Key::KP3          �L�[�o�b�h��3                 
  #   MyGame::Key::KP4          �L�[�o�b�h��4                 
  #   MyGame::Key::KP5          �L�[�o�b�h��5                 
  #   MyGame::Key::KP6          �L�[�o�b�h��6                 
  #   MyGame::Key::KP7          �L�[�o�b�h��7                 
  #   MyGame::Key::KP8          �L�[�o�b�h��8                 
  #   MyGame::Key::KP9          �L�[�o�b�h��9                 
  #   MyGame::Key::KP_PERIOD    �L�[�o�b�h�̃s���I�h          
  #   MyGame::Key::KP_DIVIDE    �L�[�p�b�h�̏��Z�L��          
  #   MyGame::Key::KP_MULTIPLY  multiply �L�[�o�b�h�̏�Z�L�� 
  #   MyGame::Key::KP_MINUS     �L�[�o�b�h�̃}�C�i�X          
  #   MyGame::Key::KP_PLUS      �L�[�o�b�h�̃v���X            
  #   MyGame::Key::KP_ENTER     �L�[�p�b�h��enter             
  #   MyGame::Key::KP_EQUALS    �L�[�p�b�h�̃C�R�[��          
  #   MyGame::Key::UP           ����                        
  #   MyGame::Key::DOWN         �����                        
  #   MyGame::Key::RIGHT        �E���                        
  #   MyGame::Key::LEFT         l�����                       
  #   MyGame::Key::INSERT       insert                        
  #   MyGame::Key::HOME         home                          
  #   MyGame::Key::END          end                           
  #   MyGame::Key::PAGEUP       page up                       
  #   MyGame::Key::PAGEDOWN     page down                     
  #   MyGame::Key::F1           F1                            
  #   MyGame::Key::F2           F2                            
  #   MyGame::Key::F3           F3                            
  #   MyGame::Key::F4           F4                            
  #   MyGame::Key::F5           F5                            
  #   MyGame::Key::F6           F6                            
  #   MyGame::Key::F7           F7                            
  #   MyGame::Key::F8           F8                            
  #   MyGame::Key::F9           F9                            
  #   MyGame::Key::F10          F10                           
  #   MyGame::Key::F11          F11                           
  #   MyGame::Key::F12          F12                           
  #   MyGame::Key::F13          F13                           
  #   MyGame::Key::F14          F14                           
  #   MyGame::Key::F15          F15                           
  #   MyGame::Key::NUMLOCK      numlock                       
  #   MyGame::Key::CAPSLOCK     capslock                      
  #   MyGame::Key::SCROLLOCK    scrollock                     
  #   MyGame::Key::RSHIFT       �Eshift                       
  #   MyGame::Key::LSHIFT       ��shift                       
  #   MyGame::Key::RCTRL        �Ectrl                        
  #   MyGame::Key::LCTRL        ��ctrl                        
  #   MyGame::Key::RALT         �Ealt                         
  #   MyGame::Key::LALT         ��alt                         
  #   MyGame::Key::RMETA        �Emeta                        
  #   MyGame::Key::LMETA        ��meta                        
  #   MyGame::Key::LSUPER       key ��windows�L�[             
  #   MyGame::Key::RSUPER       key �Ewindows�L�[             
  #   MyGame::Key::MODE         ���[�h�V�t�g                  
  #   MyGame::Key::HELP         help                          
  #   MyGame::Key::PRINT        print-screen                  
  #   MyGame::Key::SYSREQ       SysRq?                        
  #   MyGame::Key::BREAK        break                         
  #   MyGame::Key::MENU         menu                          
  #   MyGame::Key::POWER        power                         
  #   MyGame::Key::EURO         ���[��                        
  module Key
    include SDL::Key
  end
end
