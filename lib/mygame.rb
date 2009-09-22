require 'sdl'
#
#= MyGame リファレンスマニュアル
#
#Copyright:: Copyright (C) Dan Yamamoto, 2007. All rights reserved.
#License::   Ruby ライセンスに準拠
#
#MyGame は Ruby/SDL をラップしたゲーム開発用のライブラリです。
#「シンプルなゲーム開発」を目指して開発されています。
#
#=== 外部サイトへのリンク
#
#* MyGame[http://dgames.jp/ja/projects/mygame/] …… MyGame のサイト
#* Ruby/SDL[http://www.kmc.gr.jp/~ohai/rubysdl.html] …… Ruby/SDL のサイト
#
#=== 開発履歴
#
#* 2007-05-25
#  * ドキュメント追記
#  * ver 0.9.0 リリース
#
#* 2007-03-03
#  * ハッシュによるキーワード引数的 API 導入
#
#* 2007-01-07
#  * RDOC でリファレンス作成
#
#* 2006-12-07
#  * 基本仕様と実装が完成
#
module MyGame
  # = 効果音クラス
  # 
  # 効果音を制御するクラスです。
  # 
  # 次のサンプルは効果音 sample.wav を再生する例です。
  # 
  #  require 'mygame/boot'
  #  main_loop do
  #    Wave.play("sample.wav") if new_key_pressed?(Key::SPACE)
  #  end
  # 
  # 次のサンプルは効果音オブジェクト生成して sample.wav を再生する例です。
  # 
  #  require 'mygame/boot'
  #  wav = Wave.new("sample.wav")
  #  main_loop do
  #    wav.play if new_key_pressed?(Key::SPACE)
  #  end
  # 
  class Wave
    @@wave = {}
    # 効果音オブジェクトを生成します。
    def initialize(filename, ch = :auto, loop = 1)
      @ch = ch
      @loop = loop
      @filename = filename
      load(filename)
    end

    # 効果音をロードします。
    # WAVE, AIFF, RIFF, OGG, VOC 形式に対応しています。
    def load(filename)
      @@wave[filename] = SDL::Mixer::Wave.load(filename)
    end

    # ロードした効果音のキャッシュをクリアします。
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

    # 効果音を再生します。
    def play(ch = @ch, loop = @loop)
      _play(ch, @@wave[@filename], loop)
    end

    # 効果音を再生します。
    def self.play(*args)
      new(*args).play
    end
  end

  # = 音楽クラス
  #
  # BGM として使用する音楽ファイルを制御するクラスです。
  #
  class Music < Wave
    # 音楽オブジェクトを生成します。
    def initialize(filename, loop = 1)
      @loop = loop
      @filename = filename
      load(filename)
    end

    # 音楽ファイルをロードします。
    # WAVE, MOD, MIDI, OGG, MP3 形式に対応しています。
    def load(filename)
      @@wave[filename] = SDL::Mixer::Music.load(filename)
    end

    def _play(wave, loop)
      SDL::Mixer.play_music(wave, loop)
    end
    private :_play

    # 音楽を再生します。
    def play(loop = @loop)
      _play(@@wave[@filename], loop)
    end

    # 音楽の再生を停止します。
    def self.stop
      SDL::Mixer.halt_music
    end

    # 音楽の再生を停止します。
    def stop
       self.class.stop
    end
  end

  # = 描画プリミティブ
  #
  # 描画プリミティブのスーパークラスで、描画プリミティブの基本的な機能を定義しています。
  # 各種描画プリミティブはこのクラスを継承しています。
  #
  # 通常はこのクラスを使う必要はありません。このクラスのサブクラス（ Image TransparentImage Font ShadowFont Square FillSquare ）を使用してください。
  #
  class DrawPrimitive
    attr_accessor :screen
    private :screen
    # 描画座標
    attr_accessor :x, :y
    # 描画横サイズ（単位はピクセル）
    attr_accessor :w
    # 描画縦サイズ（単位はピクセル）
    attr_accessor :h
    # 描画オフセット。描画座標にこの値を加算した位置に描画されます。
    attr_accessor :offset_x, :offset_y
    # アルファ値
    attr_accessor :alpha
    # true を設定すると render メソッドを呼んでも描画されなくなります。
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

    # プリミティブ描画を行います。
    def self.render(*args)
      new(*args).render
    end

    # 描画プリミティブを生成します。
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

    # hide が真の場合に true を返します。
    def hide?
      !!hide
    end

    # target.x, target.y が描画物上にある場合に true を返します。
    def hit?(target)
      return nil if hide? or @disp_x.nil?
      SDL::CollisionMap.bounding_box_check(@disp_x, @disp_y, w, h, target.x, target.y, 1, 1)
    end

    # 描画プリミティブの更新処理を行います。
    def update
    end

    # 描画プリミティブを描画します。
    def render
    end

    #def <=>(other)
    #  y <=> other.y
    #end
  end

  # = 画像プリミティブ
  # 
  # 画像描画をするためのプリミティブです。
  # キャラクタ画像の周りを透明色として扱う場合は TransparentImage を使用してください。
  # 
  # 次のサンプルは画像オブジェクト生成して sample.bmp を画面に描画する例です。
  # 
  #  require 'mygame/boot'
  #  img = Image.new("sample.bmp")
  #  main_loop do
  #    img.render
  #  end
  # 
  class Image < DrawPrimitive
    @@image_cache = {}
    # 画像の中点を中心とした回転角。 360 で 1 回転
    attr_accessor :angle
    # 拡大率（縮小率）。基準値は 1.0
    attr_accessor :scale
    attr_reader :image, :animation

    Options = {
      :angle => 0,
      :scale => 1,
    } # :nodoc:
    def self.default_options # :nodoc:
      super.merge Options; end

    # 画像プリミティブを生成します。
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

    # 画像プリミティブの更新処理を行います。
    # アニメーションを更新するにはこのメソッドを毎フレーム呼んでください。
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

    # アニメーションパタンを追加します。
    # 
    # 次の例では animation.bmp 内の 3 パタンの画像を 20 フレーム毎に切り替えて描画します。
    # 
    #  img = Image.new("animation.bmp", :w => 100, :h => 100)
    #  img.add_animation :abc => [20, [0, 1, 2]]     # アニメーションパタンの設定
    #  img.start_animation :abc                      # 最初のアニメーションを指定
    #
    def add_animation(hash)
      hash.each do |key, params|
        _set_animation(key, *params)
      end
    end

    # アニメーションを開始します。
    def start_animation(label, restart = false)
      @animation_labels[label] or raise "cannot find animation label `#{label}'"
      return if @animation == label and !restart
      @animation = label
      @animation_counter = 0
    end

    # アニメーションを停止します。
    def stop_animation
      @animation = nil
    end

    # 画像ファイルをロードします。
    # 対応している画像フォーマットは BMP, PNM (PPM/PGM/PBM), XPM, XCF, PCX, GIF, JPEG, TIFF, TGA, PNG, LBM です。
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

    # 透明色の指定をします。透明色が存在するピクセルの座標を引数で与えます。
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

    # 画像プリミティブを描画します。
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

    # ロードした画像データのキャッシュをクリアします。
    def self.clear_cache
      @@image_cache = {}
    end
  end

  # = 透過画像プリミティブ
  #
  # 透過処理を行う画像描画プリミティブです。
  #
  # 画像に透過処理が行われる点以外は 
  # Image クラスと同じです。
  # 画像イメージ左上端 (0, 0) のピクセル色が抜け色になります。
  #
  class TransparentImage < Image
    # 画像プリミティブを生成します。
    def initialize(filename = nil, *options)
      #super
      super(filename, *options)
      set_transparent_pixel 0, 0
    end
  end

  require 'kconv'
  require 'rbconfig'

  # = フォントプリミティブ
  # 
  # フォントを描画するためのプリミティブです。
  # また ShadowFont を使うと影つきフォントを描画することができます。
  # 
  # 次のサンプルはフォントオブジェクト生成して "Hello" を画面に描画する例です。
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

    # デフォルトで使用している TTF です。
    DEFALUT_TTF = 'VL-Gothic-Regular.ttf'
    # デフォルトの TTF とフォントサイズを設定します。
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

    # デフォルトのフォントサイズを返します。
    def self.default_size
      @@default_size
    end

    # デフォルトのフォントサイズを設定します。
    def self.default_size=(size)
      @@default_size = size
    end

    # デフォルトで使用する TTF のパスを返します。
    def self.default_ttf_path
      @@default_ttf_path
    end

    # デフォルトで使用する TTF を設定します。
    def self.default_ttf_path=(path)
      @@default_ttf_path = path
    end

    # フォントオブジェクトを生成します。
    def initialize(string = '', *options)
      super(*options)

      @font = open_tff(@ttf_path, @size)
      @font.style = SDL::TTF::STYLE_NORMAL

      @last_string = nil
      self.string = string
    end

    @@tff_cache = {}
    # ロードした TTF データのキャッシュをクリアします。
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

    # 描画するする文字列
    attr_accessor :string
    # フォントの色（ [r, g, b] で指定する。赤なら [255, 0, 0] ）
    attr_accessor :color
    # フォントの影色
    attr_accessor :shadow_color
    # フォントサイズ
    attr_accessor :size
    # 使用する TTF
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

    # フォントオブジェクトを更新します。
    def update
      @w += @added_width unless max_w?
    end

    # フォントオブジェクトを描画します。
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

  # = 影つきフォントプリミティブ
  #
  # 影つきフォントを描画するためのプリミティブです。
  #
  # Font と違うのは、オブジェクト生成時に shadow_color が [64, 64, 64] で初期化されることだけです。
  #
  class ShadowFont < Font
    # 影つきフォントを生成します。
    def initialize(*args)
      @shadow_color = [64, 64, 64]
      super
    end
  end

  # = 四角形プリミティブ
  # 
  # 四角形を描画するプリミティブです。
  # 塗りつぶしを行いません。中を塗りつぶす場合はFillSquareを使用してください。
  # 
  # 次のサンプルは四角形プリミティブト生成して「白い箱」を画面に描画する例です。
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

    # フォントの色
    attr_accessor :color
    # 中を塗りつぶす場合はtrueを設定
    attr_accessor :fill

    # 四角形プリミティブを生成します。
    def initialize(x = 0, y = 0, w = 0, h = 0, *options)
      super(*options)
      @x, @y = x, y
      @w, @h = w, h
      @fill = false
    end

    # 四角形プリミティブを描画します。
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

  # = 四角形プリミティブ（中を塗りつぶす）
  #
  # 四角形を描画するプリミティブです。
  # 中を塗りつぶします。使い方はSquareと同じです。
  #
  class FillSquare < Square
    # 四角形プリミティブ（中を塗りつぶす）を生成します。
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

  # MyGame を初期化します。
  # 
  # ※ mygame/boot をロードした場合は自動的に呼ばれます。
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

  # MyGame を終了します。
  def quit
    SDL.quit
  end
  module_function :quit

  # スクリーンを生成します。
  # デフォルトでは 640x480 のスクリーンが生成されます。
  # 
  # 以下のサンプルは 320x240 のスクリーンを生成する例です。
  # 
  #  require 'mygame'
  #  MyGame.create_screen 320, 240    # 320 × 240 のスクリーンを生成
  #  MyGame.main_loop do
  #    MyGame.Image.render "sample.bmp"
  #  end
  #
  # mygame/boot をロードするとデフォルトのスクリーンサイズ 640x480 でスクリーンが生成されます。
  # mygame/boot で自動的に生成されるスクリーンのサイズを変更したい場合は、
  # 次のようにスクリーンサイズを設定してください。
  #
  #  DEFAULT_SCREEN_W, DEFAULT_SCREEN_H = 320, 240
  #  require 'mygame/boot'
  #  main_loop do
  #    Image.render "sample.bmp"
  #  end
  #
  # ※ mygame/boot をロードした場合は自動的に create_screen が呼ばれます。
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

  # メインループを実行します。
  # メインループ内で実行する処理をブロックで記述します。
  # 
  #  require 'mygame/boot'
  #  main_loop do
  #    # ループ処理
  #    Font.render "Hello, World"
  #  end
  # 
  # ブロックで渡したループ処理は秒間 60 回呼ばれます。
  # つまりデフォルトでは秒間60フレームでループ処理が実行されます。
  # 
  #  require 'mygame/boot'
  #  ct = 0
  #  main_loop do
  #    Font.render ct
  #    ct += 1    # 1秒間に 60 回加算される
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

  # FPS を取得します。
  def fps
    @@fps
  end
  module_function :fps

  # FPS を設定します。
  def fps=(fps)
    @@fps = fps
  end
  module_function :fps=

  # FPS （実測値）を取得します。
  def real_fps
    @@real_fps
  end
  module_function :real_fps

  def ran_main_loop? # :nodoc:
    @@ran_loop
  end
  module_function :ran_main_loop?

  # スクリーンオブジェクトを取得します。
  def screen
    @@screen
  end
  module_function :screen

  # 背景色を取得します。
  # 
  #  MyGame.background_color # => [0, 0, 0]
  # 
  def background_color
    @@background_color
  end
  module_function :background_color

  # 背景色を設定します。
  # 設定したい色の RGB 値を配列として与えます。デフォルト値は黒 [0, 0, 0] です。
  # 
  #  MyGame.background_color = [0, 0, 255]  # 背景色を青に設定
  # 
  def background_color=(color)
    @@background_color = color
  end
  module_function :background_color=

  # 背景色を設定します。
  # 設定したい色の RGB 値を配列として与えます。デフォルト値は黒 [0, 0, 0] です。
  # 
  #  MyGame.set_background_color [0, 0, 255]  # 背景色を青に設定
  # 
  def set_background_color(color)
    self.background_color = color
  end
  module_function :set_background_color

  # イベント処理を追加します。
  # event はシンボルで指定します。
  # 
  #  # マウスを動かしたときに発生するイベントを登録する例
  #  MyGame.add_event(:mouse_motion) {|event| puts "x:#{event.x} y:#{event.y}" }
  # 
  # event に指定できるシンボルには次のものがあります。
  #
  # * :active …… マウスカーソルのウインドウの出入り、キーボードフォーカスの得失、および最小化・アイコン化されたり元に戻ったときに発生します。
  # * :key_down …… キーボードを押したときに発生するイベントです。
  # * :key_up …… キーボードを離したときに発生するイベントです。
  # * :mouse_motion …… マウスを動かしたときに発生するイベントです。
  # * :mouse_button_down …… マウスボタンを押したときのイベントです。
  # * :mouse_button_up …… マウスボタンを離したときのイベントです。
  # * :joy_axis joy_ball …… ユーザがジョイスティックの軸を移動させるとこのイベントが発生します。
  # * :joy_hat joy_button_up …… ジョイスティックのトラックボールの動きイベントです。
  # * :joy_button_down …… ジョイスティックのハットスイッチの位置変化イベントです。
  # * :quit …… 終了要請イベントです。
  # * :video_resize …… ウィンドウがリサイズされた時にこのイベントが発生します。
  # 
  # 参考: http://www.kmc.gr.jp/~ohai/rubysdl_ref.html （SDL::Event2の部分）
  # 
  def add_event(event, key = nil, &block)
    @@events[event] || raise("unknown event type `#{event}'")
    key ||= block.object_id
    @@events[event][key] = block
    key
  end
  module_function :add_event

  # イベント処理を削除します。
  # 
  #  # マウスを動かしたときに発生するイベントを削除
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
  # イベントを初期化します。このメソッドを実行すると登録されているイベントはすべてクリアされます。
  def init_events
    Events.each {|e| @@events[e] = {} }
    add_event(:quit, :close) { @@loop_end = true }
    add_event(:key_down, :close) {|e| @@loop_end = true if e.sym == Key::ESCAPE }
    @@press_last_key = {}
  end
  module_function :init_events

  # キー入力のチェックを行います。
  # 使用できるキーシンボルについては MyGame::Key を参照してください。
  # 
  # 次のプログラムはスペースキーが押されている間 puts が実行されます。
  # 
  #  MyGame.mian_loop do
  #    puts "押された!" if key_pressed?(MyGame::Key::SPACE)
  #  end
  # 
  def key_pressed?(key)
    SDL::Key.press?(key)
  end
  module_function :key_pressed?

  # 新規キー入力のチェックを行います。
  # 使用できるキーシンボルについては MyGame::Key を参照してください。
  # 
  #  MyGame.mian_loop do
  #    puts "押された!" if new_key_pressed?(MyGame::Key::SPACE)
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

  # MyGame ではキーボード入力に対応する以下の定数が定義されています。
  #
  #            キー定数                    対応キー           
  #   MyGame::Key::BACKSPACE    backspace                     
  #   MyGame::Key::TAB          tab                           
  #   MyGame::Key::CLEAR        clear クリア                  
  #   MyGame::Key::RETURN       return                        
  #   MyGame::Key::PAUSE        pause                         
  #   MyGame::Key::ESCAPE       escape                        
  #   MyGame::Key::SPACE        スペース                      
  #   MyGame::Key::EXCLAIM      感嘆符                        
  #   MyGame::Key::QUOTEDBL     二重引用符                    
  #   MyGame::Key::HASH         ハッシュ(シャープ)            
  #   MyGame::Key::DOLLAR       ドル                          
  #   MyGame::Key::AMPERSAND    アンパサンド                  
  #   MyGame::Key::QUOTE        引用符                        
  #   MyGame::Key::LEFTPAREN    左丸括弧                      
  #   MyGame::Key::RIGHTPAREN   右丸括弧                      
  #   MyGame::Key::ASTERISK     アスタリスク                  
  #   MyGame::Key::PLUS         プラス                        
  #   MyGame::Key::COMMA        カンマ                        
  #   MyGame::Key::MINUS        マイナス                      
  #   MyGame::Key::PERIOD       ピリオド                      
  #   MyGame::Key::SLASH        スラッシュ                    
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
  #   MyGame::Key::COLON        コロン                        
  #   MyGame::Key::SEMICOLON    セミコロン                    
  #   MyGame::Key::LESS         小なり                        
  #   MyGame::Key::EQUALS       イコール                      
  #   MyGame::Key::GREATER      大なり                        
  #   MyGame::Key::QUESTION     疑問符                        
  #   MyGame::Key::AT           アットマーク                  
  #   MyGame::Key::LEFTBRACKET  左かぎ括弧                    
  #   MyGame::Key::BACKSLASH    バックスラッシュ              
  #   MyGame::Key::RIGHTBRACKET 右かぎ括弧                    
  #   MyGame::Key::CARET        キャレット                    
  #   MyGame::Key::UNDERSCORE   アンダースコア                
  #   MyGame::Key::BACKQUOTE    逆引用符                      
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
  #   MyGame::Key::KP0          キーバッド(テンキー)の0       
  #   MyGame::Key::KP1          キーバッドの1                 
  #   MyGame::Key::KP2          キーバッドの2                 
  #   MyGame::Key::KP3          キーバッドの3                 
  #   MyGame::Key::KP4          キーバッドの4                 
  #   MyGame::Key::KP5          キーバッドの5                 
  #   MyGame::Key::KP6          キーバッドの6                 
  #   MyGame::Key::KP7          キーバッドの7                 
  #   MyGame::Key::KP8          キーバッドの8                 
  #   MyGame::Key::KP9          キーバッドの9                 
  #   MyGame::Key::KP_PERIOD    キーバッドのピリオド          
  #   MyGame::Key::KP_DIVIDE    キーパッドの除算記号          
  #   MyGame::Key::KP_MULTIPLY  multiply キーバッドの乗算記号 
  #   MyGame::Key::KP_MINUS     キーバッドのマイナス          
  #   MyGame::Key::KP_PLUS      キーバッドのプラス            
  #   MyGame::Key::KP_ENTER     キーパッドのenter             
  #   MyGame::Key::KP_EQUALS    キーパッドのイコール          
  #   MyGame::Key::UP           上矢印                        
  #   MyGame::Key::DOWN         下矢印                        
  #   MyGame::Key::RIGHT        右矢印                        
  #   MyGame::Key::LEFT         l左矢印                       
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
  #   MyGame::Key::RSHIFT       右shift                       
  #   MyGame::Key::LSHIFT       左shift                       
  #   MyGame::Key::RCTRL        右ctrl                        
  #   MyGame::Key::LCTRL        左ctrl                        
  #   MyGame::Key::RALT         右alt                         
  #   MyGame::Key::LALT         左alt                         
  #   MyGame::Key::RMETA        右meta                        
  #   MyGame::Key::LMETA        左meta                        
  #   MyGame::Key::LSUPER       key 左windowsキー             
  #   MyGame::Key::RSUPER       key 右windowsキー             
  #   MyGame::Key::MODE         モードシフト                  
  #   MyGame::Key::HELP         help                          
  #   MyGame::Key::PRINT        print-screen                  
  #   MyGame::Key::SYSREQ       SysRq?                        
  #   MyGame::Key::BREAK        break                         
  #   MyGame::Key::MENU         menu                          
  #   MyGame::Key::POWER        power                         
  #   MyGame::Key::EURO         ユーロ                        
  module Key
    include SDL::Key
  end
end
