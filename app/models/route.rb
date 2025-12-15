class Route < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :city
  has_many :route_items, dependent: :destroy
  has_many :venues, through: :route_items
  has_many :entity_tags, as: :entity, dependent: :destroy
  has_many :tags, through: :entity_tags
  has_many :bookmarks, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy
  
  # Validations

  # Ассоциации
  belongs_to :user
  belongs_to :city, optional: true
  has_many :route_items, dependent: :destroy
  has_many :venues, through: :route_items
  has_many :bookmarks, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :notifications, dependent: :destroy
  
  # Для тегов (если используется acts-as-taggable-on)
  if defined?(ActsAsTaggableOn)
    acts_as_taggable_on :tags
  else
    # Простая реализация тегов без гема
    serialize :tag_list, Array
    
    def tag_list
      super || []
    end
    
    def tag_list=(value)
      if value.is_a?(String)
        super(value.split(',').map(&:strip))
      else
        super(value)
      end
    end
  end
  
  # Валидации
  validates :name, presence: true, length: { maximum: 100 }
  validates :user, presence: true
  validates :view_count, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  
  # Вложенные атрибуты
  accepts_nested_attributes_for :route_items, 
                                allow_destroy: true,
                                reject_if: :all_blank
  
  # Скоупы
  scope :public_routes, -> { where(is_public: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :trending, -> { order(view_count: :desc) }
  scope :by_city, ->(city_id) { where(city_id: city_id) }
  scope :budget, -> { where("estimated_cost <= ?", 5000) }
  
  # Колбэки
  before_create :initialize_view_count
  
  # Методы
  def increment_view_count!
    increment!(:view_count)
  end
  
  def owner?(user)
    self.user == user
  end
  
  private
  
  def initialize_view_count
    self.view_count ||= 0
  end
end
