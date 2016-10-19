require 'rails_helper'

RSpec.describe PostMetadataProvider, type: :model do
    before :each do
      @post = build(:post)
      @provider = PostMetadataProvider.new(post: @post)
    end

    describe "#cascade" do
      it "uses the primary if not-nil and present?" do
        expect(@provider.cascade("a", nil)).to eq("a")
        expect(@provider.cascade("a", "b")).to eq("a")
      end
      it "uses the secondary if primary is nil or empty" do
        expect(@provider.cascade(nil, "b")).to eq("b")
        expect(@provider.cascade('', "b")).to eq("b")
      end
      it "returns an empty string for (nil, nil)" do
        expect(@provider.cascade(nil, nil)).to eq('')
      end
      it "correctly calculates present? for nil, empty strings" do
        expect(''.present?).to     be(false)
        expect(' '.present?).to    be(false)
        expect('    '.present?).to be(false)
        expect(nil.present?).to    be(false)
      end
    end

    describe "#title" do
      it "is always the post title" do
        expect(@provider.title).to eq(@post.title)
      end
      it "can be called via the post model" do
        expect(@post.metadata_provider.title).to eq(@post.title)
      end
    end

    describe "#display_headline" do
      it "falls back to title" do
        expect(@post.metadata_provider.display_headline).to eq(@post.title)
      end
      it "overrides when present" do
        override = "override display headline"
        @post.display_headline = override
        expect(@post.metadata_provider.display_headline).to eq(override)
      end
    end

    describe "#social_description" do
      it "removes html from the deck" do
        @post.deck = "this is a <em>deck</em>"
        expect(@post.metadata_provider.social_description).to eq("this is a deck")
      end
    end

    describe "#facebook_headline" do
      it "uses the facebook_headline if present" do
        @post.facebook_headline = "facebook"
        expect(@provider.facebook_headline).to eq(@post.facebook_headline)
      end
      it "uses title as a fallback" do
        expect(@provider.facebook_headline).to eq(@post.title)
      end
    end

    describe "#facebook_description" do
      it "uses the facebook_description if present" do
        @post.facebook_description = "fb desc"
        expect(@provider.facebook_description).to eq(@post.facebook_description)
      end
      it "uses deck as a fallback" do
        expect(@provider.facebook_description).to eq(@post.deck.truncate(200))
      end
    end

    describe "#og_facebook_photo_url, twitter_photo_url" do
      it "uses the featured_photo if present" do
        photo = create(:photo)
        fake_photo_url = 'fake-url-for-1200x'
        size = '1200x'
        photo.add_new_size({
          resize_key: photo.build_resize_key(size: size),
          public_url: fake_photo_url
        })
        post = create(:post)
        post.featured_photo = photo
        post.save
        post.reload
        expect(post.featured_photo_id).to eq(photo.id)

        expect(post.metadata_provider.og_facebook_photo_url).to eq(fake_photo_url)
        expect(post.metadata_provider.og_twitter_photo_url).to eq(fake_photo_url)
      end
    end

    describe "twitter headline/desc" do
      it "has the same headline as facebook" do
        expect(@post.metadata_provider.twitter_headline).to eq(@post.metadata_provider.facebook_headline)
      end
      it "has the same headline as facebook" do
        expect(@post.metadata_provider.twitter_description).to eq(@post.metadata_provider.facebook_description)
      end
    end

end
