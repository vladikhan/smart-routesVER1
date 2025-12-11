# Encoding: UTF-8
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do # Валидации
    # Subject должен быть определен, чтобы Shoulda Matchers мог корректно проверить uniqueness.
    # Shoulda Matchers создаёт и сохраняет первый объект, затем пытается создать второй,
    # чтобы проверить уникальность.
    subject { build(:user) } 

    it { should validate_presence_of(:username) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:username).case_insensitive }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'アソシエーション' do # Ассоциации
    it { should have_many(:routes).dependent(:destroy) }
    it { should have_many(:notifications).dependent(:destroy) }
  end

  describe 'メソッド' do # Методы экземпляра
    let(:user) { create(:user) }

    describe '#unread_notifications_count' do # Проверка метода подсчёта непрочитанных уведомлений
      before do
        # 1. Создание 3 непрочитанных уведомлений (по умолчанию)
        create_list(:notification, 3, user: user) 
        
        # 2. Создание 2 прочитанных уведомлений:
        # ПРАВИЛЬНОЕ ИСПОЛЬЗОВАНИЕ: трейт :read должен быть передан в качестве аргумента.
        create_list(:notification, 2, :read, user: user) # <-- ИСПРАВЛЕНО
      end

      it '未読通知の数を返す' do # Возвращает количество непрочитанных уведомлений
        expect(user.unread_notifications_count).to eq(3)
      end
    end
  end
end