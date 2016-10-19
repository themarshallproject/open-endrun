require 'rails_helper'

RSpec.describe ShortcodeArgumentParser, type: :model do
	
	it "treats nil as an empty input" do
		expect(ShortcodeArgumentParser.new(nil).argument_string).to eq("")
	end

	it "matches the k='v' syntax" do
		matches = ShortcodeArgumentParser.new("a='a thing' b='test again'").matches
		expect(matches).to eq([["a", "a thing"], ["b", "test again"]])
	end

	it 'matches the k="v" syntax' do
		matches = ShortcodeArgumentParser.new('c="a thing" d="hello there-test"').matches
		expect(matches).to eq([["c", "a thing"], ["d", "hello there-test"]])
	end

	it 'matches the k=v syntax' do
		matches = ShortcodeArgumentParser.new('c=123 d=test-again').matches
		expect(matches).to eq([["c", "123"], ["d", "test-again"]])
	end

	it "matches multiple syntaxes" do
		matches = ShortcodeArgumentParser.new("z=\"a b\" a=1 b=\"test one\" c='yo yo'").matches
		expect(matches).to eql([["z", "a b"], ["b", "test one"], ["c", "yo yo"], ["a", "1"]])
	end

	it "parses without quotes on values" do
		args = ShortcodeArgumentParser.new("a=1 b=2").parse
		expect(args).to eq({"a" => "1", "b" => "2"})
	end

	it "finds a photo via a [photo id=xx] shortcode" do
		test_arg_string = " id=12334"
		args = ShortcodeArgumentParser.new(test_arg_string).parse
		expect(args[:id]).to eq("12334")
	end

	it "works for lots of permutations" do

	end

	# it "parses with single quotes on values" do
	# 	args = ShortcodeArgumentParser.new("a='1' b='2'").parse
	# 	expect(args).to eq({"a" => "1", "b" => "2"})
	# end

	# it "parses with double quotes on values" do
	# 	args = ShortcodeArgumentParser.new('a="1" b="2"').parse
	# 	expect(args).to eq({"a" => "1", "b" => "2"})
	# end

	# it "allows access by symbol" do
	# 	args = ShortcodeArgumentParser.new(" a='1'    b=2 ").parse
	# 	expect(args[:a]).to eq("1")
	# end

end