require 'test_helper'

class TrendsControllerTest < ActionController::TestCase

  context 'User with no trend topic' do
    setup do
      @user = FactoryGirl.create(:administrator)
      sign_in @user
      @request.env['devise.mapping'] = Devise.mappings[:user]
      @trend = FactoryGirl.build(:trending)
      post :create, {name: @trend.name, url: @trend.url}
    end

    should 'associate the trend to the user' do
      query = User.joins(:trends).where('email = ? AND trends.name = ? AND trends.url = ?',
                                        @user.email, @trend.name, @trend.url)
      assert_not_empty query
    end
  end

  context 'not insert equal trending topics' do
    setup do
      @user = FactoryGirl.create(:administrator)
      @trend = FactoryGirl.build(:trending)
      @user.trends << @trend

      sign_in @user
      @request.env['devise.mapping'] = Devise.mappings[:user]

      post :create, {name: @trend.name, url: @trend.url}

    end

    should 'only have one trend topic for user' do
      trends = User.joins(:trends).where('email = ? AND trends.name = ? AND trends.url = ?',
                                        @user.email, @trend.name, @trend.url)
      assert_equal 1, trends.size
    end
  end

  context 'if exist a trending topic, not create other equal' do
    setup do
      @user = FactoryGirl.create(:administrator)
      @trend = FactoryGirl.build(:trending)
      @user.trends << @trend
      @second_user = FactoryGirl.create(:common)
      sign_in @second_user

      @request.env['devise.mapping'] = Devise.mappings[:second_user]
      post :create, {name: @trend.name, url: @trend.url}
    end

    should 'asociate the same trend to second_user' do
      query = User.joins(:trends).where('email = ? AND trends.name = ? AND trends.url = ?',
                                        @second_user.email, @trend.name, @trend.url)
      assert_equal 1, query.size
      query = User.joins(:trends).where('email = ? AND trends.name = ? AND trends.url = ?',
                                        @user.email, @trend.name, @trend.url)
      assert_equal 1, query.size
      trends = Trend.where('name = ? AND url = ?', @trend.name, @trend.url)
      assert_equal 1, trends.size
    end
  end

end
