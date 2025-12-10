# encoding: UTF-8
require 'faker'

if Rails.env.development?
	puts "既存データをクリア中..."

	[DmMessage, DmRoom, Notification, ReviewResponse, PlaceOwner,
Bookmark, EntityTag, Like, Comment, ReviewImage, Review, RouteItem,Route, Venue, District, City, Tag, Follower, User].each do |model|
	model.delete_all
end

	# IDカウンターをリセット
	ActiveRecord::Base.connection.tables.each do |table|
		ActiveRecord::Base.connection.reset_pk_sequence!(table)
	end

	puts "クリア完了"
end

puts "シードデータの作成中..."


#=========================== 1. Users ==============================
puts "ユーザーを作成中。。。"

# Создание Администратора: используем new, чтобы избежать колбэка
admin = User.new(
  username: 'admin',
  email: 'admin@smartroutes.com',
  password: 'password',
  password_confirmation: 'password',
  is_admin: true,
  bio: "SmartRoutesの管理者です。",
  location: 'Kyoto, Japan',
  email_verified: true
)
admin.skip_confirmation! # <-- Пропускаем отправку письма
admin.save!              # <-- Сохраняем без ошибок

# Создание 30 обычных пользователей: то же исправление
30.times do |i|
  user = User.new(
    username: "user#{i + 1}",
    email: "user#{i + 1}@example.com",
    password: 'password123',
    password_confirmation: 'password123',
    bio: Faker::Lorem.sentence,
    location: ['Nara', 'Osaka', 'Kyoto'].sample,
    budget_min: [1000, 2000, 3000, 5000].sample,
    budget_max: [5000, 10000, 15000, 20000].sample,
    email_verified: true
  )
  user.skip_confirmation! # <-- Пропускаем отправку письма
  user.save!              # <-- Сохраняем без ошибок
end

puts "#{User.count}人のユーザーを作成しました。"

users = User.all
nil

#================== 2. Cities & Districts =====================
puts  "都市とエリアを作成中..."

#京都
kyoto = City.create!(
	name: '京都',
	name_en: 'Kyoto',
	description: '千年の都、日本の伝統文化の中心地'
)

kyoto_districts_data = [
	{ name: '東山区', name_en: 'Higashiyama' },
  { name: '祇園', name_en: 'Gion' },
  { name: '嵐山', name_en: 'Arashiyama' },
  { name: '伏見', name_en: 'Fushimi' },
  { name: '下鴨', name_en: 'Shimogamo' },
  { name: '北区', name_en: 'Kita Ward' },
  { name: '中京区', name_en: 'Nakagyo' }
]

kyoto_districts = kyoto_districts_data.map do |data|
	kyoto.districts.create!(data)
end

#大阪
osaka = City.create!(
	name: '大阪',
	name_en: 'Osaka',
	description: '日本第二の都市、食い倒れの街'
)

osaka_districts_data = [
	{ name: '道頓堀', name_en: 'Dotonbori' },
  { name: '梅田', name_en: 'Umeda' },
  { name: '難波', name_en: 'Namba' },
  { name: '心斎橋', name_en: 'Shinsaibashi' },
  { name: '天王寺', name_en: 'Tennoji' },
  { name: '新世界', name_en: 'Shinsekai' },
  { name: '中央区', name_en: 'Chuo Ward' },
  { name: '北区', name_en: 'Kita Ward' }
]

osaka_districts = osaka_districts_data.map do |data|
	osaka.districts.create!(data)
end

puts "#{City.count}都市と#{District.count}エリアを作成しました。" 

#=========================== 3. Tags ==============================
puts "タグを作成中..."

tags_data = %w[
	ramen sushi izakaya cafe bar yakiniku okonomiyaki takoyaki
  vegan halal familyfriendly romantic budget luxury
  historic temple shrine castle museum shopping nightlife
  view photogenic hidden_gem local_favorite michelin
  breakfast lunch dinner latenight 24hours
  traditional modern garden bamboo cherry_blossom
]

tags = tags_data.map do |tag_name|
	Tag.create!(parameter: tag_name)
end

puts "#{Tag.count}個のタグを作成しました"

#===================== 4. Venues - Kyoto ========================
puts " 京都の場所を作成中..."

kyoto_venues_data = [
	{
		name: '清水寺',
		venue_type: 'temple',
		description: '京都を代表する寺院。清水の舞台からの眺めは圧巻です。',
		address: '京都市東山区清水1-294',
		price_range: '¥',
		phone: '075-551-1234',
		business_hours: '6:00-18:00',
		geo_lat: 34.9949,
    geo_lng: 135.7850,
		district: kyoto_districts[0],
		tags: ['temple', 'historic', 'view', 'photogenic', 'world_heritage'],
		status: 'approved'
	},
	{
		name: '伏見稲荷大社',
		venue_type: 'shrine',
		description: '千本鳥居で有名な神社。幻想的な赤い鳥居のトンネルが続きます。',
		address: '京都市伏見区深草藪之内町68',
		phone: '075-641-7331',
		business_hours: '24時間開放',
		geo_lat: 34.9671,
    geo_lng: 135.7727,
		district: kyoto_districts[3],
		tags: ['shrine', 'historic', 'photogenic', 'hiking', 'free'],
		status: 'approved'
	},
	{
		name: '金閣寺',
		venue_type: 'temple',
		description: '金箔で覆われた舎利殿。池に映る姿は息をのむ美しさ。',
    address: '京都市北区金閣寺町1',
		price_range: '¥',
		phone: '075-461-0013',
		business_hours:'09:00-17:00',
		geo_lat: 35.0394,
    geo_lng: 135.7292,
		district: kyoto_districts[5],
		tags: ['temple', 'historic', 'garden', 'photogenic', 'world_heritage'],
		status: 'approved'
	},
	{
    name: '嵐山竹林の小径',
    venue_type: 'nature',
    description: '幻想的な竹林のトンネル。京都を代表する景観スポット。',
    address: '京都市右京区嵐山',
    price_range: '無料',
    business_hours: '24時間開放',
    geo_lat: 35.0089,
    geo_lng: 135.6722,
    district: kyoto_districts[2],
    tags: ['nature', 'bamboo', 'photogenic', 'walking', 'free'],
    status: 'approved'
  },
  {
    name: '祇園 花見小路',
    venue_type: 'historic_street',
    description: '舞妓さんが歩く伝統的な街並み。京都らしさを感じる場所。',
    address: '京都市東山区祇園町南側',
    price_range: '無料',
    business_hours: '24時間開放',
    geo_lat: 35.0037,
    geo_lng: 135.7749,
    district: kyoto_districts[1],
    tags: ['historic', 'traditional', 'photogenic', 'walking', 'geisha'],
    status: 'approved'
  },
  {
    name: 'イノダコーヒ 本店',
    venue_type: 'cafe',
    description: '京都を代表する老舗喫茶店。伝統のコーヒーとモーニング。',
    address: '京都市中京区堺町通三条下ル道祐町140',
    cuisine_type: 'cafe',
    price_range: '¥¥',
    phone: '075-221-0507',
    business_hours: '7:00-19:00',
    geo_lat: 35.0084,
    geo_lng: 135.7628,
    district: kyoto_districts[6],
    tags: ['cafe', 'breakfast', 'traditional', 'coffee'],
    status: 'approved'
  },
  {
    name: '天下一品 本店',
    venue_type: 'restaurant',
    description: '濃厚こってりスープが名物のラーメン店の本店。',
    address: '京都市左京区一乗寺築田町94',
    cuisine_type: 'ramen',
    price_range: '¥',
    phone: '075-722-0955',
    business_hours: '11:00-翌2:00',
    geo_lat: 35.0456,
    geo_lng: 135.7897,
    district: kyoto_districts[4],
    tags: ['ramen', 'lunch', 'dinner', 'latenight', 'local_favorite'],
    status: 'approved'
  },
  {
    name: '錦市場',
    venue_type: 'market',
    description: '京の台所。400年の歴史を持つ食材の宝庫。',
    address: '京都市中京区錦小路通',
    price_range: '¥',
    business_hours: '10:00-18:00',
    geo_lat: 35.0050,
    geo_lng: 135.7642,
    district: kyoto_districts[6],
    tags: ['market', 'food', 'shopping', 'traditional', 'local'],
    status: 'approved'
  }
]

kyoto_venues = kyoto_venues_data.map do |data|
	tag_names = data.delete(:tags)
	district = data.delete(:district)

	venue = Venue.create!(
		**data,
		district: district,
		user:users.sample
	)

	tag_names.each do |tag_name|
		tag = tags.find { |t| t.parameter == tag_name }
		EntityTag.create!(entity: venue, tag: tag) if tag
	end

	venue
end

puts "京都の場所 #{kyoto_venues.count}件を作成しました"


# ==================== 5. Venues - OSAKA ====================
puts "大阪の場所を作成中..."

osaka_venues_data = [
	{
		name: '一蘭ラーメン 道頓堀店',
		venue_type: 'restaurant',
		description: '大阪で最高の深夜ラーメン店！個室ブースで一人でも気軽に楽しめます。',
    address: '大阪市中央区道頓堀1-7-3',
		cuisine_type: 'ramen',
		price_range: '¥',
		phone: '06-6211-0101',
		business_hours: '24時間営業',
    geo_lat: 34.6686,
    geo_lng: 135.5020,
		district: osaka_districts[0],
		tags: ['ramen', 'latenight', '24hours', 'solo_dining'],
		status: 'approved'
	},
	{
		 name: '大阪城',
    venue_type: 'castle',
    description: '大阪のシンボル。天守閣からの眺めは絶景です。',
    address: '大阪市中央区大阪城1-1',
    price_range: '¥',
    phone: '06-6941-3044',
    business_hours: '9:00-17:00',
    geo_lat: 34.6873,
    geo_lng: 135.5262,
		district: osaka_districts[6],
		tags: ['historic', 'castle', 'landmark', 'photogenic', 'cherry_blossom'],
		status: 'approved'
	},
{
    name: 'たこ焼き道楽わなか 本店',
    venue_type: 'restaurant',
    description: '本場大阪のたこ焼き！外はカリッと中はトロトロ。',
    address: '大阪市中央区難波3-7-1',
    cuisine_type: 'takoyaki',
    price_range: '¥',
    business_hours: '10:00-22:00',
    geo_lat: 34.6654,
    geo_lng: 135.5009,
    district: osaka_districts[2],
    tags: ['takoyaki', 'street_food', 'local_favorite', 'budget'],
    status: 'approved'
  },
  {
    name: 'くくる 本店',
    venue_type: 'restaurant',
    description: '新鮮な海鮮たこ焼きが人気。行列必至の名店。',
    address: '大阪市中央区道頓堀1-10-5',
    cuisine_type: 'takoyaki',
    price_range: '¥',
    business_hours: '11:00-23:00',
    geo_lat: 34.6688,
    geo_lng: 135.5021,
    district: osaka_districts[0],
    tags: ['takoyaki', 'seafood', 'popular', 'lunch'],
    status: 'approved'
  },
  {
    name: '千房 道頓堀店',
    venue_type: 'restaurant',
    description: '大阪名物お好み焼きの老舗。ふわふわの食感が絶品。',
    address: '大阪市中央区道頓堀1-5-5',
    cuisine_type: 'okonomiyaki',
    price_range: '¥¥',
    phone: '06-6212-2211',
    business_hours: '11:00-23:00',
    geo_lat: 34.6685,
    geo_lng: 135.5018,
    district: osaka_districts[0],
    tags: ['okonomiyaki', 'lunch', 'dinner', 'family_friendly'],
    status: 'approved'
  },
  {
    name: 'アラビヤコーヒー',
    venue_type: 'cafe',
    description: '昭和レトロな雰囲気の喫茶店。モーニングが人気。',
    address: '大阪市中央区心斎橋筋2-4-9',
    cuisine_type: 'cafe',
    price_range: '¥',
    business_hours: '8:00-19:00',
    geo_lat: 34.6710,
    geo_lng: 135.5025,
    district: osaka_districts[3],
    tags: ['cafe', 'breakfast', 'retro', 'local'],
    status: 'approved'
  },
  {
    name: '焼肉 力丸',
    venue_type: 'restaurant',
    description: 'コスパ最強の焼肉店。ホルモンが絶品。',
    address: '大阪市中央区千日前1-9-19',
    cuisine_type: 'yakiniku',
    price_range: '¥¥',
    business_hours: '17:00-24:00',
    geo_lat: 34.6665,
    geo_lng: 135.5028,
    district: osaka_districts[2],
    tags: ['yakiniku', 'dinner', 'budget', 'meat'],
    status: 'approved'
  },
  {
    name: '串カツだるま 新世界総本店',
    venue_type: 'restaurant',
    description: '新世界名物の串カツ。ソースの二度漬け禁止！',
    address: '大阪市浪速区恵美須東2-3-9',
    cuisine_type: 'kushikatsu',
    price_range: '¥',
    business_hours: '11:00-22:30',
    geo_lat: 34.6524,
    geo_lng: 135.5066,
    district: osaka_districts[5],
    tags: ['kushikatsu', 'izakaya', 'local', 'dinner'],
    status: 'approved'
  },
  {
    name: 'グランフロント大阪',
    venue_type: 'shopping',
    description: '梅田の大型複合施設。ショッピングとグルメが楽しめる。',
    address: '大阪市北区大深町4-1',
    price_range: '¥¥¥',
    business_hours: '10:00-21:00',
    geo_lat: 34.7056,
    geo_lng: 135.4972,
    district: osaka_districts[1],
    tags: ['shopping', 'modern', 'family_friendly', 'luxury'],
    status: 'approved'
  },
  {
    name: '通天閣',
    venue_type: 'landmark',
    description: '新世界のシンボルタワー。展望台からの眺めが最高。',
    address: '大阪市浪速区恵美須東1-18-6',
    price_range: '¥',
    phone: '06-6641-9555',
    business_hours: '10:00-20:00',
    geo_lat: 34.6525,
    geo_lng: 135.5063,
    district: osaka_districts[5],
    tags: ['landmark', 'tower', 'view', 'photogenic', 'retro'],
    status: 'approved'
  },
  {
    name: '黒門市場',
    venue_type: 'market',
    description: '大阪の台所。新鮮な海鮮と食べ歩きが楽しい。',
    address: '大阪市中央区日本橋2-4-1',
    price_range: '¥¥',
    business_hours: '9:00-18:00',
    geo_lat: 34.6632,
    geo_lng: 135.5081,
    district: osaka_districts[2],
    tags: ['market', 'seafood', 'food', 'local', 'shopping'],
    status: 'approved'
  },
  {
    name: '海遊館',
    venue_type: 'aquarium',
    description: '世界最大級の水族館。ジンベエザメが人気。',
    address: '大阪市港区海岸通1-1-10',
    price_range: '¥¥',
    phone: '06-6576-5501',
    business_hours: '10:00-20:00',
    geo_lat: 34.6547,
    geo_lng: 135.4287,
    district: osaka_districts[6],
    tags: ['aquarium', 'family_friendly', 'indoor', 'popular'],
    status: 'approved'
  }
]

osaka_venues = osaka_venues_data.map do |data|
	tag_names = data.delete(:tags),
	district = data.delete(:district),

	venue = Venue.create!(
		**data,
		district: district,
		user: users.sample
	)

	tag_names.each do |tag_name|
		tag = tags.find { |t| t.parameter == tag_name }
		EntityTag.create!(entity: venue, tag: tag) if tag
	end

	venue
end

puts "大阪の場所 #{osaka_venues.count}件を作成しました"

all_venues = kyoto_venues + osaka_venues


# ==================== 6. Routes ====================
puts "ルートを作成中..."

routes_data = [
  {
    name: "京都 — 大阪 (3日間)",
    description: "京都と大阪の主要観光スポットを巡る3日間のルート",
    estimated_duration: 4320,
    estimated_cost: 50000,
    difficulty_level: 'easy',  # Changed from '簡単'
    is_public: true,
    user: users.sample,
    city: kyoto
  },
	{
		 name: '京都 世界遺産めぐり',
    description: '清水寺、金閣寺、伏見稲荷大社を一日で。京都の三大名所を制覇！',
		estimated_duration: 480,
		estimated_cost: 3000, 
		difficulty_level: 'medium',
		venues: [kyoto_venues[0], kyoto_venues[2], kyoto_venues[1]],
		tags: ['historic', 'temple', 'world_heritage', 'walking']
	},
	{
		name: '嵐山・祇園 伝統美満喫コース',
    description: '竹林と舞妓さんの街。京都らしさを存分に味わう。',
    estimated_duration: 360,
    estimated_cost: 5000,
		difficulty_level: 'easy',
		venues: [kyoto_venues[3], kyoto_venues[4], kyoto_venues[5]],
		tags: ['traditional', 'photogenic', 'bamboo', 'culture']
	},{
    name: '究極の大阪グルメツアー',
    description: '大阪の名物料理を一日で制覇！たこ焼き、お好み焼き、串カツ、ラーメンまで。',
    estimated_duration: 360,
    estimated_cost: 5000,
    difficulty_level: 'easy',
    venues: [osaka_venues[2], osaka_venues[4], osaka_venues[7], osaka_venues[0]],
    tags: ['food', 'takoyaki', 'okonomiyaki', 'budget']
  },
  {
    name: '大阪 歴史と現代の融合',
    description: '大阪城から梅田の超高層ビルまで。歴史と未来を感じる旅。',
    estimated_duration: 420,
    estimated_cost: 8000,
    difficulty_level: 'medium',
    venues: [osaka_venues[1], osaka_venues[8], osaka_venues[10]],
    tags: ['historic', 'modern', 'shopping', 'castle']
  },
  {
    name: 'ディープ大阪 新世界探検',
    description: '通天閣と串カツ。昭和レトロな大阪を体験。',
    estimated_duration: 240,
    estimated_cost: 3000,
    difficulty_level: 'easy',
    venues: [osaka_venues[9], osaka_venues[7], osaka_venues[10]],
    tags: ['local', 'retro', 'kushikatsu', 'nightlife']
  },
  {
    name: '京都・大阪 2都市周遊プラン',
    description: '京都の寺院めぐりから大阪のグルメまで。関西を満喫する欲張りコース。',
    estimated_duration: 600,
    estimated_cost: 12000,
    difficulty_level: 'hard',
    venues: [kyoto_venues[0], kyoto_venues[1], osaka_venues[1], osaka_venues[2], osaka_venues[0]],
    tags: ['temple', 'food', 'historic', 'comprehensive']
  },
  {
    name: 'インスタ映え京都',
    description: '金閣寺、竹林、祇園。京都の絶景スポット巡り。',
    estimated_duration: 300,
    estimated_cost: 4000,
    difficulty_level: 'easy',
    venues: [kyoto_venues[2], kyoto_venues[3], kyoto_venues[4]],
    tags: ['photogenic', 'instagram', 'garden', 'traditional']
  },
  {
    name: '大阪 食べ歩きパラダイス',
    description: '黒門市場で海鮮、道頓堀でたこ焼き。大阪の食文化を堪能。',
    estimated_duration: 300,
    estimated_cost: 6000,
    difficulty_level: 'easy',
    venues: [osaka_venues[10], osaka_venues[2], osaka_venues[3], osaka_venues[4]],
    tags: ['food', 'market', 'seafood', 'street_food']
  },
  {
    name: 'ファミリー向け 京都・大阪',
    description: '子供も楽しめる！海遊館、大阪城、錦市場の家族旅行。',
    estimated_duration: 480,
    estimated_cost: 15000,
    difficulty_level: 'medium',
    venues: [osaka_venues[11], osaka_venues[1], kyoto_venues[7]],
    tags: ['family_friendly', 'aquarium', 'castle', 'market']
  },
  {
    name: '京都カフェ巡り & ラーメン',
    description: '老舗喫茶店のモーニングから名物ラーメンまで。京都の食を味わう。',
    estimated_duration: 360,
    estimated_cost: 4000,
    difficulty_level: 'easy',
    venues: [kyoto_venues[5], kyoto_venues[7], kyoto_venues[6]],
    tags: ['cafe', 'ramen', 'food', 'local_favorite']
  }
]



routes = routes_data.map.with_index do |data, idx|
  tag_names     = Array(data.delete(:tags))
  venues_to_add = Array(data.delete(:venues)).compact
  user = users[idx % users.length]

  # city fallback: если первый venue не имеет city, берем случайный
  cities = City.all.to_a
  city = venues_to_add.first&.district&.city || cities.sample

  # создаём маршрут
  route = Route.create!(
    **data,
    user: user,
    city: city,
    is_public: true
  )

  # создаём RouteItems
  venues_to_add.each_with_index do |venue_data, position|
  venue = venue_data.is_a?(Venue) ? venue_data : Venue.find_by(name: venue_data[:name])
  next unless venue

  puts "venue attributes keys: #{venue.attributes.keys}"

  RouteItem.create!(
    route: route,
    item_id: venue.id,                # ← ПОЛИМОРФНЫЙ
    item_type: "venue",         # ← ВАЛИДНЫЙ ТИП
    position: position + 1,
    notes: "おすすめポイント: #{venue.description[0..50]}"
  )
end

  # создаём теги
  tag_names.each do |tag_name|
    tag = tags.find { |t| t.parameter == tag_name }
    EntityTag.create!(entity: route, tag: tag) if tag
  end

  route
end

puts "#{Route.count}件のルートを作成しました"


# ==================== 7. Reviews ====================
puts "レビューを作成中..."

all_venues.each do |venue|
	rand(3..10).times do
		user = users.sample
		next if Review.exists?(user: user, reviewable: venue)

		Review.create!(
			user: user,
			reviewable: venue,
			text: Faker::Restaurant.review,
			total_score: [3.5, 4.0, 5.0].sample
		)
	end
end

routes.each do |route|
	rand(3..8).times do
		user = users.sample
		next if Review.exists?(user: user, reviewable: route)


		Review.create!(
			user:user,
			reviewable: route,
			text: "素晴らしいルートでした！" + Faker::Lorem.paragraph,
			total_score: [4.0, 4.5, 5.0].sample
		)
	end
end

puts "#{Review.count}件のレビューを作成しました"

# ==================== 8. Comments ====================
puts "コメントを作成中..."

Review.limit(30).each do |review|
	rand(0..4).times do
		Comment.create!(
			user: users.sample,
			commentable: review,
			text: Faker::Lorem.sentence
		)
	end
end

puts "#{Comment.count}件のコメントを作成しました"


# ==================== 9. Likes ====================
puts "いいねを作成中..."

all_venues.each do |venue|
	users.sample(rand(8..20)).each do |user|
		Like.create!(user: user, likeable: venue)
	end
end

routes.each do |route|
	users.sample(rand(5..15)).each do |user|
		Like.create!(user: user, likeable: route)
	end
end

Review.limit(50).each do |review|
	users.sample(rand(1..6)).each do |user|
		Like.create!(user: user, likeable: review)
	end
end

puts  "#{Like.count}件のいいねを作成しました"

# ==================== 10. Followers ====================
puts "フォロー関係を作成中..."

users.first(15).each do |user|
	users.sample(rand(4..10)).each do |following_user|
		next if user == following_user
		Follower.create!(
			follower_user: user,
			following_user: following_user,
			status: 'accepted'
		) rescue ActiveRecord::RecordInvalid
	end
end

puts "#{Follower.count}件のフォロー関係を作成しました"


# ==================== 11. Bookmarks ====================
puts "ブックマークを作成中..."

users.first(15).each do |user|
	all_venues.sample(rand(3..8)).each do |venue|
		Bookmark.create!(
			user: user,
			item: venue,
			correction_name: ['Want to Visit', 'Favorites', 'Hidden Gems', 'Kyoto Must-See', 'Osaka Food'].sample
		) rescue ActiveRecord::RecordInvalid
	end

	routes.sample(rand(2..4)).each do |route|
		Bookmark.create!(
			user: user,
			item: route,
			collection_name: ['Want to Try', 'Favorites', 'Saved Routes'].sample
		)rescue ActiveRecord::RecordInvalid 
	end
end

puts "#{Bookmark.count}件のブックマークを作成しました"

# ==================== 12. DM Rooms & Messages ====================
puts "DMルームとメッセージを作成中..."

users.first(10).each do |sender|
	receiver = users.sample
	next if sender == receiver

	room = DmRoom.create!(
		sender: sender, 
		receiver: receiver,
	) rescue nil

	if room 
		rand(3..8).times do 
			DmMessage.create!(
				dm_room: room,
				user: [sender, receiver].sample,
				message: Faker::Lorem.sentence,
				is_read: [true, false].sample
			)
		end
	end
end

puts "#{DmRoom.count}件のDMルーム、#{DmMessage.count}件のメッセージを作成しました"


# ==================== 13. Notifications ====================
puts "通知を作成中..."

users.first(15).each do |u|
  rand(5..12).times do
    notifiable = [all_venues, routes, Review.all].flatten.sample

    Notification.create!(
      user: u,
      actor: users.sample,
      notification_type: %w[follow like comment review].sample,
      entity_type: notifiable.class.name,
      entity_id: notifiable.id,
      is_read: [true, false].sample
    )
  end
end

puts "#{Notification.count}件の通知を作成しました"


# Update venues with coordinates
puts "Updating venues with coordinates..."

# Kyoto venues
kinkakuji = Venue.find_by(name: "金閣寺")
kinkakuji&.update(geo_lat: 35.0394, geo_lng: 135.7292)

fushimi = Venue.find_by(name: "伏見稲荷大社")
fushimi&.update(geo_lat: 34.9671, geo_lng: 135.7727)

# Osaka venues  
osaka_castle = Venue.find_by(name: "大阪城")
osaka_castle&.update(geo_lat: 34.6873, geo_lng: 135.5262)

dotonbori = Venue.find_by(name: "道頓堀")
dotonbori&.update(geo_lat: 34.6686, geo_lng: 135.5004)

puts "✓ Venues coordinates updated"



# ============ 14. Place Owners (ビジネスアカウント) ============
puts "ビジネスアカウントを作成中..."

# 京都の主要施設
[kyoto_venues[0], kyoto_venues[2], kyoto_venues[5]].each do |venue| 
	PlaceOwner.create!(
		user: users.sample, 
		venue: venue,
		role: 'owner',
		status: 'approved',
		verified_at: Time.current,
		verified_by: admin.id,
		business_name: venue.name,
		contact_email: "owner#{venue.id}@example.com",
		contact_phone: '+81-75-123-4567'
	)
end

# 大阪の主要施設
[osaka_venues[0], osaka_venues[4], osaka_venues[8]].each do |venue|
	PlaceOwner.create!(
		user: users.sample,
		venue: venue,
		role: 'owner',
		status: 'approved',
		verified_at: Time.current,
		verified_by: admin.id,
		business_name: venue.name,
		contact_email: "owner#{venue.id}@example.com",
		contact_phone: '+81-6-1234-5678'
	)
end

puts "#{PlaceOwner.count}件のビジネスアカウントを作成しました"

# ============ 15. Cordinates for venues ============

#Update venues with coordinates
puts "Updating venues with coordinates..."

#Kyoto venues
kinkakuji = Venue.find_by(name: "金閣寺")
kinkakuji&.update(geo_lat: 35.0934, geo_lng: 135.7292)

fushimi = Venue.find_by(name: "稲荷大社")
fushimi&.updateI(geo_lat: 34.9671, geo_lng: 135.7727)

#Osaka venues
osaka_castle = Venue.find_by(name: "大阪城")
osaka_castle&.update(geo_lat:34.6873, geo_lng: 135.5262)

dotonbori = Venue.find_by(name: "道頓堀")
dotonbori&.update(geo_lat: 34.6686, geo_lng: 135.5004)

puts "Venues coordinates updated"

=begin
# ==================== 完了 ====================
puts "\n 京都・大阪シードデータの作成が完了しました！\n"
puts "=" * 60
puts "作成されたデータ:"
puts "  • ユーザー: #{User.count}人"
puts "  • 都市: #{City.count}都市 (京都、大阪)"
puts "  • エリア: #{District.count}エリア"
puts "  • 場所: #{Venue.count}件 (京都: #{kyoto_venues.count}件、大阪: #{osaka_venues.count}件)"
puts "  • ルート: #{Route.count}件"
puts "  • レビュー: #{Review.count}件"
puts "  • コメント: #{Comment.count}件"
puts "  • いいね: #{Like.count}件"
puts "  • フォロー: #{Follower.count}件"
puts "  • ブックマーク: #{Bookmark.count}件"
puts "  • DMルーム: #{DmRoom.count}件"
puts "  • メッセージ: #{DmMessage.count}件"
puts "  • 通知: #{Notification.count}件"
puts "  • ビジネスアカウント: #{PlaceOwner.count}件"
puts "  • タグ: #{Tag.count}個"

=end