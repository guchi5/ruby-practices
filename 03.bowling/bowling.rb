#! /usr/bin/env ruby

# フレーム単位のリストを返す
def create_frames
  input = ARGV[0].split(',')
  frames = [] # フレーム単位のリスト

  while input.length.positive?
    # 10回目は全ての得点を代入して終了
    if frames.length == 9
      frames << input.dup
      break
    end

    frame = []
    frame << input.shift
    frame << if frame[0] == 'X'
               '0'
             else
               input.shift
             end
    frames << frame
  end
  frames
end

# フレームごとのスコアの合計値を返す
def sum_frame_score(frame)
  frame.sum { |score| score == 'X' ? 10 : score.to_i }
end

# 全てのフレームのスコアの合計値を返す
def calculate_total_score(frames)
  score = 0
  frames.each_with_index do |frame, index|
    score += sum_frame_score(frame)

    # 10回目の場合は終了
    break if index == 9

    # ストライクの場合
    if frame[0] == 'X'
      score += sum_frame_score(frames[index + 1][0, 2])
      score += sum_frame_score(frames[index + 2][0, 1]) if frames[index + 1][0] == 'X' && index + 1 != 9 # 次のフレームがストライクの場合は、さらに次のフレームの1投目のスコアを加算

    # スペアの場合
    elsif (frame[0].to_i + frame[1].to_i) == 10
      score += sum_frame_score(frames[index + 1][0, 1])
    end
  end
  score
end

frames = create_frames
puts calculate_total_score(frames)
