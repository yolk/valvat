guard :rspec, cmd: "bundle exec rspec --color" do
  watch(/^spec\/(.*)_spec.rb/)
  watch(/^lib\/(.*)\.rb/)          { |m| "spec/#{m[1]}_spec.rb" }
  watch(/^spec\/spec_helper.rb/)   { "spec" }
end
