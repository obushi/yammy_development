module XlsxToCsv
	require 'rubygems'
	require 'roo'
	require 'csv'
	require 'json'
	TEMP_CSV_NAME = "tmp/menu/yammy.csv"

	def convertXlsx path_to_xlsx

		# 日付が書かれた列数を返す
		def daysRowAt
			CSV.foreach(TEMP_CSV_NAME) do |row|
				return row if row[1] == "区分"
			end
		end

		# 列の長さを返す
		def getLengthOfCols(table)
			table.by_col!
			numOfCols = table.length
			table.by_row!
			return numOfCols
		end

		# 指定した値がはじめに見つかる列の数を返す．見つからない場合は-1を返す．
		def rowAt(data, val)
			count = 0
			data.each do |row|
				row.each do |elem|
					return count if elem == val
				end
				count += 1
			end
			return -1
		end

		# 月/日(曜)のフォーマットから月を取り出す
		def getMonth(date)
			split = date.split("/")
			month = split[0].to_i
			return month
		end

		# 月/日(曜)のフォーマットから日を取り出す
		def getDay(date)
			split = date.split("/")
			splitRight = split[1]
			day = splitRight.split("(")[0].to_i
			return day
		end

		# 曜日の漢字を返す
		def getDayOfWeek(date)
			wday = -1
			kanjiArr = %w{月 火 水 木 金 土 日}
			kanjiArr.each do |kanji|
				unless date[kanji].nil?
					wday = kanji
				end
			end
			return wday
		end

		# 栄養のハッシュを返す
		def getNutrition(str)
			nutrition = Hash.new
			keys = %i{energy protein fat carbohydrate salt}
			split = str.split(/\D*[ ]\D*/)
			for i in 0...split.length do
				val = (i != 4) ? split[i].to_i : split[i].to_f
				nutrition.store(keys[i], val)
			end
			return nutrition
		end

		# 変換 xlsx => csv
		puts path_to_xlsx + 'をCSVに変換します'
		filename_year = path_to_xlsx.gsub(/[^0-9]/, '')		
		unless filename_year.length == 16
			raise StandardError.new("InvalidFileName\n")
		end
		book = Roo::Excelx.new(path_to_xlsx)
		book.default_sheet = book.sheets.first
		book.to_csv(TEMP_CSV_NAME)
		puts '変換に成功しました'

		# 空白を削る
		options = { # CSVファイルを読み込むときのオプション
			:col_sep => ',',
			:skip_blanks => true,
			:headers => daysRowAt
		}
		file = CSV.read(TEMP_CSV_NAME, options)

		(rowAt(file.to_a, '朝食')-1).times do
			file.delete(0)
		end

		# 一番左の列が空白なので削る
		file.by_col!
		file.delete(0)
		file.by_row!

		# 空白を除いたCSV::TableをArrayに変換
		arr = file.to_a

		# 日付を配列に格納
		days = Array.new
		1.step(getLengthOfCols(file), 3) do |i|
			header = file.headers
			if !header[i].nil? && header[i] != ' '
				days.push(header[i])
			end
		end

		# すべてのメニューを格納する配列を作成
		menu = Array.new(days.length)

		# 朝昼夕と合計が何行目から始まるかを格納する配列		
		meal_header = [
			rowAt(arr, '朝食'),
			rowAt(arr, '昼食'),
		  rowAt(arr, '夕食'),
		  rowAt(arr, '合計')
		]

		period_names = ['breakfast', 'lunch', 'dinner']

		# 初日の日付は2列目
		day_header = 1
		dishes = Array.new
		meals  = Array.new

		# 1日単位のループ
		for day_count in 0...days.length do

			# 1日分の食事を3要素で格納
			daily_meal = Array.new(period_names.length)

			# 食事単位のループ 0:朝 1:昼 2:夜
			period_names.length.times do |period|
				daily_meal[period] = Hash.new

				period_meal_offset = 0

				while !arr[meal_header[period] + period_meal_offset][day_header + 2].nil? && arr[meal_header[period] + period_meal_offset][day_header + 2].include?('KC')
					dishes << {
						name:         arr[meal_header[period] + period_meal_offset][day_header],
						kilo_calorie: arr[meal_header[period] + period_meal_offset][day_header+2].delete('KC').to_i,
						meal_id:      day_count * 3 + period + 1
					}
					period_meal_offset += 1
				end

				while arr[meal_header[period] + period_meal_offset][day_header] == ' ' || arr[meal_header[period] + period_meal_offset][day_header].nil?
					period_meal_offset += 1
				end

				nutrition = getNutrition(arr[meal_header[period] + period_meal_offset][day_header])
				meals << {
					date:         "%04d"%filename_year[0,4] + "%02d"%getMonth(days[day_count]) + "%02d"%getDay(days[day_count]),
					period:       period_names[period],
					energy:       nutrition[:energy],
					protein:      nutrition[:protein],
					fat:          nutrition[:fat],
					carbohydrate: nutrition[:carbohydrate],
					salt:         nutrition[:salt]
				}
			end
			day_header += 3
		end

		File.unlink(TEMP_CSV_NAME)

		CSV.open('tmp/menu/dish.csv', 'wb') do |csv|
			csv << dishes.first.keys.unshift('id')
			dishes.each_with_index do |row, i|
				csv << row.values.unshift(i + 1)
			end
		end

		CSV.open('tmp/menu/meal.csv', 'wb') do |csv|
			csv << meals.first.keys.unshift('id')
			meals.each_with_index do |row, i|
				puts row.class
				if row.has_value?(nil)
					row = {date:row[:date], period:row[:period], energy:0, protein:0, fat:0, carbohydrate:0, salt:0}
				end
				csv << row.values.unshift(i + 1)
			end
		end
	end

	def createModels
		dish_csv = CSV.read('tmp/menu/dish.csv', {headers: true})
		meal_csv = CSV.read('tmp/menu/meal.csv', {headers: true})

		updated = false
		meal_csv.each do |row|
			meal = Meal.where(:date => row[1], :period => row[2]).first_or_initialize
			meal.new_record? ? updated = true : updated = false
			meal.update_attributes(
				:energy       => row[3],
				:protein	    => row[4],
				:fat 		      => row[5],
				:carbohydrate => row[6],
				:salt		      => row[7]
			)
		end

		# 1 dish.csvのmeals_id => meal.csvのidとひもづけ
		# 2 meal.csvのdateとperiodをとってきてデータベースと照合
		# 3 データベースからidをとってくる

		# meal.csv
		# | id | date | period | energy | protein | fat | carbohydrate | salt |

		# dish.csv
		# | id | name | kcal | meals_id |

		if updated
			dish_csv.each do |dish_row|

				tmp_date, tmp_period, current_meal_id = nil

				meal_csv.each do |meal_row|
					if meal_row[0] == dish_row[3]
						tmp_date   = meal_row[1] 
						tmp_period = meal_row[2]
					end
				end

				current_meal_id = Meal.where(date: tmp_date, period: tmp_period).first.id

				DishEnergy.create(
						:name         => dish_row[1],
						:kilo_calorie => dish_row[2],
						:meal_id      => current_meal_id
				)

				dish = Dish.where(name: dish_row[1]).first_or_initialize
				dish.save

				menu = Menu.where(meal_id: current_meal_id, dish_id: dish.id).first_or_initialize
				menu.save
			end
		end

		# File.unlink('tmp/menu/dish.csv')
		# File.unlink('tmp/menu/meal.csv')
	end
end