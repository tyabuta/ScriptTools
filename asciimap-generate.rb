#!/usr/bin/env ruby
# ********************************************************************
#
#            ASCIIコードをマップしたpng画像を生成する。
#
#                                                  (c) 2013 tyabuta.
# ********************************************************************
require 'rubygems'
require 'RMagick'

# 生成する画像ファイル名
FILENAME = 'characters.png'

# 一文字あたりのピクセルサイズ
CHAR_WIDTH  = 32
CHAR_HEIGHT = 32

# 画像ファイルのピクセルサイズ
CANVAS_WIDTH  = 512
CANVAS_HEIGHT = 512


# 画像の背景色(透明なら'none')
#BACKCOLOR  = 'black'
BACKCOLOR  = 'none'


#
# 文字の描画関数
#
def draw_char(img, context, c, x, y)
    context.annotate(img, CHAR_WIDTH,
                          CHAR_HEIGHT,
                          x+(CHAR_WIDTH/2),
                          y,
                          c) do
        self.font   = 'Verdana-Bold'
        self.fill   = '#FFFFFF'
        self.align  = Magick::CenterAlign
        self.stroke = 'transparent'
        self.pointsize = CHAR_HEIGHT
        self.text_antialias = true
        self.kerning = 1
    end
end


# イメージの作成
img = Magick::Image.new(CANVAS_WIDTH, CANVAS_HEIGHT) do
    self.background_color = BACKCOLOR
end

# 描画開始
context = Magick::Draw.new
0xff.times do |a|
    # @(64)マークの文字描画で"no text"エラーが発生するため、回避。
    if 32<=a && a<127 && 64!=a then
        x = (a % 16)      * CHAR_WIDTH
        y = (a / 16).to_i * CHAR_HEIGHT
        #puts format("a:%d c:%c x:%d y:%d", a, a, x,y)
        draw_char(img, context, format("%c", a), x,y)
    end
end

# ファイル保存
img.write(FILENAME)

__END__

# 利用可能なフォント一覧
Magick.fonts.each do |font|
    puts font.name
end

# ImageMagickでフォント読み込みエラーが出る場合、
# ghostscriptのインストールが必要。
# unable to read font "n019003l.pfb"
brew install ghostscript

