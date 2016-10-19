
FactoryGirl.define do
  factory :mailchimp_webhook do
    event_type "MyString"
    email "MyString"
    payload "MyText"
  end

  factory :tag, class: Tag do
    sequence(:name) { |n| "Tag #{n}" }
    tag_type "category"
  end

  factory :link, class: Link do
    sequence(:title) { |n| "title #{n}" }
    sequence(:url) { |n| "http://localhost/#{n}" }
    sequence(:creator) { |n| create(:user) }
    approved true
  end

  factory :user, class: User do
    sequence(:name)  { |n| "Chuck Strum #{n}" }
    sequence(:email) { |n| "user_#{n}@themarshallproject.org" }
    password { SecureRandom.hex }
  end

  factory :post, class: Post do
    sequence(:title)   { |n| "Post Title #{n}" }
    sequence(:deck)    { |n| "#{n} #{'Deck '*n}" }
    sequence(:content) { |n| "#{n} #{'Content '*n}" }
    status "draft"

    factory :published_post do
      after(:create) do |post|
        post.status = 'published'
        post.rubric = create(:tag, name: SecureRandom.hex).id
        post.save
      end
    end

  end

  factory :letter, class: Letter do
    # TKTK

    factory :published_letter do
      after(:create) do |letter|
        lettter.is_anonymous = false
        letter.status = 'approved'
        letter.save
      end
    end
  end

  factory :photo, class: Photo do
    caption "The Photo Caption"
    byline "The Photo Byline"
    sequence(:original_url) { |n| "http://not-a-real-photo-#{n}" }
  end

  factory :newsletter, class: Newsletter do
  end

end
