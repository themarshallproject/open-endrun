require 'rails_helper'

RSpec.describe "DonateController" do
  it "converts dollars to cents conversion" do
  	controller = DonateController.new

    expect(controller.dollars_to_cents("$1,500,000.00")).to eql(150000000)
    expect(controller.dollars_to_cents("$1,500000")).to     eql(150000000)

    expect(controller.dollars_to_cents("$1,500.00")).to eql(150000)
    expect(controller.dollars_to_cents("$1,500")).to    eql(150000)

    expect(controller.dollars_to_cents("$2-5.00")).to   eql(200)

  	expect(controller.dollars_to_cents("$5.00")).to     eql(500)
  	expect(controller.dollars_to_cents("5.00")).to      eql(500)
  	expect(controller.dollars_to_cents("$5")).to        eql(500)
  	expect(controller.dollars_to_cents("5")).to         eql(500)

    expect(controller.dollars_to_cents("25")).to        eql(2500)
  end
end
