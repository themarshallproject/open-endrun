require 'rails_helper'

describe FeaturedBlock do  

  it 'has 3 slots for a 1-1-1 template' do
    block = FeaturedBlock.new(template: 'one_one_one')
    expect(block.slot_count).to eq(3)
  end

  it 'is unpublished by default' do    
    block = FeaturedBlock.create!(template: 'one_one_one')
    expect(block.published?).to eql false
    expect(block.is_active?).to eql false
  end

  # it 'removes posts when decreasing number of slots' do
  #   post1 = Post.create!(title: SecureRandom.hex, content: SecureRandom.hex)
  #   post2 = Post.create!(title: SecureRandom.hex, content: SecureRandom.hex)
  #   post3 = Post.create!(title: SecureRandom.hex, content: SecureRandom.hex)
  #   post4 = Post.create!(title: SecureRandom.hex, content: SecureRandom.hex)

  #   block = FeaturedBlock.new(template: 'one_one_two')
  #   block.slots = {
  #     "1" => { 'post_id' => post1.id, 'show_image' => 'false' },
  #     "2" => { 'post_id' => post2.id, 'show_image' => 'false' },
  #     "3" => { 'post_id' => post3.id, 'show_image' => 'false' },
  #     "4" => { 'post_id' => post4.id, 'show_image' => 'false' },
  #   }
  #   block.save!

  #   expect(block.slot_count).to eq 4
  #   expect(block.posts).to eq [post1, post2, post3, post4]
  #   expect(block.post_for_slot('2')).to eq post2

  #   # now go down to a 1-1-1, where slot count changes from 4 to 3
  #   block.template = 'one_one_one'
  #   block.save!

  #   expect(block.slot_count).to eq 3
  #   expect(block.posts.map(&:id)).to eq [post1, post2, post3].map(&:id)

  #   # now go to a 1-0-0 and check again
  #   block.template = 'one_zero_zero'
  #   block.save!

  #   expect(block.slot_count).to eq 1
  #   expect(block.posts).to eq [post1]

  # end

end